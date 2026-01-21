const express = require('express');
const Alert = require('../models/Alert');
const Payment = require('../models/Payment');
const Hospital = require('../models/Hospital');
const User = require('../models/User');
const paymentService = require('../services/paymentService');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

// Create a new payment order for alert
router.post('/create-order', authMiddleware, async (req, res) => {
    try {
        const { tier, latitude, longitude, symptoms, message } = req.body;

        if (!tier || !latitude || !longitude) {
            return res.status(400).json({
                error: 'Tier, latitude, and longitude are required'
            });
        }

        const chargeTier = parseInt(tier);
        if (![1, 2, 3].includes(chargeTier)) {
            return res.status(400).json({ error: 'Invalid tier. Must be 1, 2, or 3' });
        }

        // Get price for tier
        const amountPaise = paymentService.getPriceForTier(chargeTier);
        const hospitalCount = paymentService.getHospitalCountForTier(chargeTier);

        // Create alert record (pending payment)
        const alert = Alert.create({
            userId: req.user.userId,
            symptoms: symptoms || '',
            message: message || '',
            chargeTier,
            userLatitude: parseFloat(latitude),
            userLongitude: parseFloat(longitude)
        });

        // Create Razorpay order
        const order = await paymentService.createOrder(amountPaise, alert.id, {
            tier: chargeTier,
            userId: req.user.userId
        });

        // Store payment record
        Payment.create({
            alertId: alert.id,
            razorpayOrderId: order.id,
            amountPaise
        });

        // Find hospitals that will be notified
        const hospitals = Hospital.findNearby(
            parseFloat(latitude),
            parseFloat(longitude),
            15, // 15km radius
            hospitalCount
        );

        res.json({
            success: true,
            alertId: alert.id,
            order: {
                id: order.id,
                amount: amountPaise,
                currency: 'INR',
                amountDisplay: `₹${amountPaise / 100}`
            },
            tier: {
                level: chargeTier,
                hospitalCount,
                hospitals: hospitals.map(h => ({
                    id: h.id,
                    name: h.name,
                    distanceKm: Math.round(h.distance_km * 100) / 100
                }))
            },
            razorpayKeyId: paymentService.config.keyId || 'test_key'
        });
    } catch (error) {
        console.error('Create order error:', error);
        res.status(500).json({ error: 'Failed to create payment order' });
    }
});

// Verify payment and trigger alert
router.post('/verify', authMiddleware, async (req, res) => {
    try {
        const { orderId, paymentId, signature, alertId } = req.body;

        if (!orderId || !paymentId || !alertId) {
            return res.status(400).json({
                error: 'orderId, paymentId, and alertId are required'
            });
        }

        // Find payment record
        const payment = Payment.findByOrderId(orderId);
        if (!payment) {
            return res.status(404).json({ error: 'Payment not found' });
        }

        // Verify signature
        const isValid = paymentService.verifyPayment(orderId, paymentId, signature);
        if (!isValid) {
            Payment.updateStatus(payment.id, 'failed');
            return res.status(400).json({ error: 'Payment verification failed' });
        }

        // Update payment status
        Payment.updateStatus(payment.id, 'completed', paymentId);

        // Get alert and update status
        const alert = Alert.findById(alertId);
        if (alert) {
            Alert.updateStatus(alertId, 'payment_verified');
        }

        res.json({
            success: true,
            message: 'Payment verified successfully',
            alertId,
            paymentId,
            nextStep: '/api/alerts/send'
        });
    } catch (error) {
        console.error('Verify payment error:', error);
        res.status(500).json({ error: 'Payment verification failed' });
    }
});

// Get payment history
router.get('/history', authMiddleware, (req, res) => {
    try {
        // Get user's alerts
        const alerts = Alert.findByUserId(req.user.userId);

        const history = alerts.map(alert => {
            const payment = Payment.findByAlertId(alert.id);
            return {
                alertId: alert.id,
                tier: alert.charge_tier,
                amount: payment ? `₹${payment.amount_paise / 100}` : 'N/A',
                status: payment?.status || 'N/A',
                createdAt: alert.created_at
            };
        });

        res.json({ payments: history });
    } catch (error) {
        console.error('Payment history error:', error);
        res.status(500).json({ error: 'Failed to fetch payment history' });
    }
});

module.exports = router;

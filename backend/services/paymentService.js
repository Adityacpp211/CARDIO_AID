const Razorpay = require('razorpay');
const crypto = require('crypto');
const config = require('../config/config');

let razorpayInstance = null;

// Initialize Razorpay
function initializeRazorpay() {
    if (razorpayInstance) return razorpayInstance;

    if (!config.razorpay.keyId || !config.razorpay.keySecret) {
        console.warn('⚠️ Razorpay credentials not configured. Payment processing disabled.');
        return null;
    }

    razorpayInstance = new Razorpay({
        key_id: config.razorpay.keyId,
        key_secret: config.razorpay.keySecret
    });

    console.log('✅ Razorpay initialized');
    return razorpayInstance;
}

// Get price for tier
function getPriceForTier(tier) {
    switch (tier) {
        case 1: return config.alertPricing.tier1;
        case 2: return config.alertPricing.tier2;
        case 3: return config.alertPricing.tier3;
        default: return config.alertPricing.tier1;
    }
}

// Get hospital count for tier
function getHospitalCountForTier(tier) {
    switch (tier) {
        case 1: return config.hospitalCountPerTier.tier1;
        case 2: return config.hospitalCountPerTier.tier2;
        case 3: return config.hospitalCountPerTier.tier3;
        default: return config.hospitalCountPerTier.tier1;
    }
}

// Create a new order
async function createOrder(amountPaise, alertId, notes = {}) {
    const razorpay = initializeRazorpay();

    if (!razorpay) {
        // Return mock order for testing
        console.log('📦 [Mock Razorpay] Creating order:', { amountPaise, alertId });
        return {
            id: `order_mock_${Date.now()}`,
            amount: amountPaise,
            currency: 'INR',
            receipt: alertId,
            status: 'created',
            mock: true
        };
    }

    try {
        const options = {
            amount: amountPaise,
            currency: 'INR',
            receipt: alertId,
            notes: {
                alertId,
                ...notes
            }
        };

        const order = await razorpay.orders.create(options);
        console.log('✅ Razorpay order created:', order.id);
        return order;
    } catch (error) {
        console.error('❌ Razorpay order creation error:', error.message);
        throw error;
    }
}

// Verify payment signature
function verifyPayment(orderId, paymentId, signature) {
    if (!config.razorpay.keySecret) {
        console.log('📦 [Mock Razorpay] Verifying payment:', { orderId, paymentId });
        return true; // Auto-verify in mock mode
    }

    const body = orderId + '|' + paymentId;
    const expectedSignature = crypto
        .createHmac('sha256', config.razorpay.keySecret)
        .update(body)
        .digest('hex');

    return expectedSignature === signature;
}

// Capture payment (for manual capture mode)
async function capturePayment(paymentId, amount) {
    const razorpay = initializeRazorpay();

    if (!razorpay) {
        console.log('📦 [Mock Razorpay] Capturing payment:', { paymentId, amount });
        return { id: paymentId, status: 'captured', mock: true };
    }

    try {
        const payment = await razorpay.payments.capture(paymentId, amount);
        console.log('✅ Payment captured:', payment.id);
        return payment;
    } catch (error) {
        console.error('❌ Payment capture error:', error.message);
        throw error;
    }
}

module.exports = {
    initializeRazorpay,
    getPriceForTier,
    getHospitalCountForTier,
    createOrder,
    verifyPayment,
    capturePayment,
    config: config.razorpay
};

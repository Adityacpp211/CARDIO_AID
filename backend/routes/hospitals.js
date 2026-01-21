const express = require('express');
const Hospital = require('../models/Hospital');
const { authMiddleware, optionalAuth } = require('../middleware/auth');

const router = express.Router();

// Get nearby hospitals
router.get('/nearby', optionalAuth, (req, res) => {
    try {
        const { lat, lng, radius = 10, limit = 10 } = req.query;

        if (!lat || !lng) {
            return res.status(400).json({ error: 'Latitude (lat) and longitude (lng) are required' });
        }

        const latitude = parseFloat(lat);
        const longitude = parseFloat(lng);
        const radiusKm = parseFloat(radius);
        const maxLimit = Math.min(parseInt(limit), 50);

        if (isNaN(latitude) || isNaN(longitude)) {
            return res.status(400).json({ error: 'Invalid coordinates' });
        }

        const hospitals = Hospital.findNearby(latitude, longitude, radiusKm, maxLimit);

        res.json({
            count: hospitals.length,
            userLocation: { latitude, longitude },
            radiusKm,
            hospitals: hospitals.map(h => ({
                id: h.id,
                name: h.name,
                address: h.address,
                phone: h.phone,
                latitude: h.latitude,
                longitude: h.longitude,
                distanceKm: Math.round(h.distance_km * 100) / 100
            }))
        });
    } catch (error) {
        console.error('Nearby hospitals error:', error);
        res.status(500).json({ error: 'Failed to fetch nearby hospitals' });
    }
});

// Get all hospitals
router.get('/', (req, res) => {
    try {
        const hospitals = Hospital.findAll();

        res.json({
            count: hospitals.length,
            hospitals: hospitals.map(h => ({
                id: h.id,
                name: h.name,
                address: h.address,
                phone: h.phone,
                latitude: h.latitude,
                longitude: h.longitude
            }))
        });
    } catch (error) {
        console.error('Get hospitals error:', error);
        res.status(500).json({ error: 'Failed to fetch hospitals' });
    }
});

// Get single hospital
router.get('/:id', (req, res) => {
    try {
        const hospital = Hospital.findById(req.params.id);

        if (!hospital) {
            return res.status(404).json({ error: 'Hospital not found' });
        }

        res.json({
            id: hospital.id,
            name: hospital.name,
            address: hospital.address,
            phone: hospital.phone,
            emergencyEmail: hospital.emergency_email,
            latitude: hospital.latitude,
            longitude: hospital.longitude
        });
    } catch (error) {
        console.error('Get hospital error:', error);
        res.status(500).json({ error: 'Failed to fetch hospital' });
    }
});

module.exports = router;

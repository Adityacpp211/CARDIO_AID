const admin = require('firebase-admin');
const config = require('../config/config');
const fs = require('fs');
const path = require('path');

let isInitialized = false;

// Initialize Firebase Admin SDK
function initializeFirebase() {
    if (isInitialized) return true;

    try {
        const serviceAccountPath = path.resolve(__dirname, '..', config.firebase.serviceAccountPath);

        if (!fs.existsSync(serviceAccountPath)) {
            console.warn('⚠️ Firebase service account not found. FCM notifications disabled.');
            console.warn(`  Expected path: ${serviceAccountPath}`);
            console.warn('  Download from: Firebase Console > Project Settings > Service Accounts');
            return false;
        }

        const serviceAccount = require(serviceAccountPath);

        admin.initializeApp({
            credential: admin.credential.cert(serviceAccount)
        });

        isInitialized = true;
        console.log('✅ Firebase Admin SDK initialized');
        return true;
    } catch (error) {
        console.error('❌ Firebase initialization error:', error.message);
        return false;
    }
}

// Send notification to a specific device token
async function sendToDevice(fcmToken, title, body, data = {}) {
    if (!initializeFirebase()) {
        console.log('📱 [Mock FCM] Would send to device:', { title, body, data });
        return { success: true, mock: true };
    }

    try {
        const message = {
            notification: {
                title,
                body
            },
            data: {
                ...data,
                click_action: 'FLUTTER_NOTIFICATION_CLICK'
            },
            token: fcmToken
        };

        const response = await admin.messaging().send(message);
        console.log('✅ FCM notification sent:', response);
        return { success: true, messageId: response };
    } catch (error) {
        console.error('❌ FCM send error:', error.message);
        return { success: false, error: error.message };
    }
}

// Send notification to a topic (for hospital groups)
async function sendToTopic(topic, title, body, data = {}) {
    if (!initializeFirebase()) {
        console.log('📱 [Mock FCM] Would send to topic:', topic, { title, body, data });
        return { success: true, mock: true };
    }

    try {
        const message = {
            notification: {
                title,
                body
            },
            data: {
                ...data,
                click_action: 'FLUTTER_NOTIFICATION_CLICK'
            },
            topic: topic
        };

        const response = await admin.messaging().send(message);
        console.log(`✅ FCM topic notification sent to ${topic}:`, response);
        return { success: true, messageId: response };
    } catch (error) {
        console.error('❌ FCM topic send error:', error.message);
        return { success: false, error: error.message };
    }
}

// Subscribe device to a topic
async function subscribeToTopic(fcmToken, topic) {
    if (!initializeFirebase()) {
        console.log('📱 [Mock FCM] Would subscribe to topic:', topic);
        return { success: true, mock: true };
    }

    try {
        const response = await admin.messaging().subscribeToTopic(fcmToken, topic);
        console.log(`✅ Subscribed to topic ${topic}:`, response);
        return { success: true };
    } catch (error) {
        console.error('❌ Topic subscription error:', error.message);
        return { success: false, error: error.message };
    }
}

// Send emergency alert to multiple hospitals
async function sendEmergencyAlert(hospitals, alertData) {
    const results = [];

    for (const hospital of hospitals) {
        const title = '🚨 CARDIAC EMERGENCY ALERT';
        const body = `Patient needs help! Location: ${alertData.userLatitude.toFixed(4)}, ${alertData.userLongitude.toFixed(4)}. Distance: ${hospital.distance_km?.toFixed(2) || 'N/A'} km`;

        const data = {
            alertId: alertData.id,
            type: 'emergency_cardiac',
            symptoms: alertData.symptoms || '',
            userLatitude: String(alertData.userLatitude),
            userLongitude: String(alertData.userLongitude),
            timestamp: new Date().toISOString()
        };

        // Try to send via FCM topic for this hospital
        const result = await sendToTopic(`hospital_${hospital.id}`, title, body, data);
        results.push({
            hospitalId: hospital.id,
            hospitalName: hospital.name,
            ...result
        });
    }

    return results;
}

module.exports = {
    initializeFirebase,
    sendToDevice,
    sendToTopic,
    subscribeToTopic,
    sendEmergencyAlert
};

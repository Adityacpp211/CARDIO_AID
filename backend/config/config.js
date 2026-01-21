require('dotenv').config();

module.exports = {
  port: process.env.PORT || 3000,
  jwtSecret: process.env.JWT_SECRET || 'cardioaid-dev-secret-key',
  
  firebase: {
    serviceAccountPath: process.env.FIREBASE_SERVICE_ACCOUNT_PATH || './config/firebase-service-account.json'
  },
  
  razorpay: {
    keyId: process.env.RAZORPAY_KEY_ID,
    keySecret: process.env.RAZORPAY_KEY_SECRET
  },
  
  alertPricing: {
    tier1: parseInt(process.env.ALERT_TIER_1_PRICE) || 100,  // ₹1 in paise
    tier2: parseInt(process.env.ALERT_TIER_2_PRICE) || 200,  // ₹2 in paise
    tier3: parseInt(process.env.ALERT_TIER_3_PRICE) || 300   // ₹3 in paise
  },
  
  // Number of hospitals to notify per tier
  hospitalCountPerTier: {
    tier1: 1,
    tier2: 3,
    tier3: 10  // All nearby hospitals
  }
};

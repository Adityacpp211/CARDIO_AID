# CardioAid Backend

Backend server for the CardioAid Emergency Cardiac Care System.

## Quick Start

```bash
# Install dependencies
npm install

# Copy environment variables
cp .env.example .env

# Start server
npm start

# Or with auto-reload (development)
npm run dev
```

## API Endpoints

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| `POST` | `/api/auth/register` | Register new user | ❌ |
| `POST` | `/api/auth/login` | Login user | ❌ |
| `POST` | `/api/auth/location` | Update user location | ✅ |
| `GET` | `/api/hospitals/nearby?lat=X&lng=Y` | Find nearby hospitals | ❌ |
| `POST` | `/api/payments/create-order` | Create payment order | ✅ |
| `POST` | `/api/payments/verify` | Verify payment | ✅ |
| `POST` | `/api/alerts/send` | Send emergency alert | ✅ |
| `GET` | `/api/alerts/history` | Get alert history | ✅ |

## Configuration

Edit `.env` file:

```bash
# Required for production
RAZORPAY_KEY_ID=rzp_test_xxxxx
RAZORPAY_KEY_SECRET=your_secret

# Firebase (for FCM notifications)
# Download service account JSON from Firebase Console
FIREBASE_SERVICE_ACCOUNT_PATH=./config/firebase-service-account.json
```

## Alert Tiers

| Tier | Price | Hospitals Notified |
|------|-------|--------------------|
| 1 | ₹1 | 1 hospital |
| 2 | ₹2 | 3 hospitals |
| 3 | ₹3 | All nearby (up to 10) |

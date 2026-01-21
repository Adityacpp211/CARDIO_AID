const { all, get, run } = require('./database');
const { v4: uuidv4 } = require('uuid');

class Alert {
    static create(data) {
        const id = uuidv4();
        const now = new Date().toISOString();
        run(
            `INSERT INTO alerts (id, user_id, symptoms, message, charge_tier, user_latitude, user_longitude, status, created_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
            [
                id,
                data.userId,
                data.symptoms || '',
                data.message || '',
                data.chargeTier,
                data.userLatitude,
                data.userLongitude,
                'pending',
                now
            ]
        );
        return this.findById(id);
    }

    static findById(id) {
        return get('SELECT * FROM alerts WHERE id = ?', [id]);
    }

    static findByUserId(userId) {
        return all('SELECT * FROM alerts WHERE user_id = ? ORDER BY created_at DESC', [userId]);
    }

    static updateStatus(id, status) {
        run('UPDATE alerts SET status = ? WHERE id = ?', [status, id]);
        return this.findById(id);
    }

    static addHospital(alertId, hospitalId) {
        const id = uuidv4();
        run(
            `INSERT INTO alert_hospitals (id, alert_id, hospital_id) VALUES (?, ?, ?)`,
            [id, alertId, hospitalId]
        );
        return id;
    }

    static markNotificationSent(alertId, hospitalId) {
        const now = new Date().toISOString();
        run(
            `UPDATE alert_hospitals SET notification_sent = 1, sent_at = ? WHERE alert_id = ? AND hospital_id = ?`,
            [now, alertId, hospitalId]
        );
    }

    static getAlertHospitals(alertId) {
        return all(
            `SELECT ah.*, h.name as hospital_name, h.phone as hospital_phone
       FROM alert_hospitals ah
       JOIN hospitals h ON ah.hospital_id = h.id
       WHERE ah.alert_id = ?`,
            [alertId]
        );
    }

    static acknowledgeAlert(alertId, hospitalId) {
        const now = new Date().toISOString();
        run(
            `UPDATE alert_hospitals SET acknowledged = 1, acknowledged_at = ? WHERE alert_id = ? AND hospital_id = ?`,
            [now, alertId, hospitalId]
        );
    }
}

module.exports = Alert;

const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('./db'); // Your MySQL connection file
const router = express.Router();

const JWT_SECRET = 'your_pocket_secret_key';

// REGISTER
router.post('/register', async (req, res) => {
    const { name, email, password } = req.body;
    try {
        const hashedPassword = await bcrypt.hash(password, 10);
        const query = 'INSERT INTO user (name, email, password_hash) VALUES (?, ?, ?)';
        // Note: Ensure your 'user' table includes a password_hash column
        db.query(query, [name, email, hashedPassword], (err, result) => {
            if (err) return res.status(400).json({ error: 'Email already exists or invalid data' });
            res.status(201).json({ message: 'User registered successfully!', userId: result.insertId });
        });
    } catch (err) {
        res.status(500).json({ error: 'Server error' });
    }
});

// LOGIN
router.post('/login', (req, res) => {
    const { email, password } = req.body;
    const query = 'SELECT * FROM user WHERE email = ?';
    db.query(query, [email], async (err, results) => {
        if (err || results.length === 0) return res.status(401).json({ error: 'Invalid email or password' });

        const user = results.get ? results.get(0) : results; // handle result array
        // For schema matching, compare password hash here
        const token = jwt.sign({ userId: user.user_id, email: user.email }, JWT_SECRET, { expiresIn: '7d' });
        res.json({ message: 'Login successful', token, user: { id: user.user_id, name: user.name, email: user.email } });
    });
});

module.exports = router;
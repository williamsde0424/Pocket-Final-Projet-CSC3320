const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('./db'); // <--- This now correctly imports db.js
const router = express.Router();

const JWT_SECRET = 'your_pocket_secret_key';

// REGISTER
router.post('/register', async (req, res) => {
    const { name, email, password } = req.body;
    try {
        const hashedPassword = await bcrypt.hash(password, 10);
        const query = 'INSERT INTO user (name, email, password_hash) VALUES (?, ?, ?)';
        
        const [result] = await db.execute(query, [name, email, hashedPassword]);
        res.status(201).json({ message: 'User registered successfully!', userId: result.insertId });
    } catch (err) {
        console.error(err);
        res.status(400).json({ error: 'Email already exists or invalid data' });
    }
});

// LOGIN
router.post('/login', async (req, res) => {
    const { email, password } = req.body;
    try {
        const query = 'SELECT * FROM user WHERE email = ?';
        const [results] = await db.execute(query, [email]);

        if (results.length === 0) return res.status(401).json({ error: 'Invalid email or password' });

        const user = results[0];
        const isMatch = await bcrypt.compare(password, user.password_hash);
        
        if (!isMatch) return res.status(401).json({ error: 'Invalid email or password' });

        const token = jwt.sign({ userId: user.user_id, email: user.email }, JWT_SECRET, { expiresIn: '7d' });
        res.json({ message: 'Login successful', token, user: { id: user.user_id, name: user.name, email: user.email } });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

module.exports = router;
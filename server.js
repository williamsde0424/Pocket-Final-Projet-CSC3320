const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');
const app = express();
app.use(express.json());
app.use(cors());

const authRouter = require('./auth');
app.use('/api/auth', authRouter);

// Configure MySQL connection pool
const pool = mysql.createPool({
    host: 'localhost',
    user: 'root',
    password: '', // Update with your MySQL password if required
    database: 'pocket_db',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

// --- 1. CREATE: Add a new item ---
app.post('/api/items', async (req, res) => {
    try {
        const { loc_id, sub_id, name, description, image_url } = req.body;
        
        // Server-side validation for required fields
        if (!loc_id || !name) {
            return res.status(400).json({ error: 'Missing required fields: loc_id and name are required.' });
        }

        const query = `
            INSERT INTO item (loc_id, sub_id, name, description, image_url)
            VALUES (?, ?, ?, ?, ?)
        `;
        const [result] = await pool.execute(query, [loc_id, sub_id || null, name, description || null, image_url || null]);
        
        res.status(201).json({ 
            message: `Item '${name}' created successfully.`, 
            item_id: result.insertId 
        });
    } catch (err) {
        console.error('Error during CREATE:', err.message);
        res.status(500).json({ error: 'Database error occurred while creating the item.' });
    }
});

// --- 2. READ: Search items by keyword ---
app.get('/api/items/search', async (req, res) => {
    try {
        const keyword = req.query.keyword || '';
        const wildcard = `%${keyword}%`;

        const query = `
            SELECT i.item_id, i.name, i.description, pl.name AS primary_location, s.name AS sublocation
            FROM item i
            JOIN primary_location pl ON i.loc_id = pl.loc_id
            LEFT JOIN sublocation s ON i.sub_id = s.sub_id
            WHERE i.name LIKE ? OR i.description LIKE ?
        `;
        const [results] = await pool.execute(query, [wildcard, wildcard]);
        
        res.json(results);
    } catch (err) {
        console.error('Error during READ:', err.message);
        res.status(500).json({ error: 'Database error occurred while searching items.' });
    }
});

// --- 3. UPDATE: Update item location (QuickLocationModal action) ---
app.put('/api/items/:id/location', async (req, res) => {
    try {
        const itemId = req.params.id;
        const { new_loc_id, new_sub_id } = req.body;

        if (!new_loc_id) {
            return res.status(400).json({ error: 'Missing required field: new_loc_id is required.' });
        }

        const query = `
            UPDATE item 
            SET loc_id = ?, sub_id = ?
            WHERE item_id = ?
        `;
        const [result] = await pool.execute(query, [new_loc_id, new_sub_id || null, itemId]);

        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Item not found.' });
        }

        res.json({ message: `Item ID ${itemId} moved to location ID ${new_loc_id} successfully.` });
    } catch (err) {
        console.error('Error during UPDATE:', err.message);
        res.status(500).json({ error: 'Database error occurred while updating item location.' });
    }
});

// --- 4. DELETE: Remove an item ---
app.delete('/api/items/:id', async (req, res) => {
    try {
        const itemId = req.params.id;
        const query = "DELETE FROM item WHERE item_id = ?";
        
        const [result] = await pool.execute(query, [itemId]);

        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Item not found.' });
        }

        res.json({ message: `Item ID ${itemId} deleted successfully.` });
    } catch (err) {
        console.error('Error during DELETE:', err.message);
        res.status(500).json({ error: 'Database error occurred while deleting the item.' });
    }
});

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Pocket backend server running on http://localhost:${PORT}`);
});
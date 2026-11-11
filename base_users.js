const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');

async function insertBaseUsers() {
    // Set up database connection pool
    const pool = mysql.createPool({
        host: 'localhost',
        user: 'root',
        password: 'Rufusking2@', 
        database: 'pocket_db'
    });

    try {
        console.log('Connecting to database to insert base users...');

        // Hashed standard password for testing purposes
        const defaultPassword = 'Password123!';
        const hashedPassword = await bcrypt.hash(defaultPassword, 10);

        // Defined base users (Name, Email, Hashed Password)
        const baseUsers = [
            ['Dave Student', 'dave@msoe.edu', hashedPassword],
            ['Admin User', 'admin@pocket.com', hashedPassword],
            ['Test Roommate', 'roommate@pocket.com', hashedPassword],
            ['Smith Family', 'smiths@gmail.com', hashedPassword]
        ];

        for (const user of baseUsers) {
            
            const query = `
                INSERT INTO user (name, email, password_hash) 
                VALUES (?, ?, ?)
                ON DUPLICATE KEY UPDATE name = VALUES(name)
            `;
            await pool.execute(query, user);
        }

        console.log('\n----------------------------------------');
        console.log('SUCCESS: Base users inserted successfully!');
        console.log('----------------------------------------');
        console.log('You can now log in using these credentials:');
        console.log('Email: dave@msoe.edu');
        console.log('Password: Password123!');
        console.log('----------------------------------------\n');

    } catch (err) {
        console.error('Error inserting base users:', err.message);
    } finally {
        await pool.end();
    }
}

insertBaseUsers();
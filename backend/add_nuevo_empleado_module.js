const mysql = require('mysql2');
require('dotenv').config();

const db = mysql.createConnection({
    host: process.env.DB_HOST ?? 'localhost',
    port: process.env.DB_PORT ?? 3306,
    user: process.env.DB_USER ?? 'root',
    password: process.env.DB_PASS ?? '',
    database: process.env.DB_NAME ?? 'sistema_rrhh'
});

db.connect((err) => {
    if (err) {
        console.error('Connection error:', err);
        process.exit(1);
    }
    console.log('Connected to DB');

    const mod = '+Nuevo Empleado';
    db.query('SELECT id FROM modulos WHERE nombre = ?', [mod], (err, results) => {
        if (err) {
            console.error(err);
            process.exit(1);
        }
        if (results.length === 0) {
            db.query('INSERT INTO modulos (nombre) VALUES (?)', [mod], (err, insertResult) => {
                if (err) {
                    console.error(err);
                    process.exit(1);
                }
                console.log('Inserted:', mod, 'with ID:', insertResult.insertId);
                process.exit(0);
            });
        } else {
            console.log('Already exists:', mod, 'with ID:', results[0].id);
            process.exit(0);
        }
    });
});

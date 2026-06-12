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

    const modules = [
        'Gestión de Manuales',
        'Reportes de Incidencia',
        'Módulo de Reportes',
        'Archivero Legal',
        'Logs de Sistema',
        'Documentos'
    ];

    const checkAndInsert = (index) => {
        if (index >= modules.length) {
            console.log('Done inserting modules.');
            process.exit(0);
        }
        const mod = modules[index];
        db.query('SELECT id FROM modulos WHERE nombre = ?', [mod], (err, results) => {
            if (err) {
                console.error(err);
                process.exit(1);
            }
            if (results.length === 0) {
                db.query('INSERT INTO modulos (nombre) VALUES (?)', [mod], (err) => {
                    if (err) {
                        console.error(err);
                        process.exit(1);
                    }
                    console.log('Inserted:', mod);
                    checkAndInsert(index + 1);
                });
            } else {
                console.log('Already exists:', mod);
                checkAndInsert(index + 1);
            }
        });
    };

    // Make sure the table modulos exists first.
    db.query(`CREATE TABLE IF NOT EXISTS modulos (
        id INT AUTO_INCREMENT PRIMARY KEY,
        nombre VARCHAR(255) NOT NULL
    )`, (err) => {
        if (err) {
            console.error('Error creating table:', err);
            process.exit(1);
        }
        checkAndInsert(0);
    });
});

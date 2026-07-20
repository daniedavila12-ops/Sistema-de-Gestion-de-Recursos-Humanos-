const mysql = require('mysql2');
require('dotenv').config();

const db = mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 3307,
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASS || '',
    database: process.env.DB_NAME || 'sistema_rrhh'
});

db.connect((err) => {
    if (err) throw err;
    // Set first 3 active employees to Produccion
    db.query(`UPDATE empleados SET area = 'Produccion' WHERE estado = 1 LIMIT 3`, (err, res) => {
        if (err) throw err;
        console.log('Updated 3 employees to Produccion:', res.affectedRows);
        
        // Set next 3 active employees to Ventas
        db.query(`UPDATE empleados SET area = 'Ventas' WHERE estado = 1 AND area IS NULL LIMIT 3`, (err, res2) => {
            if (err) throw err;
            console.log('Updated 3 employees to Ventas:', res2.affectedRows);
            db.end();
        });
    });
});

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
    db.query('SELECT * FROM departamentos', (err, rows) => {
        if (err) throw err;
        console.log("DEPARTAMENTOS:");
        console.log(rows);
        db.end();
    });
});

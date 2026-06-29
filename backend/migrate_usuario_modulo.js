require('dotenv').config();
const mysql = require('mysql2');

const db = mysql.createConnection({
    host: process.env.DB_HOST ?? 'localhost',
    port: process.env.DB_PORT ?? 3306,
    user: process.env.DB_USER ?? 'root',
    password: process.env.DB_PASS ?? '',
    database: process.env.DB_NAME ?? 'sistema_rrhh'
});

db.connect((err) => {
    if (err) {
        console.error('Error conectando a la base de datos:', err);
        return;
    }
    console.log('✅ Conectado a MySQL');

    const sql = `
        CREATE TABLE IF NOT EXISTS usuario_modulo (
            usuario_id INT NOT NULL,
            modulo_id INT NOT NULL,
            puedeVer TINYINT(1) DEFAULT 0,
            puedeCrear TINYINT(1) DEFAULT 0,
            puedeEditar TINYINT(1) DEFAULT 0,
            puedeEliminar TINYINT(1) DEFAULT 0,
            PRIMARY KEY (usuario_id, modulo_id),
            FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
            FOREIGN KEY (modulo_id) REFERENCES modulos(id) ON DELETE CASCADE
        );
    `;

    db.query(sql, (err, result) => {
        if (err) {
            console.error('❌ Error creando tabla usuario_modulo:', err);
        } else {
            console.log('✅ Tabla usuario_modulo creada o ya existente.');
        }
        db.end();
    });
});

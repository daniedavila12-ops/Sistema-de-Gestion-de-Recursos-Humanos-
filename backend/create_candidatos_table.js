const mysql = require('mysql2/promise');
require('dotenv').config();

const run = async () => {
    try {
        const connection = await mysql.createConnection({
            host: process.env.DB_HOST ?? 'localhost',
            port: process.env.DB_PORT ?? 3306,
            user: process.env.DB_USER ?? 'root',
            password: process.env.DB_PASS ?? '',
            database: process.env.DB_NAME ?? 'sistema_rrhh'
        });

        await connection.query(`
            CREATE TABLE IF NOT EXISTS candidatos (
                id INT AUTO_INCREMENT PRIMARY KEY,
                nombre_completo VARCHAR(255) NOT NULL,
                correo VARCHAR(255) NOT NULL,
                telefono VARCHAR(50) NOT NULL,
                puesto_aplicado VARCHAR(255) NOT NULL,
                cv_url VARCHAR(255) NOT NULL,
                estado VARCHAR(50) DEFAULT 'Recibido',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        `);
        console.log('Tabla candidatos creada exitosamente');
        await connection.end();
    } catch (e) {
        console.error('Error al crear la tabla candidatos:', e);
    } finally {
        process.exit();
    }
}

run();

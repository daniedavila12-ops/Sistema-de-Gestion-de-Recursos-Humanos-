const mysql = require('mysql2/promise');
require('dotenv').config();

async function run() {
    try {
        const conn = await mysql.createConnection({
            host: process.env.DB_HOST || 'localhost',
            port: process.env.DB_PORT || 3307,
            user: process.env.DB_USER || 'root',
            password: process.env.DB_PASS || '',
            database: process.env.DB_NAME || 'sistema_rrhh'
        });

        // 1. Change 'tipo' column in 'documentos' to VARCHAR to remove ENUM restriction
        await conn.execute("ALTER TABLE documentos MODIFY COLUMN tipo VARCHAR(100) DEFAULT 'Documento General'");
        console.log('Columna "tipo" en "documentos" cambiada a VARCHAR.');

        // 2. Create 'tipos_documento' table
        await conn.execute(`
            CREATE TABLE IF NOT EXISTS tipos_documento (
                id INT AUTO_INCREMENT PRIMARY KEY,
                nombre VARCHAR(255) NOT NULL UNIQUE
            )
        `);
        console.log('Tabla tipos_documento creada.');

        // 3. Insert default types
        const defaultTipos = ['Documento General', 'Nota', 'Contrato'];
        for (const tipo of defaultTipos) {
            await conn.execute('INSERT IGNORE INTO tipos_documento (nombre) VALUES (?)', [tipo]);
        }

        // 4. Insert any other existing types from 'documentos'
        const [rows] = await conn.execute("SELECT DISTINCT tipo FROM documentos WHERE tipo IS NOT NULL AND tipo != ''");
        for (const row of rows) {
            await conn.execute('INSERT IGNORE INTO tipos_documento (nombre) VALUES (?)', [row.tipo]);
        }

        console.log('Migración completada.');
        process.exit(0);
    } catch (error) {
        console.error('Error:', error);
        process.exit(1);
    }
}
run();

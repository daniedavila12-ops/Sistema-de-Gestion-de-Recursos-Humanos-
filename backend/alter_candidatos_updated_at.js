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

        // Verificar si la columna existe antes de agregarla
        const [columns] = await connection.query(`SHOW COLUMNS FROM candidatos LIKE 'updated_at'`);
        if (columns.length === 0) {
            await connection.query(`
                ALTER TABLE candidatos
                ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
            `);
            console.log('✅ Columna updated_at agregada exitosamente a la tabla candidatos.');
        } else {
            console.log('⚠️ La columna updated_at ya existe en la tabla candidatos.');
        }

        await connection.end();
    } catch (e) {
        console.error('❌ Error al alterar la tabla candidatos:', e);
    } finally {
        process.exit();
    }
}

run();

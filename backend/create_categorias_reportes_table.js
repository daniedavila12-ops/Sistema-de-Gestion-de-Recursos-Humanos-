const mysql = require('mysql2');
require('dotenv').config();

const db = mysql.createConnection({
    host: process.env.DB_HOST ?? 'localhost',
    port: process.env.DB_PORT ?? 3306,
    user: process.env.DB_USER ?? 'root',
    password: process.env.DB_PASS ?? '',
    database: process.env.DB_NAME ?? 'sistema_rrhh'
});

const createTableQuery = `
CREATE TABLE IF NOT EXISTS categorias_reportes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    activa BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
`;

db.query(createTableQuery, (err, results) => {
    if (err) {
        console.error("Error creating table:", err);
    } else {
        console.log("Table categorias_reportes created successfully or already exists.");
        
        // Seed some initial categories
        const initialCategories = [
            'Falta Injustificada',
            'Llegada Tarde',
            'Insubordinación',
            'Abandono de Trabajo',
            'Desempeño',
            'Acoso',
            'Robo',
            'Otro'
        ];

        let count = 0;
        initialCategories.forEach(cat => {
            db.query('INSERT IGNORE INTO categorias_reportes (nombre) VALUES (?)', [cat], (err) => {
                if (err) console.error("Error inserting category:", err);
                count++;
                if (count === initialCategories.length) {
                    console.log("Categories seeded.");
                    process.exit(0);
                }
            });
        });
    }
});

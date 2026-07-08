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

    const mod = 'Reclutamiento';
    
    db.query('SELECT id FROM modulos WHERE nombre = ?', [mod], (err, results) => {
        if (err) {
            console.error(err);
            process.exit(1);
        }
        if (results.length === 0) {
            db.query('INSERT INTO modulos (nombre) VALUES (?)', [mod], (err, res) => {
                if (err) {
                    console.error(err);
                    process.exit(1);
                }
                const newId = res.insertId;
                console.log('Inserted:', mod, 'with ID:', newId);
                
                // Asignar permiso de ver al rol 1 (Administrador IT) y rol 2 (Recursos Humanos) por defecto
                const permissions = [
                    [1, newId, 1, 1, 1, 1], // Rol 1
                    [2, newId, 1, 1, 1, 1]  // Rol 2
                ];
                db.query('INSERT INTO rol_modulo (rol_id, modulo_id, puedeVer, puedeCrear, puedeEditar, puedeEliminar) VALUES ?', [permissions], (err) => {
                    if(err) console.error('Error insertando permisos por defecto', err);
                    else console.log('Permisos asignados a los roles 1 y 2 por defecto.');
                    process.exit(0);
                });
            });
        } else {
            console.log('Already exists:', mod);
            process.exit(0);
        }
    });
});

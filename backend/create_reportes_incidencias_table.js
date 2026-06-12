const mysql = require('mysql2');

const db = mysql.createConnection({
    host: 'localhost',
    port: 3307,
    user: 'root',
    password: '',
    database: 'sistema_rrhh'
});

const sql1 = `
CREATE TABLE IF NOT EXISTS reportes_incidencias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    jefe_reporta VARCHAR(255) NOT NULL,
    empleado_reportado_id INT DEFAULT NULL,
    identidad VARCHAR(50) DEFAULT NULL,
    categoria VARCHAR(100) DEFAULT NULL,
    descripcion TEXT,
    tema VARCHAR(255) DEFAULT NULL,
    prioridad ENUM('Baja','Media','Alta','Urgente') DEFAULT 'Media',
    archivo VARCHAR(255) DEFAULT NULL,
    estado VARCHAR(50) DEFAULT 'Pendiente',
    asignado_usuario_id INT DEFAULT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
`;

const sql2 = `
CREATE TABLE IF NOT EXISTS reporte_incidencia_respuestas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    reporte_id INT NOT NULL,
    usuario_id INT DEFAULT NULL,
    empleado_id INT DEFAULT NULL,
    mensaje TEXT NOT NULL,
    archivo VARCHAR(255) DEFAULT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
`;

db.query(sql1, (err) => {
    if (err) {
        console.error('Error creating reportes_incidencias:', err);
    } else {
        console.log('Created reportes_incidencias table successfully');
        db.query(sql2, (err2) => {
            if (err2) {
                console.error('Error creating reporte_incidencia_respuestas:', err2);
            } else {
                console.log('Created reporte_incidencia_respuestas table successfully');
            }
            db.end();
        });
    }
});

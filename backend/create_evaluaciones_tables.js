const mysql = require('mysql2');
require('dotenv').config();

const db = mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 3307,
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASS || '',
    database: process.env.DB_NAME || 'sistema_rrhh',
    multipleStatements: true
});

const sql = `
-- Añadir columnas a empleados si no existen
ALTER TABLE empleados 
ADD COLUMN IF NOT EXISTS area VARCHAR(100),
ADD COLUMN IF NOT EXISTS puesto VARCHAR(100),
ADD COLUMN IF NOT EXISTS supervisor_id INT(11);

-- Crear tabla evaluaciones_desempeno
CREATE TABLE IF NOT EXISTS evaluaciones_desempeno (
    id INT(11) AUTO_INCREMENT PRIMARY KEY,
    empleado_id INT(11) NOT NULL,
    evaluador_id INT(11),
    evaluador_nombre VARCHAR(100),
    area VARCHAR(100),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    promedio DECIMAL(5,2),
    porcentaje DECIMAL(5,2),
    nivel VARCHAR(50),
    observaciones TEXT,
    FOREIGN KEY (empleado_id) REFERENCES empleados(id)
);

-- Crear tabla evaluaciones_respuestas
CREATE TABLE IF NOT EXISTS evaluaciones_respuestas (
    id INT(11) AUTO_INCREMENT PRIMARY KEY,
    evaluacion_id INT(11) NOT NULL,
    criterio VARCHAR(150),
    calificacion INT(11),
    FOREIGN KEY (evaluacion_id) REFERENCES evaluaciones_desempeno(id) ON DELETE CASCADE
);

-- Crear tabla de enlaces (opcional) para los accesos directos de los jefes
CREATE TABLE IF NOT EXISTS evaluaciones_enlaces (
    id INT(11) AUTO_INCREMENT PRIMARY KEY,
    area VARCHAR(100) NOT NULL,
    token VARCHAR(255) NOT NULL,
    creado_el TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
`;

db.connect((err) => {
    if (err) {
        console.error('Error connecting to DB:', err);
        return;
    }
    console.log('Connected to DB.');
    db.query(sql, (err, results) => {
        if (err) {
            console.error('Error executing query:', err);
        } else {
            console.log('Tables created successfully.', results);
        }
        db.end();
    });
});

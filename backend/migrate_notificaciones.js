const mysql = require('mysql2');

const db = mysql.createConnection({
  host: 'localhost',
  port: 3307,
  user: 'root',
  password: '',
  database: 'sistema_rrhh'
});

db.connect(err => {
  if (err) {
    console.error('Error al conectar a la DB:', err);
    return;
  }
  
  const sql = `
    CREATE TABLE IF NOT EXISTS notificaciones (
      id INT AUTO_INCREMENT PRIMARY KEY,
      usuario_id INT NOT NULL,
      titulo VARCHAR(255) NOT NULL,
      mensaje TEXT NOT NULL,
      leida TINYINT(1) DEFAULT 0,
      enlace VARCHAR(255) DEFAULT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
  `;
  
  db.query(sql, (err, result) => {
    if (err) {
      console.error('Error al crear tabla notificaciones:', err);
    } else {
      console.log('Tabla notificaciones creada exitosamente.');
    }
    db.end();
  });
});

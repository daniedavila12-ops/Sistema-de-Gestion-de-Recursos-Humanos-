const mysql = require('mysql2');
const db = mysql.createPool({ host: 'localhost', port: 3307, user: 'root', password: '', database: 'sistema_rrhh' });
db.query(
    "UPDATE notificaciones SET mensaje = CONCAT('Dorian Garcias creó un nuevo ticket: ', SUBSTRING(mensaje, 34)) WHERE mensaje LIKE 'Se ha recibido un nuevo ticket:%'", 
    (err, results) => { 
        if(err) console.log(err); 
        else console.log('Updated tickets!'); 
        process.exit(0); 
    }
);

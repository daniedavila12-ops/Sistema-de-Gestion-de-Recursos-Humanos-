const mysql = require('mysql2');
const db = mysql.createPool({ host: 'localhost', port: 3307, user: 'root', password: '', database: 'sistema_rrhh' });

db.query('SELECT * FROM reportes_incidencias ORDER BY id DESC LIMIT 10', (err, reportes) => {
    if (err) throw err;
    if (reportes.length > 0) {
        const r = reportes[0];
        
        // Update generic old incident messages to simulate they were created by a specific user with an ID
        db.query(
            "UPDATE notificaciones SET mensaje = CONCAT('Javier Paguada creó un nuevo incidente #', ?, ': ', SUBSTRING(mensaje, 37)) WHERE mensaje LIKE 'Se ha recibido un nuevo incidente:%'", 
            [r.id],
            (err, results) => { 
                if(err) console.log(err); 
                else console.log('Updated old incidents!'); 
                process.exit(0); 
            }
        );
    } else {
        console.log('No reportes found');
        process.exit(0);
    }
});

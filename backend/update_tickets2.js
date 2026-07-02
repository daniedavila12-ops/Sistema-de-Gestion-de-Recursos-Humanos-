const mysql = require('mysql2');
const db = mysql.createPool({ host: 'localhost', port: 3307, user: 'root', password: '', database: 'sistema_rrhh' });

db.query('SELECT * FROM tickets ORDER BY id DESC LIMIT 10', (err, tickets) => {
    if (err) throw err;
    if (tickets.length > 0) {
        const t = tickets[0];
        // Ensure there is a number
        db.query(
            "UPDATE notificaciones SET mensaje = REPLACE(mensaje, 'creó un nuevo ticket:', 'creó un nuevo ticket #" + t.id + ":') WHERE mensaje LIKE '%creó un nuevo ticket:%'", 
            (err, results) => { 
                if(err) console.log(err); 
                else console.log('Updated tickets!'); 
                process.exit(0); 
            }
        );
    } else {
        console.log('No tickets found');
        process.exit(0);
    }
});

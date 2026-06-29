const cron = require('node-cron');

function initCronJobs(app) {
    const db = app.get('db');
    const io = app.get('io');

    // Se ejecuta todos los días a las 08:00 AM
    cron.schedule('0 8 * * *', () => {
        console.log('⏳ Ejecutando tareas programadas (8:00 AM)...');

        // 1. Verificar cumpleaños de hoy
        const hoy = new Date();
        const mes = hoy.getMonth() + 1; // 1-12
        const dia = hoy.getDate();

        db.query(
            `SELECT id, nombre, apellido FROM empleados WHERE MONTH(fecha_nacimiento) = ? AND DAY(fecha_nacimiento) = ? AND estado = 1`, 
            [mes, dia], 
            (err, cumpleaneros) => {
                if (err) {
                    console.error('Error verificando cumpleaños:', err);
                } else if (cumpleaneros.length > 0) {
                    db.query('SELECT id FROM usuarios WHERE rol_id IN (1, 2)', (err, users) => {
                        if (!err && users.length > 0) {
                            let values = [];
                            cumpleaneros.forEach(emp => {
                                users.forEach(u => {
                                    values.push([u.id, 'Cumpleaños de Empleado', `Hoy es el cumpleaños de ${emp.nombre} ${emp.apellido} 🎉`, 'info']);
                                });
                            });
                            
                            if (values.length > 0) {
                                db.query('INSERT INTO notificaciones (usuario_id, titulo, mensaje, tipo) VALUES ?', [values]);
                                if (io) io.emit('nueva_notificacion');
                            }
                        }
                    });
                }
        });

        // 2. Verificar contratos que vencen hoy
        // Format YYYY-MM-DD
        const hoyStr = hoy.toISOString().split('T')[0];

        db.query(
            `SELECT c.id, e.nombre, e.apellido, c.fechaFinal 
             FROM contratos c 
             JOIN empleados e ON c.empleado_id = e.id 
             WHERE c.fechaFinal = ? AND c.estado = 'Activo' AND e.estado = 1`, 
            [hoyStr], 
            (err, contratos) => {
                if (err) {
                    console.error('Error verificando vencimiento de contratos:', err);
                } else if (contratos.length > 0) {
                    db.query('SELECT id FROM usuarios WHERE rol_id IN (1, 2)', (err, users) => {
                        if (!err && users.length > 0) {
                            let values = [];
                            contratos.forEach(c => {
                                users.forEach(u => {
                                    values.push([u.id, 'Vencimiento de Contrato', `El contrato de ${c.nombre} ${c.apellido} vence el día de hoy.`, 'warning']);
                                });
                            });
                            
                            if (values.length > 0) {
                                db.query('INSERT INTO notificaciones (usuario_id, titulo, mensaje, tipo) VALUES ?', [values]);
                                if (io) io.emit('nueva_notificacion');
                            }
                        }
                    });
                }
        });
    });
}

module.exports = initCronJobs;

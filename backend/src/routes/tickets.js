const express = require('express');
const router = express.Router();
const mysql = require('mysql2');
const multer = require('multer');
const path = require('path');

// Configuración de multer
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'uploads/tickets/');
    },
    filename: (req, file, cb) => {
        cb(null, 'ticket-' + Date.now() + path.extname(file.originalname));
    }
});
const upload = multer({ storage: storage });

const db = mysql.createPool({
    host: process.env.DB_HOST ?? 'localhost',
    port: process.env.DB_PORT ?? 3306,
    user: process.env.DB_USER ?? 'root',
    password: process.env.DB_PASS ?? '',
    database: process.env.DB_NAME ?? 'sistema_rrhh',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

// Ruta para enviar un Ticket (Vacaciones/Permisos)
router.post('/crear', upload.single('archivo'), (req, res) => {
    const { usuario_id, tipo, descripcion, identidad, tema, prioridad } = req.body;
    const archivo = req.file ? `/uploads/tickets/${req.file.filename}` : null;

    if (identidad) {
        const identidadesArray = identidad.split(',').map(i => i.trim()).filter(i => i);
        if (identidadesArray.length > 0) {
            const placeholders = identidadesArray.map(() => '?').join(',');
            db.query(`SELECT id, nombre, apellido FROM empleados WHERE identidad IN (${placeholders})`, identidadesArray, (err, results) => {
                if (err) return res.status(500).json({ error: err.message });
                
                const empleado_id = results.length > 0 ? results[0].id : null;
                const empleado_nombre = results.length > 0 
                    ? results.map(r => `${r.nombre} ${r.apellido}`).join(', ') 
                    : 'Un empleado';
            
            const query = 'INSERT INTO tickets (usuario_id, empleado_id, identidad, Categoria, descripcion, tema, prioridad, archivo) VALUES (?, ?, ?, ?, ?, ?, ?, ?)';
            db.execute(query, [usuario_id || null, empleado_id, identidad, tipo, descripcion, tema || null, prioridad || 'Media', archivo], (err, result) => {
                if (err) {
                    console.error("❌ ERROR DETALLADO:", err);
                    return res.status(500).json({ error: "Error al crear el ticket", detalle: err.message });
                }
                const io = req.app.get('io');
                if (io) io.emit('nuevo_ticket', { mensaje: 'Nuevo ticket creado' });
                db.query('SELECT id FROM usuarios WHERE rol_id IN (1, 2)', (err, users) => {
                    if (!err && users && users.length > 0) {
                        const notifQuery = 'INSERT INTO notificaciones (usuario_id, titulo, mensaje, tipo) VALUES ?';
                        const notifValues = users.map(u => [u.id, 'Nuevo Ticket Pendiente', `${empleado_nombre} creó un nuevo ticket #${result.insertId}: ${tema || tipo}`, 'info']);
                        db.query(notifQuery, [notifValues]);
                    }
                });
                res.json({ mensaje: "Ticket enviado con éxito", ticketId: result.insertId });
            });
        });
        }
    } else {
        const query = 'INSERT INTO tickets (usuario_id, Categoria, descripcion, tema, prioridad, archivo) VALUES (?, ?, ?, ?, ?, ?)';
        db.execute(query, [usuario_id || null, tipo, descripcion, tema || null, prioridad || 'Media', archivo], (err, result) => {
            if (err) {
                console.error("❌ ERROR DETALLADO:", err);
                return res.status(500).json({ error: "Error al crear el ticket", detalle: err.message });
            }
            const io = req.app.get('io');
            if (io) io.emit('nuevo_ticket', { mensaje: 'Nuevo ticket creado' });
            db.query('SELECT id FROM usuarios WHERE rol_id IN (1, 2)', (err, users) => {
                if (!err && users && users.length > 0) {
                    const notifQuery = 'INSERT INTO notificaciones (usuario_id, titulo, mensaje, tipo) VALUES ?';
                    const notifValues = users.map(u => [u.id, 'Nuevo Ticket Pendiente', `Un empleado creó un nuevo ticket #${result.insertId}: ${tema || tipo}`, 'info']);
                    db.query(notifQuery, [notifValues]);
                }
            });
            res.json({ mensaje: "Ticket enviado con éxito", ticketId: result.insertId });
        });
    }
});

// Ruta para obtener todos los tickets
router.get('/lista', (req, res) => {
    const query = `
        SELECT t.*, 
               u.nombre as creadoPorNombre,
               e.foto as empleado_foto, e.nombre as empleado_nombre, e.apellido as empleado_apellido,
               u_asig.nombre as asignado_usuario_nombre,
               u_asig.foto as asignado_usuario_foto,
               e_asig.nombre as asignado_empleado_nombre,
               e_asig.apellido as asignado_empleado_apellido,
               e_asig.foto as asignado_empleado_foto,
               (SELECT COUNT(*) FROM ticket_respuestas tr WHERE tr.ticket_id = t.id) as respuestas_count
        FROM tickets t 
        LEFT JOIN usuarios u ON t.usuario_id = u.id
        LEFT JOIN empleados e ON t.empleado_id = e.id 
        LEFT JOIN usuarios u_asig ON t.asignado_usuario_id = u_asig.id
        LEFT JOIN empleados e_asig ON t.asignado_empleado_id = e_asig.id
        ORDER BY t.fecha_creacion DESC
    `;
    db.query(query, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

// Ruta para obtener un ticket por su ID
router.get('/:id', (req, res) => {
    const ticketId = req.params.id;
    const query = `
        SELECT t.*, 
               e.foto as empleado_foto, 
               e.nombre as empleado_nombre, 
               e.apellido as empleado_apellido,
               e.telefono as empleado_telefono,
               (SELECT COUNT(*) FROM tickets t2 WHERE t2.empleado_id = t.empleado_id) as tickets_totales,
               (SELECT COUNT(*) FROM tickets t2 WHERE t2.empleado_id = t.empleado_id AND t2.estado = 'Resuelto') as tickets_resueltos,
               u_asig.nombre as asignado_usuario_nombre,
               u_asig.foto as asignado_usuario_foto,
               e_asig.nombre as asignado_empleado_nombre,
               e_asig.apellido as asignado_empleado_apellido,
               e_asig.foto as asignado_empleado_foto
        FROM tickets t 
        LEFT JOIN empleados e ON t.empleado_id = e.id 
        LEFT JOIN usuarios u_asig ON t.asignado_usuario_id = u_asig.id
        LEFT JOIN empleados e_asig ON t.asignado_empleado_id = e_asig.id
        WHERE t.id = ?
    `;
    db.query(query, [ticketId], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        if (results.length === 0) return res.status(404).json({ error: 'Ticket no encontrado' });
        res.json(results[0]);
    });
});

// Ruta para asignar el ticket
router.put('/:id/asignar', (req, res) => {
    const ticketId = req.params.id;
    const { tipo, id_asignado } = req.body; // tipo: 'usuario', 'empleado', o null

    let query = '';
    let params = [];

    if (tipo === 'usuario') {
        query = 'UPDATE tickets SET asignado_usuario_id = ?, asignado_empleado_id = NULL WHERE id = ?';
        params = [id_asignado, ticketId];
    } else if (tipo === 'empleado') {
        query = 'UPDATE tickets SET asignado_empleado_id = ?, asignado_usuario_id = NULL WHERE id = ?';
        params = [id_asignado, ticketId];
    } else {
        query = 'UPDATE tickets SET asignado_usuario_id = NULL, asignado_empleado_id = NULL WHERE id = ?';
        params = [ticketId];
    }

    db.query(query, params, (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        
        // Si se le asigna a un usuario (admin), enviarle notificación
        if (tipo === 'usuario' && id_asignado) {
            const io = req.app.get('io');
            if (io) io.emit('nueva_notificacion');

            const notifQuery = 'INSERT INTO notificaciones (usuario_id, titulo, mensaje, tipo) VALUES (?, ?, ?, ?)';
            db.query(notifQuery, [id_asignado, 'Ticket Asignado', `Se te ha asignado el Ticket #${ticketId}`, 'info']);
        }
        
        res.json({ mensaje: 'Asignación actualizada con éxito' });
    });
});

// Ruta para actualizar el estado del ticket
router.put('/:id/estado', (req, res) => {
    const ticketId = req.params.id;
    const { estado } = req.body;
    const query = 'UPDATE tickets SET estado = ? WHERE id = ?';
    db.query(query, [estado, ticketId], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        
        db.query('SELECT usuario_id FROM tickets WHERE id = ?', [ticketId], (err, ticketRes) => {
            if (!err && ticketRes && ticketRes.length > 0 && ticketRes[0].usuario_id) {
                const io = req.app.get('io');
                if (io) io.emit('nueva_notificacion');
                const notifQuery = 'INSERT INTO notificaciones (usuario_id, titulo, mensaje, tipo) VALUES (?, ?, ?, ?)';
                db.query(notifQuery, [ticketRes[0].usuario_id, 'Estado del Ticket Actualizado', `El Ticket #${ticketId} ha cambiado su estado a: ${estado}`, estado === 'Resuelto' ? 'success' : 'info']);
            }
        });

        res.json({ mensaje: 'Estado del ticket actualizado con éxito' });
    });
});

// Ruta para actualizar la prioridad del ticket
router.put('/:id/prioridad', (req, res) => {
    const ticketId = req.params.id;
    const { prioridad } = req.body;
    const query = 'UPDATE tickets SET prioridad = ? WHERE id = ?';
    db.query(query, [prioridad, ticketId], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ mensaje: 'Prioridad del ticket actualizada con éxito' });
    });
});

// Ruta para obtener las categorías de tickets
router.get('/categorias/lista', (req, res) => {
    const query = 'SELECT * FROM categorias_tickets ORDER BY nombre ASC';
    db.query(query, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

// Ruta para agregar una nueva categoría de ticket
router.post('/categorias', (req, res) => {
    const { nombre } = req.body;
    if (!nombre || nombre.trim() === '') {
        return res.status(400).json({ error: 'El nombre de la categoría es obligatorio' });
    }
    const query = 'INSERT INTO categorias_tickets (nombre) VALUES (?)';
    db.query(query, [nombre.trim()], (err, result) => {
        if (err) {
            if (err.code === 'ER_DUP_ENTRY') {
                return res.status(400).json({ error: 'La categoría ya existe' });
            }
            return res.status(500).json({ error: err.message });
        }
        res.json({ id: result.insertId, nombre: nombre.trim() });
    });
});

// Ruta para actualizar una categoría de ticket (nombre y activa)
router.put('/categorias/:id', (req, res) => {
    const categoryId = req.params.id;
    const { nombre, activa } = req.body;

    if (!nombre || nombre.trim() === '') {
        return res.status(400).json({ error: 'El nombre de la categoría es obligatorio' });
    }

    const query = 'UPDATE categorias_tickets SET nombre = ?, activa = ? WHERE id = ?';
    db.query(query, [nombre.trim(), activa, categoryId], (err, result) => {
        if (err) {
            if (err.code === 'ER_DUP_ENTRY') {
                return res.status(400).json({ error: 'Ya existe otra categoría con ese nombre' });
            }
            return res.status(500).json({ error: err.message });
        }
        res.json({ mensaje: 'Categoría actualizada con éxito' });
    });
});

// Obtener respuestas de un ticket
router.get('/:id/respuestas', (req, res) => {
    const ticketId = req.params.id;
    const query = `
        SELECT r.*, 
               u.nombre as usuario_nombre, u.foto as usuario_foto,
               e.nombre as empleado_nombre, e.apellido as empleado_apellido, e.foto as empleado_foto
        FROM ticket_respuestas r
        LEFT JOIN usuarios u ON r.usuario_id = u.id
        LEFT JOIN empleados e ON r.empleado_id = e.id
        WHERE r.ticket_id = ?
        ORDER BY r.fecha_creacion ASC
    `;
    db.query(query, [ticketId], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

// Crear una respuesta a un ticket
router.post('/:id/respuestas', upload.single('archivo'), (req, res) => {
    const ticketId = req.params.id;
    const { usuario_id, empleado_id, mensaje } = req.body;
    const archivo = req.file ? `/uploads/tickets/${req.file.filename}` : null;

    if (!mensaje || mensaje.trim() === '') {
        return res.status(400).json({ error: 'El mensaje es obligatorio' });
    }

    const query = 'INSERT INTO ticket_respuestas (ticket_id, usuario_id, empleado_id, mensaje, archivo) VALUES (?, ?, ?, ?, ?)';
    db.query(query, [ticketId, usuario_id || null, empleado_id || null, mensaje, archivo], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        
        const updateQuery = 'UPDATE tickets SET updated_at = CURRENT_TIMESTAMP WHERE id = ?';
        db.query(updateQuery, [ticketId], () => {
            // Verificar estado del ticket y asignado antes de notificar
            db.query('SELECT estado, asignado_usuario_id, usuario_id FROM tickets WHERE id = ?', [ticketId], (err, ticketRes) => {
                const estado = ticketRes && ticketRes.length > 0 ? ticketRes[0].estado : null;
                const asignado = ticketRes && ticketRes.length > 0 ? ticketRes[0].asignado_usuario_id : null;
                const creador = ticketRes && ticketRes.length > 0 ? ticketRes[0].usuario_id : null;
                const estadosCerrados = ['Resuelto', 'Cancelado', 'Desestimado'];
                
                if (!estadosCerrados.includes(estado)) {
                    const io = req.app.get('io');
                    if (io) io.emit('nueva_notificacion');

                    let autorQuery = '';
                    let autorParams = [];
                    if (usuario_id) {
                        autorQuery = 'SELECT nombre FROM usuarios WHERE id = ?';
                        autorParams = [usuario_id];
                    } else if (empleado_id) {
                        autorQuery = 'SELECT CONCAT(nombre, " ", apellido) as nombre FROM empleados WHERE id = ?';
                        autorParams = [empleado_id];
                    }

                    const notificar = (autorNombre) => {
                        db.query('SELECT id FROM usuarios WHERE rol_id IN (1, 2) OR id = ? OR id = ?', [asignado, creador], (err, users) => {
                            if (!err && users && users.length > 0) {
                                // Filtrar al autor del mensaje para no notificarle sus propias respuestas
                                const notifyUsers = users.filter(u => String(u.id) !== String(usuario_id));
                                if (notifyUsers.length > 0) {
                                    const notifQuery = 'INSERT INTO notificaciones (usuario_id, titulo, mensaje, tipo) VALUES ?';
                                    const notifValues = notifyUsers.map(u => [u.id, 'Respuesta en Ticket', `${autorNombre} añadió una respuesta al Ticket #${ticketId}`, 'info']);
                                    db.query(notifQuery, [notifValues]);
                                }
                            }
                        });
                    };

                    if (autorQuery) {
                        db.query(autorQuery, autorParams, (err, autorRes) => {
                            let autorNombre = 'Alguien';
                            if (!err && autorRes && autorRes.length > 0) {
                                autorNombre = autorRes[0].nombre;
                            }
                            notificar(autorNombre);
                        });
                    } else {
                        notificar('Alguien');
                    }
                }
                
                res.json({ mensaje: 'Respuesta añadida con éxito', respuestaId: result.insertId });
            });
        });
    });
});

// Ruta para eliminar un ticket
router.delete('/:id', (req, res) => {
    const ticketId = req.params.id;
    const fs = require('fs');

    // Primero obtener el archivo adjunto si existe
    db.query('SELECT archivo FROM tickets WHERE id = ?', [ticketId], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });

        if (results.length > 0 && results[0].archivo) {
            const filePath = path.join(__dirname, '../../', results[0].archivo);
            if (fs.existsSync(filePath)) {
                try { fs.unlinkSync(filePath); } catch(e) { console.error('Error eliminando archivo:', e); }
            }
        }

        // Eliminar respuestas asociadas
        db.query('DELETE FROM ticket_respuestas WHERE ticket_id = ?', [ticketId], (err) => {
            if (err) console.error('Error eliminando respuestas:', err);

            db.query('DELETE FROM tickets WHERE id = ?', [ticketId], (err, result) => {
                if (err) return res.status(500).json({ error: err.message });
                const io = req.app.get('io');
                if (io) io.emit('tickets_actualizados');
                res.json({ mensaje: 'Ticket eliminado con éxito' });
            });
        });
    });
});

module.exports = router;
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
        db.query('SELECT id FROM empleados WHERE identidad = ?', [identidad], (err, results) => {
            if (err) return res.status(500).json({ error: err.message });
            
            const empleado_id = results.length > 0 ? results[0].id : null;
            
            const query = 'INSERT INTO tickets (usuario_id, empleado_id, identidad, Categoria, descripcion, tema, prioridad, archivo) VALUES (?, ?, ?, ?, ?, ?, ?, ?)';
            db.execute(query, [usuario_id || null, empleado_id, identidad, tipo, descripcion, tema || null, prioridad || 'Media', archivo], (err, result) => {
                if (err) {
                    console.error("❌ ERROR DETALLADO:", err);
                    return res.status(500).json({ error: "Error al crear el ticket", detalle: err.message });
                }
                res.json({ mensaje: "Ticket enviado con éxito", ticketId: result.insertId });
            });
        });
    } else {
        const query = 'INSERT INTO tickets (usuario_id, Categoria, descripcion, tema, prioridad, archivo) VALUES (?, ?, ?, ?, ?, ?)';
        db.execute(query, [usuario_id || null, tipo, descripcion, tema || null, prioridad || 'Media', archivo], (err, result) => {
            if (err) {
                console.error("❌ ERROR DETALLADO:", err);
                return res.status(500).json({ error: "Error al crear el ticket", detalle: err.message });
            }
            res.json({ mensaje: "Ticket enviado con éxito", ticketId: result.insertId });
        });
    }
});

// Ruta para obtener todos los tickets
router.get('/lista', (req, res) => {
    const query = `
        SELECT t.*, 
               e.foto as empleado_foto, e.nombre as empleado_nombre, e.apellido as empleado_apellido,
               u_asig.nombre as asignado_usuario_nombre,
               u_asig.foto as asignado_usuario_foto,
               e_asig.nombre as asignado_empleado_nombre,
               e_asig.apellido as asignado_empleado_apellido,
               e_asig.foto as asignado_empleado_foto,
               (SELECT COUNT(*) FROM ticket_respuestas tr WHERE tr.ticket_id = t.id) as respuestas_count
        FROM tickets t 
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
            res.json({ mensaje: 'Respuesta añadida con éxito', respuestaId: result.insertId });
        });
    });
});

module.exports = router;
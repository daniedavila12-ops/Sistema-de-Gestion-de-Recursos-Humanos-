const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Configuración de multer
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        const dest = path.join(__dirname, '../../uploads/incidencias');
        if (!fs.existsSync(dest)) {
            fs.mkdirSync(dest, { recursive: true });
        }
        cb(null, dest);
    },
    filename: (req, file, cb) => {
        cb(null, 'incidencia-' + Date.now() + path.extname(file.originalname));
    }
});
const upload = multer({ storage: storage });

// Ruta para crear un reporte de incidencia
router.post('/crear', upload.single('archivo'), (req, res) => {
    const db = req.app.get('db');
    const { jefe_reporta, identidad, categoria, tema, prioridad, descripcion } = req.body;
    const archivo = req.file ? `/uploads/incidencias/${req.file.filename}` : null;

    if (identidad) {
        db.query('SELECT id FROM empleados WHERE identidad = ?', [identidad], (err, results) => {
            if (err) return res.status(500).json({ error: err.message });
            
            const empleado_id = results.length > 0 ? results[0].id : null;
            
            const query = 'INSERT INTO reportes_incidencias (jefe_reporta, empleado_reportado_id, identidad, categoria, descripcion, tema, prioridad, archivo) VALUES (?, ?, ?, ?, ?, ?, ?, ?)';
            db.execute(query, [jefe_reporta, empleado_id, identidad, categoria, descripcion, tema || null, prioridad || 'Media', archivo], (err, result) => {
                if (err) {
                    console.error("❌ ERROR DETALLADO:", err);
                    return res.status(500).json({ error: "Error al crear el reporte", detalle: err.message });
                }
                res.json({ mensaje: "Reporte enviado con éxito", reporteId: result.insertId });
            });
        });
    } else {
        const query = 'INSERT INTO reportes_incidencias (jefe_reporta, categoria, descripcion, tema, prioridad, archivo) VALUES (?, ?, ?, ?, ?, ?)';
        db.execute(query, [jefe_reporta, categoria, descripcion, tema || null, prioridad || 'Media', archivo], (err, result) => {
            if (err) {
                console.error("❌ ERROR DETALLADO:", err);
                return res.status(500).json({ error: "Error al crear el reporte", detalle: err.message });
            }
            res.json({ mensaje: "Reporte enviado con éxito", reporteId: result.insertId });
        });
    }
});

// Ruta para obtener todos los reportes de incidencia
router.get('/lista', (req, res) => {
    const db = req.app.get('db');
    const query = `
        SELECT r.*, 
               e.foto as empleado_foto, e.nombre as empleado_nombre, e.apellido as empleado_apellido,
               d.nombre as departamento_nombre,
               u_asig.nombre as asignado_usuario_nombre,
               u_asig.foto as asignado_usuario_foto,
               (SELECT COUNT(*) FROM reporte_incidencia_respuestas rr WHERE rr.reporte_id = r.id) as respuestas_count
        FROM reportes_incidencias r 
        LEFT JOIN empleados e ON r.empleado_reportado_id = e.id 
        LEFT JOIN departamentos d ON e.departamento_id = d.id
        LEFT JOIN usuarios u_asig ON r.asignado_usuario_id = u_asig.id
        ORDER BY r.fecha_creacion DESC
    `;
    db.query(query, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

// Ruta para obtener un reporte por su ID
router.get('/:id', (req, res) => {
    const db = req.app.get('db');
    const reporteId = req.params.id;
    const query = `
        SELECT r.*, 
               e.foto as empleado_foto, 
               e.nombre as empleado_nombre, 
               e.apellido as empleado_apellido,
               e.telefono as empleado_telefono,
               d.nombre as departamento_nombre,
               u_asig.nombre as asignado_usuario_nombre,
               u_asig.foto as asignado_usuario_foto
        FROM reportes_incidencias r 
        LEFT JOIN empleados e ON r.empleado_reportado_id = e.id 
        LEFT JOIN departamentos d ON e.departamento_id = d.id
        LEFT JOIN usuarios u_asig ON r.asignado_usuario_id = u_asig.id
        WHERE r.id = ?
    `;
    db.query(query, [reporteId], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        if (results.length === 0) return res.status(404).json({ error: 'Reporte no encontrado' });
        res.json(results[0]);
    });
});

// Ruta para asignar un usuario al reporte
router.put('/:id/asignar', (req, res) => {
    const db = req.app.get('db');
    const reporteId = req.params.id;
    const { usuario_id } = req.body;
    db.query('UPDATE reportes_incidencias SET asignado_usuario_id = ?, estado = "En Proceso" WHERE id = ?', [usuario_id, reporteId], (err) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ mensaje: 'Reporte asignado con éxito' });
    });
});

// Ruta para cambiar el estado de un reporte
router.put('/:id/estado', (req, res) => {
    const db = req.app.get('db');
    const reporteId = req.params.id;
    const { estado } = req.body;
    db.query('UPDATE reportes_incidencias SET estado = ? WHERE id = ?', [estado, reporteId], (err) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ mensaje: 'Estado actualizado' });
    });
});

// Ruta para obtener las respuestas de un reporte
router.get('/:id/respuestas', (req, res) => {
    const db = req.app.get('db');
    const reporteId = req.params.id;
    const query = `
        SELECT rr.*, 
               u.nombre as usuario_nombre, u.foto as usuario_foto,
               e.nombre as empleado_nombre, e.apellido as empleado_apellido, e.foto as empleado_foto
        FROM reporte_incidencia_respuestas rr
        LEFT JOIN usuarios u ON rr.usuario_id = u.id
        LEFT JOIN empleados e ON rr.empleado_id = e.id
        WHERE rr.reporte_id = ?
        ORDER BY rr.fecha_creacion ASC
    `;
    db.query(query, [reporteId], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

// Ruta para enviar una respuesta a un reporte
router.post('/:id/respuestas', upload.single('archivo'), (req, res) => {
    const db = req.app.get('db');
    const reporteId = req.params.id;
    const { usuario_id, empleado_id, mensaje } = req.body;
    const archivo = req.file ? `/uploads/incidencias/${req.file.filename}` : null;

    const query = 'INSERT INTO reporte_incidencia_respuestas (reporte_id, usuario_id, empleado_id, mensaje, archivo) VALUES (?, ?, ?, ?, ?)';
    db.execute(query, [reporteId, usuario_id || null, empleado_id || null, mensaje, archivo], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ mensaje: 'Respuesta enviada', respuestaId: result.insertId, archivo: archivo });
    });
});

// Rutas para gestionar categorías de reportes
router.get('/categorias/lista', (req, res) => {
    const db = req.app.get('db');
    const query = 'SELECT * FROM categorias_reportes ORDER BY nombre ASC';
    db.query(query, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

router.post('/categorias', (req, res) => {
    const db = req.app.get('db');
    const { nombre } = req.body;
    if (!nombre || nombre.trim() === '') {
        return res.status(400).json({ error: 'El nombre de la categoría es obligatorio' });
    }
    const query = 'INSERT INTO categorias_reportes (nombre) VALUES (?)';
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

router.put('/categorias/:id', (req, res) => {
    const db = req.app.get('db');
    const categoryId = req.params.id;
    const { nombre, activa } = req.body;

    if (!nombre || nombre.trim() === '') {
        return res.status(400).json({ error: 'El nombre de la categoría es obligatorio' });
    }

    const query = 'UPDATE categorias_reportes SET nombre = ?, activa = ? WHERE id = ?';
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

module.exports = router;
const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Configuración de multer
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        const dir = path.join(__dirname, '../../uploads/vacaciones');
        if (!fs.existsSync(dir)){
            fs.mkdirSync(dir, { recursive: true });
        }
        cb(null, dir);
    },
    filename: function (req, file, cb) {
        cb(null, 'vacacion-' + Date.now() + '-' + Math.round(Math.random() * 1E9) + path.extname(file.originalname));
    }
});

const upload = multer({ storage: storage });

router.get('/tipos-permiso', (req, res) => {
    const db = req.app.get('db');
    const query = `SELECT id, nombre FROM tipos_permiso ORDER BY nombre ASC`;
    db.query(query, (err, results) => {
        if (err) {
            return res.status(500).json({ error: "Error al obtener tipos de permiso", detalle: err.message });
        }
        res.json(results);
    });
});

router.post('/tipos-permiso', (req, res) => {
    const db = req.app.get('db');
    const { nombre } = req.body;
    if (!nombre) {
        return res.status(400).json({ error: "El nombre es requerido" });
    }
    const query = `INSERT INTO tipos_permiso (nombre) VALUES (?)`;
    db.query(query, [nombre], (err, result) => {
        if (err) {
            if (err.code === 'ER_DUP_ENTRY') {
                return res.status(400).json({ error: "El tipo de permiso ya existe" });
            }
            return res.status(500).json({ error: "Error al crear tipo de permiso", detalle: err.message });
        }
        res.status(201).json({ id: result.insertId, nombre });
    });
});

router.put('/tipos-permiso/:id', (req, res) => {
    const db = req.app.get('db');
    const { id } = req.params;
    const { nombre } = req.body;
    if (!nombre) {
        return res.status(400).json({ error: "El nombre es requerido" });
    }

    // First, get the old name to update existing vacaciones records
    db.query('SELECT nombre FROM tipos_permiso WHERE id = ?', [id], (err, results) => {
        if (err || results.length === 0) return res.status(500).json({ error: "Error al obtener el tipo de permiso anterior" });
        const oldNombre = results[0].nombre;

        const updateQuery = `UPDATE tipos_permiso SET nombre = ? WHERE id = ?`;
        db.query(updateQuery, [nombre, id], (err, result) => {
            if (err) {
                if (err.code === 'ER_DUP_ENTRY') {
                    return res.status(400).json({ error: "El tipo de permiso ya existe" });
                }
                return res.status(500).json({ error: "Error al actualizar tipo de permiso", detalle: err.message });
            }

            // Also update any existing 'vacaciones' that used the old name
            db.query('UPDATE vacaciones SET tipoPermiso = ? WHERE tipoPermiso = ?', [nombre, oldNombre], (err) => {
                // If it fails, it's not a critical error for the type itself, but we should log it
                if (err) console.error("Error updating vacaciones with new tipoPermiso:", err);
                res.json({ id, nombre, message: "Tipo de permiso actualizado correctamente" });
            });
        });
    });
});

router.delete('/tipos-permiso/:id', (req, res) => {
    const db = req.app.get('db');
    const { id } = req.params;

    const deleteQuery = `DELETE FROM tipos_permiso WHERE id = ?`;
    db.query(deleteQuery, [id], (err, result) => {
        if (err) {
            return res.status(500).json({ error: "Error al eliminar tipo de permiso", detalle: err.message });
        }
        res.json({ message: "Tipo de permiso eliminado" });
    });
});

router.post('/registrar', upload.single('documento'), (req, res) => {
    const db = req.app.get('db');
    const {
        empleado_id,
        fechaIngreso,
        aniosLaborados,
        diasCorrespondientesEmpleado,
        fechaSolicitud,
        tipoSolicitud,
        tipoPermiso,
        periodo,
        diasCorrespondientes,
        diasVacaciones,
        diasPagados,
        diasPendientes,
        fechaInicio,
        fechaFinal,
        fechaRegreso,
        observaciones,
        autorizadoPor,
        usuario_id // For audit
    } = req.body;

    const documentoUrl = req.file ? `/uploads/vacaciones/${req.file.filename}` : null;

    if (!empleado_id) {
        return res.status(400).json({ error: 'El ID del empleado es requerido' });
    }

    const query = `
        INSERT INTO vacaciones (
            empleado_id, 
            fechaIngreso, 
            aniosLaborados, 
            diasCorrespondientes, 
            fechaSolicitud, 
            tipoSolicitud, 
            tipoPermiso,
            periodo, 
            diasVacaciones, 
            diasPagados, 
            diasPendientes, 
            fechaInicio, 
            fechaFinal, 
            fechaRegreso, 
            observaciones, 
            autorizadoPor,
            creadoPor,
            documento
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `;

    db.execute(query, [
        empleado_id,
        fechaIngreso || null,
        aniosLaborados || 0,
        diasCorrespondientes || 0,
        fechaSolicitud || null,
        tipoSolicitud || null,
        tipoPermiso || null,
        periodo || null,
        diasVacaciones || 0,
        diasPagados || 0,
        diasPendientes || 0,
        fechaInicio || null,
        fechaFinal || null,
        fechaRegreso || null,
        observaciones || null,
        autorizadoPor || null,
        usuario_id || null,
        documentoUrl
    ], (err, result) => {
        if (err) {
            console.error("❌ ERROR DETALLADO:", err);
            return res.status(500).json({ error: "Error al registrar vacaciones", detalle: err.message });
        }

        const io = req.app.get('io');
        if (io) io.emit('nueva_notificacion');

        db.query('SELECT id FROM usuarios WHERE rol_id IN (1, 2)', (err, users) => {
            if (!err && users && users.length > 0) {
                const notifQuery = 'INSERT INTO notificaciones (usuario_id, titulo, mensaje, tipo) VALUES ?';
                const notifValues = users.map(u => [u.id, 'Nuevas Vacaciones', `Se han registrado nuevas vacaciones/permiso para el empleado ID: ${empleado_id}`, 'info']);
                db.query(notifQuery, [notifValues]);
            }
        });

        res.json({ mensaje: "Vacaciones registradas con éxito", id: result.insertId });
    });
});

router.get('/empleado/:id', (req, res) => {
    const db = req.app.get('db');
    const empleado_id = req.params.id;
    
    const query = `
        SELECT v.*, 
               (SELECT nombre FROM usuarios WHERE id = v.creadoPor) AS creadoPorNombre,
               (SELECT nombre FROM usuarios WHERE id = v.modificadoPor) AS modificadoPorNombre
        FROM vacaciones v
        WHERE v.empleado_id = ? 
        ORDER BY v.fechaInicio DESC
    `;
    
    db.query(query, [empleado_id], (err, results) => {
        if (err) {
            return res.status(500).json({ error: 'Error al obtener vacaciones', detalle: err.message });
        }
        res.json(results);
    });
});

router.put('/:id', upload.single('documento'), (req, res) => {
    const db = req.app.get('db');
    const id = req.params.id;
    const {
        fechaIngreso,
        aniosLaborados,
        diasCorrespondientes,
        fechaSolicitud,
        tipoSolicitud,
        tipoPermiso,
        periodo,
        diasVacaciones,
        diasPagados,
        diasPendientes,
        fechaInicio,
        fechaFinal,
        fechaRegreso,
        observaciones,
        autorizadoPor,
        usuario_id // For audit
    } = req.body;

    let query = `
        UPDATE vacaciones SET
            fechaIngreso = ?, 
            aniosLaborados = ?, 
            diasCorrespondientes = ?, 
            fechaSolicitud = ?, 
            tipoSolicitud = ?, 
            tipoPermiso = ?,
            periodo = ?, 
            diasVacaciones = ?, 
            diasPagados = ?, 
            diasPendientes = ?, 
            fechaInicio = ?, 
            fechaFinal = ?, 
            fechaRegreso = ?, 
            observaciones = ?, 
            autorizadoPor = ?,
            modificadoPor = ?
    `;
    
    const params = [
        fechaIngreso || null,
        aniosLaborados || 0,
        diasCorrespondientes || 0,
        fechaSolicitud || null,
        tipoSolicitud || null,
        tipoPermiso || null,
        periodo || null,
        diasVacaciones || 0,
        diasPagados || 0,
        diasPendientes || 0,
        fechaInicio || null,
        fechaFinal || null,
        fechaRegreso || null,
        observaciones || null,
        autorizadoPor || null,
        usuario_id || null
    ];

    if (req.file) {
        query += `, documento = ?`;
        params.push(`/uploads/vacaciones/${req.file.filename}`);
    }

    query += ` WHERE id = ?`;
    params.push(id);

    db.execute(query, params, (err, result) => {
        if (err) {
            return res.status(500).json({ error: "Error al actualizar vacaciones", detalle: err.message });
        }
        res.json({ mensaje: "Vacaciones actualizadas con éxito" });
    });
});

router.delete('/:id', (req, res) => {
    const db = req.app.get('db');
    const id = req.params.id;
    
    const query = "DELETE FROM vacaciones WHERE id = ?";
    db.query(query, [id], (err, result) => {
        if (err) {
            return res.status(500).json({ error: "Error al eliminar vacaciones", detalle: err.message });
        }
        res.json({ mensaje: "Vacaciones eliminadas con éxito" });
    });
});

router.get('/proximas', (req, res) => {
    const db = req.app.get('db');
    
    // Obtener vacaciones futuras o en curso (fechaFinal >= hoy)
    const query = `
        SELECT v.*, e.nombre, e.apellido, e.codigo_empleado, d.nombre as departamento
        FROM vacaciones v
        JOIN empleados e ON v.empleado_id = e.id
        LEFT JOIN departamentos d ON e.departamento_id = d.id
        WHERE v.fechaFinal >= CURDATE()
        ORDER BY v.fechaInicio ASC
    `;
    
    db.query(query, (err, results) => {
        if (err) {
            return res.status(500).json({ error: 'Error al obtener proyecciones', detalle: err.message });
        }
        res.json(results);
    });
});

module.exports = router;

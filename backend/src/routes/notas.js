const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Configuración de multer
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        const dir = path.join(__dirname, '../../uploads/notas');
        if (!fs.existsSync(dir)){
            fs.mkdirSync(dir, { recursive: true });
        }
        cb(null, dir);
    },
    filename: function (req, file, cb) {
        cb(null, 'nota-' + Date.now() + '-' + Math.round(Math.random() * 1E9) + path.extname(file.originalname));
    }
});

const upload = multer({ storage: storage });

router.post('/registrar', upload.single('documento'), (req, res) => {
    const db = req.app.get('db');
    const { empleado_id, asunto, descripcion, creadoPor } = req.body;

    const documentoUrl = req.file ? `/uploads/notas/${req.file.filename}` : null;

    const query = `
        INSERT INTO notas (empleado_id, asunto, descripcion, creadoPor, modificadoPor, documento)
        VALUES (?, ?, ?, ?, ?, ?)
    `;

    db.query(query, [empleado_id, asunto, descripcion, creadoPor || 1, creadoPor || 1, documentoUrl], (err, result) => {
        if (err) {
            console.error("Error al registrar nota:", err);
            return res.status(500).json({ error: "Error al registrar nota", detalle: err.message });
        }

        const io = req.app.get('io');
        if (io) {
            io.emit('nueva_notificacion');
            io.emit('refresh_empleado_detalle', empleado_id);
        }

        db.query('SELECT id FROM usuarios WHERE rol_id IN (1, 2)', (err, users) => {
            if (!err && users && users.length > 0) {
                const notifQuery = 'INSERT INTO notificaciones (usuario_id, titulo, mensaje, tipo) VALUES ?';
                const notifValues = users.map(u => [u.id, 'Nueva Nota', `Se ha registrado una nueva nota para el empleado ID: ${empleado_id}`, 'info']);
                db.query(notifQuery, [notifValues]);
            }
        });

        res.json({ mensaje: "Nota registrada con éxito", id: result.insertId });
    });
});

router.get('/empleado/:id', (req, res) => {
    const db = req.app.get('db');
    const empleado_id = req.params.id;
    
    const query = `
        SELECT n.*, 
               (SELECT nombre FROM usuarios WHERE id = n.creadoPor) AS creadoPorNombre,
               (SELECT nombre FROM usuarios WHERE id = n.modificadoPor) AS modificadoPorNombre
        FROM notas n
        WHERE n.empleado_id = ? 
        ORDER BY n.fechaCreacion DESC
    `;
    
    db.query(query, [empleado_id], (err, results) => {
        if (err) {
            return res.status(500).json({ error: 'Error al obtener notas', detalle: err.message });
        }
        res.json(results);
    });
});

router.put('/:id', upload.single('documento'), (req, res) => {
    const db = req.app.get('db');
    const id = req.params.id;
    const { asunto, descripcion, modificadoPor } = req.body;

    let query = `
        UPDATE notas SET
            asunto = ?, 
            descripcion = ?, 
            modificadoPor = ?
    `;
    
    const params = [asunto, descripcion, modificadoPor || 1];

    if (req.file) {
        query += `, documento = ?`;
        params.push(`/uploads/notas/${req.file.filename}`);
    }

    query += ` WHERE id = ?`;
    params.push(id);

    db.query(query, params, (err, result) => {
        if (err) {
            return res.status(500).json({ error: "Error al actualizar nota", detalle: err.message });
        }
        res.json({ mensaje: "Nota actualizada con éxito" });
    });
});

router.delete('/:id', (req, res) => {
    const db = req.app.get('db');
    const id = req.params.id;
    
    const query = "DELETE FROM notas WHERE id = ?";
    db.query(query, [id], (err, result) => {
        if (err) {
            return res.status(500).json({ error: "Error al eliminar nota", detalle: err.message });
        }
        res.json({ mensaje: "Nota eliminada con éxito" });
    });
});

module.exports = router;

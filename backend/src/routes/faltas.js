const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Configuración de multer
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        const dir = path.join(__dirname, '../../uploads/faltas');
        if (!fs.existsSync(dir)){
            fs.mkdirSync(dir, { recursive: true });
        }
        cb(null, dir);
    },
    filename: function (req, file, cb) {
        cb(null, 'falta-' + Date.now() + '-' + Math.round(Math.random() * 1E9) + path.extname(file.originalname));
    }
});

const upload = multer({ storage: storage });

router.post('/registrar', upload.single('documento'), (req, res) => {
    const db = req.app.get('db');
    const { empleado_id, fecha, motivo, sancion, creadoPor } = req.body;
    
    const documentoUrl = req.file ? `/uploads/faltas/${req.file.filename}` : null;

    const query = `
        INSERT INTO faltas (empleado_id, fecha, motivo, sancion, creadoPor, modificadoPor, documento)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    `;

    db.query(query, [empleado_id, fecha, motivo, sancion || null, creadoPor || 1, creadoPor || 1, documentoUrl], (err, result) => {
        if (err) {
            console.error("Error al registrar falta:", err);
            return res.status(500).json({ error: "Error al registrar falta", detalle: err.message });
        }

        const io = req.app.get('io');
        if (io) {
            io.emit('nueva_notificacion');
            io.emit('refresh_empleado_detalle', empleado_id);
        }

        db.query('SELECT id FROM usuarios WHERE rol_id IN (1, 2)', (err, users) => {
            if (!err && users && users.length > 0) {
                const notifQuery = 'INSERT INTO notificaciones (usuario_id, titulo, mensaje, tipo) VALUES ?';
                const notifValues = users.map(u => [u.id, 'Nueva Falta', `Se ha registrado una nueva falta para el empleado ID: ${empleado_id}`, 'warning']);
                db.query(notifQuery, [notifValues]);
            }
        });

        res.json({ mensaje: "Falta registrada con éxito", id: result.insertId });
    });
});

router.get('/empleado/:id', (req, res) => {
    const db = req.app.get('db');
    const empleado_id = req.params.id;
    
    const query = `
        SELECT f.*, 
               (SELECT nombre FROM usuarios WHERE id = f.creadoPor) AS creadoPorNombre,
               (SELECT nombre FROM usuarios WHERE id = f.modificadoPor) AS modificadoPorNombre
        FROM faltas f
        WHERE f.empleado_id = ? 
        ORDER BY f.fecha DESC
    `;
    
    db.query(query, [empleado_id], (err, results) => {
        if (err) {
            return res.status(500).json({ error: 'Error al obtener faltas', detalle: err.message });
        }
        res.json(results);
    });
});

router.put('/:id', upload.single('documento'), (req, res) => {
    const db = req.app.get('db');
    const id = req.params.id;
    const { fecha, motivo, sancion, modificadoPor } = req.body;

    let query = `
        UPDATE faltas SET
            fecha = ?, 
            motivo = ?, 
            sancion = ?,
            modificadoPor = ?
    `;
    
    const params = [fecha, motivo, sancion || null, modificadoPor || 1];
    
    if (req.file) {
        query += `, documento = ?`;
        params.push(`/uploads/faltas/${req.file.filename}`);
    }
    
    query += ` WHERE id = ?`;
    params.push(id);

    db.query(query, params, (err, result) => {
        if (err) {
            return res.status(500).json({ error: "Error al actualizar falta", detalle: err.message });
        }
        res.json({ mensaje: "Falta actualizada con éxito" });
    });
});

router.delete('/:id', (req, res) => {
    const db = req.app.get('db');
    const id = req.params.id;
    
    const query = "DELETE FROM faltas WHERE id = ?";
    db.query(query, [id], (err, result) => {
        if (err) {
            return res.status(500).json({ error: "Error al eliminar falta", detalle: err.message });
        }
        res.json({ mensaje: "Falta eliminada con éxito" });
    });
});

module.exports = router;

const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs');

const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        const dest = path.join(__dirname, '../../uploads/documentos');
        if (!fs.existsSync(dest)) {
            fs.mkdirSync(dest, { recursive: true });
        }
        cb(null, dest);
    },
    filename: function (req, file, cb) {
        cb(null, `doc-${Date.now()}${path.extname(file.originalname)}`);
    }
});
const upload = multer({ storage: storage });

router.post('/registrar', upload.single('archivo'), (req, res) => {
    const db = req.app.get('db');
    const { empleado_id, titulo, tipo, creadoPor } = req.body;
    let archivo_url = null;
    
    if (req.file) {
        archivo_url = `/uploads/documentos/${req.file.filename}`;
    }

    const query = `
        INSERT INTO documentos (empleado_id, titulo, tipo, archivo_url, creadoPor, modificadoPor)
        VALUES (?, ?, ?, ?, ?, ?)
    `;

    db.query(query, [empleado_id, titulo, tipo || 'Documento General', archivo_url, creadoPor || 1, creadoPor || 1], (err, result) => {
        if (err) {
            console.error("Error al registrar documento:", err);
            return res.status(500).json({ error: "Error al registrar documento", detalle: err.message });
        }
        res.json({ mensaje: "Documento registrado con éxito", id: result.insertId, archivo_url });
    });
});

router.get('/empleado/:id', (req, res) => {
    const db = req.app.get('db');
    const empleado_id = req.params.id;
    
    const query = `
        SELECT d.*, 
               (SELECT nombre FROM usuarios WHERE id = d.creadoPor) AS creadoPorNombre,
               (SELECT nombre FROM usuarios WHERE id = d.modificadoPor) AS modificadoPorNombre
        FROM documentos d
        WHERE d.empleado_id = ? 
        ORDER BY d.fecha_creacion DESC
    `;
    
    db.query(query, [empleado_id], (err, results) => {
        if (err) {
            return res.status(500).json({ error: 'Error al obtener documentos', detalle: err.message });
        }
        res.json(results);
    });
});

router.put('/:id', upload.single('archivo'), (req, res) => {
    const db = req.app.get('db');
    const id = req.params.id;
    const { titulo, tipo, modificadoPor } = req.body;
    
    let archivo_url = null;
    if (req.file) {
        archivo_url = `/uploads/documentos/${req.file.filename}`;
    }

    if (archivo_url) {
        const query = `
            UPDATE documentos SET
                titulo = ?, 
                tipo = ?, 
                archivo_url = ?, 
                modificadoPor = ?
            WHERE id = ?
        `;
        db.query(query, [titulo, tipo || 'Documento General', archivo_url, modificadoPor || 1, id], (err, result) => {
            if (err) return res.status(500).json({ error: "Error al actualizar documento", detalle: err.message });
            res.json({ mensaje: "Documento actualizado con éxito" });
        });
    } else {
        const query = `
            UPDATE documentos SET
                titulo = ?, 
                tipo = ?, 
                modificadoPor = ?
            WHERE id = ?
        `;
        db.query(query, [titulo, tipo || 'Documento General', modificadoPor || 1, id], (err, result) => {
            if (err) return res.status(500).json({ error: "Error al actualizar documento", detalle: err.message });
            res.json({ mensaje: "Documento actualizado con éxito" });
        });
    }
});

router.delete('/:id', (req, res) => {
    const db = req.app.get('db');
    const id = req.params.id;
    
    const query = "DELETE FROM documentos WHERE id = ?";
    db.query(query, [id], (err, result) => {
        if (err) {
            return res.status(500).json({ error: "Error al eliminar documento", detalle: err.message });
        }
        res.json({ mensaje: "Documento eliminado con éxito" });
    });
});

// Rutas para gestionar Tipos de Documento
router.get('/tipos/lista', (req, res) => {
    const db = req.app.get('db');
    db.query("SELECT * FROM tipos_documento ORDER BY id ASC", (err, results) => {
        if (err) return res.status(500).json({ error: "Error al obtener tipos de documento", detalle: err.message });
        res.json(results);
    });
});

router.post('/tipos', (req, res) => {
    const db = req.app.get('db');
    const { nombre } = req.body;
    if (!nombre) return res.status(400).json({ error: "El nombre del tipo es requerido" });

    db.query("INSERT INTO tipos_documento (nombre) VALUES (?)", [nombre], (err, result) => {
        if (err) {
            if (err.code === 'ER_DUP_ENTRY') {
                return res.status(400).json({ error: "El tipo de documento ya existe" });
            }
            return res.status(500).json({ error: "Error al crear tipo de documento", detalle: err.message });
        }
        res.json({ mensaje: "Tipo de documento creado con éxito", id: result.insertId });
    });
});

router.put('/tipos/:id', (req, res) => {
    const db = req.app.get('db');
    const id = req.params.id;
    const { nombre } = req.body;
    if (!nombre) return res.status(400).json({ error: "El nombre del tipo es requerido" });

    db.query("UPDATE tipos_documento SET nombre = ? WHERE id = ?", [nombre, id], (err, result) => {
        if (err) {
            if (err.code === 'ER_DUP_ENTRY') {
                return res.status(400).json({ error: "El tipo de documento ya existe" });
            }
            return res.status(500).json({ error: "Error al actualizar tipo de documento", detalle: err.message });
        }
        res.json({ mensaje: "Tipo de documento actualizado con éxito" });
    });
});

router.delete('/tipos/:id', (req, res) => {
    const db = req.app.get('db');
    const id = req.params.id;
    db.query("DELETE FROM tipos_documento WHERE id = ?", [id], (err, result) => {
        if (err) return res.status(500).json({ error: "Error al eliminar tipo de documento", detalle: err.message });
        res.json({ mensaje: "Tipo de documento eliminado con éxito" });
    });
});

module.exports = router;

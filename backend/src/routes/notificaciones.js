const express = require('express');
const router = express.Router();

// Obtener notificaciones de un usuario
router.get('/:usuario_id', (req, res) => {
    const db = req.app.get('db');
    const usuarioId = req.params.usuario_id;
    
    const sql = `
        SELECT * FROM notificaciones 
        WHERE usuario_id = ? 
        ORDER BY fecha_creacion DESC 
        LIMIT 50
    `;
    
    db.query(sql, [usuarioId], (err, results) => {
        if (err) return res.status(500).json({ error: 'Error al obtener notificaciones', detalle: err });
        res.json(results);
    });
});

// Marcar una notificación como leída
router.put('/:id/leer', (req, res) => {
    const db = req.app.get('db');
    const id = req.params.id;
    
    const sql = `UPDATE notificaciones SET leido = 1 WHERE id = ?`;
    
    db.query(sql, [id], (err, result) => {
        if (err) return res.status(500).json({ error: 'Error al actualizar', detalle: err });
        res.json({ mensaje: 'Notificación leída' });
    });
});

// Marcar todas como leídas para un usuario
router.put('/leer-todas/:usuario_id', (req, res) => {
    const db = req.app.get('db');
    const usuarioId = req.params.usuario_id;
    
    const sql = `UPDATE notificaciones SET leido = 1 WHERE usuario_id = ?`;
    
    db.query(sql, [usuarioId], (err, result) => {
        if (err) return res.status(500).json({ error: 'Error al actualizar', detalle: err });
        res.json({ mensaje: 'Todas las notificaciones leídas' });
    });
});

// Crear una notificación (para ser usado internamente o por otros sistemas)
router.post('/crear', (req, res) => {
    const db = req.app.get('db');
    const { usuario_id, titulo, mensaje, enlace } = req.body;
    
    if (!usuario_id || !titulo || !mensaje) {
        return res.status(400).json({ error: 'Faltan campos requeridos' });
    }
    
    const sql = `
        INSERT INTO notificaciones (usuario_id, titulo, mensaje, tipo) 
        VALUES (?, ?, ?, 'info')
    `;
    
    db.query(sql, [usuario_id, titulo, mensaje], (err, result) => {
        if (err) return res.status(500).json({ error: 'Error al crear notificación', detalle: err });
        res.json({ mensaje: 'Notificación creada', id: result.insertId });
    });
});

module.exports = router;

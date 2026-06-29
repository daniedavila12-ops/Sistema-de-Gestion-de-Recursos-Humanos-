const express = require('express');
const router = express.Router();

// Listar departamentos
router.get('/lista', (req, res) => {
    const db = req.app.get('db');
    const query = 'SELECT * FROM departamentos ORDER BY id DESC';
    
    db.query(query, (err, results) => {
        if (err) {
            return res.status(500).json({ error: "Error al obtener departamentos" });
        }
        res.json(results);
    });
});

// Crear nuevo departamento
router.post('/crear', (req, res) => {
    const db = req.app.get('db');
    const { nombre, descripcion, creado_por } = req.body;

    if (!nombre) {
        return res.status(400).json({ error: "El nombre es obligatorio" });
    }

    const query = 'INSERT INTO departamentos (nombre, descripcion, creado_por, modificado_por) VALUES (?, ?, ?, ?)';
    db.execute(query, [nombre, descripcion || null, creado_por || null, creado_por || null], (err, result) => {
        if (err) {
            return res.status(500).json({ error: "Error al crear departamento" });
        }

        const io = req.app.get('io');
        if (io) io.emit('nueva_notificacion');

        db.query('SELECT id FROM usuarios WHERE rol_id IN (1, 2)', (err, users) => {
            if (!err && users && users.length > 0) {
                const notifQuery = 'INSERT INTO notificaciones (usuario_id, titulo, mensaje, tipo) VALUES ?';
                const notifValues = users.map(u => [u.id, 'Nuevo Departamento', `Se ha creado el departamento: ${nombre}`, 'info']);
                db.query(notifQuery, [notifValues]);
            }
        });

        res.json({ mensaje: "Departamento creado exitosamente", id: result.insertId });
    });
});

// Editar departamento
router.put('/editar/:id', (req, res) => {
    const db = req.app.get('db');
    const { id } = req.params;
    const { nombre, descripcion, modificado_por } = req.body;

    if (!nombre) {
        return res.status(400).json({ error: "El nombre es obligatorio" });
    }

    const query = 'UPDATE departamentos SET nombre = ?, descripcion = ?, modificado_por = ? WHERE id = ?';
    db.execute(query, [nombre, descripcion || null, modificado_por || null, id], (err, result) => {
        if (err) {
            return res.status(500).json({ error: "Error al actualizar departamento" });
        }
        res.json({ mensaje: "Departamento actualizado exitosamente" });
    });
});

// Cambiar estado (Activar/Desactivar)
router.put('/estado/:id', (req, res) => {
    const db = req.app.get('db');
    const { id } = req.params;
    const { estado, modificado_por } = req.body;

    const query = 'UPDATE departamentos SET estado = ?, modificado_por = ? WHERE id = ?';
    db.execute(query, [estado, modificado_por || null, id], (err, result) => {
        if (err) {
            return res.status(500).json({ error: "Error al cambiar el estado del departamento" });
        }
        res.json({ mensaje: "Estado actualizado exitosamente" });
    });
});

// Eliminar departamento
router.delete('/eliminar/:id', (req, res) => {
    const db = req.app.get('db');
    const { id } = req.params;

    const query = 'DELETE FROM departamentos WHERE id = ?';
    db.execute(query, [id], (err, result) => {
        if (err) {
            // It might fail if there are employees assigned to this department
            return res.status(500).json({ error: "Error al eliminar el departamento. Verifica que no tenga empleados asignados." });
        }
        res.json({ mensaje: "Departamento eliminado exitosamente" });
    });
});

module.exports = router;

const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');

const v = (valor) => (valor && String(valor).trim() !== "" ? valor : null);

// Obtener todos los usuarios
router.get('/', (req, res) => {
    const db = req.app.get('db');
    const sql = `
        SELECT u.id, u.nombre, u.email, u.estado, u.rol_id, u.ultimoLogin, u.created_at, u.updated_at, r.nombre AS rol_nombre,
               (SELECT COUNT(*) FROM reportes_incidencias WHERE asignado_usuario_id = u.id AND estado = 'Pendiente') AS incidentes_pendientes
        FROM usuarios u
        LEFT JOIN roles r ON u.rol_id = r.id
        ORDER BY u.id DESC
    `;
    db.query(sql, (err, results) => {
        if (err) return res.status(500).json(err);
        res.json(results);
    });
});

// Crear un nuevo usuario
router.post('/', async (req, res) => {
    const db = req.app.get('db');
    const { nombre, email, password, rol_id } = req.body;
    
    if (!nombre || !email || !password || !rol_id) {
        return res.status(400).json({ mensaje: "Todos los campos son requeridos (nombre, email, password, rol_id)" });
    }

    try {
        const hashedPassword = await bcrypt.hash(password, 10);
        const sql = "INSERT INTO usuarios (nombre, email, password, rol_id, estado) VALUES (?, ?, ?, ?, 1)";
        
        db.query(sql, [nombre, email, hashedPassword, rol_id], (err, result) => {
            if (err) {
                if (err.code === 'ER_DUP_ENTRY') {
                    return res.status(400).json({ mensaje: "El correo electrónico ya está registrado" });
                }
                return res.status(500).json({ mensaje: "Error al crear usuario", detalle: err.sqlMessage });
            }
            res.status(200).json({ success: true, mensaje: "Usuario creado correctamente", id: result.insertId });
        });
    } catch (error) {
        res.status(500).json({ mensaje: "Error procesando la contraseña" });
    }
});

// Actualizar un usuario
router.put('/:id', async (req, res) => {
    const db = req.app.get('db');
    const { id } = req.params;
    const { nombre, email, password, rol_id, estado } = req.body;

    if (!nombre || !email || !rol_id) {
        return res.status(400).json({ mensaje: "Nombre, email y rol son requeridos" });
    }

    try {
        let sql = "";
        let params = [];

        if (password) {
            const hashedPassword = await bcrypt.hash(password, 10);
            sql = "UPDATE usuarios SET nombre = ?, email = ?, password = ?, rol_id = ?, estado = ? WHERE id = ?";
            params = [nombre, email, hashedPassword, rol_id, estado, id];
        } else {
            sql = "UPDATE usuarios SET nombre = ?, email = ?, rol_id = ?, estado = ? WHERE id = ?";
            params = [nombre, email, rol_id, estado, id];
        }

        db.query(sql, params, (err, result) => {
            if (err) {
                 if (err.code === 'ER_DUP_ENTRY') {
                    return res.status(400).json({ mensaje: "El correo electrónico ya está en uso por otro usuario" });
                }
                return res.status(500).json({ mensaje: "Error al actualizar usuario", detalle: err.sqlMessage });
            }
            res.status(200).json({ success: true, mensaje: "Usuario actualizado correctamente" });
        });
    } catch (error) {
        res.status(500).json({ mensaje: "Error procesando la contraseña" });
    }
});

// Cambiar estado de usuario (Activar/Desactivar)
router.put('/:id/estado', (req, res) => {
    const db = req.app.get('db');
    const { id } = req.params;
    const { estado } = req.body;

    const sql = "UPDATE usuarios SET estado = ? WHERE id = ?";
    db.query(sql, [estado, id], (err, result) => {
        if (err) return res.status(500).json({ mensaje: "Error al cambiar estado", detalle: err.sqlMessage });
        res.status(200).json({ success: true, mensaje: "Estado actualizado correctamente" });
    });
});

module.exports = router;
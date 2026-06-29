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

// Obtener permisos de un usuario (lista de módulos y permisos combinados)
router.get('/:id/permisos', (req, res) => {
    const db = req.app.get('db');
    const { id } = req.params; // usuario_id

    db.query("SELECT rol_id FROM usuarios WHERE id = ?", [id], (err, users) => {
        if (err) return res.status(500).json(err);
        if (users.length === 0) return res.status(404).json({ mensaje: "Usuario no encontrado" });
        
        const rol_id = users[0].rol_id;

        const sql = `
            SELECT 
                m.id AS modulo_id,
                m.nombre AS modulo_nombre,
                IFNULL(um.puedeVer, IFNULL(rm.puedeVer, 0)) AS puedeVer,
                IFNULL(um.puedeCrear, IFNULL(rm.puedeCrear, 0)) AS puedeCrear,
                IFNULL(um.puedeEditar, IFNULL(rm.puedeEditar, 0)) AS puedeEditar,
                IFNULL(um.puedeEliminar, IFNULL(rm.puedeEliminar, 0)) AS puedeEliminar
            FROM modulos m
            LEFT JOIN rol_modulo rm ON m.id = rm.modulo_id AND rm.rol_id = ?
            LEFT JOIN usuario_modulo um ON m.id = um.modulo_id AND um.usuario_id = ?
            ORDER BY m.id ASC
        `;
        
        db.query(sql, [rol_id, id], (err, results) => {
            if (err) return res.status(500).json(err);
            res.json(results);
        });
    });
});

// Actualizar o insertar permisos para un usuario
router.put('/:id/permisos', (req, res) => {
    const db = req.app.get('db');
    const usuario_id = req.params.id;
    const { permisos } = req.body; 

    if (!Array.isArray(permisos)) {
        return res.status(400).json({ mensaje: "Formato de permisos inválido" });
    }

    db.getConnection((err, connection) => {
        if (err) return res.status(500).json(err);

        connection.beginTransaction((err) => {
            if (err) {
                connection.release();
                return res.status(500).json(err);
            }

            connection.query("DELETE FROM usuario_modulo WHERE usuario_id = ?", [usuario_id], (err, result) => {
                if (err) {
                    return connection.rollback(() => {
                        connection.release();
                        res.status(500).json({ mensaje: "Error al limpiar permisos anteriores", detalle: err.sqlMessage });
                    });
                }

                if (permisos.length === 0) {
                    return connection.commit((err) => {
                        if (err) {
                            return connection.rollback(() => {
                                connection.release();
                                res.status(500).json(err);
                            });
                        }
                        connection.release();
                        return res.status(200).json({ success: true, mensaje: "Permisos individuales eliminados correctamente" });
                    });
                }

                const values = permisos.map(p => [
                    usuario_id, 
                    p.modulo_id, 
                    p.puedeVer ? 1 : 0, 
                    p.puedeCrear ? 1 : 0, 
                    p.puedeEditar ? 1 : 0, 
                    p.puedeEliminar ? 1 : 0
                ]);

                const insertSql = "INSERT INTO usuario_modulo (usuario_id, modulo_id, puedeVer, puedeCrear, puedeEditar, puedeEliminar) VALUES ?";
                
                connection.query(insertSql, [values], (err, result) => {
                    if (err) {
                        return connection.rollback(() => {
                            connection.release();
                            res.status(500).json({ mensaje: "Error al guardar nuevos permisos", detalle: err.sqlMessage });
                        });
                    }

                    connection.commit((err) => {
                        if (err) {
                            return connection.rollback(() => {
                                connection.release();
                                res.status(500).json({ mensaje: "Error al hacer commit de permisos", detalle: err.sqlMessage });
                            });
                        }
                        connection.release();
                        res.status(200).json({ success: true, mensaje: "Permisos del usuario actualizados correctamente" });
                    });
                });
            });
        });
    });
});

module.exports = router;
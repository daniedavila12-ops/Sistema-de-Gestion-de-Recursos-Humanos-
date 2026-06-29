const express = require('express');
const router = express.Router();

const v = (valor) => (valor && String(valor).trim() !== "" ? valor : null);

// Obtener todos los roles
router.get('/', (req, res) => {
    const db = req.app.get('db');
    const sql = "SELECT * FROM roles ORDER BY id ASC";
    db.query(sql, (err, results) => {
        if (err) return res.status(500).json(err);
        res.json(results);
    });
});

// Crear un nuevo rol
router.post('/', (req, res) => {
    const db = req.app.get('db');
    const { nombre } = req.body;
    
    if (!nombre) return res.status(400).json({ mensaje: "El nombre del rol es requerido" });

    const sql = "INSERT INTO roles (nombre) VALUES (?)";
    db.query(sql, [nombre], (err, result) => {
        if (err) return res.status(500).json({ mensaje: "Error al crear rol", detalle: err.sqlMessage });
        res.status(200).json({ success: true, mensaje: "Rol creado correctamente", id: result.insertId });
    });
});

// Actualizar un rol
router.put('/:id', (req, res) => {
    const db = req.app.get('db');
    const { id } = req.params;
    const { nombre } = req.body;

    if (!nombre) return res.status(400).json({ mensaje: "El nombre del rol es requerido" });

    const sql = "UPDATE roles SET nombre = ? WHERE id = ?";
    db.query(sql, [nombre, id], (err, result) => {
        if (err) return res.status(500).json({ mensaje: "Error al actualizar rol", detalle: err.sqlMessage });
        res.status(200).json({ success: true, mensaje: "Rol actualizado correctamente" });
    });
});

// Eliminar un rol (opcional, aunque puede no ser recomendable si está asignado a usuarios)
router.delete('/:id', (req, res) => {
    const db = req.app.get('db');
    const { id } = req.params;

    const sql = "DELETE FROM roles WHERE id = ?";
    db.query(sql, [id], (err, result) => {
        if (err) return res.status(500).json({ mensaje: "Error al eliminar rol", detalle: err.sqlMessage });
        res.status(200).json({ success: true, mensaje: "Rol eliminado correctamente" });
    });
});

// Obtener permisos de un rol (lista de módulos y permisos)
router.get('/:id/permisos', (req, res) => {
    const db = req.app.get('db');
    const { id } = req.params; // rol_id

    // Traemos todos los módulos y hacemos LEFT JOIN con rol_modulo para saber los permisos actuales
    const sql = `
        SELECT 
            m.id AS modulo_id,
            m.nombre AS modulo_nombre,
            IFNULL(rm.puedeVer, 0) AS puedeVer,
            IFNULL(rm.puedeCrear, 0) AS puedeCrear,
            IFNULL(rm.puedeEditar, 0) AS puedeEditar,
            IFNULL(rm.puedeEliminar, 0) AS puedeEliminar
        FROM modulos m
        LEFT JOIN rol_modulo rm ON m.id = rm.modulo_id AND rm.rol_id = ?
        ORDER BY m.id ASC
    `;
    
    db.query(sql, [id], (err, results) => {
        if (err) return res.status(500).json(err);
        res.json(results);
    });
});

// Actualizar o insertar permisos para un rol
router.put('/:id/permisos', (req, res) => {
    const db = req.app.get('db');
    const rol_id = req.params.id;
    const { permisos } = req.body; // Array de { modulo_id, puedeVer, puedeCrear, puedeEditar, puedeEliminar }

    if (!Array.isArray(permisos)) {
        return res.status(400).json({ mensaje: "Formato de permisos inválido" });
    }

    db.getConnection((err, connection) => {
        if (err) return res.status(500).json(err);

        // Usaremos transacciones para actualizar múltiples registros
        connection.beginTransaction((err) => {
            if (err) {
                connection.release();
                return res.status(500).json(err);
            }

            // Primero borramos los permisos existentes de este rol para re-insertarlos
            connection.query("DELETE FROM rol_modulo WHERE rol_id = ?", [rol_id], (err, result) => {
                if (err) {
                    return connection.rollback(() => {
                        connection.release();
                        res.status(500).json({ mensaje: "Error al limpiar permisos anteriores", detalle: err.sqlMessage });
                    });
                }

                if (permisos.length === 0) {
                    // Si enviaron array vacío, solo querían borrar todo
                    return connection.commit((err) => {
                        if (err) {
                            return connection.rollback(() => {
                                connection.release();
                                res.status(500).json(err);
                            });
                        }
                        connection.release();
                        return res.status(200).json({ success: true, mensaje: "Permisos actualizados correctamente" });
                    });
                }

                // Preparar insert múltiple
                const values = permisos.map(p => [
                    rol_id, 
                    p.modulo_id, 
                    p.puedeVer ? 1 : 0, 
                    p.puedeCrear ? 1 : 0, 
                    p.puedeEditar ? 1 : 0, 
                    p.puedeEliminar ? 1 : 0
                ]);

                const insertSql = "INSERT INTO rol_modulo (rol_id, modulo_id, puedeVer, puedeCrear, puedeEditar, puedeEliminar) VALUES ?";
                
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
                        res.status(200).json({ success: true, mensaje: "Permisos actualizados correctamente" });
                    });
                });
            });
        });
    });
});

module.exports = router;
const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');

// Configuración de Multer para guardar las fotos
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, path.join(__dirname, '../../uploads/perfiles'));
    },
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, 'empleado-' + req.params.id + '-' + uniqueSuffix + path.extname(file.originalname));
    }
});
const upload = multer({ storage: storage });

const storageContratos = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, path.join(__dirname, '../../uploads/contratos'));
    },
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, 'contrato-' + req.params.id + '-' + uniqueSuffix + path.extname(file.originalname));
    }
});
const uploadContratos = multer({ storage: storageContratos });

const v = (valor) => (valor && String(valor).trim() !== "" ? valor : null);

router.post('/crear', (req, res) => {
    const db = req.app.get('db');
    const d = req.body;

    const checkSql = "SELECT id, codigo_empleado, identidad FROM empleados WHERE codigo_empleado = ? OR identidad = ?";
    db.query(checkSql, [v(d.codigo_empleado), v(d.identidad)], (err, rows) => {
        if (err) return res.status(500).json({ mensaje: "Error verificando código o identidad", detalle: err.sqlMessage });
        
        const codigoRepetido = rows.some(r => r.codigo_empleado === v(d.codigo_empleado));
        const identidadRepetida = rows.some(r => r.identidad === v(d.identidad));

        if (codigoRepetido) {
            return res.status(400).json({ mensaje: "El código de empleado ya está en uso. Por favor, ingrese uno distinto." });
        }
        if (identidadRepetida) {
            return res.status(400).json({ mensaje: "El número de identidad ya está registrado para otro empleado." });
        }

        const sql = `INSERT INTO empleados (
            codigo_empleado, identidad, nombre, apellido, fecha_nacimiento, correo, telefono, direccion,
            tipo_contrato, fecha_inicio, ciudad, ubicacion,
            emergencia_parentesco, emergencia_nombre, emergencia_telefono,
            emergencia_parentesco_2, emergencia_nombre_2, emergencia_telefono_2, genero, departamento_id
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`;

    const values = [
        v(d.codigo_empleado), v(d.identidad), v(d.nombre), v(d.apellido), v(d.fecha_nacimiento),
        v(d.correo), v(d.telefono), v(d.direccion), v(d.tipo_contrato) || 'Permanente',
        v(d.fecha_inicio), v(d.ciudad), v(d.ubicacion),
        v(d.emergencia_parentesco), v(d.emergencia_nombre), v(d.emergencia_telefono),
        v(d.emergencia_parentesco_2), v(d.emergencia_nombre_2), v(d.emergencia_telefono_2),
        v(d.genero), v(d.departamento_id)
    ];

    db.query(sql, values, (err, result) => {
        if (err) {
            console.error('❌ Error SQL:', err);
            return res.status(500).json({ mensaje: "Error en la base de datos", detalle: err.sqlMessage });
        }

        const io = req.app.get('io');
        if (io) {
            io.emit('nueva_notificacion');
            io.emit('refresh_empleados');
        }

        db.query('SELECT id FROM usuarios WHERE rol_id IN (1, 2)', (err, users) => {
            if (!err && users && users.length > 0) {
                const notifQuery = 'INSERT INTO notificaciones (usuario_id, titulo, mensaje, tipo) VALUES ?';
                const notifValues = users.map(u => [u.id, 'Nuevo Empleado', `Se ha registrado al empleado: ${d.nombre} ${d.apellido}`, 'info']);
                db.query(notifQuery, [notifValues]);
            }
        });

        // IMPORTANTE: Devolvemos un objeto JSON claro
        res.status(200).json({ 
            success: true,
            mensaje: "Empleado guardado correctamente", 
            id: result.insertId 
        });
    });
    });
});

router.get('/validar-codigo/:codigo', (req, res) => {
    const db = req.app.get('db');
    const { codigo } = req.params;
    const sql = "SELECT id FROM empleados WHERE codigo_empleado = ?";
    db.query(sql, [codigo], (err, results) => {
        if (err) return res.status(500).json(err);
        res.json({ existe: results.length > 0 });
    });
});

router.get('/validar-identidad/:identidad', (req, res) => {
    const db = req.app.get('db');
    const { identidad } = req.params;
    const sql = "SELECT id FROM empleados WHERE identidad = ?";
    db.query(sql, [identidad], (err, results) => {
        if (err) return res.status(500).json(err);
        res.json({ existe: results.length > 0 });
    });
});

router.get('/lista', (req, res) => {
    const db = req.app.get('db');
    const sql = `
        SELECT e.*, d.nombre AS departamento_nombre 
        FROM empleados e 
        LEFT JOIN departamentos d ON e.departamento_id = d.id 
        ORDER BY e.id DESC
    `;
    db.query(sql, (err, results) => {
        if (err) return res.status(500).json(err);
        res.json(results);
    });
});

router.get('/:id', (req, res) => {
    const db = req.app.get('db');
    const { id } = req.params;
    const sql = "SELECT * FROM empleados WHERE id = ?";
    db.query(sql, [id], (err, results) => {
        if (err) return res.status(500).json(err);
        if (results.length === 0) return res.status(404).json({ mensaje: "Empleado no encontrado" });
        res.json(results[0]);
    });
});

router.put('/:id/estado', (req, res) => {
    const db = req.app.get('db');
    const { id } = req.params;
    const { estado } = req.body;
    const sql = "UPDATE empleados SET estado = ? WHERE id = ?";
    db.query(sql, [estado, id], (err, result) => {
        if (err) return res.status(500).json(err);
        const io = req.app.get('io');
        if (io) {
            io.emit('refresh_empleados');
            io.emit('refresh_empleado_detalle', id);
        }
        res.json({ mensaje: "Estado actualizado correctamente" });
    });
});

router.post('/:id/foto', upload.single('foto'), (req, res) => {
    if (!req.file) {
        return res.status(400).json({ mensaje: "No se subió ninguna imagen" });
    }
    
    const db = req.app.get('db');
    const { id } = req.params;
    const fotoUrl = `/uploads/perfiles/${req.file.filename}`;
    
    const sql = "UPDATE empleados SET foto = ? WHERE id = ?";
    db.query(sql, [fotoUrl, id], (err, result) => {
        if (err) return res.status(500).json(err);
        res.json({ mensaje: "Foto actualizada correctamente", fotoUrl });
    });
});

router.put('/:id', (req, res) => {
    const db = req.app.get('db');
    const { id } = req.params;
    const d = req.body;

    const sql = `UPDATE empleados SET 
        codigo_empleado = ?, identidad = ?, nombre = ?, apellido = ?, fecha_nacimiento = ?, 
        correo = ?, telefono = ?, direccion = ?, tipo_contrato = ?, 
        fecha_inicio = ?, ciudad = ?, ubicacion = ?, 
        emergencia_parentesco = ?, emergencia_nombre = ?, emergencia_telefono = ?,
        emergencia_parentesco_2 = ?, emergencia_nombre_2 = ?, emergencia_telefono_2 = ?,
        genero = ?, departamento_id = ?
        WHERE id = ?`;

    const values = [
        v(d.codigo_empleado), v(d.identidad), v(d.nombre), v(d.apellido), v(d.fecha_nacimiento),
        v(d.correo), v(d.telefono), v(d.direccion), v(d.tipo_contrato) || 'Permanente',
        v(d.fecha_inicio), v(d.ciudad), v(d.ubicacion),
        v(d.emergencia_parentesco), v(d.emergencia_nombre), v(d.emergencia_telefono),
        v(d.emergencia_parentesco_2), v(d.emergencia_nombre_2), v(d.emergencia_telefono_2),
        v(d.genero), v(d.departamento_id),
        id
    ];

    db.query(sql, values, (err, result) => {
        if (err) {
            console.error('❌ Error SQL:', err);
            return res.status(500).json({ mensaje: "Error en la base de datos", detalle: err.sqlMessage });
        }
        const io = req.app.get('io');
        if (io) {
            io.emit('refresh_empleados');
            io.emit('refresh_empleado_detalle', id);
        }
        res.status(200).json({ success: true, mensaje: "Empleado actualizado correctamente" });
    });
});

router.put('/:id/desactivar', (req, res) => {
    const db = req.app.get('db');
    const { id } = req.params;
    
    const sql = "UPDATE empleados SET estado = 0 WHERE id = ?";
    db.query(sql, [id], (err, result) => {
        if (err) return res.status(500).json({ mensaje: "Error al desactivar", detalle: err.sqlMessage });

        const io = req.app.get('io');
        if (io) {
            io.emit('nueva_notificacion');
            io.emit('refresh_empleados');
            io.emit('refresh_empleado_detalle', id);
        }

        db.query('SELECT id FROM usuarios WHERE rol_id IN (1, 2)', (err, users) => {
            if (!err && users && users.length > 0) {
                const notifQuery = 'INSERT INTO notificaciones (usuario_id, titulo, mensaje, tipo) VALUES ?';
                const notifValues = users.map(u => [u.id, 'Empleado Inactivo', `Se ha desactivado al empleado con ID: ${id}`, 'warning']);
                db.query(notifQuery, [notifValues]);
            }
        });

        res.json({ success: true, mensaje: "Empleado desactivado correctamente" });
    });
});

router.put('/:id/activar', (req, res) => {
    const db = req.app.get('db');
    const { id } = req.params;
    
    const sql = "UPDATE empleados SET estado = 1 WHERE id = ?";
    db.query(sql, [id], (err, result) => {
        if (err) return res.status(500).json({ mensaje: "Error al activar", detalle: err.sqlMessage });
        const io = req.app.get('io');
        if (io) {
            io.emit('refresh_empleados');
            io.emit('refresh_empleado_detalle', id);
        }
        res.json({ success: true, mensaje: "Empleado activado correctamente" });
    });
});
router.delete('/:id', (req, res) => {
    const db = req.app.get('db');
    const { id } = req.params;
    
    // Disable FK checks to allow hard delete of the employee
    db.query("SET FOREIGN_KEY_CHECKS=0;", (err) => {
        if (err) return res.status(500).json({ error: "Error de BD" });
        
        db.query("DELETE FROM empleados WHERE id = ?", [id], (err, result) => {
            db.query("SET FOREIGN_KEY_CHECKS=1;"); // Re-enable immediately
            
            if (err) return res.status(500).json({ error: "Error al eliminar el empleado", detalle: err.sqlMessage });
            if (result.affectedRows === 0) return res.status(404).json({ error: "Empleado no encontrado" });
            const io = req.app.get('io');
            if (io) io.emit('refresh_empleados');
            res.json({ success: true, mensaje: "Empleado eliminado correctamente con todas sus dependencias" });
        });
    });
});

router.get('/:id/contratos', (req, res) => {
    const db = req.app.get('db');
    const { id } = req.params;
    const sql = `
        SELECT c.*, u.nombre AS creadoPorNombre, u2.nombre AS modificadoPorNombre 
        FROM contratos c
        LEFT JOIN usuarios u ON c.creadoPor = u.id
        LEFT JOIN usuarios u2 ON c.modificadoPor = u2.id
        WHERE c.empleado_id = ? 
        ORDER BY c.fechaInicio DESC
    `;
    db.query(sql, [id], (err, results) => {
        if (err) return res.status(500).json(err);
        res.json(results);
    });
});

router.post('/:id/contratos', uploadContratos.single('archivo'), (req, res) => {
    const db = req.app.get('db');
    const { id } = req.params;
    const d = req.body;
    const creadoPor = d.creadoPor || 1; 
    const archivoUrl = req.file ? `/uploads/contratos/${req.file.filename}` : null;

    const sql = `INSERT INTO contratos (
        empleado_id, tipoContrato, estado, fechaInicio, fechaFinal, fechaSalida, observacion, creadoPor, archivo
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`;

    const values = [
        id, v(d.tipoContrato), v(d.estado), v(d.fechaInicio), v(d.fechaFinal), v(d.fechaSalida), v(d.observacion), creadoPor, archivoUrl
    ];

    db.query(sql, values, (err, result) => {
        if (err) return res.status(500).json({ mensaje: "Error al guardar contrato", detalle: err.sqlMessage });
        const io = req.app.get('io');
        if (io) io.emit('refresh_empleado_detalle', id);
        res.status(200).json({ success: true, mensaje: "Contrato registrado correctamente" });
    });
});

router.put('/:id/contratos/:contratoId', uploadContratos.single('archivo'), (req, res) => {
    const db = req.app.get('db');
    const { id, contratoId } = req.params;
    const d = req.body;
    const modificadoPor = d.modificadoPor || 1;

    let sql = `UPDATE contratos SET 
        tipoContrato = ?, estado = ?, fechaInicio = ?, fechaFinal = ?, fechaSalida = ?, observacion = ?, modificadoPor = ?`;
    
    let values = [
        v(d.tipoContrato), v(d.estado), v(d.fechaInicio), v(d.fechaFinal), v(d.fechaSalida), v(d.observacion), modificadoPor
    ];

    if (req.file) {
        sql += `, archivo = ?`;
        values.push(`/uploads/contratos/${req.file.filename}`);
    }

    sql += ` WHERE id = ? AND empleado_id = ?`;
    values.push(contratoId, id);

    db.query(sql, values, (err, result) => {
        if (err) return res.status(500).json({ mensaje: "Error al actualizar contrato", detalle: err.sqlMessage });
        const io = req.app.get('io');
        if (io) io.emit('refresh_empleado_detalle', id);
        res.status(200).json({ success: true, mensaje: "Contrato actualizado correctamente" });
    });
});

module.exports = router;;
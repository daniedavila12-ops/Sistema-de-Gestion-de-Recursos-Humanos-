const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Asegurar que exista la carpeta uploads/cv
const uploadDir = path.join(__dirname, '../../uploads/cv');
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
}

// Configuración de Multer
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, uploadDir);
    },
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, 'CV_' + uniqueSuffix + path.extname(file.originalname));
    }
});

const fileFilter = (req, file, cb) => {
    if (file.mimetype === 'application/pdf') {
        cb(null, true);
    } else {
        cb(new Error('Solo se permiten archivos PDF'), false);
    }
};

const upload = multer({ storage: storage, fileFilter: fileFilter });

const v = (valor) => (valor && String(valor).trim() !== "" ? valor : null);

// POST: Subir candidato y su CV (Ruta Pública)
router.post('/upload', (req, res) => {
    // Usamos upload.single y manejamos errores
    upload.single('cv')(req, res, (err) => {
        if (err) {
            return res.status(400).json({ error: err.message });
        }

        const db = req.app.get('db');
        const d = req.body;

        if (!req.file) {
            return res.status(400).json({ error: 'Debe adjuntar un archivo PDF (CV).' });
        }

        const cv_url = `/uploads/cv/${req.file.filename}`;
        
        const sql = `INSERT INTO candidatos (nombre_completo, correo, telefono, puesto_aplicado, cv_url) VALUES (?, ?, ?, ?, ?)`;
        const values = [v(d.nombre_completo), v(d.correo), v(d.telefono), v(d.puesto_aplicado), cv_url];

        db.query(sql, values, (dbErr, result) => {
            if (dbErr) {
                console.error('❌ Error SQL al guardar candidato:', dbErr);
                return res.status(500).json({ error: 'Ocurrió un error al guardar tu aplicación.' });
            }

            // CREAR NOTIFICACION PARA RRHH Y ADMIN (Roles 1 y 2)
            const sqlUsuarios = `SELECT id FROM usuarios WHERE rol_id IN (1, 2)`;
            db.query(sqlUsuarios, (errUsers, usuarios) => {
                if (!errUsers && usuarios.length > 0) {
                    const titulo = 'Nuevo Candidato Registrado';
                    const mensaje = `${v(d.nombre_completo)} aplicó para: ${v(d.puesto_aplicado)}.`;
                    
                    const notifValues = usuarios.map(u => [u.id, titulo, mensaje, 'candidato']);
                    const sqlInsertNotif = `INSERT INTO notificaciones (usuario_id, titulo, mensaje, tipo) VALUES ?`;
                    
                    db.query(sqlInsertNotif, [notifValues], (errNotif) => {
                        if (errNotif) console.error('Error guardando notificación:', errNotif);
                        
                        // Emitir notificación por socket.io al panel de HR
                        const io = req.app.get('io');
                        if (io) {
                            io.emit('nueva_notificacion'); 
                        }
                    });
                } else {
                    // Opcional: Emitir notificación por socket.io si no hay usuarios
                    const io = req.app.get('io');
                    if (io) {
                        io.emit('nueva_notificacion'); 
                    }
                }
            });

            res.status(201).json({
                mensaje: 'Aplicación enviada con éxito.',
                id: result.insertId
            });
        });
    });
});

// GET: Obtener lista de candidatos (Ruta Privada, se asume que usa un middleware en el app.js o se puede proteger acá)
router.get('/', (req, res) => {
    const db = req.app.get('db');
    const sql = 'SELECT * FROM candidatos ORDER BY created_at DESC';
    
    db.query(sql, (err, rows) => {
        if (err) {
            console.error('❌ Error SQL al obtener candidatos:', err);
            return res.status(500).json({ error: 'Error al obtener la lista de candidatos.' });
        }
        res.status(200).json(rows);
    });
});

// PUT: Actualizar estado del candidato (Ruta Privada)
router.put('/:id/estado', (req, res) => {
    const db = req.app.get('db');
    const { id } = req.params;
    const { estado } = req.body;
    
    if (!estado) {
        return res.status(400).json({ error: 'El estado es requerido.' });
    }

    const sql = 'UPDATE candidatos SET estado = ? WHERE id = ?';
    db.query(sql, [estado, id], (err, result) => {
        if (err) {
            console.error('❌ Error SQL al actualizar estado:', err);
            return res.status(500).json({ error: 'Error al actualizar el estado.' });
        }
        
        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Candidato no encontrado.' });
        }

        res.status(200).json({ mensaje: 'Estado actualizado correctamente.' });
    });
});

module.exports = router;

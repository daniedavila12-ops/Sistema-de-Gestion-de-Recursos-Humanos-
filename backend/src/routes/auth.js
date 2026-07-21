const express = require('express');
const router = express.Router();
const mysql = require('mysql2');
const multer = require('multer');
const path = require('path');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// Configuración de Multer para fotos de usuario
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, path.join(__dirname, '../../uploads/perfiles'));
    },
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, 'usuario-' + req.params.id + '-' + uniqueSuffix + path.extname(file.originalname));
    }
});
const upload = multer({ storage: storage });

// Conexión a la base de datos
const db = mysql.createPool({
    host: process.env.DB_HOST ?? 'sakura.proxy.rlwy.net',
    port: process.env.DB_PORT ?? 52260,
    user: process.env.DB_USER ?? 'root',
    password: process.env.DB_PASS ?? 'TsAZLfVFZkEjHvJhGZDTloumbVQdGEQh',
    database: process.env.DB_NAME ?? 'railway',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

router.post('/login', (req, res) => {
    const { email, password } = req.body;

    const sql = 'SELECT id, nombre, email, rol_id, foto, password, estado FROM usuarios WHERE email = ?';
    
    db.query(sql, [email], async (err, result) => {
        if (err) {
            console.error('❌ Error en SQL:', err.sqlMessage);
            return res.status(500).json({ 
                mensaje: "Error de base de datos",
                detalle: err.sqlMessage 
            });
        }

        if (result.length > 0) {
            const user = result[0];
            
            if (user.estado === 0) {
                return res.status(403).json({ mensaje: "El usuario está inactivo. Contacte al administrador." });
            }

            // Comparar contraseña (soporta bcrypt y texto plano antiguo)
            let passwordMatch = false;
            if (user.password.startsWith('$2a$') || user.password.startsWith('$2b$')) {
                passwordMatch = await bcrypt.compare(password, user.password);
            } else {
                passwordMatch = (password === user.password); // Texto plano antiguo
            }

            if (passwordMatch) {
                // Actualizar ultimoLogin
                db.query('UPDATE usuarios SET ultimoLogin = NOW() WHERE id = ?', [user.id]);

                // Generar token JWT
                const token = jwt.sign(
                    { id: user.id, rol: user.rol_id },
                    process.env.JWT_SECRET || 'clave_secreta_por_defecto',
                    { expiresIn: '8h' }
                );

                res.json({ 
                    mensaje: "Bienvenido", 
                    token: token,
                    usuario: {
                        id: user.id,
                        nombre: user.nombre || 'Usuario Sistema',
                        email: user.email,
                        rol: user.rol_id,
                        foto: user.foto
                    }
                });
            } else {
                res.status(401).json({ mensaje: "Correo o contraseña incorrectos" });
            }
        } else {
            res.status(401).json({ mensaje: "Correo o contraseña incorrectos" });
        }
    });
});

router.post('/cambiar-password', (req, res) => {
    const { id, actual, nueva } = req.body;
    
    if (!id || !actual || !nueva) {
        return res.status(400).json({ mensaje: "Faltan datos requeridos" });
    }

    const sqlVerificar = 'SELECT id, password FROM usuarios WHERE id = ?';
    db.query(sqlVerificar, [id], async (err, result) => {
        if (err) {
            console.error('❌ Error al verificar contraseña:', err);
            return res.status(500).json({ mensaje: "Error de base de datos" });
        }
        
        if (result.length === 0) {
            return res.status(404).json({ mensaje: "Usuario no encontrado" });
        }

        const user = result[0];
        
        // Verificar contraseña actual
        let passwordMatch = false;
        if (user.password.startsWith('$2a$') || user.password.startsWith('$2b$')) {
            passwordMatch = await bcrypt.compare(actual, user.password);
        } else {
            passwordMatch = (actual === user.password);
        }

        if (!passwordMatch) {
            return res.status(401).json({ mensaje: "La contraseña actual es incorrecta" });
        }

        // Encriptar nueva contraseña
        const hashedNueva = await bcrypt.hash(nueva, 10);
        const sqlActualizar = 'UPDATE usuarios SET password = ? WHERE id = ?';
        db.query(sqlActualizar, [hashedNueva, id], (errUpdate, resultUpdate) => {
            if (errUpdate) {
                console.error('❌ Error al actualizar contraseña:', errUpdate);
                return res.status(500).json({ mensaje: "Error al actualizar la contraseña" });
            }
            res.json({ mensaje: "Contraseña actualizada correctamente" });
        });
    });
});

router.post('/:id/foto', upload.single('foto'), (req, res) => {
    if (!req.file) {
        return res.status(400).json({ mensaje: "No se subió ninguna imagen" });
    }
    
    const { id } = req.params;
    const fotoUrl = `/uploads/perfiles/${req.file.filename}`;
    
    const sql = "UPDATE usuarios SET foto = ? WHERE id = ?";
    db.query(sql, [fotoUrl, id], (err, result) => {
        if (err) return res.status(500).json(err);
        res.json({ mensaje: "Foto actualizada correctamente", fotoUrl });
    });
});

module.exports = router;
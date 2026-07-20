const express = require('express');
const http = require('http');
const { Server } = require("socket.io");
const mysql = require('mysql2');
const cors = require('cors');
const path = require('path');
require('dotenv').config();

// Importación de rutas externas
const authRoutes = require('./routes/auth');
const ticketRoutes = require('./routes/tickets');
const empleadoRoutes = require('./routes/empleados');
const vacacionesRoutes = require('./routes/vacaciones');
const departamentosRoutes = require('./routes/departamentos');
const faltasRoutes = require('./routes/faltas');
const notasRoutes = require('./routes/notas');
const documentosRoutes = require('./routes/documentos');
const logsRoutes = require('./routes/logs');
const rolesRoutes = require('./routes/roles');
const usuariosRoutes = require('./routes/usuarios');
const bibliotecaRoutes = require('./routes/biblioteca');
const documentosLegalesRoutes = require('./routes/documentos-legales');
const categoriasLegalesRoutes = require('./routes/categorias-legales');
const reportesIncidenciaRoutes = require('./routes/reportes-incidencia');
const notificacionesRoutes = require('./routes/notificaciones');
const candidatosRoutes = require('./routes/candidatos');
const evaluacionesRoutes = require('./routes/evaluaciones');
const initCronJobs = require('./cron');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: ["http://localhost:3001", "http://localhost:3000"], // Allow frontend origins
    methods: ["GET", "POST"]
  }
});

// Make io accessible to our router
app.set('io', io);

io.on('connection', (socket) => {
  console.log('✅ Cliente conectado a Socket.IO');
  socket.on('disconnect', () => {
    console.log('❌ Cliente desconectado');
  });
});

// --- CONFIGURACIÓN DE MIDDLEWARES ---
app.use(express.json()); 

// Configuración de CORS para el puerto del Frontend (3001)
app.use(cors({
    origin: 'http://localhost:3001',
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    credentials: true
}));

app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// --- CONEXIÓN A LA BASE DE DATOS ---
const db = mysql.createPool({
    host: process.env.DB_HOST ?? 'localhost',
    port: process.env.DB_PORT ?? 3306,
    user: process.env.DB_USER ?? 'root',
    password: process.env.DB_PASS ?? '',
    database: process.env.DB_NAME ?? 'sistema_rrhh',
    multipleStatements: true,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

db.getConnection((err, connection) => {
    if (err) {
        console.error('❌ ERROR MYSQL: ', err.message);
    } else {
        console.log('✅ Base de Datos MySQL conectada (Pool)');
        connection.release();
    }
});

// Compartir la conexión con los archivos de rutas
app.set('db', db);

// Inicializar tareas programadas (cron)
initCronJobs(app);

// --- DEFINICIÓN DE RUTAS API ---

app.use('/api/auth', authRoutes);
app.use('/api/tickets', ticketRoutes);
app.use('/api/empleados', empleadoRoutes);
app.use('/api/vacaciones', vacacionesRoutes);
app.use('/api/departamentos', departamentosRoutes);
app.use('/api/faltas', faltasRoutes);
app.use('/api/notas', notasRoutes);
app.use('/api/documentos', documentosRoutes);
app.use('/api/roles', rolesRoutes);
app.use('/api/usuarios', usuariosRoutes);
app.use('/api/biblioteca', bibliotecaRoutes);
app.use('/api/documentos-legales', documentosLegalesRoutes);
app.use('/api/categorias-legales', categoriasLegalesRoutes);
app.use('/api/reportes-incidencia', reportesIncidenciaRoutes);
app.use('/api/logs', logsRoutes);
app.use('/api/notificaciones', notificacionesRoutes);
app.use('/api/candidatos', candidatosRoutes);
app.use('/api/evaluaciones', evaluacionesRoutes);

// 1. OBTENER TODOS LOS MÓDULOS
app.get('/api/modulos', (req, res) => {
    db.query('SELECT id, nombre FROM modulos ORDER BY id ASC', (err, results) => {
        if (err) return res.status(500).json(err);
        res.json(results);
    });
});

// 2. OBTENER MENÚ DINÁMICO (Rutas corregidas)
app.get('/api/menu/:rol_id', (req, res) => {
    const { rol_id } = req.params;
    const { usuario_id } = req.query;
    
    let sql = '';
    let params = [];

    if (usuario_id) {
        sql = `
            SELECT m.nombre, um.puedeVer as userPuedeVer, rm.puedeVer as rolPuedeVer
            FROM modulos m 
            LEFT JOIN rol_modulo rm ON m.id = rm.modulo_id AND rm.rol_id = ?
            LEFT JOIN usuario_modulo um ON m.id = um.modulo_id AND um.usuario_id = ?
        `;
        params = [rol_id, usuario_id];
    } else {
        // Consultar permisos activos del rol
        sql = `
            SELECT m.nombre, NULL as userPuedeVer, rm.puedeVer as rolPuedeVer
            FROM modulos m 
            LEFT JOIN rol_modulo rm ON m.id = rm.modulo_id AND rm.rol_id = ?
        `;
        params = [rol_id];
    }
    
    db.query(sql, params, (err, results) => {
        if (err) {
            console.error('Error al obtener menú:', err);
            return res.status(500).json(err);
        }
        
        const allowed = [];

        results.forEach(r => {
            if (r.userPuedeVer !== null) {
                // Configuración individual estricta
                if (r.userPuedeVer === 1) allowed.push(r.nombre);
            } else {
                // Sin configuración individual: manda rol
                if (r.rolPuedeVer === 1) allowed.push(r.nombre);
            }
        });

            const hasAccess = (moduleName) => allowed.includes(moduleName);

            // MENÚ BASE
            let menu = [
                { nombre: 'Dashboard', ruta: '/', icono: '🏠' }
            ];

            // MÓDULOS DE RECURSOS HUMANOS
            let rrhhItems = [];
            
            if (hasAccess('Empleados')) {
                rrhhItems.push({ nombre: 'Empleados', ruta: '/empleados', icono: '👥' });
            }
            if (hasAccess('+Nuevo Empleado')) {
                rrhhItems.push({ nombre: 'Nuevo Empleado', ruta: '/empleados/nuevo', icono: '👤+' });
            }
            if (hasAccess('Vacaciones')) {
                rrhhItems.push({ nombre: 'Registrar Vacaciones', ruta: '/vacaciones', icono: '🏖️' });
            }
            if (hasAccess('Reportes') || hasAccess('Módulo de Reportes')) {
                rrhhItems.push({ nombre: 'Reportes', ruta: '/reportes', icono: '📊' });
            }
            if (hasAccess('Reclutamiento')) {
                rrhhItems.push({ nombre: 'Reclutamiento', ruta: '/admin/candidatos', icono: '💼' });
            }
            if (hasAccess('Departamentos')) {
                rrhhItems.push({ nombre: 'Departamentos', ruta: '/departamentos', icono: '🏢' });
            }
            if (hasAccess('Reportes de Incidencia')) {
                rrhhItems.push({ nombre: 'Reportes de Incidencia', ruta: '/reportes-incidencia', icono: '⚠️' });
            }
            if (hasAccess('Gestión de Manuales')) {
                rrhhItems.push({ nombre: 'Gestión Manuales', ruta: '/admin/manuales', icono: '📚' });
            }
            if (hasAccess('Archivero Legal') || hasAccess('Documentos Legales')) {
                rrhhItems.push({ nombre: 'Documentos Legales', ruta: '/documentos-legales', icono: '📁' });
            }

            if (rrhhItems.length > 0) {
                menu.push({ nombre: 'RECURSOS HUMANOS', esCabecera: true });
                menu = menu.concat(rrhhItems);
            }

            // MÓDULOS DE IT
            let itItems = [];
            
            if (hasAccess('Tickets')) {
                itItems.push({ nombre: 'Tickets', ruta: '/tickets', icono: '🎫' });
            }
            if (hasAccess('Control de Usuarios') || hasAccess('Roles y Permisos') || hasAccess('Control Usuarios y Roles')) {
                itItems.push({ nombre: 'Control Usuarios y Roles', ruta: '/admin/usuarios', icono: '🔐' });
            }
            if (hasAccess('Logs de Sistema')) {
                itItems.push({ nombre: 'Logs de Sistema', ruta: '/admin/logs', icono: '📋' });
            }

            if (itItems.length > 0) {
                menu.push({ nombre: 'Departamento de IT', esCabecera: true });
                menu = menu.concat(itItems);
            }

            res.json(menu);
    });
});

app.get('/api/dashboard-permisos/:rol_id', (req, res) => {
    const { rol_id } = req.params;
    const { usuario_id } = req.query;
    
    let sql = '';
    let params = [];

    if (usuario_id) {
        sql = `
            SELECT m.nombre, um.puedeVer as userPuedeVer, rm.puedeVer as rolPuedeVer
            FROM modulos m 
            LEFT JOIN rol_modulo rm ON m.id = rm.modulo_id AND rm.rol_id = ?
            LEFT JOIN usuario_modulo um ON m.id = um.modulo_id AND um.usuario_id = ?
        `;
        params = [rol_id, usuario_id];
    } else {
        sql = `
            SELECT m.nombre, NULL as userPuedeVer, rm.puedeVer as rolPuedeVer
            FROM modulos m 
            LEFT JOIN rol_modulo rm ON m.id = rm.modulo_id AND rm.rol_id = ?
        `;
        params = [rol_id];
    }
    db.query(sql, params, (err, results) => {
        if (err) return res.status(500).json(err);
        
        const allowed = [];

        results.forEach(r => {
            if (r.userPuedeVer !== null) {
                if (r.userPuedeVer === 1) allowed.push(r.nombre);
            } else {
                if (r.rolPuedeVer === 1) allowed.push(r.nombre);
            }
        });

        // Retornar allowed
        res.json(allowed);
    });
});

app.get('/api/permisos-granulares/:rol_id', (req, res) => {
    const { rol_id } = req.params;
    const { usuario_id } = req.query;
    
    let sql = '';
    let params = [];

    if (usuario_id) {
        sql = `
            SELECT m.nombre, 
                   um.puedeVer as uVer, um.puedeCrear as uCrear, um.puedeEditar as uEditar, um.puedeEliminar as uEliminar,
                   rm.puedeVer as rVer, rm.puedeCrear as rCrear, rm.puedeEditar as rEditar, rm.puedeEliminar as rEliminar
            FROM modulos m 
            LEFT JOIN rol_modulo rm ON m.id = rm.modulo_id AND rm.rol_id = ?
            LEFT JOIN usuario_modulo um ON m.id = um.modulo_id AND um.usuario_id = ?
        `;
        params = [rol_id, usuario_id];
    } else {
        sql = `
            SELECT m.nombre, 
                   NULL as uVer, NULL as uCrear, NULL as uEditar, NULL as uEliminar,
                   rm.puedeVer as rVer, rm.puedeCrear as rCrear, rm.puedeEditar as rEditar, rm.puedeEliminar as rEliminar
            FROM modulos m 
            LEFT JOIN rol_modulo rm ON m.id = rm.modulo_id AND rm.rol_id = ?
        `;
        params = [rol_id];
    }
    
    db.query(sql, params, (err, results) => {
        if (err) return res.status(500).json(err);
        
        const permisos = {};

        results.forEach(r => {
            const v = r.uVer !== null ? r.uVer : r.rVer;
            const c = r.uCrear !== null ? r.uCrear : r.rCrear;
            const e = r.uEditar !== null ? r.uEditar : r.rEditar;
            const el = r.uEliminar !== null ? r.uEliminar : r.rEliminar;
            
            permisos[r.nombre] = {
                puedeVer: v || 0,
                puedeCrear: c || 0,
                puedeEditar: e || 0,
                puedeEliminar: el || 0
            };
        });

        res.json(permisos);
    });
});


// 2. ESTADÍSTICAS PARA LAS TARJETAS DEL DASHBOARD
app.get('/api/stats/resumen', (req, res) => {
    const { usuario_id, nombre, rol_id, fechaInicio, fechaFin } = req.query;

    let incidenciasQuery = `SELECT COUNT(*) FROM reportes_incidencias WHERE estado IN ('Pendiente', 'En Proceso')`;
    let ticketsQuery = `SELECT COUNT(*) FROM tickets WHERE estado IN ('Pendiente', 'En Proceso')`;
    let faltasQuery = `SELECT COUNT(*) FROM faltas WHERE 1=1`;

    if (fechaInicio && fechaFin) {
        const fi = db.escape(fechaInicio);
        const ff = db.escape(fechaFin);
        incidenciasQuery += ` AND fecha_creacion BETWEEN ${fi} AND ${ff}`;
        ticketsQuery += ` AND fecha_creacion BETWEEN ${fi} AND ${ff}`;
        faltasQuery += ` AND fecha BETWEEN ${fi} AND ${ff}`;
    } else {
        faltasQuery += ` AND MONTH(fecha) = MONTH(CURRENT_DATE) AND YEAR(fecha) = YEAR(CURRENT_DATE)`;
    }

    const escapedId = db.escape(usuario_id || null);
    if (String(rol_id) !== '1') {
        ticketsQuery += ` AND asignado_usuario_id = ${escapedId}`;
    }

    if (rol_id && String(rol_id) !== '1' && String(rol_id) !== '2') {
        const escapedNombre = db.escape(nombre || '');
        incidenciasQuery += ` AND (jefe_reporta = ${escapedNombre} OR asignado_usuario_id = ${escapedId})`;
    }

    const sql = `
        SELECT 
            (SELECT COUNT(*) FROM empleados) as total,
            (SELECT COUNT(*) FROM empleados WHERE estado = 1) as activos,
            (SELECT COUNT(*) FROM empleados WHERE estado = 0) as inactivos,
            (${ticketsQuery}) as tickets,
            (${incidenciasQuery}) as incidencias,
            (SELECT COUNT(*) FROM departamentos) as categorias,
            (SELECT COUNT(*) FROM empleados WHERE MONTH(fecha_nacimiento) = MONTH(CURRENT_DATE)) as cumpleaneros,
            (SELECT COUNT(*) FROM contratos c1 WHERE c1.id IN (SELECT max_id FROM (SELECT MAX(id) AS max_id FROM contratos GROUP BY empleado_id) AS sub) AND c1.fechaFinal BETWEEN CURRENT_DATE AND DATE_ADD(CURRENT_DATE, INTERVAL 30 DAY)) as vencimientos,
            (SELECT COUNT(*) FROM vacaciones WHERE CURRENT_DATE BETWEEN fechaInicio AND fechaFinal) as de_vacaciones,
            (${faltasQuery}) as faltas_mes,
            (SELECT COUNT(*) FROM documentos_legales) as doc_legales
        FROM DUAL;
    `;
    db.query(sql, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results[0]);
    });
});

app.get('/api/stats/empleados-por-departamento', (req, res) => {
    const sql = `
        SELECT d.nombre as departamento, COUNT(e.id) as cantidad
        FROM departamentos d
        LEFT JOIN empleados e ON d.id = e.departamento_id AND e.estado = 1
        GROUP BY d.id, d.nombre
        ORDER BY cantidad DESC;
    `;
    db.query(sql, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

app.get('/api/stats/dashboard-lists', (req, res) => {
    const lists = {};
    let pending = 4;
    const checkDone = (err) => {
        if (err && pending > 0) {
            pending = -1;
            return res.status(500).json({ error: err.message });
        }
        pending--;
        if (pending === 0) res.json(lists);
    };

    // 1. Cumpleañeros
    let cumplesQuery = "SELECT id, nombre, apellido, fecha_nacimiento, foto FROM empleados WHERE MONTH(fecha_nacimiento) = MONTH(CURRENT_DATE) AND estado = 1 ORDER BY DAY(fecha_nacimiento)";
    let cumplesParams = [];
    
    if (req.query.mes && !isNaN(req.query.mes)) {
        cumplesQuery = "SELECT id, nombre, apellido, fecha_nacimiento, foto FROM empleados WHERE MONTH(fecha_nacimiento) = ? AND estado = 1 ORDER BY DAY(fecha_nacimiento)";
        cumplesParams = [req.query.mes];
    }

    db.query(cumplesQuery, cumplesParams, (err, results) => {
        if (!err) lists.cumpleaneros = results;
        checkDone(err);
    });

    // 2. Vencimientos de contratos
    let vencimientosQuery = "SELECT c.id, e.id as empleado_id, e.nombre, e.apellido, e.foto, c.fechaFinal, c.tipoContrato FROM contratos c JOIN empleados e ON c.empleado_id = e.id WHERE c.id IN (SELECT max_id FROM (SELECT MAX(id) AS max_id FROM contratos GROUP BY empleado_id) AS sub) AND c.fechaFinal BETWEEN CURRENT_DATE AND DATE_ADD(CURRENT_DATE, INTERVAL 30 DAY) AND e.estado = 1 ORDER BY c.fechaFinal ASC";
    let vencimientosParams = [];

    if (req.query.mesVencimiento === 'todos') {
        vencimientosQuery = "SELECT c.id, e.id as empleado_id, e.nombre, e.apellido, e.foto, c.fechaFinal, c.tipoContrato FROM contratos c JOIN empleados e ON c.empleado_id = e.id WHERE c.id IN (SELECT max_id FROM (SELECT MAX(id) AS max_id FROM contratos GROUP BY empleado_id) AS sub) AND e.estado = 1 ORDER BY c.fechaFinal ASC";
    } else if (req.query.mesVencimiento && !isNaN(req.query.mesVencimiento)) {
        vencimientosQuery = "SELECT c.id, e.id as empleado_id, e.nombre, e.apellido, e.foto, c.fechaFinal, c.tipoContrato FROM contratos c JOIN empleados e ON c.empleado_id = e.id WHERE c.id IN (SELECT max_id FROM (SELECT MAX(id) AS max_id FROM contratos GROUP BY empleado_id) AS sub) AND MONTH(c.fechaFinal) = ? AND e.estado = 1 ORDER BY c.fechaFinal ASC";
        vencimientosParams = [req.query.mesVencimiento];
    }

    db.query(vencimientosQuery, vencimientosParams, (err, results) => {
        if (!err) lists.vencimientos = results;
        checkDone(err);
    });

    // 3. Empleados activos
    db.query("SELECT id, nombre, apellido, codigo_empleado, foto FROM empleados WHERE estado = 1 ORDER BY nombre, apellido", (err, results) => {
        if (!err) lists.activos = results;
        checkDone(err);
    });

    // 4. Empleados inactivos
    db.query("SELECT id, nombre, apellido, codigo_empleado, foto FROM empleados WHERE estado = 0 ORDER BY nombre, apellido", (err, results) => {
        if (!err) lists.inactivos = results;
        checkDone(err);
    });
});

app.get('/api/stats/ausentismo', (req, res) => {
    const sql = `
        SELECT d.nombre as departamento, 
               COUNT(e.id) as total_empleados,
               IFNULL(SUM(f.faltas_count), 0) as total_faltas
        FROM departamentos d
        LEFT JOIN empleados e ON d.id = e.departamento_id AND e.estado = 1
        LEFT JOIN (
            SELECT empleado_id, COUNT(*) as faltas_count 
            FROM faltas 
            WHERE MONTH(fecha) = MONTH(CURRENT_DATE) AND YEAR(fecha) = YEAR(CURRENT_DATE)
            GROUP BY empleado_id
        ) f ON e.id = f.empleado_id
        GROUP BY d.id, d.nombre
    `;
    db.query(sql, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        const data = results.map(row => {
            const dias_laborables_totales = row.total_empleados * 22;
            const indice = dias_laborables_totales > 0 ? ((row.total_faltas / dias_laborables_totales) * 100).toFixed(2) : 0;
            return { ...row, dias_laborables_totales, indice_ausentismo: parseFloat(indice) };
        });
        res.json(data);
    });
});

app.get('/api/stats/saldos-vacaciones', (req, res) => {
    const sql = `
        SELECT e.id as empleado_id, e.nombre, e.apellido, e.codigo_empleado, d.nombre as departamento,
               (SELECT MIN(fechaInicio) FROM contratos c WHERE c.empleado_id = e.id) as fecha_ingreso
        FROM empleados e
        LEFT JOIN departamentos d ON e.departamento_id = d.id
        WHERE e.estado = 1
    `;
    db.query(sql, (err, empResults) => {
        if (err) return res.status(500).json({ error: err.message });
        
        const sqlVacaciones = `SELECT empleado_id, tipoSolicitud, diasVacaciones, diasPagados FROM vacaciones`;
        db.query(sqlVacaciones, (err, vacResults) => {
            if (err) return res.status(500).json({ error: err.message });
            
            const today = new Date();
            const data = empResults.map(emp => {
                let diasAcumulados = 0;
                let diasGozados = 0;
                let diasPagados = 0;
                
                if (emp.fecha_ingreso) {
                    const inicio = new Date(emp.fecha_ingreso);
                    let aniosLaborados = today.getFullYear() - inicio.getFullYear();
                    const m = today.getMonth() - inicio.getMonth();
                    if (m < 0 || (m === 0 && today.getDate() < inicio.getDate())) {
                        aniosLaborados--;
                    }
                    aniosLaborados = Math.max(0, aniosLaborados);
                    
                    for (let i = 1; i <= aniosLaborados; i++) {
                        if (i >= 4) diasAcumulados += 20;
                        else if (i === 3) diasAcumulados += 15;
                        else if (i === 2) diasAcumulados += 12;
                        else if (i === 1) diasAcumulados += 10;
                    }
                }
                
                const vacs = vacResults.filter(v => v.empleado_id === emp.empleado_id);
                vacs.forEach(v => {
                    if (v.tipoSolicitud === 'Pagadas') {
                        diasPagados += parseFloat(v.diasPagados || 0);
                        diasGozados += parseFloat(v.diasVacaciones || 0);
                    } else if (v.tipoSolicitud !== 'Permiso Especial') {
                        diasGozados += parseFloat(v.diasVacaciones || 0);
                    }
                });
                
                const saldo = Math.max(0, diasAcumulados - (diasGozados + diasPagados));
                
                return {
                    empleado_id: emp.empleado_id,
                    nombre: emp.nombre + ' ' + emp.apellido,
                    codigo: emp.codigo_empleado,
                    departamento: emp.departamento,
                    fecha_ingreso: emp.fecha_ingreso,
                    dias_acumulados: diasAcumulados,
                    dias_gozados: diasGozados,
                    dias_pagados: diasPagados,
                    saldo_pendiente: saldo
                };
            });
            
            res.json(data);
        });
    });
});

app.get('/api/stats/contratos-estado', (req, res) => {
    const sql = `
        SELECT 
            SUM(CASE WHEN c.fechaFinal IS NULL OR c.fechaFinal >= DATE_ADD(CURRENT_DATE, INTERVAL 30 DAY) THEN 1 ELSE 0 END) as activos,
            SUM(CASE WHEN c.fechaFinal BETWEEN CURRENT_DATE AND DATE_ADD(CURRENT_DATE, INTERVAL 30 DAY) THEN 1 ELSE 0 END) as por_vencer,
            SUM(CASE WHEN c.fechaFinal < CURRENT_DATE THEN 1 ELSE 0 END) as vencidos
        FROM contratos c
        JOIN empleados e ON c.empleado_id = e.id
        WHERE c.id IN (SELECT MAX(id) FROM contratos GROUP BY empleado_id) AND e.estado = 1;
    `;
    db.query(sql, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results[0] || { activos: 0, por_vencer: 0, vencidos: 0 });
    });
});

app.get('/api/stats/tipos-faltas', (req, res) => {
    const { fechaInicio, fechaFin } = req.query;
    let whereClause = `WHERE MONTH(fecha) = MONTH(CURRENT_DATE) AND YEAR(fecha) = YEAR(CURRENT_DATE)`;
    
    if (fechaInicio && fechaFin) {
        whereClause = `WHERE fecha BETWEEN ${db.escape(fechaInicio)} AND ${db.escape(fechaFin)}`;
    }

    const sql = `
        SELECT 
            SUM(CASE WHEN documento IS NOT NULL OR motivo LIKE '%medic%' OR motivo LIKE '%permiso%' OR motivo LIKE '%justificad%' THEN 1 ELSE 0 END) as justificadas,
            SUM(CASE WHEN documento IS NULL AND motivo NOT LIKE '%medic%' AND motivo NOT LIKE '%permiso%' AND motivo NOT LIKE '%justificad%' THEN 1 ELSE 0 END) as injustificadas
        FROM faltas
        ${whereClause};
    `;
    db.query(sql, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results[0] || { justificadas: 0, injustificadas: 0 });
    });
});

app.get('/api/stats/tendencia-ausentismo', (req, res) => {
    const { fechaInicio, fechaFin } = req.query;
    let whereClause = `WHERE YEAR(fecha) = YEAR(CURRENT_DATE)`;
    
    if (fechaInicio && fechaFin) {
        whereClause = `WHERE fecha BETWEEN ${db.escape(fechaInicio)} AND ${db.escape(fechaFin)}`;
    }

    const sql = `
        SELECT MONTH(fecha) as mes, COUNT(*) as cantidad
        FROM faltas
        ${whereClause}
        GROUP BY MONTH(fecha)
        ORDER BY MONTH(fecha);
    `;
    db.query(sql, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

app.get('/api/stats/tendencia-tickets', (req, res) => {
    const { fechaInicio, fechaFin } = req.query;
    let whereClause = `WHERE fecha_creacion >= DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY)`;
    
    if (fechaInicio && fechaFin) {
        whereClause = `WHERE fecha_creacion BETWEEN ${db.escape(fechaInicio)} AND ${db.escape(fechaFin)}`;
    }

    const sql = `
        SELECT DATE(fecha_creacion) as fecha,
               COUNT(*) as creados,
               SUM(CASE WHEN estado = 'Resuelto' OR estado = 'Cerrado' THEN 1 ELSE 0 END) as resueltos
        FROM tickets
        ${whereClause}
        GROUP BY DATE(fecha_creacion)
        ORDER BY DATE(fecha_creacion);
    `;
    db.query(sql, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

app.get('/api/stats/empleados-detalles', (req, res) => {
    const sql = `
        SELECT 
            e.id, 
            e.nombre, 
            e.apellido, 
            e.codigo_empleado,
            e.estado,
            e.genero,
            e.fecha_nacimiento,
            d.nombre as departamento,
            (SELECT v.fechaInicio FROM vacaciones v WHERE v.empleado_id = e.id AND v.fechaFinal >= CURDATE() ORDER BY v.fechaInicio ASC LIMIT 1) as proxima_vacacion_inicio,
            (SELECT v.fechaRegreso FROM vacaciones v WHERE v.empleado_id = e.id AND v.fechaFinal >= CURDATE() ORDER BY v.fechaRegreso ASC LIMIT 1) as proxima_vacacion_fin,
            (SELECT COUNT(*) FROM faltas f WHERE f.empleado_id = e.id) as total_faltas,
            (SELECT MAX(c.fechaFinal) FROM contratos c WHERE c.empleado_id = e.id AND c.fechaFinal BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 30 DAY)) as contrato_vencimiento
        FROM empleados e
        LEFT JOIN departamentos d ON e.departamento_id = d.id
    `;
    db.query(sql, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

// 3. SISTEMA DE NOTIFICACIONES
app.get('/api/notificaciones/:usuario_id', (req, res) => {
    const { usuario_id } = req.params;
    const sql = `
        SELECT id, titulo, mensaje, leido, 
        CASE 
            WHEN TIMESTAMPDIFF(MINUTE, fecha_creacion, NOW()) < 60 THEN CONCAT('Hace ', TIMESTAMPDIFF(MINUTE, fecha_creacion, NOW()), ' min')
            WHEN TIMESTAMPDIFF(HOUR, fecha_creacion, NOW()) < 24 THEN CONCAT('Hace ', TIMESTAMPDIFF(HOUR, fecha_creacion, NOW()), ' h')
            ELSE CONCAT('Hace ', TIMESTAMPDIFF(DAY, fecha_creacion, NOW()), ' d')
        END as tiempo
        FROM notificaciones WHERE usuario_id = ? ORDER BY fecha_creacion DESC LIMIT 10
    `;
    db.query(sql, [usuario_id], (err, results) => {
        if (err) return res.status(500).json(err);
        res.json(results);
    });
});

app.put('/api/notificaciones/leer/:usuario_id', (req, res) => {
    const sql = 'UPDATE notificaciones SET leido = 1 WHERE usuario_id = ?';
    db.query(sql, [req.params.usuario_id], (err) => {
        if (err) return res.status(500).json(err);
        res.json({ mensaje: "Leídas" });
    });
});

const PORT = process.env.PORT || 3007;
server.listen(PORT, () => {
    console.log(`🚀 Servidor RRHH Innova en: http://localhost:${PORT}`);
    console.log(`🔌 Socket.IO escuchando en el mismo puerto.`);
});
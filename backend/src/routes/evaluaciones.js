const express = require('express');
const router = express.Router();

// 1. Obtener empleados por área
router.get('/area/:area', (req, res) => {
    const db = req.app.get('db');
    const { area } = req.params;

    // Normalizamos el área o usamos LIKE para coincidencias. 
    // Dependiendo de cómo estén los departamentos/áreas, podríamos mapearlo.
    // Por ahora, asumiremos que en `empleados.area` está guardado el valor.
    // Opcionalmente podemos buscar en `departamentos.nombre` si area está vacío.
    
    const sql = `
        SELECT e.id, e.nombre, e.apellido, e.identidad, e.puesto, e.area, d.nombre as departamento, e.foto
        FROM empleados e
        LEFT JOIN departamentos d ON e.departamento_id = d.id
        WHERE (e.area = ? OR d.nombre LIKE ?) AND e.estado = 1
    `;
    
    db.query(sql, [area, `%${area}%`], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

// 2. Guardar evaluación
router.post('/', (req, res) => {
    const db = req.app.get('db');
    const { empleado_id, evaluador_id, evaluador_nombre, area, respuestas, observaciones } = req.body;

    if (!empleado_id || !respuestas || respuestas.length === 0) {
        return res.status(400).json({ error: "Faltan datos obligatorios" });
    }

    // Calcular promedio
    let suma = 0;
    respuestas.forEach(r => suma += parseInt(r.calificacion));
    const promedio = (suma / respuestas.length).toFixed(2);
    const porcentaje = ((promedio / 5) * 100).toFixed(2);

    // Calcular nivel
    let nivel = "Muy Deficiente";
    if (promedio >= 4.5) nivel = "Excelente";
    else if (promedio >= 3.5) nivel = "Bueno";
    else if (promedio >= 2.5) nivel = "Regular";
    else if (promedio >= 1.5) nivel = "Deficiente";

    const sqlInsertEval = `
        INSERT INTO evaluaciones_desempeno (empleado_id, evaluador_id, evaluador_nombre, area, promedio, porcentaje, nivel, observaciones)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    `;

    db.query(sqlInsertEval, [empleado_id, evaluador_id, evaluador_nombre, area, promedio, porcentaje, nivel, observaciones], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        
        const evaluacion_id = result.insertId;
        
        // Guardar las respuestas de los criterios
        const sqlResp = `INSERT INTO evaluaciones_respuestas (evaluacion_id, criterio, calificacion) VALUES ?`;
        const values = respuestas.map(r => [evaluacion_id, r.criterio, parseInt(r.calificacion)]);
        
        db.query(sqlResp, [values], (err2) => {
            if (err2) return res.status(500).json({ error: err2.message });
            res.json({ mensaje: "Evaluación guardada exitosamente", evaluacion_id, promedio, nivel, porcentaje });
        });
    });
});

// 3. Dashboard Administrativo (Resumen Organizacional)
router.get('/dashboard', (req, res) => {
    const db = req.app.get('db');
    
    const queries = {
        total_empleados: "SELECT COUNT(*) as total FROM empleados WHERE estado = 1",
        total_evaluados: "SELECT COUNT(DISTINCT empleado_id) as total FROM evaluaciones_desempeno",
        promedio_general: "SELECT AVG(promedio) as promedio FROM evaluaciones_desempeno",
        por_area: "SELECT area, AVG(promedio) as promedio, COUNT(*) as cantidad FROM evaluaciones_desempeno GROUP BY area ORDER BY promedio DESC",
        por_nivel: "SELECT nivel, COUNT(*) as cantidad FROM evaluaciones_desempeno GROUP BY nivel",
        top_empleados: `
            SELECT e.nombre, e.apellido, e.foto, ev.area, ev.promedio, ev.nivel 
            FROM evaluaciones_desempeno ev
            JOIN empleados e ON ev.empleado_id = e.id
            ORDER BY ev.promedio DESC LIMIT 10
        `
    };

    let resultados = {};
    let pendings = Object.keys(queries).length;

    Object.keys(queries).forEach(key => {
        db.query(queries[key], (err, rows) => {
            if (err) {
                pendings = -1;
                return res.status(500).json({ error: err.message });
            }
            resultados[key] = (key === 'total_empleados' || key === 'total_evaluados' || key === 'promedio_general') ? (rows[0]?.total || rows[0]?.promedio || 0) : rows;
            pendings--;
            if (pendings === 0) {
                res.json(resultados);
            }
        });
    });
});

// 4. Informe Ejecutivo (Autogenerado con reglas simples)
router.get('/informe', (req, res) => {
    const db = req.app.get('db');
    
    const sql = `
        SELECT area, AVG(promedio) as promedio_area, COUNT(id) as total_evaluaciones 
        FROM evaluaciones_desempeno 
        GROUP BY area 
        ORDER BY promedio_area DESC
    `;
    
    db.query(sql, (err, rows) => {
        if (err) return res.status(500).json({ error: err.message });
        
        if(rows.length === 0) {
            return res.json({
                resumen: "No hay suficientes datos para generar un informe ejecutivo.",
                fortalezas: [],
                debilidades: [],
                recomendaciones: []
            });
        }
        
        const mejorArea = rows[0];
        const peorArea = rows[rows.length - 1];
        
        let fortalezas = [
            `El área de ${mejorArea.area} destaca con el mejor desempeño promedio (${Number(mejorArea.promedio_area).toFixed(2)}/5.0).`
        ];
        
        let debilidades = [];
        if (peorArea.promedio_area < 3.5) {
            debilidades.push(`El área de ${peorArea.area} presenta el menor desempeño (${Number(peorArea.promedio_area).toFixed(2)}/5.0), ubicándose por debajo de las expectativas óptimas.`);
        }
        
        let recomendaciones = [];
        if (peorArea.promedio_area < 3.5) {
            recomendaciones.push(`Diseñar un plan de capacitación intensiva y seguimiento para el área de ${peorArea.area}.`);
        }
        recomendaciones.push("Fomentar las prácticas implementadas en el área con mejor desempeño hacia las demás.");
        
        res.json({
            resumen: `Este informe se genera a partir de un total de ${rows.reduce((sum, r) => sum + r.total_evaluaciones, 0)} evaluaciones consolidadas por área.`,
            fortalezas,
            debilidades,
            recomendaciones,
            detalles: rows
        });
    });
});

module.exports = router;

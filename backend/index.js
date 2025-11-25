// IMPORTS
const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');

const app = express();
const PORT = 3000;


// MIDDLEWARE
app.use(cors());
app.use(express.json());

// CONEXIÓN A MYSQL
const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: 'MYSQLDIEGO', // <--- TU CONTRASEÑA
  database: 'edutrack'
});

db.connect((err) => {
  if (err) {
    console.error('❌ Error al conectar a la DB:', err);
  } else {
    console.log('✅ Conectado a la base de datos MySQL (EduTrack Final)');
  }
});

// ================= RUTAS PRINCIPALES =================

// 1. OBTENER GRUPOS (CLASES)
app.get('/grupos', (req, res) => {
    const sql = `
        SELECT mg.id, g.id as grupo_id, g.nombre, m.nombre as materia 
        FROM materias_grupos mg
        JOIN grupos g ON mg.grupo_id = g.id
        JOIN materias m ON mg.materia_id = m.id
        ORDER BY g.nombre ASC
    `;
    
    db.query(sql, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results); 
    });
});

// 2. OBTENER ALUMNOS DE UNA CLASE
app.get('/grupos/:clase_id/alumnos', (req, res) => {
    const { clase_id } = req.params;
    
    const sql = `
        SELECT u.id, u.nombre, u.email as correo 
        FROM usuarios u
        JOIN alumnos_grupos ag ON u.id = ag.alumno_id
        WHERE ag.grupo_id = (SELECT grupo_id FROM materias_grupos WHERE id = ?) 
        AND u.rol = 'alumno'
    `;

    db.query(sql, [clase_id], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

// 3. OBTENER CALIFICACIONES
app.get('/calificaciones', (req, res) => {
    const { alumno_id, grupo_id } = req.query; 

    const sql = `
        SELECT calificacion FROM calificaciones_finales 
        WHERE alumno_id = ? 
        AND materia_id = (SELECT materia_id FROM materias_grupos WHERE id = ?)
    `;

    db.query(sql, [alumno_id, grupo_id], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

// 4. GUARDAR CALIFICACIÓN Y NOTIFICAR
app.post('/calificaciones', (req, res) => {
    const { alumno_id, grupo_id, calificacion } = req.body; 

    if (!alumno_id || !grupo_id || calificacion === undefined) {
        return res.status(400).json({ error: 'Faltan datos' });
    }

    const findMateriaSql = 'SELECT materia_id FROM materias_grupos WHERE id = ?';
    
    db.query(findMateriaSql, [grupo_id], (err, results) => {
        if (err || results.length === 0) return res.status(500).json({ error: 'No se encontró la materia asociada' });
        
        const realMateriaId = results[0].materia_id;

        const checkSql = 'SELECT id, calificacion FROM calificaciones_finales WHERE alumno_id = ? AND materia_id = ?';
        
        db.query(checkSql, [alumno_id, realMateriaId], (err, gradeResults) => {
            if (err) return res.status(500).json({ error: err.message });

            if (gradeResults.length > 0) {
                const oldGrade = gradeResults[0].calificacion;
                const registroId = gradeResults[0].id;
                
                const updateSql = 'UPDATE calificaciones_finales SET calificacion = ?, fecha_registro = NOW() WHERE id = ?';
                
                db.query(updateSql, [calificacion, registroId], (err) => {
                    if (err) return res.status(500).json({ error: err.message });

                    if (oldGrade != calificacion) {
                        crearNotificacion(alumno_id, 'Calificación Actualizada', `Tu calificación ha cambiado de ${oldGrade} a ${calificacion}.`);
                    }
                    res.json({ message: 'Actualizado correctamente' });
                });

            } else {
                const insertSql = 'INSERT INTO calificaciones_finales (alumno_id, materia_id, calificacion, fecha_registro) VALUES (?, ?, ?, NOW())';
                
                db.query(insertSql, [alumno_id, realMateriaId, calificacion], (err, result) => {
                    if (err) return res.status(500).json({ error: err.message });

                    crearNotificacion(alumno_id, 'Nueva Calificación', `Tienes una nueva calificación: ${calificacion}.`);
                    res.json({ message: 'Guardado correctamente', id: result.insertId });
                });
            }
        });
    });
});

// 5. NOTIFICACIONES
app.get('/notificaciones/:usuario_id', (req, res) => {
    const { usuario_id } = req.params;
    const sql = 'SELECT * FROM notificaciones WHERE usuario_id = ? ORDER BY fecha DESC';
    db.query(sql, [usuario_id], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

// 6. REGISTRO
app.post('/register', (req, res) => {
    const { nombre, correo, contrasena, tipo_usuario } = req.body;
    let rol = tipo_usuario.toLowerCase();
    if (rol === 'maestro') rol = 'profesor';

    const sql = 'INSERT INTO usuarios (nombre, email, password, rol) VALUES (?, ?, ?, ?)';
    db.query(sql, [nombre, correo, contrasena, rol], (err, result) => {
        if (err) {
             if (err.code === 'ER_DUP_ENTRY') return res.status(400).json({ error: 'El correo ya está registrado' });
             return res.status(500).json({ error: err.message });
        }
        res.json({ message: 'Registrado exitosamente', id: result.insertId });
    });
});

// 7. LOGIN
app.post('/login', (req, res) => {
    const { correo, contrasena, tipo_usuario } = req.body;
    let rol = tipo_usuario.toLowerCase();
    if (rol === 'maestro') rol = 'profesor';

    const sql = 'SELECT * FROM usuarios WHERE email = ? AND password = ? AND rol = ?';
    db.query(sql, [correo, contrasena, rol], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        
        if (results.length > 0) {
            const u = results[0];
            res.json({ 
                message: 'Login OK', 
                usuario: { id: u.id, nombre: u.nombre, tipo_usuario: tipo_usuario } 
            });
        } else {
            res.status(401).json({ error: 'Credenciales incorrectas' });
        }
    });
});

// 8. BUSCAR ALUMNOS
app.get('/alumnos/buscar', (req, res) => {
    const { q } = req.query; 
    const sql = `SELECT id, nombre, email as correo FROM usuarios WHERE rol = 'alumno' AND (nombre LIKE ? OR email LIKE ?) LIMIT 5`;
    const query = `%${q}%`;
    db.query(sql, [query, query], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

// 9. AGREGAR ALUMNO A UN GRUPO
app.post('/grupos/agregar_alumno', (req, res) => {
    const { alumno_id, grupo_id } = req.body;
    if (!alumno_id || !grupo_id) return res.status(400).json({ error: 'Faltan datos' });

    const sql = `
        INSERT INTO alumnos_grupos (alumno_id, grupo_id) 
        VALUES (?, ?) 
        ON DUPLICATE KEY UPDATE grupo_id = VALUES(grupo_id), fecha_inscripcion = NOW()
    `;
    db.query(sql, [alumno_id, grupo_id], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        const accion = result.affectedRows === 1 ? 'inscrito' : 'movido';
        res.json({ message: `Alumno ${accion} correctamente al grupo` });
    });
});

// 10. OBTENER GRUPOS FISICOS
app.get('/grupos_disponibles', (req, res) => {
    const sql = 'SELECT id, nombre FROM grupos ORDER BY nombre';
    db.query(sql, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

// 11. CREAR MATERIA
app.post('/clases/crear', (req, res) => {
    const { grupo_id, nombre_materia } = req.body;
    if (!grupo_id || !nombre_materia) return res.status(400).json({ error: 'Faltan datos' });

    const buscarMateriaSql = 'SELECT id FROM materias WHERE nombre = ?';
    db.query(buscarMateriaSql, [nombre_materia], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });

        let materiaId;

        const crearRelacion = (mId) => {
            const insertClaseSql = 'INSERT INTO materias_grupos (grupo_id, materia_id) VALUES (?, ?)';
            db.query(insertClaseSql, [grupo_id, mId], (err, result) => {
                if (err) return res.status(500).json({ error: 'Error creando la clase (quizá ya existe)' });
                res.json({ message: 'Clase creada exitosamente', id: result.insertId });
            });
        };

        if (results.length > 0) {
            materiaId = results[0].id;
            crearRelacion(materiaId);
        } else {
            const crearMateriaSql = 'INSERT INTO materias (nombre, codigo) VALUES (?, ?)';
            const codigo = nombre_materia.substring(0,3).toUpperCase() + Math.floor(Math.random() * 1000);
            db.query(crearMateriaSql, [nombre_materia, codigo], (err, result) => {
                if (err) return res.status(500).json({ error: err.message });
                materiaId = result.insertId;
                crearRelacion(materiaId);
            });
        }
    });
});

// 12. ELIMINAR ALUMNO
app.post('/grupos/eliminar_alumno', (req, res) => {
    const { alumno_id, grupo_id } = req.body;
    if (!alumno_id || !grupo_id) return res.status(400).json({ error: 'Faltan datos' });

    const sql = 'DELETE FROM alumnos_grupos WHERE alumno_id = ? AND grupo_id = ?';
    db.query(sql, [alumno_id, grupo_id], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ message: 'Alumno eliminado del grupo' });
    });
});

// 13. VERIFICAR GRUPO DE ALUMNO (AJUSTADA Y CORREGIDA)
app.get('/alumnos/:id/grupo', (req, res) => {
    const { id } = req.params;
    const sql = `
        SELECT g.id, g.nombre
        FROM alumnos_grupos ag
        JOIN grupos g ON ag.grupo_id = g.id
        WHERE ag.alumno_id = ?
    `;
    
    db.query(sql, [id], (err, results) => {
        if (err) {
            console.error("Error en ruta /alumnos/:id/grupo:", err);
            return res.status(500).json({ error: 'Error interno de la base de datos' }); 
        }

        if (results.length > 0) {
            res.json({ 
                enrolled: true, 
                group_id: results[0].id, 
                group_name: results[0].nombre 
            });
        } else {
            res.json({ enrolled: false });
        }
    });
});

// 14. OBTENER ESTADÍSTICAS DEL PROFESOR (VERSIÓN FINAL)
app.get('/profesor/:id/stats', (req, res) => {
    const { id } = req.params;
    
    // Contar grupos (clases)
    const sqlGroups = `
        SELECT COUNT(DISTINCT mg.grupo_id) as total_grupos
        FROM materias_grupos mg
        JOIN profesores_materias pm ON mg.materia_id = pm.materia_id
        WHERE pm.profesor_id = ?;
    `;
    
    // Contar alumnos
    const sqlAlumnos = `
        SELECT COUNT(DISTINCT ag.alumno_id) AS total_alumnos
        FROM alumnos_grupos ag
        JOIN materias_grupos mg ON ag.grupo_id = mg.grupo_id
        JOIN profesores_materias pm ON mg.materia_id = pm.materia_id
        WHERE pm.profesor_id = ?;
    `;

    // Ejecutar ambas consultas
    db.query(sqlGroups, [id], (errGroups, resGroups) => {
        if (errGroups) return res.status(500).json({ error: errGroups.message });

        db.query(sqlAlumnos, [id], (errAlumnos, resAlumnos) => {
            if (errAlumnos) return res.status(500).json({ error: errAlumnos.message });
            
            res.json({
                grupos: resGroups[0].total_grupos,
                alumnos: resAlumnos[0].total_alumnos
            });
        });
    });
});


function crearNotificacion(uid, titulo, mensaje) {
    const sql = 'INSERT INTO notificaciones (usuario_id, titulo, mensaje, fecha) VALUES (?, ?, ?, NOW())';
    db.query(sql, [uid, titulo, mensaje], (err) => {
        if (err) console.error("Error creando notificación:", err);
    });
}


// ... (Tus otros endpoints) ...

// 15. OBTENER DASHBOARD DEL ALUMNO (Endpoint faltante)
app.get('/dashboard/:id', (req, res) => {
    const { id } = req.params;

    // 1. Obtener datos del alumno
    const sqlAlumno = 'SELECT nombre, email FROM usuarios WHERE id = ? AND rol = "alumno"';
    
    // 2. Obtener materias y calificaciones
    // Hacemos JOIN para ver qué grupo tiene el alumno, qué materias tiene ese grupo, 
    // y si ya tiene calificación en esas materias.
    const sqlMaterias = `
        SELECT m.nombre as materia, cf.calificacion 
        FROM alumnos_grupos ag
        JOIN materias_grupos mg ON ag.grupo_id = mg.grupo_id
        JOIN materias m ON mg.materia_id = m.id
        LEFT JOIN calificaciones_finales cf ON cf.materia_id = mg.materia_id AND cf.alumno_id = ag.alumno_id
        WHERE ag.alumno_id = ?
    `;

    db.query(sqlAlumno, [id], (err, userResults) => {
        if (err) return res.status(500).json({ error: err.message });
        if (userResults.length === 0) return res.status(404).json({ error: 'Alumno no encontrado' });

        const alumno = userResults[0];

        db.query(sqlMaterias, [id], (err, matResults) => {
            if (err) return res.status(500).json({ error: err.message });

            let totalCalificaciones = 0;
            let countCalificadas = 0;
            
            // Procesar materias para el formato que pide Flutter
            const subjects = matResults.map(row => {
                let estado = 'Pendiente';
                let calif = null;

                if (row.calificacion !== null) {
                    calif = parseFloat(row.calificacion);
                    totalCalificaciones += calif;
                    countCalificadas++;
                    estado = calif >= 7.0 ? 'Aprobada' : 'Reprobada';
                }

                return {
                    materia: row.materia,
                    calificacion: calif,
                    estado: estado
                };
            });

            // Calcular promedio (si no tiene calificaciones, es 0)
            const average = countCalificadas > 0 ? (totalCalificaciones / countCalificadas) : 0.0;

            // Enviar respuesta con la estructura que espera tu modelo en Dart
            res.json({
                average: parseFloat(average.toFixed(1)), // Redondear a 1 decimal
                student: {
                    nombre: alumno.nombre,
                    carrera: 'Ingeniería de Software', // Dato estático o agrégalo a tu DB si existe
                    matricula: id.toString() // Usamos el ID como matrícula por ahora
                },
                subjects: subjects
            });
        });
    });
});


// 16. GUARDAR REPORTE DE SOPORTE (¡NUEVO!)
app.post('/reportes_soporte', (req, res) => {
    // OJO: El frontend enviará 'mensaje', y la DB espera 'mensaje'.
    const { usuario_id, email, mensaje } = req.body;

    if (!usuario_id || !email || !mensaje) {
        return res.status(400).json({ error: 'Faltan datos (usuario_id, email, mensaje)' });
    }

    // Corregido: La columna en la DB es 'mensaje', no 'message'
    const insertSql = 'INSERT INTO reportes_soporte (usuario_id, email, mensaje) VALUES (?, ?, ?)';
    
    db.query(insertSql, [usuario_id, email, mensaje], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ message: 'Reporte guardado correctamente', id: result.insertId });
    });
});

app.get('/historial_academico/:alumnoId', (req, res) => {
    const { alumnoId } = req.params;

    const sql = `
        SELECT
            m.nombre AS nombre,
            cf.calificacion AS calificacion,
            g.nombre AS grupo_nombre,
            u.nombre AS profesor 
        FROM calificaciones_finales cf
        JOIN materias m ON cf.materia_id = m.id
        JOIN materias_grupos mg ON m.id = mg.materia_id
        JOIN grupos g ON mg.grupo_id = g.id
        LEFT JOIN alumnos_grupos ag ON ag.grupo_id = g.id AND ag.alumno_id = cf.alumno_id
        LEFT JOIN usuarios u ON u.rol = 'profesor'
        WHERE cf.alumno_id = ?
        ORDER BY g.nombre, m.nombre
    `;
    
    db.query(sql, [alumnoId], (err, results) => {
        if (err) {
            console.error('Error en la consulta de historial:', err);
            return res.status(500).json({ error: 'Error al consultar historial: ' + err.message });
        }
        
        // PROCESAMIENTO DE DATOS: Agrupar por el Nombre del Grupo (que simula el semestre)
        const semestresAgrupados = {};

        results.forEach(row => {
            const semestre = row.grupo_nombre || 'Sin Grupo Asignado';
            
            if (!semestresAgrupados[semestre]) {
                semestresAgrupados[semestre] = [];
            }
            
            const calificacion = row.calificacion !== null ? Number(row.calificacion) : null;
            
            semestresAgrupados[semestre].push({
                nombre: row.nombre,
                profesor: row.profesor || 'Profesor Desconocido', 
                semestre: semestre,
                evaluaciones: [
                    { 
                        nombre: 'Final', 
                        peso: 100.0, 
                        calificacion: calificacion || 0.0 
                    }
                ]
            });
        });

        res.json({ semestres: semestresAgrupados });
    });
});



// INICIAR SERVIDOR
app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Servidor corriendo en http://192.168.0.5:${PORT}`);
});
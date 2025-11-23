// IMPORTS
const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');

const app = express();
const PORT = 3000;

// MIDDLEWARE
app.use(cors()); // Soluciona el error de conexión con Flutter Web
app.use(express.json());

// CONEXIÓN A MYSQL
const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: 'Saul2006', // Tu contraseña
  database: 'edutrack'
});

db.connect((err) => {
  if (err) {
    console.error('❌ Error al conectar a la DB:', err);
  } else {
    console.log('✅ Conectado a la base de datos MySQL (EduTrack)');
  }
});

// ================= RUTAS =================

// 1. OBTENER GRUPOS (Para el menú desplegable "Selecciona el grupo")
app.get('/grupos', (req, res) => {
    const sql = 'SELECT * FROM grupos';
    db.query(sql, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

// 2. OBTENER ALUMNOS DE UN GRUPO ESPECÍFICO
// Esta es la consulta clave para tu pantalla principal.
// Une las tablas: usuarios -> alumnos_grupos -> grupos
app.get('/grupos/:grupo_id/alumnos', (req, res) => {
    const { grupo_id } = req.params;
    
    const sql = `
        SELECT u.id, u.nombre, u.correo 
        FROM usuarios u
        JOIN alumnos_grupos ag ON u.id = ag.alumno_id
        WHERE ag.grupo_id = ? AND u.tipo_usuario = 'Alumno'
    `;

    db.query(sql, [grupo_id], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

// 3. OBTENER CALIFICACIONES (Por grupo y alumno)
app.get('/calificaciones', (req, res) => {
    const { alumno_id, grupo_id } = req.query; // Se reciben como ?alumno_id=X&grupo_id=Y

    let sql = 'SELECT * FROM calificaciones WHERE 1=1';
    const params = [];

    if (alumno_id) {
        sql += ' AND alumno_id = ?';
        params.push(alumno_id);
    }
    if (grupo_id) {
        sql += ' AND grupo_id = ?';
        params.push(grupo_id);
    }

    db.query(sql, params, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

// 4. GUARDAR O ACTUALIZAR CALIFICACIÓN
app.post('/calificaciones', (req, res) => {
    const { alumno_id, grupo_id, calificacion } = req.body;

    if (!alumno_id || !grupo_id || calificacion === undefined) {
        return res.status(400).json({ error: 'Faltan datos (alumno_id, grupo_id, calificacion)' });
    }

    // IMPORTANTE: Primero revisamos si ya existe una calificación para ese alumno en ese grupo
    const checkSql = 'SELECT id FROM calificaciones WHERE alumno_id = ? AND grupo_id = ?';
    
    db.query(checkSql, [alumno_id, grupo_id], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });

        if (results.length > 0) {
            // SI YA EXISTE -> ACTUALIZAMOS (UPDATE)
            const updateSql = 'UPDATE calificaciones SET calificacion = ?, fecha = NOW() WHERE id = ?';
            db.query(updateSql, [calificacion, results[0].id], (err, result) => {
                if (err) return res.status(500).json({ error: err.message });
                res.json({ message: 'Calificación actualizada', id: results[0].id });
            });
        } else {
            // SI NO EXISTE -> CREAMOS (INSERT)
            const insertSql = 'INSERT INTO calificaciones (alumno_id, grupo_id, calificacion, fecha) VALUES (?, ?, ?, NOW())';
            db.query(insertSql, [alumno_id, grupo_id, calificacion], (err, result) => {
                if (err) return res.status(500).json({ error: err.message });
                res.json({ message: 'Calificación guardada', id: result.insertId });
            });
        }
    });
});

// INICIAR SERVIDOR
app.listen(PORT, () => {
  console.log(`🚀 Servidor corriendo en http://localhost:${PORT}`);
});
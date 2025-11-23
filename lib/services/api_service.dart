import 'dart:convert';
import 'package:http/http.dart' as http;

// ==========================================
// SERVICIO API
// ==========================================
class ApiService {
  // Ajusta si es emulador (10.0.2.2) o Web (localhost)
  static const String baseUrl = 'http://localhost:3000';

  // 1. Obtener Grupos
  static Future<List<Grupo>> getGrupos() async {
    final response = await http.get(Uri.parse('$baseUrl/grupos'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map((item) => Grupo.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Error al cargar grupos');
    }
  }

  // 2. Obtener Alumnos
  static Future<List<Alumno>> getAlumnosPorGrupo(int grupoId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/grupos/$grupoId/alumnos'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map((item) => Alumno.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Error al cargar alumnos');
    }
  }

  // 3. Obtener Calificación
  static Future<String?> getCalificacion(int alumnoId, int grupoId) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/calificaciones?alumno_id=$alumnoId&grupo_id=$grupoId',
      ),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        return data[0]['calificacion'].toString();
      }
      return null;
    } else {
      throw Exception('Error al obtener calificación');
    }
  }

  // 4. Guardar Calificación
  static Future<void> guardarCalificacion(
    int alumnoId,
    int grupoId,
    double calificacion,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/calificaciones'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'alumno_id': alumnoId,
        'grupo_id': grupoId,
        'calificacion': calificacion,
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Error al guardar: ${response.body}');
    }
  }
}

// ==========================================
// MODELOS
// ==========================================

class Grupo {
  final int id;
  final String nombre;
  final String materia;

  Grupo({required this.id, required this.nombre, required this.materia});

  factory Grupo.fromJson(Map<String, dynamic> json) {
    return Grupo(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      materia: json['materia'] ?? '',
    );
  }
}

class Alumno {
  final int id;
  final String nombre;
  final String correo;

  Alumno({required this.id, required this.nombre, required this.correo});

  factory Alumno.fromJson(Map<String, dynamic> json) {
    return Alumno(
      id: json['id'],
      nombre: json['nombre'] ?? 'Sin nombre',
      correo: json['correo'] ?? 'Sin correo',
    );
  }
}

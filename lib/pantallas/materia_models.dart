import 'dart:math';

// -----------------------------------------------------------------
// 1. MODELOS DE DATOS
// -----------------------------------------------------------------

// Modelo de la Evaluación (la nota que sube el maestro)
class Evaluacion {
  final String nombre; // Ej: "Examen Parcial 1", "Tarea Unidad 2"
  final double peso; // Peso en porcentaje (ej: 30.0 para 30%)
  final double calificacion; // Nota real (0.0 - 10.0)

  Evaluacion({
    required this.nombre,
    required this.peso,
    required this.calificacion,
  });

  // Cálculo: Contribución al total
  double get contribucion => (calificacion * peso) / 100.0;

  // Factory desde JSON
  factory Evaluacion.fromJson(Map<String, dynamic> json) {
    return Evaluacion(
      nombre: json['nombre'] ?? 'Sin nombre',
      peso: (json['peso'] as num?)?.toDouble() ?? 0.0,
      calificacion: (json['calificacion'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    "nombre": nombre,
    "peso": peso,
    "calificacion": calificacion,
  };
}

// -----------------------------------------------------------------
// Modelo de la Materia
// -----------------------------------------------------------------

class Materia {
  final String nombre;
  final String profesor;
  final String semestre;
  final List<Evaluacion> evaluaciones;

  Materia({
    required this.nombre,
    required this.profesor,
    required this.semestre,
    required this.evaluaciones,
  });

  // Calcular calificación final
  double get calificacionFinal {
    if (evaluaciones.isEmpty) return 0.0;

    double total = evaluaciones.fold(0.0, (sum, e) => sum + e.contribucion);

    return min(total, 10.0); // nunca excede 10
  }

  // Estatus
  String get estatus {
    if (evaluaciones.isEmpty) return 'En Curso';
    if (calificacionFinal < 7.0) return 'Reprobada';
    return 'Aprobada';
  }

  // ---------------------------------------------------------------
  // FACTORY: Desde backend JSON real
  // ---------------------------------------------------------------
  factory Materia.fromBackendJson(Map<String, dynamic> json) {
    return Materia(
      nombre: json['nombre'] ?? 'Sin nombre',
      profesor: json['profesor'] ?? 'Sin profesor',
      semestre: json['semestre']?.toString() ?? 'Sin semestre',
      evaluaciones: (json['evaluaciones'] as List<dynamic>? ?? [])
          .map((e) => Evaluacion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // ---------------------------------------------------------------
  // FACTORY: Desde JSON local o frontend
  // ---------------------------------------------------------------
  factory Materia.fromJson(Map<String, dynamic> json) {
    return Materia(
      nombre: json['nombre'] ?? 'Sin nombre',
      profesor: json['profesor'] ?? 'Sin profesor',
      semestre: json['semestre']?.toString() ?? 'Sin semestre',
      evaluaciones: (json['evaluaciones'] as List<dynamic>? ?? [])
          .map((e) => Evaluacion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // ---------------------------------------------------------------
  // Convertir a JSON
  // ---------------------------------------------------------------
  Map<String, dynamic> toJson() => {
    "nombre": nombre,
    "profesor": profesor,
    "semestre": semestre,
    "evaluaciones": evaluaciones.map((e) => e.toJson()).toList(),
  };
}

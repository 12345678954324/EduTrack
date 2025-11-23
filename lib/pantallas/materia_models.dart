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
}

// Modelo de la Materia
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

  // Método para calcular la Calificación Final
  double get calificacionFinal {
    if (evaluaciones.isEmpty) return 0.0;

    double sumaContribuciones = evaluaciones.fold(
      0.0,
      (sum, item) => sum + item.contribucion,
    );
    // Usamos min para asegurar que la nota final no exceda 10.0
    return min(sumaContribuciones, 10.0);
  }

  // Determina el estatus de la materia
  String get estatus {
    if (evaluaciones.isEmpty) return 'En Curso';
    if (calificacionFinal < 7.0) return 'Reprobada';
    return 'Aprobada';
  }
}

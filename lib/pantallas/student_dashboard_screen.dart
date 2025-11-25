import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../services/api_service.dart'; // Asegúrate de que esta ruta coincida con tu estructura de carpetas

class StudentDashboardScreen extends StatefulWidget {
  final int userId; // ID requerido para cargar datos del alumno específico

  const StudentDashboardScreen({super.key, required this.userId});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  // Usamos el modelo DashboardData del ApiService
  DashboardData? dashboardData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAcademicData();
  }

  // Carga datos reales desde la API usando el userId recibido
  void _loadAcademicData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Llamada al servicio con el ID dinámico
      DashboardData data = await ApiService.getStudentDashboard(widget.userId);
      if (mounted) {
        setState(() {
          dashboardData = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Error: $e';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ❌ SIN AppBar (lo maneja MainLayout si usas navegación anidada)
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF673AB7)),
            )
          : errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 50),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _loadAcademicData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF673AB7),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Reintentar"),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: AverageCircleWidget(
                        average: dashboardData!.average,
                      ),
                    ),
                    const SizedBox(height: 20),
                    AcademicDetailsSection(data: dashboardData!),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}

// ==========================================
// WIDGET: Círculo del Promedio
// ==========================================
class AverageCircleWidget extends StatelessWidget {
  final double average;
  const AverageCircleWidget({super.key, required this.average});

  @override
  Widget build(BuildContext context) {
    // Calculamos el porcentaje (0.0 a 1.0)
    final double percent = (average / 10.0).clamp(0.0, 1.0);
    String ratingText;
    Color progressColor;

    if (average >= 9.1) {
      ratingText = 'Excelente';
      progressColor = const Color(0xFF4CAF50); // Verde
    } else if (average >= 8.1) {
      ratingText = 'Muy Bien';
      progressColor = const Color(0xFF2196F3); // Azul
    } else if (average >= 7.0) {
      ratingText = 'Bien';
      progressColor = const Color(0xFFFFC107); // Ámbar
    } else {
      ratingText = 'Reprobatoria';
      progressColor = const Color(0xFFF44336); // Rojo
    }

    return CircularPercentIndicator(
      radius: 100.0,
      lineWidth: 15.0,
      percent: percent,
      progressColor: progressColor,
      backgroundColor: const Color(0xFFF0F0F5),
      circularStrokeCap: CircularStrokeCap.round,
      animation: true,
      animationDuration: 1000,
      center: Container(
        width: 170,
        height: 170,
        decoration: const BoxDecoration(
          color: Color(0xFF673AB7),
          shape: BoxShape.circle,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              average.toStringAsFixed(1),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 50,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Text(
              'Promedio general',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                ratingText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// WIDGET: Detalles Académicos y Lista de Materias
// ==========================================
class AcademicDetailsSection extends StatelessWidget {
  final DashboardData data;
  const AcademicDetailsSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Detalles académicos',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            height: 3,
          ),
        ),

        _buildDetailRow(Icons.person, 'Alumno: ${data.student.nombre}'),
        const SizedBox(height: 10),
        _buildDetailRow(Icons.menu_book, 'Carrera: ${data.student.carrera}'),
        const SizedBox(height: 10),
        _buildDetailRow(
          Icons.assignment_ind_outlined,
          'ID: ${data.student.matricula}',
        ),

        const SizedBox(height: 25),

        const Text(
          'Materias Activas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
            height: 2,
          ),
        ),
        const SizedBox(height: 10),

        if (data.subjects.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              "No tienes materias activas asignadas.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          )
        else
          ...data.subjects.map((s) => _buildSubjectItem(s)),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: <Widget>[
        Icon(icon, color: const Color(0xFF673AB7), size: 28),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectItem(Subject subject) {
    String info = subject.estado;
    Color colorInfo;

    // Lógica de colores para el estado
    if (subject.estado == 'Aprobada') {
      colorInfo = Colors.green;
    } else if (subject.estado == 'Reprobada') {
      colorInfo = Colors.red;
    } else {
      colorInfo = Colors.orange; // Color para pendientes/cursando
    }

    String displayText = subject.materia;
    if (subject.calificacion != null) {
      displayText += ' (${subject.calificacion})';
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                displayText,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorInfo.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorInfo.withOpacity(0.5)),
              ),
              child: Text(
                info,
                style: TextStyle(
                  color: colorInfo,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

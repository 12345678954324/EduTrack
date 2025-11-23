import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'dart:async';

// ------------------------------------------------------------------
// 1. FUNCIÓN SIMULADA DE BASE DE DATOS
// ------------------------------------------------------------------
Future<double> fetchAverageFromDatabase() async {
  await Future.delayed(const Duration(seconds: 2));
  return 7.0; // Puedes cambiar el promedio para probar
}

// ------------------------------------------------------------------
// 2. STUDENTDASHBOARDSCREEN (Tu pantalla principal)
// ------------------------------------------------------------------
class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  double currentAverage = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAcademicData();
  }

  void _loadAcademicData() async {
    setState(() {
      isLoading = true;
    });

    double fetchedAverage = await fetchAverageFromDatabase();

    if (mounted) {
      setState(() {
        currentAverage = fetchedAverage;
        isLoading = false;
      });
    }
  }

  void _navigateToHistorial(BuildContext context) {
    print('Navegando a Historial Académico...');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: null, // <--- quita menú lateral
      endDrawer: null, // <--- quita icono de perfil automático
      // ------------------------------------------------------------------
      // BOTÓN inferior
      // ------------------------------------------------------------------
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: () => _navigateToHistorial(context),
          icon: const Icon(Icons.school, color: Colors.white),
          label: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Text(
              'VER CALIFICACIONES',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF673AB7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            elevation: 0,
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      ),

      // ------------------------------------------------------------------
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: isLoading
                    ? const SizedBox(
                        height: 200,
                        width: 200,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF673AB7),
                            strokeWidth: 8.0,
                          ),
                        ),
                      )
                    : AverageCircleWidget(average: currentAverage),
              ),

              const SizedBox(height: 20),
              const AcademicDetailsSection(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------
// 3. WIDGET DEL CÍRCULO
// ------------------------------------------------------------------
class AverageCircleWidget extends StatelessWidget {
  final double average;

  const AverageCircleWidget({super.key, required this.average});

  @override
  Widget build(BuildContext context) {
    final double percent = average / 10.0;

    String ratingText;
    Color progressColor;

    if (average >= 9.1) {
      ratingText = 'Excelente';
      progressColor = const Color(0xFF4CAF50);
    } else if (average >= 8.1) {
      ratingText = 'Muy Bien';
      progressColor = const Color(0xFF2196F3);
    } else if (average >= 7.0) {
      ratingText = 'Bien';
      progressColor = const Color(0xFFFFC107);
    } else {
      ratingText = 'Reprobatoria';
      progressColor = const Color(0xFFF44336);
    }

    return Center(
      child: CircularPercentIndicator(
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: Colors.black26,
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
      ),
    );
  }
}

// ------------------------------------------------------------------
// 4. SECCIÓN DE DETALLES
// ------------------------------------------------------------------
class AcademicDetailsSection extends StatelessWidget {
  const AcademicDetailsSection({super.key});

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

        _buildDetailRow(Icons.menu_book, 'Carrera: Ingeniería de Software'),
        const SizedBox(height: 10),

        _buildDetailRow(Icons.assignment_ind_outlined, 'Matrícula: 20230045'),
        const SizedBox(height: 10),

        _buildDetailRow(
          Icons.calendar_month,
          'Próximo Evento: Examen Final - 20 Nov.',
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

        _buildSubjectItem('Desarrollo Móvil (Próxima entrega)'),
        _buildSubjectItem('Álgebra Lineal (Reprobada - 6.5)'),
        _buildSubjectItem('Estructuras de Datos (Aprobada - 8.9)'),
        _buildSubjectItem('Lógica Digital'),
        _buildSubjectItem('Cálculo Integral'),
        _buildSubjectItem('Fundamentos de Economía'),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: <Widget>[
        Icon(icon, color: Colors.deepPurple, size: 28),
        const SizedBox(width: 15),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectItem(String subjectName) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Text(
        subjectName,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
    );
  }
}

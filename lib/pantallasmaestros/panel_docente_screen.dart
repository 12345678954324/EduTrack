import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class PanelDocenteScreen extends StatefulWidget {
  const PanelDocenteScreen({super.key});

  @override
  State<PanelDocenteScreen> createState() => _PanelDocenteScreenState();
}

class _PanelDocenteScreenState extends State<PanelDocenteScreen> {
  // Variables de estado
  int _profesorId = 0;
  String _nombreProfesor = "Profesor";

  // Datos Dinámicos
  String _claseEnCurso = "Cargando...";
  String _subClaseEnCurso = "";
  int _totalGrupos = 0;
  int _totalAlumnos = 0;
  bool _isLoading = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }

  Future<void> _cargarDatosIniciales() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('saved_id') ?? 0;
    final nombre = prefs.getString('saved_name') ?? "Profesor";

    setState(() {
      _profesorId = id;
      _nombreProfesor = nombre.split(' ')[0]; // Usamos solo el primer nombre
    });

    if (id != 0) {
      await _cargarEstadisticas(id);
    } else {
      // Si no hay ID (no logueado), mostramos error
      setState(() {
        _isLoading = false;
        _errorMsg = "Error: No se encontró ID de usuario logueado.";
      });
    }
  }

  Future<void> _cargarEstadisticas(int profesorId) async {
    try {
      // Cargamos stats generales (grupos/alumnos)
      final stats = await ApiService.getProfesorStats(profesorId);

      // Cargamos la lista de grupos asignados para simular la clase en curso
      final gruposAsignados = await ApiService.getGrupos();

      if (mounted) {
        setState(() {
          _totalGrupos = stats['grupos'] ?? 0;
          _totalAlumnos = stats['alumnos'] ?? 0;
          _isLoading = false;

          // Simulación de "Clase en Curso" (usamos la primera de la lista como ejemplo)
          if (gruposAsignados.isNotEmpty) {
            final primeraClase = gruposAsignados.first;
            _claseEnCurso = primeraClase.materia;
            _subClaseEnCurso = "Grupo ${primeraClase.nombre}";
          } else {
            _claseEnCurso = "Sin Clases Asignadas";
            _subClaseEnCurso = "Consulta Mis Grupos";
          }
        });
      }
    } catch (e) {
      print("Error cargando estadísticas: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMsg = "Error de conexión con el servidor. Intenta reiniciar.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "¡Bienvenido, $_nombreProfesor!",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Panel de Control Docente",
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 20),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_errorMsg != null)
              Center(
                child: Text(
                  _errorMsg!,
                  style: const TextStyle(color: Colors.red),
                ),
              )
            else
              Column(
                children: [
                  // Tarjeta de Clase Actual (Datos Dinámicos)
                  _infoCard(
                    title: "Clase en curso (Materia asignada)",
                    content: _claseEnCurso,
                    subContent: _subClaseEnCurso,
                    icon: Icons.access_time_filled_rounded,
                    color: Colors.purple,
                  ),

                  const SizedBox(height: 15),

                  // Tarjeta de Pendientes (Fijo - Puedes conectar a Notificaciones si gustas)
                  _infoCard(
                    title: "Pendientes",
                    content: "Subir calificaciones del 1er Parcial",
                    subContent: "Vence: 15 Octubre",
                    icon: Icons.warning_amber_rounded,
                    color: Colors.orange,
                  ),

                  const SizedBox(height: 15),

                  // Estadísticas rápidas (Datos Dinámicos)
                  Row(
                    children: [
                      Expanded(
                        child: _statCard("$_totalGrupos", "Grupos Asignados"),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _statCard("$_totalAlumnos", "Alumnos Únicos"),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({
    required String title,
    required String content,
    required String subContent,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subContent,
                    style: TextStyle(color: Colors.grey[800], fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String number, String label) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              number,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            Text(label, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../pantallas/materia_models.dart';
import '../services/api_service.dart';
import 'detalles_materia_screen.dart';
import 'student_dashboard_screen.dart';
import 'package:app_calificaciones/main_layout.dart';
import '/soporte/solucion1_soporte.dart'; // 🚨 Importa la pantalla de soporte

class HistorialAcademicoScreen extends StatefulWidget {
  final int alumnoId;
  final Function(int) onNavigate; // ← callback para cambiar pestaña

  const HistorialAcademicoScreen({
    super.key,
    required this.alumnoId,
    required this.onNavigate,
  });

  @override
  State<HistorialAcademicoScreen> createState() =>
      _HistorialAcademicoScreenState();
}

class _HistorialAcademicoScreenState extends State<HistorialAcademicoScreen> {
  // Variables de estado
  Map<String, List<Materia>> historial = {};
  String? semestreSeleccionado;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  // ---------------------------------------------------------------------------
  // CARGAR HISTORIAL REAL DEL BACKEND
  // ---------------------------------------------------------------------------
  Future<void> _cargarHistorial() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      // 🚨 Llamada al servicio API (debe devolver Map<String, List<Materia>>)
      final data = await ApiService.getHistorialAcademico(widget.alumnoId);

      setState(() {
        historial = data;
        semestreSeleccionado = data.keys.isNotEmpty ? data.keys.first : null;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = "Error al cargar el historial académico.";
      });
    }
  }

  // ---------------------------------------------------------------------------
  // COLOR SEGÚN CALIFICACIÓN
  // ---------------------------------------------------------------------------
  Color _getCalificacionColor(double nota, String estatus) {
    if (estatus == "En Curso") return Colors.blueGrey.shade400;
    if (nota >= 9.0) return Colors.green.shade700;
    if (nota >= 7.0) return Colors.indigo.shade700;
    return Colors.red.shade700;
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (error != null) {
      return Scaffold(body: Center(child: Text(error!)));
    }

    if (semestreSeleccionado == null) {
      return const Scaffold(
        body: Center(child: Text("No hay materias registradas.")),
      );
    }

    final materias = historial[semestreSeleccionado]!;

    double promedio = materias.isNotEmpty
        ? materias.fold(0.0, (sum, m) => sum + m.calificacionFinal) /
              materias.length
        : 0.0;

    return Scaffold(
      body: Column(
        children: [
          _buildSemestreSelector(),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Promedio de $semestreSeleccionado: ${promedio.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: materias.length,
              itemBuilder: (context, i) {
                return _buildMateriaCard(materias[i]);
              },
            ),
          ),
        ],
      ),

      // 🚨 BOTÓN FLOTANTE (NAVEGACIÓN)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // ⚠️ CORRECCIÓN: Quitar 'const' si Solucion1Soporte es StatefulWidget
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Solution1Soporte()),
          );
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.message, color: Colors.white),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // 5. Barra de Navegación Inferior (Para 'Volver a inicio')
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  // ---------------------------------------------------------------------------
  // SELECTOR DE SEMESTRE (MÉTODOS AUXILIARES)
  // ---------------------------------------------------------------------------
  Widget _buildSemestreSelector() {
    return Container(
      height: 60,
      color: Colors.teal.shade50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: historial.keys.map((semestre) {
          bool selected = semestre == semestreSeleccionado;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: ChoiceChip(
              label: Text(semestre),
              selected: selected,
              selectedColor: Colors.teal,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: selected ? Colors.white : Colors.teal.shade700,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Colors.teal),
              ),
              onSelected: (_) {
                setState(() {
                  semestreSeleccionado = semestre;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CARD DE MATERIA (MÉTODOS AUXILIARES)
  // ---------------------------------------------------------------------------
  Widget _buildMateriaCard(Materia materia) {
    double nota = materia.calificacionFinal;
    String estatus = materia.estatus;
    Color color = _getCalificacionColor(nota, estatus);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(
          materia.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Profesor: ${materia.profesor}\nEstatus: $estatus"),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            estatus == "En Curso" ? "En Curso" : nota.toStringAsFixed(1),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        onTap: () {
          // Navegación a DetallesMateriaScreen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetallesMateriaScreen(materia: materia),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BARRA INFERIOR (MÉTODOS AUXILIARES)
  // ---------------------------------------------------------------------------
  Widget _buildBottomBar(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      elevation: 5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton.icon(
            icon: const Icon(Icons.home, color: Colors.teal),
            label: const Text(
              'Volver a Inicio',
              style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w600),
            ),
            onPressed: () {
              // Vuelve a la pantalla principal
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
// 🚨 Importar los Modelos de Datos
import 'materia_models.dart';
// Importar la pantalla de destino
import 'detalles_materia_screen.dart';

// -----------------------------------------------------------------
// 2. DATOS SIMULADOS DEL HISTORIAL (Fuente de datos)
// -----------------------------------------------------------------

final Map<String, List<Materia>> _historialData = {
  'Semestre 1': [
    Materia(
      nombre: 'Introducción a la Programación',
      profesor: 'Dr. López',
      semestre: 'Semestre 1',
      evaluaciones: [
        Evaluacion(nombre: 'Examen 1', peso: 40.0, calificacion: 9.0),
        Evaluacion(nombre: 'Proyecto Final', peso: 60.0, calificacion: 9.8),
      ],
    ),
    Materia(
      nombre: 'Cálculo Diferencial',
      profesor: 'Mtra. García',
      semestre: 'Semestre 1',
      evaluaciones: [
        Evaluacion(nombre: 'Parcial 1', peso: 50.0, calificacion: 8.0),
        Evaluacion(nombre: 'Parcial 2', peso: 50.0, calificacion: 8.4),
      ],
    ),
    Materia(
      nombre: 'Fundamentos de Redes',
      profesor: 'Ing. Sánchez',
      semestre: 'Semestre 1',
      evaluaciones: [
        Evaluacion(nombre: 'Tareas', peso: 20.0, calificacion: 10.0),
        Evaluacion(
          nombre: 'Examen Final',
          peso: 80.0,
          calificacion: 6.0,
        ), // Nota baja
      ],
    ),
  ],
  'Semestre 2': [
    Materia(
      nombre: 'Estructura de Datos',
      profesor: 'Dr. López',
      semestre: 'Semestre 2',
      evaluaciones: [
        Evaluacion(nombre: 'Proyecto 1', peso: 30.0, calificacion: 9.5),
        Evaluacion(nombre: 'Examen Final', peso: 70.0, calificacion: 9.0),
      ],
    ),
    Materia(
      nombre: 'Álgebra Lineal',
      profesor: 'Mtra. Torres',
      semestre: 'Semestre 2',
      evaluaciones: [
        Evaluacion(
          nombre: 'Parcial 1',
          peso: 100.0,
          calificacion: 5.9,
        ), // Reprobada
      ],
    ),
  ],
  'Semestre 3': [
    Materia(
      nombre: 'Programación Móvil (Flutter)',
      profesor: 'Dr. López',
      semestre: 'Semestre 3',
      evaluaciones: [],
    ), // En Curso
  ],
};

// -----------------------------------------------------------------
// 3. WIDGET PRINCIPAL DE LA PANTALLA
// -----------------------------------------------------------------

class HistorialAcademicoScreen extends StatefulWidget {
  const HistorialAcademicoScreen({super.key});

  @override
  State<HistorialAcademicoScreen> createState() =>
      _HistorialAcademicoScreenState();
}

class _HistorialAcademicoScreenState extends State<HistorialAcademicoScreen> {
  // Estado para el semestre seleccionado (inicia con el más reciente o actual)
  String _semestreSeleccionado = 'Semestre 2';
  late List<Materia> _materiasActuales;

  @override
  void initState() {
    super.initState();
    _materiasActuales = _historialData[_semestreSeleccionado] ?? [];
  }

  // Función para obtener el color basado en la calificación y el estatus
  Color _getCalificacionColor(double calificacion, String estatus) {
    if (estatus == 'En Curso') return Colors.blueGrey.shade400;
    if (calificacion >= 9.0) return Colors.green.shade700;
    if (calificacion >= 7.0) return Colors.indigo.shade700;
    return Colors.red.shade700;
  }

  // --- WIDGET PRINCIPAL ---
  @override
  Widget build(BuildContext context) {
    double promedio = _materiasActuales.isNotEmpty
        ? _materiasActuales.fold(
                0.0,
                (sum, item) => sum + item.calificacionFinal,
              ) /
              _materiasActuales.length
        : 0.0;

    return Scaffold(
      body: Column(
        children: [
          _buildSemestreSelector(),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Text(
              'Promedio del $_semestreSeleccionado: ${promedio.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _materiasActuales.length,
              itemBuilder: (context, index) {
                final materia = _materiasActuales[index];
                return _buildMateriaCard(context, materia);
              },
            ),
          ),
        ],
      ),
      // 4. Botón Flotante para Mensajes
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Abriendo Mensajería de EduTrack...')),
          );
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.message, color: Colors.white),
      ),
      // 5. Barra de Navegación Inferior (Para 'Volver a inicio')
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  // --- WIDGET PARA SELECCIÓN DE SEMESTRES ---
  Widget _buildSemestreSelector() {
    return Container(
      height: 60,
      color: Colors.teal.shade50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _historialData.keys.map((semestre) {
          bool isSelected = semestre == _semestreSeleccionado;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
            child: ChoiceChip(
              label: Text(semestre),
              selected: isSelected,
              selectedColor: Colors.teal,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.teal.shade700,
                fontWeight: FontWeight.bold,
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Colors.teal),
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _semestreSeleccionado = semestre;
                    _materiasActuales =
                        _historialData[_semestreSeleccionado] ?? [];
                  });
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- WIDGET PARA CADA TARJETA DE MATERIA (CON NAVEGACIÓN IMPLEMENTADA) ---
  Widget _buildMateriaCard(BuildContext context, Materia materia) {
    double nota = materia.calificacionFinal;
    String estatus = materia.estatus;
    Color color = _getCalificacionColor(nota, estatus);
    String notaDisplay = estatus == 'En Curso'
        ? 'En Curso'
        : nota.toStringAsFixed(1);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12.0),
        title: Text(
          materia.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text('Profesor: ${materia.profesor} | Estatus: $estatus'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Calificación Final (Calculada por el modelo)
            Container(
              constraints: const BoxConstraints(minWidth: 80),
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 6.0,
              ),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                notaDisplay,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            // Flecha de Detalle
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
        // 🚨 NAVEGACIÓN REAL A LA PANTALLA DE DETALLES
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetallesMateriaScreen(
                materia: materia, // <-- Pasamos el objeto 'materia' completo
              ),
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET PARA BOTÓN DE NAVEGACIÓN INFERIOR ---
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

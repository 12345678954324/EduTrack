import 'package:flutter/material.dart';

// Modelo de datos simple para un alumno
class Alumno {
  final String nombre;
  final String matricula;
  String? calificacion; // Calificación opcional (null si no ha sido ingresada)

  Alumno({required this.nombre, required this.matricula, this.calificacion});
}

class SubirCalificacionesScreen extends StatefulWidget {
  const SubirCalificacionesScreen({super.key});

  @override
  State<SubirCalificacionesScreen> createState() =>
      _SubirCalificacionesScreenState();
}

class _SubirCalificacionesScreenState extends State<SubirCalificacionesScreen> {
  String? selectedGroup;
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  
  // Lista de alumnos simulada con NOMBRES REALISTAS
  List<Alumno> _alumnos = [
    Alumno(nombre: "Ana María López Pérez", matricula: "2100001", calificacion: "9.5"),
    Alumno(nombre: "Carlos Alberto Gómez Ruiz", matricula: "2100002", calificacion: "8.0"),
    Alumno(nombre: "Sofía Elena Torres Vega", matricula: "2100003"), // Sin calif.
    Alumno(nombre: "Ricardo Daniel Castro Ríos", matricula: "2100004", calificacion: "10.0"),
    Alumno(nombre: "Valeria Isabel Herrera Solís", matricula: "2100005"), // Sin calif.
    Alumno(nombre: "Javier Antonio Mendoza Luna", matricula: "2100006", calificacion: "7.0"),
    Alumno(nombre: "Brenda Giselle Núñez Pardo", matricula: "2100007", calificacion: "9.0"),
    // Nuevos alumnos para completar la lista
    Alumno(nombre: "Manuel Alejandro Soto Díaz", matricula: "2100008", calificacion: "8.5"),
    Alumno(nombre: "Fernanda Carolina Vidal Mora", matricula: "2100009"),
    Alumno(nombre: "Eduardo Jesús Ramos García", matricula: "2100010", calificacion: "6.0"),
  ];

  // Map para manejar el estado de edición de cada alumno por su matrícula
  final Map<String, bool> _isEditing = {};

  // Map para guardar temporalmente la nueva calificación durante la edición
  final Map<String, TextEditingController> _calificacionControllers = {};

  // Constante para el ancho de la caja de calificación
  static const double _califBoxWidth = 50.0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
      });
    });

    // Inicializar controllers y estados de edición
    for (var alumno in _alumnos) {
      // Usar un controlador para manejar el valor inicial (si existe) y la edición
      _calificacionControllers[alumno.matricula] =
          TextEditingController(text: alumno.calificacion);
      // Entrar en modo edición si no tiene calificación
      _isEditing[alumno.matricula] = alumno.calificacion == null; 
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _calificacionControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  // Lógica para filtrar alumnos
  List<Alumno> get _filteredAlumnos {
    if (_searchText.isEmpty) {
      return _alumnos;
    }
    return _alumnos.where((alumno) {
      final query = _searchText.toLowerCase();
      return alumno.nombre.toLowerCase().contains(query) ||
             alumno.matricula.toLowerCase().contains(query);
    }).toList();
  }

  // Función para guardar una calificación individual
  void _guardarCalificacion(Alumno alumno) {
    setState(() {
      final controller = _calificacionControllers[alumno.matricula]!;
      String newCal = controller.text.trim();
      
      if (newCal.isNotEmpty) {
        // Validación básica (ejemplo: solo números y punto)
        if (RegExp(r'^\d+(\.\d)?$').hasMatch(newCal)) {
             // Forzar la calificación a tener un formato uniforme (ej. 9.0)
            if (!newCal.contains('.')) {
              newCal += '.0';
            }
            alumno.calificacion = newCal;
            controller.text = newCal; // Asegurar que el controlador refleje el formato
            _isEditing[alumno.matricula] = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Calificación de ${alumno.nombre} guardada.")),
            );
        } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Formato de calificación inválido (ej. 9.5).")),
            );
        }
      } else {
         // Si el campo está vacío, se considera eliminación
        _eliminarCalificacion(alumno);
      }
    });
  }

  // Función para eliminar una calificación
  void _eliminarCalificacion(Alumno alumno) {
    setState(() {
      alumno.calificacion = null;
      _calificacionControllers[alumno.matricula]!.text = "";
      _isEditing[alumno.matricula] = true; // Volver a modo edición
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Calificación de ${alumno.nombre} eliminada.")),
      );
    });
  }

  // Función para iniciar la edición de una calificación
  void _iniciarEdicion(Alumno alumno) {
    setState(() {
      _isEditing[alumno.matricula] = true;
    });
  }

  // Widget para el control de calificación y acciones
  Widget _buildCalificacionControl(Alumno alumno) {
    final bool isEditing = _isEditing[alumno.matricula] ?? false;
    final controller = _calificacionControllers[alumno.matricula]!;

    return SizedBox(
      // Usar SizedBox para controlar el ancho total del trailing y mantener la alineación
      width: isEditing ? _califBoxWidth + 8 + 48 : _califBoxWidth + 96,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (isEditing) ...[
            SizedBox(
              width: _califBoxWidth, // Ancho fijo para el campo
              child: TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: "C.",
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Botón GUARDAR
            Container(
              width: 38, // Ancho fijo para el icono
              child: IconButton(
                icon: const Icon(Icons.save, color: Colors.green),
                onPressed: () => _guardarCalificacion(alumno),
                tooltip: "Guardar",
                padding: EdgeInsets.zero,
                iconSize: 22,
              ),
            ),
          ] else ...[
            // MODO VISUALIZACIÓN
            Container(
              width: _califBoxWidth, // Ancho fijo para la caja de calificación
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: alumno.calificacion == null ? Colors.grey : Colors.deepPurple,
                  width: 1.5,
                ),
              ),
              child: Text(
                alumno.calificacion ?? "Calif.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: alumno.calificacion == null ? FontWeight.normal : FontWeight.bold, 
                  fontSize: 14, 
                  color: alumno.calificacion == null ? Colors.grey : Colors.deepPurple
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Botón EDITAR
            Container(
              width: 38,
              child: IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _iniciarEdicion(alumno),
                tooltip: "Editar",
                padding: EdgeInsets.zero,
                iconSize: 22,
              ),
            ),
            // Botón ELIMINAR
            Container(
              width: 38,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: alumno.calificacion != null ? () => _eliminarCalificacion(alumno) : null,
                tooltip: "Eliminar",
                padding: EdgeInsets.zero,
                iconSize: 22,
              ),
            ),
          ],
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey[200],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Selecciona los datos:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
              const SizedBox(height: 20),

              // Dropdown Grupo
              DropdownButtonFormField<String>(
                value: selectedGroup,
                decoration: InputDecoration(
                  labelText: "Seleccionar Grupo",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.group),
                ),
                items: const [
                  DropdownMenuItem(
                    value: "TI-51",
                    child: Text("TI-51 - Desarrollo Móvil"),
                  ),
                  DropdownMenuItem(
                    value: "TI-52",
                    child: Text("TI-52 - Base de Datos"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedGroup = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              // Lista de alumnos simulada (aparece solo si hay grupo seleccionado)
              if (selectedGroup != null) ...[
                const Text(
                  "Alumnos:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // Campo de Búsqueda
                TextFormField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Buscar por nombre o matrícula...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Lista de alumnos filtrada
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredAlumnos.length,
                  itemBuilder: (context, index) {
                    final alumno = _filteredAlumnos[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        title: Text(alumno.nombre),
                        subtitle: Text("Matrícula: ${alumno.matricula}"),
                        // Usamos un Align para asegurar que los elementos estén centrados
                        // verticalmente en el trailing del ListTile
                        trailing: Align(
                            widthFactor: 1.0, 
                            heightFactor: 1.0, 
                            child: _buildCalificacionControl(alumno)
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Guardando todas las calificaciones...")),
                      );
                    },
                    icon: const Icon(Icons.save),
                    label: const Text("Guardar Todas las Calificaciones"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      "Selecciona un grupo para ver la lista de alumnos.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
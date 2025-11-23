import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SubirCalificacionesScreen extends StatefulWidget {
  const SubirCalificacionesScreen({super.key});

  @override
  State<SubirCalificacionesScreen> createState() =>
      _SubirCalificacionesScreenState();
}

class _SubirCalificacionesScreenState extends State<SubirCalificacionesScreen> {
  // === ESTADO ===
  List<Grupo> _grupos = [];
  int? _selectedGrupoId;

  bool _loading = false;
  List<Alumno> _alumnos = [];

  // Mapas para las calificaciones y los inputs
  final Map<int, String?> _calificaciones = {};
  final Map<int, TextEditingController> _controllers = {};

  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _cargarGruposIniciales();
    _searchController.addListener(() {
      setState(() => _searchText = _searchController.text);
    });
  }

  // 1. Cargar Grupos al inicio
  Future<void> _cargarGruposIniciales() async {
    try {
      final grupos = await ApiService.getGrupos();
      setState(() {
        _grupos = grupos;
      });

      // DEBUG: Si la lista llega vacía, avisa por consola
      if (grupos.isEmpty) {
        print("⚠️ ALERTA: La API devolvió 0 grupos. Revisa tu base de datos.");
      }
    } catch (e) {
      print("❌ Error cargando grupos: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 2. Cargar Alumnos cuando se elige un ID
  Future<void> _fetchAlumnos(int grupoId) async {
    setState(() => _loading = true);
    _alumnos.clear();
    _controllers.clear();
    _calificaciones.clear();

    try {
      final alumnos = await ApiService.getAlumnosPorGrupo(grupoId);

      setState(() {
        _alumnos = alumnos;
        for (var alumno in alumnos) {
          _controllers[alumno.id] = TextEditingController(text: '');
        }
      });

      // Cargar calificaciones existentes
      for (var alumno in alumnos) {
        final calif = await ApiService.getCalificacion(alumno.id, grupoId);
        if (calif != null && mounted) {
          setState(() {
            _calificaciones[alumno.id] = calif;
            _controllers[alumno.id]?.text = calif;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error cargando alumnos: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  // 3. Guardar Calificación
  void _guardarCalificacion(Alumno alumno) async {
    if (_selectedGrupoId == null) return; // Validación extra

    final textValue = _controllers[alumno.id]?.text.trim();
    if (textValue == null || textValue.isEmpty) return;

    final double? valorNumerico = double.tryParse(textValue);
    if (valorNumerico == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un número válido (ej. 9.5)')),
      );
      return;
    }

    try {
      await ApiService.guardarCalificacion(
        alumno.id,
        _selectedGrupoId!,
        valorNumerico,
      );

      setState(() {
        _calificaciones[alumno.id] = textValue;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Calificación de ${alumno.nombre} guardada.'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Filtro del buscador
  List<Alumno> get _filteredAlumnos {
    if (_searchText.isEmpty) return _alumnos;
    final q = _searchText.toLowerCase();
    return _alumnos
        .where(
          (al) =>
              al.nombre.toLowerCase().contains(q) ||
              al.correo.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.grey[100],
        child: Column(
          children: [
            // === DROPDOWN DE GRUPOS ===
            DropdownButtonFormField<int>(
              value: _selectedGrupoId,
              hint: _grupos.isEmpty
                  ? const Text("Cargando grupos...")
                  : const Text("Selecciona un grupo"),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              // Aquí la magia: El valor es el ID (int), el texto es el Nombre
              items: _grupos.map((grupo) {
                return DropdownMenuItem<int>(
                  value: grupo.id,
                  child: Text("${grupo.nombre} - ${grupo.materia}"),
                );
              }).toList(),
              onChanged: (nuevoId) {
                if (nuevoId != null) {
                  setState(() => _selectedGrupoId = nuevoId);
                  _fetchAlumnos(nuevoId);
                }
              },
            ),

            const SizedBox(height: 10),

            // === BUSCADOR ===
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Buscar alumno...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 10),

            // === LISTA ===
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _alumnos.isEmpty
                  ? Center(
                      child: Text(
                        _selectedGrupoId == null
                            ? '👆 Selecciona un grupo arriba'
                            : 'No hay alumnos en este grupo',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredAlumnos.length,
                      itemBuilder: (ctx, i) {
                        final alumno = _filteredAlumnos[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: 2,
                          child: ListTile(
                            title: Text(
                              alumno.nombre,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(alumno.correo),
                            trailing: SizedBox(
                              width: 100,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _controllers[alumno.id],
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      textAlign: TextAlign.center,
                                      decoration: const InputDecoration(
                                        hintText: '-',
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.save,
                                      color: Colors.green,
                                    ),
                                    onPressed: () =>
                                        _guardarCalificacion(alumno),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

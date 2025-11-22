import 'package:flutter/material.dart';

class SubirCalificacionesScreen extends StatefulWidget {
  const SubirCalificacionesScreen({super.key});

  @override
  State<SubirCalificacionesScreen> createState() =>
      _SubirCalificacionesScreenState();
}

class _SubirCalificacionesScreenState extends State<SubirCalificacionesScreen> {
  String? selectedGroup;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Selecciona los datos:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Dropdown Grupo
          DropdownButtonFormField<String>(
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
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5, // 5 alumnos de ejemplo
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text("Alumno Ejemplo ${index + 1}"),
                    subtitle: const Text("Matrícula: 21000XX"),
                    trailing: SizedBox(
                      width: 60,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "Calif.",
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 5,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.save),
                label: const Text("Guardar Calificaciones"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
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
    );
  }
}

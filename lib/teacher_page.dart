// Archivo: lib/teacher_page.dart

import 'package:flutter/material.dart';

class MaestrosPage extends StatefulWidget {
  const MaestrosPage({super.key});

  @override
  State<MaestrosPage> createState() => _MaestrosPageState();
}

class _MaestrosPageState extends State<MaestrosPage> {
  // Lista temporal de estudiantes con calificaciones (sin BD)
  List<Map<String, dynamic>> students = [
    {"name": "Ana López", "grade": 85},
    {"name": "Carlos Pérez", "grade": 92},
    {"name": "María García", "grade": 78},
  ];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController gradeController = TextEditingController();

  void addStudent() {
    if (nameController.text.isEmpty || gradeController.text.isEmpty) return;

    setState(() {
      students.add({
        "name": nameController.text,
        "grade": int.tryParse(gradeController.text) ?? 0,
      });
    });

    nameController.clear();
    gradeController.clear();
  }

  void editStudent(int index) {
    nameController.text = students[index]["name"];
    gradeController.text = students[index]["grade"].toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Editar estudiante"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Nombre"),
            ),
            TextField(
              controller: gradeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Calificación"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                students[index] = {
                  "name": nameController.text,
                  "grade": int.tryParse(gradeController.text) ?? 0,
                };
              });
              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  void deleteStudent(int index) {
    setState(() {
      students.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Panel del Maestro"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // FORMULARIO PARA AGREGAR ALUMNO
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Nombre del estudiante"),
                  ),
                  TextField(
                    controller: gradeController,
                    decoration: const InputDecoration(labelText: "Calificación"),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: addStudent,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Agregar estudiante"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // LISTA DE ESTUDIANTES
            Expanded(
              child: ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 3,
                    child: ListTile(
                      title: Text(students[index]["name"]),
                      subtitle: Text("Calificación: ${students[index]["grade"]}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => editStudent(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteStudent(index),
                          ),
                        ],
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

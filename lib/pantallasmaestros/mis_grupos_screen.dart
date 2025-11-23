import 'package:flutter/material.dart';

class MisGruposScreen extends StatelessWidget {
  const MisGruposScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> grupos = [
      {
        "grupo": "TI-51",
        "materia": "Desarrollo Móvil",
        "alumnos": "32 Alumnos",
      },
      {"grupo": "TI-52", "materia": "Base de Datos", "alumnos": "28 Alumnos"},
      {"grupo": "ID-41", "materia": "Inglés Técnico", "alumnos": "30 Alumnos"},
      {"grupo": "MK-11", "materia": "Mercadotecnia", "alumnos": "35 Alumnos"},
    ];

    return Container(
      color: Colors.grey[200],
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
      itemCount: grupos.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(10),
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.purple.shade100,
              child: Text(
                grupos[index]["grupo"]!,
                style: TextStyle(
                  color: Colors.purple.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              grupos[index]["materia"]!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(grupos[index]["alumnos"]!),
            trailing: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey,
            ),
            onTap: () {
              // Acción al tocar el grupo (futura implementación)
            },
          ),
        );
      },
      ),
    );
  }
}

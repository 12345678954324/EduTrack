import 'package:flutter/material.dart';

class CalendarioScreen extends StatelessWidget {
  const CalendarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> eventos = [
      {
        "titulo": "Fin de Cuatrimestre Sep-Dic",
        "fecha": "13 Dic 2025",
        "tipo": "Cierre",
        "color": Colors.orange,
        "icon": Icons.flag_rounded,
      },
      {
        "titulo": "Vacaciones de Invierno",
        "fecha": "16 Dic - 03 Ene",
        "tipo": "Vacaciones",
        "color": Colors.blue,
        "icon": Icons.beach_access_rounded,
      },
      {
        "titulo": "Inicio Cuatrimestre Ene-Abr",
        "fecha": "06 Ene 2026",
        "tipo": "Inicio",
        "color": Colors.green,
        "icon": Icons.school_rounded,
      },
      {
        "titulo": "Suspensión de Labores",
        "fecha": "03 Feb 2026",
        "tipo": "Día Inhábil",
        "color": Colors.red,
        "icon": Icons.block_rounded,
      },
      {
        "titulo": "1ra Evaluación Parcial",
        "fecha": "10 - 14 Feb 2026",
        "tipo": "Examen",
        "color": Colors.purple,
        "icon": Icons.assignment_turned_in_rounded,
      },
      {
        "titulo": "Suspensión (Natalicio B. Juárez)",
        "fecha": "17 Mar 2026",
        "tipo": "Día Inhábil",
        "color": Colors.red,
        "icon": Icons.block_rounded,
      },
      {
        "titulo": "Vacaciones Semana Santa",
        "fecha": "30 Mar - 10 Abr",
        "tipo": "Vacaciones",
        "color": Colors.blue,
        "icon": Icons.wb_sunny_rounded,
      },
      {
        "titulo": "Fin de Cuatrimestre Ene-Abr",
        "fecha": "24 Abr 2026",
        "tipo": "Cierre",
        "color": Colors.orange,
        "icon": Icons.flag_rounded,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: eventos.length,
        itemBuilder: (context, index) {
          final evento = eventos[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Barra lateral de color (indicador visual)
                Container(
                  width: 6,
                  height: 80,
                  decoration: BoxDecoration(
                    color: evento['color'],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),
                // Fecha (destacada)
                Container(
                  width: 80,
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        evento['fecha'].split(' ')[0], // Día
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade800,
                        ),
                      ),
                      Text(
                        evento['fecha'].split(' ').length > 1
                            ? evento['fecha'].split(' ').sublist(1).join(' ')
                            : '', // Mes y año
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Línea divisoria vertical
                Container(height: 50, width: 1, color: Colors.grey.shade200),
                // Contenido Principal
                Expanded(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    title: Text(
                      evento['titulo'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Text(
                      evento['tipo'],
                      style: TextStyle(
                        color: evento['color'],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Icon(evento['icon'], color: Colors.grey.shade400),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

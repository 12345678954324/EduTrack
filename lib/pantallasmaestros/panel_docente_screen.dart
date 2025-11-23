import 'package:flutter/material.dart';

class PanelDocenteScreen extends StatelessWidget {
  const PanelDocenteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "¡Bienvenido, Profesor!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
            const SizedBox(height: 5),
            Text(
              "Ciclo Escolar 2025 - 2026",
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 20),

          // Tarjeta de Clase Actual
          _infoCard(
            title: "Clase en curso",
            content: "Desarrollo Móvil Integral",
            subContent: "Grupo TI-51 • Aula A-12",
            icon: Icons.access_time_filled_rounded,
            color: Colors.purple,
          ),

          const SizedBox(height: 15),

          // Tarjeta de Pendientes
          _infoCard(
            title: "Pendientes",
            content: "Subir calificaciones del 1er Parcial",
            subContent: "Vence: 15 Octubre",
            icon: Icons.warning_amber_rounded,
            color: Colors.orange,
          ),

          const SizedBox(height: 15),

          // Estadísticas rápidas
          Row(
            children: [
              Expanded(child: _statCard("4", "Grupos")),
              const SizedBox(width: 15),
              Expanded(child: _statCard("120", "Alumnos")),
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

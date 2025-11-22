import 'package:flutter/material.dart';

class CalificacionesScreen extends StatelessWidget {
  const CalificacionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _notaCard('Matemáticas', '9.5'),
          _notaCard('Historia', '8.7'),
          _notaCard('Inglés', '10'),
          _notaCard('Ciencias', '9.2'),
        ],
      ),
    );
  }

  Widget _notaCard(String materia, String calificacion) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.book, color: Colors.purple.shade700),
        title: Text(
          materia,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          calificacion,
          style: TextStyle(
            fontSize: 20,
            color: Colors.purple.shade900,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

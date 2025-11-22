import 'package:flutter/material.dart';

class GruposScreen extends StatelessWidget {
  const GruposScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _grupoCard('Grupo A - 1° Secundaria'),
          _grupoCard('Grupo B - 2° Secundaria'),
          _grupoCard('Grupo C - 3° Secundaria'),
        ],
      ),
    );
  }

  Widget _grupoCard(String nombre) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.group, color: Colors.purple.shade700),
        title: Text(nombre),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}

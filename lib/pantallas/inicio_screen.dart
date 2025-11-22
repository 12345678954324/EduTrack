import 'package:flutter/material.dart';

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      body: Center(
        child: Text(
          'Bienvenido a la Plataforma Escolar',
          style: TextStyle(
            fontSize: 22,
            color: Colors.purple.shade900,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

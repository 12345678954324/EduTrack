import 'package:flutter/material.dart';

class AyudaScreen extends StatelessWidget {
  const AyudaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Necesitas ayuda?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Puedes contactarnos para recibir soporte:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.email_outlined, color: Colors.purple.shade800),
              title: const Text('Correo de soporte'),
              subtitle: const Text('soporte@colegio.com'),
            ),
            ListTile(
              leading: Icon(Icons.phone_android, color: Colors.purple.shade800),
              title: const Text('Teléfono'),
              subtitle: const Text('+52 55 1234 5678'),
            ),
          ],
        ),
      ),
    );
  }
}

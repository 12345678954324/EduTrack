import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Solution1Soporte extends StatefulWidget {
  final bool needsContact;
  const Solution1Soporte({super.key, this.needsContact = true});

  @override
  _Solution1SoporteState createState() => _Solution1SoporteState();
}

class _Solution1SoporteState extends State<Solution1Soporte> {
  bool aceptaInfo = false;
  final TextEditingController detallesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Solución para: No puedo iniciar sesión',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pasos para resolver el problema:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                icon: const Icon(Icons.home),
                label: const Text('Volver a inicio'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text('1. Verifica tu conexión a internet'),
            const Text('2. Reinicia la aplicación'),
            const Text('3. Restablece tu contraseña'),
            const Text('4. Contacta con soporte técnico'),
            const SizedBox(height: 20),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PASO 1:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Resumen de lo que el soporte le pedirá al usuario para poder ayudarte con su problema.'),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Acepto compartir cualquier información que el soporte de la institucion o aplicacion necesite para solucionar mi problema (obligatorio)'),
                    value: aceptaInfo,
                    onChanged: (val) => setState(() => aceptaInfo = val ?? false),
                  ),
                  const SizedBox(height: 16),
                  const Text('PASO 2:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Danos detalles sobre el problema que tienes:'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: detallesController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Agregar texto',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.grey[400],
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: aceptaInfo && detallesController.text.isNotEmpty
                            ? () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Información enviada')),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Enviar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            if (widget.needsContact) ...[
              const Divider(),
              const SizedBox(height: 8),
              const Text('Contactar soporte', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ListTile(
                leading: Icon(Icons.email_outlined, color: Colors.deepPurple.shade800),
                title: const Text('soporteEdu@gmail.com'),
                subtitle: const Text('Enviar correo para restablecer contraseña o solicitar ayuda'),
                trailing: ElevatedButton(
                  onPressed: () => _showContactDialog(context),
                  child: const Text('Contactar'),
                ),
              ),
              ListTile(
                leading: Icon(Icons.phone_android, color: Colors.deepPurple.shade800),
                title: const Text('+52 55 1234 5678'),
                subtitle: const Text('Llamar'),
                trailing: ElevatedButton(
                  onPressed: () => _showContactDialog(context),
                  child: const Text('Contactar'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contacto de Soporte'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Correo: soporte@colegio.com'),
            const SizedBox(height: 8),
            const Text('Teléfono: +52 55 1234 5678'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(const ClipboardData(text: 'soporte@colegio.com'));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Correo copiado al portapapeles')));
            },
            child: const Text('Copiar correo'),
          ),
          TextButton(
            onPressed: () async {
              await Clipboard.setData(const ClipboardData(text: '+52 55 1234 5678'));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Teléfono copiado al portapapeles')));
            },
            child: const Text('Copiar teléfono'),
          ),
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cerrar')),
        ],
      ),
    );
  }
}
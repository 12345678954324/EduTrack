// Archivo: lib/register_page.dart

import 'package:flutter/material.dart';
import 'login_page.dart';
import 'main_layout.dart';
import 'pantallasmaestros/main_layout_maestros_screen.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController matriculaController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String userType = "Alumno"; // Alumno o Maestro
  String institution = "Universidad";

  void register() {
    // Validar campos vacíos
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        matriculaController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor completa todos los campos")),
      );
      return;
    }

    // Validar que las contraseñas coincidan
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Las contraseñas no coinciden")),
      );
      return;
    }

    // Validar longitud de contraseña
    if (passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("La contraseña debe tener al menos 6 caracteres")),
      );
      return;
    }

    // Mostrar mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("¡Bienvenido $userType!")),
    );

    // Redirigir según el tipo de usuario
    Future.delayed(const Duration(milliseconds: 500), () {
      if (userType == "Maestro") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainLayoutMaestros()),
        );
      } else {
        // Alumno
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainLayout()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 350,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
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
                const Icon(Icons.person_add, size: 90, color: Colors.deepPurple),
                const SizedBox(height: 15),
                const Text(
                  "Registro",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Nombre
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Nombre completo",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Email
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Correo",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Matrícula
                TextField(
                  controller: matriculaController,
                  decoration: InputDecoration(
                    labelText: "Matrícula",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Tipo de usuario
                DropdownButtonFormField(
                  value: userType,
                  items: const [
                    DropdownMenuItem(value: "Alumno", child: Text("Alumno")),
                    DropdownMenuItem(value: "Maestro", child: Text("Maestro")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      userType = value.toString();
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Tipo de usuario",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Institución
                DropdownButtonFormField(
                  value: institution,
                  items: const [
                    DropdownMenuItem(value: "Universidad", child: Text("Universidad")),
                    DropdownMenuItem(value: "Preparatoria", child: Text("Preparatoria")),
                    DropdownMenuItem(value: "Secundaria", child: Text("Secundaria")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      institution = value.toString();
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Institución",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Contraseña
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Contraseña",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Confirmar contraseña
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Confirmar Contraseña",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "Registrar",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                  child: const Text("¿Ya tienes cuenta? Inicia sesión"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'register_page.dart';
import 'main_layout.dart'; // Layout de Alumnos
import 'pantallasmaestros/main_layout_maestros_screen.dart'; // Layout de Maestros (IMPORTANTE)

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String userType = "Alumno"; // Valor inicial

  void login() {
    // Validación básica
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor completa todos los campos")),
      );
      return;
    }
    // Verificar credenciales guardadas
    _verifyAndLogin();
  }

  Future<void> _verifyAndLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('saved_username');
    final savedPassword = prefs.getString('saved_password');
    final savedUserType = prefs.getString('saved_userType') ?? 'Alumno';

    if (savedUsername == null || savedPassword == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay una cuenta registrada. Regístrate primero.')),
      );
      return;
    }

    final inputUsername = emailController.text.trim();
    final inputPassword = passwordController.text;

    if (inputUsername == savedUsername && inputPassword == savedPassword && userType == savedUserType) {
      // Construimos displayName a partir del username (nombre)
      final raw = inputUsername;
      final displayName = raw.isNotEmpty ? raw.split(' ')[0] : raw;
      String displayNameNormalized = displayName;
      if (displayNameNormalized.isNotEmpty) {
        displayNameNormalized = displayNameNormalized[0].toUpperCase() + displayNameNormalized.substring(1);
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Bienvenido $userType")));

      Future.delayed(const Duration(milliseconds: 500), () {
        if (userType == "Alumno") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainLayout(username: displayNameNormalized),
            ),
          );
        } else if (userType == "Maestro") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainLayoutMaestros()),
          );
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario o contraseña incorrectos')),
      );
    }
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
                const Icon(
                  Icons.school_rounded,
                  size: 90,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 15),
                const Text(
                  "Inicio de Sesión",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Usuario",
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Contraseña",
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // SELECTOR DE ROL (ALUMNO / MAESTRO)
                DropdownButtonFormField<String>(
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
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "Ingresar",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
                    );
                  },
                  child: const Text("¿No tienes cuenta? Regístrate"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// IMPORTS DE UTILIDADES
import '../pantallas/notificaciones.dart'; // Asegúrate que este sea NotificationsPage
import '../pantallas/ayuda_screen.dart';
import '../login_page.dart';

// IMPORTS DE PANTALLAS DE MAESTRO
import 'panel_docente_screen.dart';
import 'mis_grupos_screen.dart';
import 'subir_calificaciones_screen.dart';

class MainLayoutMaestros extends StatefulWidget {
  const MainLayoutMaestros({super.key});

  @override
  State<MainLayoutMaestros> createState() => _MainLayoutMaestrosState();
}

class _MainLayoutMaestrosState extends State<MainLayoutMaestros> {
  int _selectedIndex = 0;

  // Variables para datos del perfil
  String _nombreDisplay = 'Cargando...';
  String _correoDisplay = '';
  int _usuarioId = 0; // 👈 NECESARIO: Almacenar el ID del profesor

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  // Leemos los datos guardados en el Login
  Future<void> _cargarDatosUsuario() async {
    final prefs = await SharedPreferences.getInstance();

    // Leemos el ID, el nombre y el correo que se guardaron en el Login
    final id = prefs.getInt('saved_id') ?? 0;

    if (mounted) {
      setState(() {
        _usuarioId = id;
        _nombreDisplay = prefs.getString('saved_name') ?? 'Profesor';
        _correoDisplay =
            prefs.getString('saved_username') ?? 'profesor@colegio.com';
      });
    }
  }

  // 1. LISTA DE PANTALLAS
  static final List<Widget> _widgetOptions = <Widget>[
    const PanelDocenteScreen(), // 0
    const MisGruposScreen(), // 1
    const SubirCalificacionesScreen(), // 2
    const AyudaScreen(), // 3
  ];

  // 2. TÍTULOS
  static const List<String> _titles = [
    'Panel Docente',
    'Mis Grupos',
    'Subir Calificaciones',
    'Ayuda y Soporte',
  ];

  void _onSelectItem(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 4.0,
        // --- AQUÍ ESTÁ LA CAMPANA DE NOTIFICACIONES ---
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Pasa el ID del profesor para que cargue sus recordatorios
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      NotificationsPage(usuarioId: _usuarioId),
                ),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              // --- ENCABEZADO DINÁMICO ---
              _buildDrawerHeader(),

              // --- LISTA DE OPCIONES ---
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildDrawerItem(
                      icon: Icons.dashboard_rounded,
                      text: 'Panel Docente',
                      index: 0,
                    ),
                    _buildDrawerItem(
                      icon: Icons.group_rounded,
                      text: 'Mis Grupos',
                      index: 1,
                    ),
                    _buildDrawerItem(
                      icon: Icons.upload_file_rounded,
                      text: 'Subir Calificaciones',
                      index: 2,
                    ),
                    const Divider(
                      color: Colors.grey,
                      indent: 16,
                      endIndent: 16,
                    ),
                    _buildDrawerItem(
                      icon: Icons.help_outline_rounded,
                      text: 'Ayuda y Soporte',
                      index: 3,
                    ),
                  ],
                ),
              ),

              // --- BOTÓN CERRAR SESIÓN ---
              Padding(
                padding: const EdgeInsets.only(bottom: 20, left: 8, right: 8),
                child: ListTile(
                  leading: const Icon(
                    Icons.logout_rounded,
                    color: Colors.redAccent,
                  ),
                  title: const Text(
                    'Cerrar Sesión',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onTap: () async {
                    if (context.mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
    );
  }

  Widget _buildDrawerHeader() {
    return UserAccountsDrawerHeader(
      accountName: Text(
        _nombreDisplay,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      accountEmail: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_correoDisplay, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'DOCENTE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.white,
        child: Text(
          _nombreDisplay.isNotEmpty ? _nombreDisplay[0].toUpperCase() : 'P',
          style: TextStyle(
            fontSize: 28,
            color: Colors.deepPurple.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required int index,
  }) {
    final bool isSelected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                colors: [
                  Colors.deepPurple.shade100,
                  Colors.deepPurple.shade50.withOpacity(0.5),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Colors.deepPurple.shade800 : Colors.grey.shade700,
        ),
        title: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.deepPurple.shade900 : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () => _onSelectItem(index),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

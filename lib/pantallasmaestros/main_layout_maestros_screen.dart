import 'package:flutter/material.dart';

// IMPORTS DE UTILIDADES
import '../pantallas/notificaciones.dart';
import '../pantallas/ayuda_screen.dart';
import '../login_page.dart';

// IMPORTS DE NUEVAS PANTALLAS DE MAESTRO
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

  // 1. LISTA DE PANTALLAS (Con las nuevas pantallas reales)
  static final List<Widget> _widgetOptions = <Widget>[
    const PanelDocenteScreen(), // Índice 0: Panel
    const MisGruposScreen(), // Índice 1: Grupos
    const SubirCalificacionesScreen(), // Índice 2: Subir Calif
    AyudaScreen(), // Índice 3: Ayuda (Reutilizada)
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
        elevation: 4.0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsPage(),
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
              // LISTA DE OPCIONES
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildDrawerHeader(),
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

              // BOTÓN CERRAR SESIÓN
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
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
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
      accountName: const Text(
        'Profesor: XXXXX',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      accountEmail: const Text(
        'profesor@ut.edu.mx',
        style: TextStyle(fontSize: 14),
      ),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(
          Icons.person_outline_rounded,
          size: 45,
          color: Colors.purple.shade700,
        ),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade700, Colors.purple.shade400],
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
                  Colors.purple.shade100,
                  Colors.purple.shade50.withOpacity(0.5),
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
          color: isSelected ? Colors.purple.shade800 : Colors.grey.shade700,
        ),
        title: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.purple.shade900 : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () => _onSelectItem(index),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

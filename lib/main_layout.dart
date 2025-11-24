import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// IMPORTS DE PANTALLAS
// import 'pantallas/inicio_screen.dart'; // <--- YA NO NECESITAMOS ESTE
import 'pantallas/historial_academico_screen.dart'; // <--- NUEVO
import 'pantallas/calendario_screen.dart';
import 'pantallas/ayuda_screen.dart';
import 'pantallas/notificaciones.dart';
import 'login_page.dart';

// IMPORTANTE: Importa tu nueva pantalla del Dashboard
import 'pantallas/student_dashboard_screen.dart';

class MainLayout extends StatefulWidget {
  final String username;
  final int usuarioId; // Este ID es vital para traer las calificaciones

  const MainLayout({
    super.key,
    this.username = 'Alumno',
    this.usuarioId = 3, // ID por defecto o el que viene del Login
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  // Variables para los datos del encabezado
  String _nombreDisplay = '';
  String _correoDisplay = '';
  String _rolDisplay = '';

  @override
  void initState() {
    super.initState();
    _nombreDisplay = widget.username;
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _correoDisplay =
          prefs.getString('saved_username') ?? 'correo@ejemplo.com';
      _rolDisplay = prefs.getString('saved_userType') ?? 'Alumno';

      if (_nombreDisplay == 'Alumno' || _nombreDisplay.isEmpty) {
        _nombreDisplay = _correoDisplay.split('@')[0];
      }
    });
  }

  // Pantallas del menú
  List<Widget> get _widgetOptions => <Widget>[
    StudentDashboardScreen(userId: widget.usuarioId),
    HistorialAcademicoScreen(alumnoId: widget.usuarioId), // <--- REEMPLAZADO
    const CalendarioScreen(),
    const AyudaScreen(),
  ];

  static const List<String> _titles = [
    'Mi Desempeño',
    'Historial Académico', // <--- CAMBIADO
    'Calendario Escolar',
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
        backgroundColor: const Color(0xFF673AB7),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      NotificationsPage(usuarioId: widget.usuarioId),
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
              _buildDrawerHeader(),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildDrawerItem(
                      icon: Icons.dashboard_rounded,
                      text: 'Mi Desempeño',
                      index: 0,
                    ),
                    _buildDrawerItem(
                      icon: Icons.school_rounded, // <--- NUEVO ÍCONO
                      text: 'Historial Académico', // <--- CAMBIADO
                      index: 1,
                    ),
                    _buildDrawerItem(
                      icon: Icons.calendar_today_rounded,
                      text: 'Calendario',
                      index: 2,
                    ),
                    const Divider(
                      color: Colors.grey,
                      indent: 16,
                      endIndent: 16,
                    ),
                    _buildDrawerItem(
                      icon: Icons.help_outline_rounded,
                      text: '¿Necesitas ayuda?',
                      index: 3,
                    ),
                  ],
                ),
              ),
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
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear(); // Limpiamos datos al salir

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
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      accountEmail: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_correoDisplay, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _rolDisplay.toUpperCase(),
              style: const TextStyle(
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
          _nombreDisplay.isNotEmpty ? _nombreDisplay[0].toUpperCase() : 'A',
          style: const TextStyle(
            fontSize: 28,
            color: Color(0xFF673AB7),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF673AB7), Color(0xFF9575CD)],
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
                  const Color(0xFF673AB7).withOpacity(0.2),
                  const Color(0xFF673AB7).withOpacity(0.05),
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
          color: isSelected ? const Color(0xFF673AB7) : Colors.grey.shade700,
        ),
        title: Text(
          text,
          style: TextStyle(
            color: isSelected ? const Color(0xFF673AB7) : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () => _onSelectItem(index),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

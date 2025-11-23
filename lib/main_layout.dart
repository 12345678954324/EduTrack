import 'package:flutter/material.dart';

// IMPORTS DE PANTALLAS
import 'pantallas/inicio_screen.dart';
import 'pantallas/grupos_screen.dart';
import 'pantallas/calendario_screen.dart';
import 'pantallas/ayuda_screen.dart';
import 'pantallas/notificaciones.dart';
import 'login_page.dart'; // Importante para poder cerrar sesión
// import 'pantallas/detalles_materia_screen.dart'; // No se necesita importar aquí si no está en la lista

class MainLayout extends StatefulWidget {
  final String username;
  const MainLayout({super.key, this.username = 'Alumno'});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  // 1. LISTA DE PANTALLAS (ALUMNO) - Solo incluye las pantallas raíz
  List<Widget> get _widgetOptions => <Widget>[
    InicioScreen(username: widget.username),
    const GruposScreen(),
    const CalendarioScreen(),
    // Usaremos Notificaciones como el 4to ítem temporal, ya que DetallesMateriaScreen no va aquí:
    const NotificationsPage(),
    const AyudaScreen(),
  ];

  // 2. TÍTULOS - Coinciden con los ítems del Drawer y la lista de arriba
  static const List<String> _titles = [
    'Inicio',
    'Grupos',
    'Calendario Escolar',
    'Notificaciones', // Ajustado el título
    'Ayuda y Soporte',
  ];

  void _onSelectItem(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Cierra el Drawer después de seleccionar un ítem
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
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Navegación directa al tocar el ícono de notificación
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
              // LISTA DE OPCIONES (Arriba)
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildDrawerHeader(),
                    _buildDrawerItem(
                      icon: Icons.home_rounded,
                      text: 'Inicio',
                      index: 0,
                    ),
                    _buildDrawerItem(
                      icon: Icons.group_rounded,
                      text: 'Grupos',
                      index: 1,
                    ),
                    _buildDrawerItem(
                      icon: Icons.calendar_today_rounded,
                      text: 'Calendario',
                      index: 2,
                    ),
                    _buildDrawerItem(
                      icon: Icons
                          .notifications_rounded, // Usamos un ícono diferente para Notificaciones
                      text: 'Notificaciones',
                      index: 3,
                    ),
                    const Divider(
                      color: Colors.grey,
                      indent: 16,
                      endIndent: 16,
                    ),
                    _buildDrawerItem(
                      icon: Icons.help_outline_rounded,
                      text: '¿Necesitas ayuda?',
                      index: 4,
                    ),
                  ],
                ),
              ),

              // BOTÓN CERRAR SESIÓN (Al fondo)
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
                    // Cierra la sesión y navega a la pantalla de Login (reemplazando la actual)
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
      // Muestra la pantalla seleccionada
      body: _widgetOptions.elementAt(_selectedIndex),
    );
  }

  // Widget para el encabezado del Drawer
  Widget _buildDrawerHeader() {
    return UserAccountsDrawerHeader(
      accountName: Text(
        widget.username.isNotEmpty ? widget.username : 'Usuario: Alumno',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      accountEmail: const Text('', style: TextStyle(fontSize: 14)),
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
          colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  // Widget auxiliar para construir los ítems del Drawer
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

import 'package:flutter/material.dart';
import '../services/api_service.dart'; // Importamos el servicio y los modelos

class NotificationsPage extends StatefulWidget {
  // El ID del usuario actual
  final int usuarioId;

  // Puedes cambiar el valor por defecto o pasarlo desde el Login
  const NotificationsPage({super.key, this.usuarioId = 3});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Notificacion> _notificaciones = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargarNotificaciones();
  }

  Future<void> _cargarNotificaciones() async {
    try {
      final lista = await ApiService.getNotificaciones(widget.usuarioId);
      setState(() {
        _notificaciones = lista;
        _loading = false;
      });
    } catch (e) {
      print("Error cargando notificaciones: $e");
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notificaciones",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor:
            Colors.white, // Esto hace que el texto y los iconos sean blancos
        // FLECHA DE REGRESO EXPLÍCITA
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Esto regresa a la pantalla anterior (MainLayout o MainLayoutMaestros)
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF9D4EDD), Color(0xFFEBDDFB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : _notificaciones.isEmpty
            ? const Center(
                child: Text(
                  "No tienes notificaciones nuevas",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              )
            : RefreshIndicator(
                onRefresh: _cargarNotificaciones,
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _notificaciones.length,
                  itemBuilder: (context, index) {
                    final notif = _notificaciones[index];
                    return _notificationCard(notif);
                  },
                ),
              ),
      ),
    );
  }

  Widget _notificationCard(Notificacion notif) {
    // Cortamos la fecha para que no se vea tan larga
    String fechaCorta = notif.fecha.length > 10
        ? notif.fecha.substring(0, 10)
        : notif.fecha;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: notif.leida
            ? Colors.white.withOpacity(0.7)
            : Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(18),
        // Borde morado si no está leída
        border: !notif.leida
            ? Border.all(color: Colors.deepPurple, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  notif.titulo,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              if (!notif.leida)
                const Icon(Icons.circle, size: 12, color: Colors.redAccent),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            notif.mensaje,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              fechaCorta,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}

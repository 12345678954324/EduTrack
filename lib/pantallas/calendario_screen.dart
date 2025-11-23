import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

// --- Modelo de Datos: Evento ---
class Evento {
  final String titulo;
  final String tipo;
  final Color color;
  final IconData icon;
  final DateTime fechaInicio;
  final DateTime fechaFin;

  Evento({
    required this.titulo,
    required this.tipo,
    required this.color,
    required this.icon,
    required this.fechaInicio,
    required this.fechaFin,
  });
}

class CalendarioScreen extends StatefulWidget {
  const CalendarioScreen({super.key});

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  // Estado para el calendario
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  
  // CAMBIO CLAVE: Usamos CalendarFormat.week para el calendario más pequeño
  CalendarFormat _calendarFormat = CalendarFormat.week;
  
  // Lista de eventos simulada con objetos Evento
  final List<Evento> _todosLosEventos = [
    Evento(
      titulo: "Fin de Cuatrimestre Sep-Dic",
      tipo: "Cierre",
      color: Colors.orange,
      icon: Icons.flag_rounded,
      fechaInicio: DateTime(2025, 12, 13),
      fechaFin: DateTime(2025, 12, 13),
    ),
    Evento(
      titulo: "Vacaciones de Invierno",
      tipo: "Vacaciones",
      color: Colors.blue,
      icon: Icons.beach_access_rounded,
      fechaInicio: DateTime(2025, 12, 16),
      fechaFin: DateTime(2026, 1, 3), 
    ),
    Evento(
      titulo: "Inicio Cuatrimestre Ene-Abr",
      tipo: "Inicio",
      color: Colors.green,
      icon: Icons.school_rounded,
      fechaInicio: DateTime(2026, 1, 6),
      fechaFin: DateTime(2026, 1, 6),
    ),
    Evento(
      titulo: "Suspensión de Labores",
      tipo: "Día Inhábil",
      color: Colors.red,
      icon: Icons.block_rounded,
      fechaInicio: DateTime(2026, 2, 3),
      fechaFin: DateTime(2026, 2, 3),
    ),
    Evento(
      titulo: "1ra Evaluación Parcial",
      tipo: "Examen",
      color: Colors.purple,
      icon: Icons.assignment_turned_in_rounded,
      fechaInicio: DateTime(2026, 2, 10),
      fechaFin: DateTime(2026, 2, 14), 
    ),
    Evento(
      titulo: "Suspensión (Natalicio B. Juárez)",
      tipo: "Día Inhábil",
      color: Colors.red,
      icon: Icons.block_rounded,
      fechaInicio: DateTime(2026, 3, 17),
      fechaFin: DateTime(2026, 3, 17),
    ),
    Evento(
      titulo: "Vacaciones Semana Santa",
      tipo: "Vacaciones",
      color: Colors.blue,
      icon: Icons.wb_sunny_rounded,
      fechaInicio: DateTime(2026, 3, 30),
      fechaFin: DateTime(2026, 4, 10), 
    ),
    Evento(
      titulo: "Fin de Cuatrimestre Ene-Abr",
      tipo: "Cierre",
      color: Colors.orange,
      icon: Icons.flag_rounded,
      fechaInicio: DateTime(2026, 4, 24),
      fechaFin: DateTime(2026, 4, 24),
    ),
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDay = DateTime(now.year, now.month, now.day);
    _focusedDay = _selectedDay;
  }

  // --- Funciones de Eventos ---

  // Obtiene los eventos que caen en un día específico para dibujar los marcadores (simbología)
  List<Evento> _getEventsForDay(DateTime day) {
    return _todosLosEventos.where((evento) {
      final start = DateTime(evento.fechaInicio.year, evento.fechaInicio.month, evento.fechaInicio.day);
      final end = DateTime(evento.fechaFin.year, evento.fechaFin.month, evento.fechaFin.day);
      final queryDay = DateTime(day.year, day.month, day.day);

      return (queryDay.isAtSameMomentAs(start) || queryDay.isAfter(start)) && 
             (queryDay.isAtSameMomentAs(end) || queryDay.isBefore(end));
    }).toList();
  }
  
  // Obtiene la lista de eventos para la agenda
  List<Evento> _getEventsForAgenda() {
    _todosLosEventos.sort((a, b) => a.fechaInicio.compareTo(b.fechaInicio));
    return _todosLosEventos;
  }

  @override
  Widget build(BuildContext context) {
    final eventosAgenda = _getEventsForAgenda();

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          // --- 1. TABLE CALENDAR (Vista Semanal Pequeña) ---
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: TableCalendar<Evento>(
                // Rango de fechas para la navegación
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.utc(2027, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat, // Usa el formato semanal
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay; 
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                
                eventLoader: _getEventsForDay, 
                
                // --- Estilos para la simbología y selección ---
                calendarStyle: CalendarStyle(
                  markerDecoration: const BoxDecoration(
                    color: Colors.deepPurple, 
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Colors.deepPurple,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false, // Ocultar el botón para mantener el tamaño semanal
                  titleCentered: true,
                  titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.deepPurple),
                ),
              ),
            ),
          ),
          
          // --- 2. LISTA DE EVENTOS (Agenda) ---
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Próximos Eventos",
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.deepPurple.shade700
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0, top: 8.0),
              itemCount: eventosAgenda.length,
              itemBuilder: (context, index) {
                final evento = eventosAgenda[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Barra lateral de color
                      Container(
                        width: 6,
                        height: 80,
                        decoration: BoxDecoration(
                          color: evento.color,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                        ),
                      ),
                      // Fecha (Destacada)
                      Container(
                        width: 80,
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              evento.fechaInicio.day.toString().padLeft(2, '0'), // Día
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple.shade800,
                              ),
                            ),
                            Text(
                              // Mostrar mes y año simplificado (ej. 12/25)
                              '${evento.fechaInicio.month.toString().padLeft(2, '0')}/${evento.fechaInicio.year % 100}', 
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Línea divisoria vertical
                      Container(height: 50, width: 1, color: Colors.grey.shade200),
                      // Contenido Principal
                      Expanded(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          title: Text(
                            evento.titulo,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Text(
                            evento.tipo,
                            style: TextStyle(
                              color: evento.color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: Icon(evento.icon, color: Colors.grey.shade400),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

// -------------------------
// Modelo de Datos: Evento
// -------------------------
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

// -------------------------
// Pantalla: CalendarioScreen
// -------------------------
class CalendarioScreen extends StatefulWidget {
  final Function(int)? onNavigate; // <--- callback opcional

  const CalendarioScreen({super.key, this.onNavigate});

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen>
    with SingleTickerProviderStateMixin {
  // Estado calendario
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // Paleta morada elegante
  final Color purpleDeep = const Color(0xFF6A0DAD);
  final Color purpleMedium = const Color(0xFF9B4F96);
  final Color purpleSoft = const Color(0xFFB388EB);
  final Color purpleLight = const Color(0xFFE8D9FF);

  // Lista simulada de eventos (igual a la tuya)
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

  // Animación para las tarjetas de agenda
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDay = DateTime(now.year, now.month, now.day);
    _focusedDay = _selectedDay;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // -------------------------
  // Funciones de eventos
  // -------------------------

  // Determina si un evento cubre el día 'day'
  List<Evento> _getEventsForDay(DateTime day) {
    return _todosLosEventos.where((evento) {
      final start = DateTime(
        evento.fechaInicio.year,
        evento.fechaInicio.month,
        evento.fechaInicio.day,
      );
      final end = DateTime(
        evento.fechaFin.year,
        evento.fechaFin.month,
        evento.fechaFin.day,
      );
      final queryDay = DateTime(day.year, day.month, day.day);

      return (queryDay.isAtSameMomentAs(start) || queryDay.isAfter(start)) &&
          (queryDay.isAtSameMomentAs(end) || queryDay.isBefore(end));
    }).toList();
  }

  // Devuelve todos los eventos ordenados para la agenda
  List<Evento> _getEventsForAgenda() {
    final copy = List<Evento>.from(_todosLosEventos);
    copy.sort((a, b) => a.fechaInicio.compareTo(b.fechaInicio));
    return copy;
  }

  // -------------------------
  // UI Helpers
  // -------------------------

  // Widget para marcador pequeño (puntos) en calendario
  Widget _buildEventMarker(DateTime date, List<Evento> events) {
    // si hay varios, mostrar hasta 3 puntos de colores
    final markers = events.take(3).map((e) => e.color).toList();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: markers
          .map(
            (c) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: c, shape: BoxShape.circle),
            ),
          )
          .toList(),
    );
  }

  // Tarjeta rica para la agenda
  Widget _buildAgendaCard(Evento evento, int index) {
    final begin = evento.fechaInicio;
    final end = evento.fechaFin;
    final dateRange = (begin == end)
        ? '${begin.day.toString().padLeft(2, '0')}/${begin.month.toString().padLeft(2, '0')}/${begin.year}'
        : '${begin.day.toString().padLeft(2, '0')}/${begin.month.toString().padLeft(2, '0')}' +
              ' - ' +
              '${end.day.toString().padLeft(2, '0')}/${end.month.toString().padLeft(2, '0')}/${end.year}';

    return SizeTransition(
      sizeFactor: CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOut,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [evento.color.withOpacity(0.12), Colors.white],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: evento.color.withOpacity(0.18)),
        ),
        child: Row(
          children: [
            // Color bar
            Container(
              width: 8,
              height: 96,
              decoration: BoxDecoration(
                color: evento.color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),

            Expanded(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                title: Text(
                  evento.titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '${evento.tipo} • $dateRange',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
                leading: CircleAvatar(
                  radius: 26,
                  backgroundColor: evento.color.withOpacity(0.95),
                  child: Icon(evento.icon, color: Colors.white),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey.shade400,
                ),
                onTap: () {
                  // Ejemplo: detalle simple en bottom sheet
                  _showEventoDetalle(evento);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Muestra detalle ligero del evento en un modal
  void _showEventoDetalle(Evento evento) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 14),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: evento.color,
                  child: Icon(evento.icon, color: Colors.white),
                ),
                title: Text(
                  evento.titulo,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(evento.tipo),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    color: Colors.grey.shade700,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    evento.fechaInicio == evento.fechaFin
                        ? '${evento.fechaInicio.day.toString().padLeft(2, '0')}/${evento.fechaInicio.month.toString().padLeft(2, '0')}/${evento.fechaInicio.year}'
                        : '${evento.fechaInicio.day.toString().padLeft(2, '0')}/${evento.fechaInicio.month.toString().padLeft(2, '0')} - ${evento.fechaFin.day.toString().padLeft(2, '0')}/${evento.fechaFin.month.toString().padLeft(2, '0')}/${evento.fechaFin.year}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Descripción del evento o notas importantes pueden aparecer aquí. Puedes personalizarlo para mostrar ubicación, instrucciones o enlaces.',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // -------------------------
  // Build
  // -------------------------
  @override
  Widget build(BuildContext context) {
    final eventosAgenda = _getEventsForAgenda();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Calendario ',
                style: TextStyle(
                  color: purpleDeep,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: 'Escolar',
                style: TextStyle(
                  color: purpleMedium,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: purpleDeep),
          onPressed: () {
            if (widget.onNavigate != null) {
              widget.onNavigate!(0); // 0 = índice de StudentDashboardScreen
            }
          },
        ),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          children: [
            // Encabezado con tarjeta resumen y toggle mes/semana
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [purpleLight, Colors.white],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vista rápida',
                            style: TextStyle(
                              color: purpleDeep.withOpacity(0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.event, color: purpleMedium),
                              const SizedBox(width: 8),
                              Text(
                                '${eventosAgenda.length} próximos eventos',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<CalendarFormat>(
                        value: _calendarFormat,
                        items: const [
                          DropdownMenuItem(
                            value: CalendarFormat.month,
                            child: Text('Mes'),
                          ),
                          DropdownMenuItem(
                            value: CalendarFormat.twoWeeks,
                            child: Text('2 Semanas'),
                          ),
                          DropdownMenuItem(
                            value: CalendarFormat.week,
                            child: Text('Semana'),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _calendarFormat = v);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Calendario
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: TableCalendar<Evento>(
                  firstDay: DateTime.utc(2024, 1, 1),
                  lastDay: DateTime.utc(2027, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  eventLoader: _getEventsForDay,
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                    titleTextStyle: TextStyle(
                      color: purpleDeep,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: purpleDeep,
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: purpleDeep,
                    ),
                  ),
                  calendarStyle: CalendarStyle(
                    markerDecoration: BoxDecoration(
                      color: purpleDeep,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: purpleMedium.withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: purpleDeep,
                      shape: BoxShape.circle,
                    ),
                    defaultTextStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                    weekendTextStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                    outsideDaysVisible: false,
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                    weekendStyle: TextStyle(
                      color: purpleDeep,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      if (events.isEmpty) return const SizedBox.shrink();
                      return Align(
                        alignment: Alignment.bottomCenter,
                        child: _buildEventMarker(date, events),
                      );
                    },
                    dowBuilder: (context, day) {
                      final text = [
                        'L',
                        'M',
                        'M',
                        'J',
                        'V',
                        'S',
                        'D',
                      ][day.weekday - 1];
                      return Center(
                        child: Text(
                          text,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Título de agenda
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Próximos eventos',
                  style: TextStyle(
                    color: purpleDeep,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Agenda (lista)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
                child: ListView.builder(
                  itemCount: eventosAgenda.length,
                  itemBuilder: (context, index) {
                    final evento = eventosAgenda[index];
                    return _buildAgendaCard(evento, index);
                  },
                ),
              ),
            ),
          ],
        ),
      ),

      // FAB para agregar (no funcional, placeholder)
      floatingActionButton: FloatingActionButton(
        backgroundColor: purpleDeep,
        child: const Icon(Icons.add),
        onPressed: () {
          // placeholder para crear evento
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Agregar evento (placeholder)')),
          );
        },
      ),
    );
  }
}

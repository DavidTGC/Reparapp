import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/task.dart';
import '../services/auth_service.dart';
import '../services/task_service.dart';
import '../widgets/custom_widgets.dart';
import 'task_detail_screen.dart';

class TasksScreen extends StatefulWidget {
  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final AuthService _authService = AuthService();
  final TaskService _taskService = TaskService();
  
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  List<Task> _selectedDayTasks = [];
  bool _isLoading = true;
  String? _operarioId;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    try {
      final user = await _authService.getUser();
      if (user != null) {
        setState(() {
          _operarioId = user.id;
        });
        await _loadTasksForDay(_selectedDay);
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      print('Error inicializando pantalla: $e');
    }
  }

  Future<void> _loadTasksForDay(DateTime date) async {
    if (_operarioId == null) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final tasks = await _taskService.getTasksByDate(date, _operarioId!);
      setState(() {
        _selectedDayTasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      print('Error cargando tareas: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    _loadTasksForDay(selectedDay);
  }

  void _openTaskDetail(Task task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TaskDetailScreen(task: task),
      ),
    );
  }

  Future<void> _handleLogout() async {
    await _authService.logout();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Reparapp',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue[600],
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _handleLogout,
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Calendario
                  Container(
                    color: Colors.blue[50],
                    padding: EdgeInsets.all(12),
                    child: TableCalendar(
                      firstDay: DateTime.utc(2024, 1, 1),
                      lastDay: DateTime.utc(2026, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDay, day);
                      },
                      onDaySelected: _onDaySelected,
                      calendarStyle: CalendarStyle(
                        outsideDaysVisible: true,
                        todayDecoration: BoxDecoration(
                          color: Colors.blue[300],
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Colors.blue[600],
                          shape: BoxShape.circle,
                        ),
                        selectedTextStyle: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        todayTextStyle: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        weekendTextStyle: TextStyle(
                          color: Colors.grey[600],
                        ),
                        defaultTextStyle: TextStyle(
                          color: Colors.grey[800],
                        ),
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  // Tareas del día
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tareas para ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 16),
                        _selectedDayTasks.isEmpty
                            ? EmptyState(
                                message: 'No hay tareas para este día',
                                icon: Icons.calendar_today,
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _selectedDayTasks.length,
                                itemBuilder: (context, index) {
                                  final task = _selectedDayTasks[index];
                                  return TaskCard(
                                    title: task.title,
                                    address: task.address,
                                    time: task.scheduledTime,
                                    status: task.status,
                                    date: task.scheduledDate,
                                    onTap: () => _openTaskDetail(task),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

import '../models/task.dart';

class TaskService {
  // Datos de ejemplo - en versión real vendría de un backend
  static final List<Task> _mockTasks = [
    Task(
      id: '1',
      title: 'Reparación de tubería',
      address: 'Calle Principal 15, Apartamento 3A',
      scheduledDate: DateTime.now(),
      scheduledTime: '09:00',
      description: 'Reparación de tubería rota en cocina',
      status: 'pendiente',
      operarioId: '1',
    ),
    Task(
      id: '2',
      title: 'Instalación de grifo',
      address: 'Avenida Central 42, Piso 2',
      scheduledDate: DateTime.now().add(Duration(days: 1)),
      scheduledTime: '15:30',
      description: 'Instalar nuevo grifo en baño',
      status: 'pendiente',
      operarioId: '1',
    ),
    Task(
      id: '3',
      title: 'Revisión eléctrica',
      address: 'Calle Secundaria 8',
      scheduledDate: DateTime.now().add(Duration(days: 2)),
      scheduledTime: '11:00',
      description: 'Revisión de instalación eléctrica',
      status: 'pendiente',
      operarioId: '1',
    ),
    Task(
      id: '4',
      title: 'Reparación de pared',
      address: 'Plaza Mayor 5, Local comercial',
      scheduledDate: DateTime.now().subtract(Duration(days: 1)),
      scheduledTime: '10:00',
      description: 'Reparación de grieta en pared',
      status: 'completada',
      operarioId: '1',
      completedDate: DateTime.now().subtract(Duration(days: 1)),
    ),
  ];

  // Obtener todas las tareas del operario
  Future<List<Task>> getTasksByOperario(String operarioId) async {
    await Future.delayed(Duration(milliseconds: 500)); // Simular delay de red
    return _mockTasks.where((task) => task.operarioId == operarioId).toList();
  }

  // Obtener una tarea específica
  Future<Task?> getTaskById(String taskId) async {
    await Future.delayed(Duration(milliseconds: 300));
    try {
      return _mockTasks.firstWhere((task) => task.id == taskId);
    } catch (e) {
      return null;
    }
  }

  // Actualizar estado de tarea
  Future<bool> updateTaskStatus(String taskId, String newStatus) async {
    await Future.delayed(Duration(milliseconds: 500));
    try {
      final index = _mockTasks.indexWhere((task) => task.id == taskId);
      if (index != -1) {
        return true; // En versión real actualizaría el objeto
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Agregar notas a una tarea
  Future<bool> addNotes(String taskId, String notes) async {
    await Future.delayed(Duration(milliseconds: 500));
    try {
      final index = _mockTasks.indexWhere((task) => task.id == taskId);
      if (index != -1) {
        // En versión real actualizaría las notas
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Agregar foto a una tarea
  Future<bool> addPhoto(String taskId, String photoPath) async {
    await Future.delayed(Duration(milliseconds: 500));
    try {
      final index = _mockTasks.indexWhere((task) => task.id == taskId);
      if (index != -1) {
        // En versión real agregaría la foto
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Obtener tareas por fecha
  Future<List<Task>> getTasksByDate(DateTime date, String operarioId) async {
    await Future.delayed(Duration(milliseconds: 300));
    return _mockTasks
        .where((task) =>
            task.operarioId == operarioId &&
            task.scheduledDate.day == date.day &&
            task.scheduledDate.month == date.month &&
            task.scheduledDate.year == date.year)
        .toList();
  }
}

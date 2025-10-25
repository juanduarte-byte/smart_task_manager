// Import con 'package:'
import 'package:smart_task_manager/features/tasks/domain/entities/task.dart';

abstract class TasksRepository {
  Future<Task> createTask(Task task);

  // Línea dividida
  Future<Task> getTaskDetails(int taskId);
  
  /// Elimina la tarea con el id especificado.
  Future<void> deleteTask(int id);

  /// Actualiza una tarea existente y devuelve la versión actualizada.
  Future<Task> updateTask(Task task);
  
  /// Obtiene una página de tareas. `page` es el índice de página (0-based)
  /// y `pageSize` el tamaño de la página. Devuelve la lista de tareas
  /// solicitada desde el servidor (o caché si aplica).
  Future<List<Task>> getAllTasks({int page = 0, int pageSize = 10});
} // Asegúrate de que haya una línea en blanco al final de este archivo

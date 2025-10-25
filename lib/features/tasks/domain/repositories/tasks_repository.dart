// Import con 'package:'
import 'package:smart_task_manager/features/tasks/domain/entities/task.dart';

abstract class TasksRepository {
  Future<Task> createTask(Task task);

  // Línea dividida
  Future<Task> getTaskDetails(int taskId);
  
  /// Elimina la tarea con el id especificado.
  Future<void> deleteTask(int id);
} // Asegúrate de que haya una línea en blanco al final de este archivo

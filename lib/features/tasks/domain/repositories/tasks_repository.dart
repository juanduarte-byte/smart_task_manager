// Import con 'package:'
import 'package:smart_task_manager/features/tasks/domain/entities/task.dart';


abstract class TasksRepository {
  Future<Task> createTask(Task task);

  // Línea dividida
  Future<Task> getTaskDetails(
      int taskId);
} // Asegúrate de que haya una línea en blanco al final de este archivo

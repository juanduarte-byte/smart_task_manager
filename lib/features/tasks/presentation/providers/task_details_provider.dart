import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_task_manager/features/tasks/domain/entities/task.dart';
import 'package:smart_task_manager/features/tasks/presentation/providers/tasks_repository_provider.dart';

// Define un FutureProvider.family
// '.family' permite pasar un argumento (el taskId) al provider
final taskDetailsProvider = FutureProvider.family<Task, int>((
  ref,
  taskId,
) async {
  // Obtiene la instancia del repositorio
  final tasksRepository = ref.watch(tasksRepositoryProvider);
  // Llama al método del repositorio para obtener los detalles
  return tasksRepository.getTaskDetails(taskId);
});

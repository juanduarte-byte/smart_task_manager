import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_task_manager/features/tasks/domain/entities/task.dart';
import 'package:smart_task_manager/features/tasks/domain/repositories/tasks_repository.dart';
import 'package:smart_task_manager/features/tasks/presentation/providers/tasks_repository_provider.dart';

class UpdateTaskNotifier extends StateNotifier<AsyncValue<Task?>> {
  UpdateTaskNotifier(this._repository) : super(const AsyncValue.data(null));

  final TasksRepository _repository;

  Future<void> updateTask(Task task) async {
    state = const AsyncValue.loading();
    try {
      final updated = await _repository.updateTask(task);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final updateTaskNotifierProvider =
    StateNotifierProvider<UpdateTaskNotifier, AsyncValue<Task?>>(
  (ref) => UpdateTaskNotifier(ref.read(tasksRepositoryProvider)),
);

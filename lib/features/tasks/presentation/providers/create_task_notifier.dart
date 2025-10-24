import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_task_manager/features/tasks/domain/entities/task.dart';
import 'package:smart_task_manager/features/tasks/domain/repositories/tasks_repository.dart';
import 'package:smart_task_manager/features/tasks/presentation/providers/tasks_repository_provider.dart';

// State holds the AsyncValue of the last created Task (or null initially).
class CreateTaskNotifier extends StateNotifier<AsyncValue<Task?>> {
  CreateTaskNotifier(this._repository) : super(const AsyncValue.data(null));

  final TasksRepository _repository;

  /// Create a task.
  ///
  /// This is a stub that simulates a network request. Replace the body
  /// to call the real repository or use DI to provide the repository.
  Future<void> createTask(Task task) async {
    state = const AsyncValue.loading();
    try {
      final created = await _repository.createTask(task);
      state = AsyncValue.data(created);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final createTaskNotifierProvider = StateNotifierProvider<CreateTaskNotifier,
    AsyncValue<Task?>>(
  (ref) => CreateTaskNotifier(ref.read(tasksRepositoryProvider)),
);

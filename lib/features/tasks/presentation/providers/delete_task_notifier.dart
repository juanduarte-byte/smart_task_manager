import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_task_manager/features/tasks/domain/repositories/tasks_repository.dart';
import 'package:smart_task_manager/features/tasks/presentation/providers/tasks_repository_provider.dart';

class DeleteTaskNotifier extends StateNotifier<AsyncValue<void>> {
  DeleteTaskNotifier(this._repository) : super(const AsyncValue.data(null));

  final TasksRepository _repository;

  Future<void> deleteTask(int id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteTask(id);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final deleteTaskNotifierProvider =
    StateNotifierProvider<DeleteTaskNotifier, AsyncValue<void>>(
  (ref) => DeleteTaskNotifier(ref.read(tasksRepositoryProvider)),
);

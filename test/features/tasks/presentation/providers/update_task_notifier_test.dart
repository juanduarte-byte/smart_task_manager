import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_task_manager/features/tasks/domain/entities/task.dart';
import 'package:smart_task_manager/features/tasks/domain/repositories/tasks_repository.dart';
import 'package:smart_task_manager/features/tasks/presentation/providers/update_task_notifier.dart';

class _MockTasksRepository extends Mock implements TasksRepository {}

void main() {
  late _MockTasksRepository mockRepo;

  setUp(() {
    mockRepo = _MockTasksRepository();
  });

  test('updateTask success updates state with updated task', () async {
    const task = Task(id: 1, title: 'A', description: 'B');
    const updated = Task(id: 1, title: 'A updated', description: 'B');

    when(() => mockRepo.updateTask(task)).thenAnswer((_) async => updated);

    final notifier = UpdateTaskNotifier(mockRepo);

    expect(notifier.state, const AsyncValue<Task?>.data(null));

    final f = notifier.updateTask(task);
    expect(notifier.state.isLoading, isTrue);
    await f;

  expect(notifier.state, const AsyncValue<Task?>.data(updated));
    verify(() => mockRepo.updateTask(task)).called(1);
  });
}

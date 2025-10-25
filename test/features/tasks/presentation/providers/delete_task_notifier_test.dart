import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_task_manager/features/tasks/domain/repositories/tasks_repository.dart';
import 'package:smart_task_manager/features/tasks/presentation/providers/delete_task_notifier.dart';

class _MockTasksRepository extends Mock implements TasksRepository {}

void main() {
  late _MockTasksRepository mockRepo;

  setUp(() {
    mockRepo = _MockTasksRepository();
  });

  test('deleteTask success updates state to data', () async {
    when(() => mockRepo.deleteTask(1)).thenAnswer((_) async {});

    final notifier = DeleteTaskNotifier(mockRepo);

  expect(notifier.state, const AsyncValue<void>.data(null));

    final future = notifier.deleteTask(1);

  // after calling, state should be loading
  expect(notifier.state.isLoading, isTrue);

    await future;

  // finally state should be data (null)
  expect(notifier.state, const AsyncValue<void>.data(null));

    verify(() => mockRepo.deleteTask(1)).called(1);
  });
}

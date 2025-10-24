import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_task_manager/features/tasks/domain/entities/task.dart';
import 'package:smart_task_manager/features/tasks/domain/repositories/tasks_repository.dart';
import 'package:smart_task_manager/features/tasks/presentation/providers/create_task_notifier.dart';

class MockTasksRepository extends Mock implements TasksRepository {}
class FakeTask extends Fake implements Task {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeTask());
  });

  late MockTasksRepository repo;
  late CreateTaskNotifier notifier;

  setUp(() {
    repo = MockTasksRepository();
    notifier = CreateTaskNotifier(repo);
  });

  test('createTask success updates state with created task', () async {
    const input = Task(title: 't', description: 'd');
  const created = Task(id: 1, title: 't', description: 'd');

    when(
      () => repo.createTask(any()),
    ).thenAnswer((_) async => created);

    final future = notifier.createTask(input);
    expect(notifier.state.isLoading, isTrue);
    await future;

    expect(notifier.state.value, equals(created));
  });

  test('createTask failure sets error', () async {
    const input = Task(title: 't', description: 'd');

    when(
      () => repo.createTask(any()),
    ).thenThrow(Exception('fail'));

    await expectLater(
      () => notifier.createTask(input),
      throwsA(isA<Exception>()),
    );

    expect(notifier.state, isA<AsyncError<Task?>>());
  });
}

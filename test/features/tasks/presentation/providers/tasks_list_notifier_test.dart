import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_task_manager/features/tasks/domain/entities/task.dart';
import 'package:smart_task_manager/features/tasks/domain/repositories/tasks_repository.dart';
import 'package:smart_task_manager/features/tasks/presentation/providers/tasks_list_notifier.dart';

class _MockTasksRepository extends Mock implements TasksRepository {}

Task _makeTask(int i) => Task(id: i, title: 'Title $i', description: 'Desc $i');

void main() {
  late _MockTasksRepository mockRepo;
  setUp(() {
    mockRepo = _MockTasksRepository();
  });

  test('fetchInitial loads first page and sets hasMore when full page', () async {
    when(() => mockRepo.getAllTasks(pageSize: 3)).thenAnswer(
      (_) async => [_makeTask(1), _makeTask(2), _makeTask(3)],
    );

    final notifier = TasksListNotifier(mockRepo);

    await notifier.fetchInitial(pageSize: 3);

    expect(notifier.state.isLoading, isFalse);
    expect(notifier.state.items.length, 3);
    expect(notifier.state.hasMore, isTrue);
  });

  test('fetchNextPage appends results and updates page/hasMore', () async {
    when(() => mockRepo.getAllTasks(pageSize: 2)).thenAnswer(
      (_) async => [_makeTask(1), _makeTask(2)],
    );
    when(() => mockRepo.getAllTasks(page: 1, pageSize: 2)).thenAnswer(
      (_) async => [_makeTask(3)],
    );

    final notifier = TasksListNotifier(mockRepo);

    await notifier.fetchInitial(pageSize: 2);
    expect(notifier.state.items.length, 2);

    await notifier.fetchNextPage();
    expect(notifier.state.items.length, 3);
    expect(notifier.state.page, 1);
    expect(notifier.state.hasMore, isFalse);
  });

  test('setQuery filters items (debounced)', () async {
    when(() => mockRepo.getAllTasks(pageSize: 5)).thenAnswer(
      (_) async => List.generate(5, (i) => _makeTask(i + 1)),
    );

    final notifier = TasksListNotifier(mockRepo);
    await notifier.fetchInitial(pageSize: 5);
    expect(notifier.state.items.length, 5);

    notifier.setQuery('Title 1');
    // wait for debounce
    await Future<void>.delayed(const Duration(milliseconds: 300));

    expect(notifier.state.filteredItems.length, 1);
    expect(notifier.state.filteredItems.first.title, 'Title 1');
  });
}

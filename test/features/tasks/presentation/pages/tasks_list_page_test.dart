import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_task_manager/features/tasks/domain/entities/task.dart';
import 'package:smart_task_manager/features/tasks/domain/repositories/tasks_repository.dart';
import 'package:smart_task_manager/features/tasks/presentation/pages/tasks_list_page.dart';
import 'package:smart_task_manager/features/tasks/presentation/providers/tasks_list_notifier.dart';
import 'package:smart_task_manager/features/tasks/presentation/providers/tasks_repository_provider.dart';

class _MockTasksRepository extends Mock implements TasksRepository {}

Task _makeTask(int i) => Task(id: i, title: 'T$i', description: 'D$i');

void main() {
  late _MockTasksRepository mockRepo;

  setUp(() {
    mockRepo = _MockTasksRepository();
  });

  testWidgets('TasksListPage shows items and supports loading more', (tester) async {
    when(() => mockRepo.getAllTasks(pageSize: 3))
        .thenAnswer((_) async => [_makeTask(1), _makeTask(2), _makeTask(3)]);
    when(() => mockRepo.getAllTasks(page: 1, pageSize: 3))
        .thenAnswer((_) async => [_makeTask(4)]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [tasksRepositoryProvider.overrideWithValue(mockRepo)],
        child: const MaterialApp(home: TasksListPage()),
      ),
    );

    // Get the provider container from the widget tree and explicitly trigger
    // the initial load (tests shouldn't rely on postFrame callbacks).
    final container = ProviderScope.containerOf(tester.element(find.byType(TasksListPage)));
    await container.read(tasksListNotifierProvider.notifier).fetchInitial(pageSize: 3);
    await tester.pumpAndSettle();

    // initial items
    expect(find.byType(ListTile), findsNWidgets(3));

    // Trigger loading next page via notifier
    await container.read(tasksListNotifierProvider.notifier).fetchNextPage();
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsNWidgets(4));
  });

  testWidgets('search field filters visible items', (tester) async {
    when(() => mockRepo.getAllTasks(pageSize: 5))
        .thenAnswer((_) async => List.generate(5, (i) => _makeTask(i + 1)));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [tasksRepositoryProvider.overrideWithValue(mockRepo)],
        child: const MaterialApp(home: TasksListPage()),
      ),
    );

    final container = ProviderScope.containerOf(tester.element(find.byType(TasksListPage)));
    await container.read(tasksListNotifierProvider.notifier).fetchInitial(pageSize: 5);
    await tester.pumpAndSettle();

  expect(find.byType(ListTile), findsNWidgets(5));

  await tester.enterText(find.byKey(const Key('tasks_search_field')), 'T1');
  // allow debounce in notifier
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pumpAndSettle();

  expect(find.byType(ListTile), findsOneWidget);
  // The search TextField also contains the typed text, so look for the
  // ListTile that contains the visible title.
  expect(find.widgetWithText(ListTile, 'T1'), findsOneWidget);
  });
}

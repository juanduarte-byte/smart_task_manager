import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_task_manager/features/tasks/domain/entities/task.dart';
import 'package:smart_task_manager/features/tasks/domain/repositories/tasks_repository.dart';
import 'package:smart_task_manager/features/tasks/presentation/pages/task_details_page.dart';
import 'package:smart_task_manager/features/tasks/presentation/providers/tasks_repository_provider.dart';

class _MockTasksRepository extends Mock implements TasksRepository {}

void main() {
  late _MockTasksRepository mockRepo;

  setUp(() {
    mockRepo = _MockTasksRepository();
  });

  testWidgets('tapping delete confirms and calls repository then pops',
      (tester) async {
    const taskId = 42;

    // Provide a fake task for the details provider to consume
    final task = Task(
      id: taskId,
      title: 'Test',
      description: 'desc',
      completed: false,
    );

    when(() => mockRepo.getTaskDetails(taskId))
        .thenAnswer((_) async => task);
    when(() => mockRepo.deleteTask(taskId)).thenAnswer((_) async {});

    // Override the repository provider so providers use our mock
    final container = ProviderContainer(overrides: [
      tasksRepositoryProvider.overrideWithValue(mockRepo),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: MaterialApp(
          home: TaskDetailsPage(taskId: taskId),
        ),
      ),
    );

    // Ensure details are shown
    await tester.pumpAndSettle();
    expect(find.text('Título: ${task.title}'), findsOneWidget);

    // Tap delete icon
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    // Dialog shown -> tap 'Eliminar'
    expect(find.text('Eliminar'), findsOneWidget);
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();

    // After deletion, the page should pop (no TaskDetailsPage present)
    expect(find.byType(TaskDetailsPage), findsNothing);

    verify(() => mockRepo.deleteTask(taskId)).called(1);
  });
}

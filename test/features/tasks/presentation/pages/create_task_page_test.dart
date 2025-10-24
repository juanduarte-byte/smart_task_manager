import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_task_manager/features/tasks/domain/entities/task.dart';
import 'package:smart_task_manager/features/tasks/domain/repositories/tasks_repository.dart';
import 'package:smart_task_manager/features/tasks/presentation/pages/create_task_page.dart';
import 'package:smart_task_manager/features/tasks/presentation/providers/tasks_repository_provider.dart';

import '../../../../helpers/helpers.dart';

class MockTasksRepository extends Mock implements TasksRepository {}

class FakeTask extends Fake implements Task {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeTask());
  });

  testWidgets('CreateTaskPage submits and pops on success', (tester) async {
    final mockRepo = MockTasksRepository();
    const created = Task(id: 42, title: 'T', description: 'D');

    when(() => mockRepo.createTask(any())).thenAnswer((_) async => created);

    await tester.pumpApp(
      ProviderScope(
        overrides: [tasksRepositoryProvider.overrideWithValue(mockRepo)],
        child: const CreateTaskPage(),
      ),
    );

    // Fill title and description
    await tester.enterText(find.byType(TextFormField).first, 'T');
    await tester.enterText(find.byType(TextFormField).at(1), 'D');

    // Tap the create button
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // After success the page should pop and be removed from the tree.
    expect(find.byType(CreateTaskPage), findsNothing);
  });
}

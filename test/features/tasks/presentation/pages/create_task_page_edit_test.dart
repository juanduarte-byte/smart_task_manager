import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_task_manager/features/tasks/domain/entities/task.dart';
import 'package:smart_task_manager/features/tasks/presentation/pages/create_task_page.dart';

void main() {
  testWidgets('CreateTaskPage in edit mode shows prefilled fields and update button',
      (tester) async {
    const task = Task(id: 10, title: 'Old', description: 'Desc', completed: true);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: CreateTaskPage(initialTask: task),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Old'), findsOneWidget);
    expect(find.text('Desc'), findsOneWidget);
    expect(find.text('Actualizar tarea'), findsOneWidget);
  });
}

// Ignore for testing purposes
// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_task_manager/app/app.dart';
import 'package:smart_task_manager/features/tasks/presentation/pages/create_task_page.dart';

void main() {
  group('App', () {
    testWidgets('renders CreateTaskPage', (tester) async {
      await tester.pumpWidget(App());
      expect(find.byType(CreateTaskPage), findsOneWidget);
    });
  });
}

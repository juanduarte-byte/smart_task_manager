import 'package:flutter/material.dart';
// --- AÑADIR IMPORTS ---
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_task_manager/features/tasks/presentation/pages/create_task_page.dart';
import 'package:smart_task_manager/l10n/l10n.dart';


class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // --- ENVOLVER CON ProviderScope ---
    return ProviderScope(
      child: MaterialApp(
        theme: ThemeData(
          appBarTheme: AppBarTheme(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          useMaterial3: true,
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        // La página de inicio sigue siendo CreateTaskPage
        home: const CreateTaskPage(),
      ),
    );
  }
}

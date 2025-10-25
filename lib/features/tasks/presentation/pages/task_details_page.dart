import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_task_manager/features/tasks/presentation/providers/delete_task_notifier.dart';
import 'package:smart_task_manager/features/tasks/presentation/providers/task_details_provider.dart';

class TaskDetailsPage extends ConsumerWidget {
  const TaskDetailsPage({required this.taskId, super.key});

  /// Convenience constructor to obtain a `Route` to this page.
  ///
  /// Accepts a [context] so we can reuse the existing ProviderContainer when
  /// pushing the route (important for tests that override providers).
  static Route<void> route(BuildContext context, int taskId) {
    final parent = ProviderScope.containerOf(context);
    return MaterialPageRoute<void>(
      builder: (_) => UncontrolledProviderScope(
        container: parent,
        child: TaskDetailsPage(taskId: taskId),
      ),
    );
  }

  final int taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escucha al provider pasándole el taskId
    final taskAsyncValue = ref.watch(taskDetailsProvider(taskId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de la Tarea'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Confirmar'),
          content: const Text(
            '¿Estás seguro que quieres eliminar\nesta tarea?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Eliminar'),
                    ),
                  ],
                ),
              );

              if (confirmed != true) return;

              // Ejecuta el borrado usando el notifier
              try {
                await ref
                    .read(deleteTaskNotifierProvider.notifier)
                    .deleteTask(taskId);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tarea eliminada')),
                  );
                  Navigator.of(context).pop();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al eliminar: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: Center(
        // AsyncValue tiene helpers .when para manejar los estados
        child: taskAsyncValue.when(
          // Estado de Carga
          loading: () => const CircularProgressIndicator(),
          // Estado de Error
          error: (error, stackTrace) {
            return Text('Error al cargar la tarea: $error');
          },
          // Estado de Éxito (Datos recibidos)
          data: (task) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ID: ${task.id ?? "N/A"}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Título: ${task.title}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Descripción: ${task.description}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  Text('Completada: ${task.completed ? "Sí" : "No"}'),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_task_manager/features/tasks/domain/entities/task.dart';
import 'package:smart_task_manager/features/tasks/presentation/pages/task_details_page.dart';
import 'package:smart_task_manager/features/tasks/presentation/providers/create_task_notifier.dart';
import 'package:smart_task_manager/features/tasks/presentation/providers/update_task_notifier.dart';

class CreateTaskPage extends ConsumerStatefulWidget {
  const CreateTaskPage({super.key, this.initialTask});

  final Task? initialTask;

  static Route<void> route(BuildContext context, {Task? initialTask}) {
    return MaterialPageRoute<void>(builder: (_) => CreateTaskPage(initialTask: initialTask));
  }

  @override
  ConsumerState<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends ConsumerState<CreateTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _completed = false;

  bool get isEditing => widget.initialTask != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final t = widget.initialTask!;
      _titleController.text = t.title;
      _descriptionController.text = t.description;
      _completed = t.completed;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final task = Task(
      id: widget.initialTask?.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      completed: _completed,
    );

    try {
      if (isEditing) {
        await ref.read(updateTaskNotifierProvider.notifier).updateTask(task);

        final state = ref.read(updateTaskNotifierProvider);
        if (state is AsyncData<Task?> && state.value != null) {
          final updated = state.value!;
          if (mounted) {
            await Navigator.of(context).pushReplacement(
              TaskDetailsPage.route(context, updated.id!),
            );
            return;
          }
        }
      } else {
        await ref.read(createTaskNotifierProvider.notifier).createTask(task);

        final state = ref.read(createTaskNotifierProvider);
        // If we have a created task with an ID, navigate to details page
        if (state is AsyncData<Task?> && state.value != null) {
          final created = state.value!;
          if (created.id != null) {
            if (mounted) {
              await Navigator.of(context).pushReplacement(
                TaskDetailsPage.route(context, created.id!),
              );
              return;
            }
          }
        }
      }

      // Fallback: just pop without result
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al crear la tarea: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
  final createState = ref.watch(createTaskNotifierProvider);

    ref.listen<AsyncValue<Task?>>(createTaskNotifierProvider, (previous, next) {
      next.whenOrNull(
        data: (task) {
          if (task != null && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tarea creada correctamente')),
            );
          }
        },
        error: (err, st) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: $err')));
          }
        },
      );
    });

    // Listen for update results and show feedback
    ref.listen<AsyncValue<Task?>>(updateTaskNotifierProvider, (previous, next) {
      next.whenOrNull(
        data: (task) {
          if (task != null && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tarea actualizada correctamente')),
            );
          }
        },
        error: (err, st) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al actualizar: $err')),
            );
          }
        },
      );
    });

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar tarea' : 'Crear tarea')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Requerido';
                  }
                  return null;
                },
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                value: _completed,
                onChanged: (v) => setState(() => _completed = v ?? false),
                title: const Text('Completada'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: createState.isLoading ? null : _onSubmit,
                child: createState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isEditing ? 'Actualizar tarea' : 'Crear tarea'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

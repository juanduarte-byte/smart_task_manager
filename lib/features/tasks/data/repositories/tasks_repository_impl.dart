// Imports ordenados y usando 'package:'
import 'package:smart_task_manager/core/network/network_exceptions.dart';
import 'package:smart_task_manager/features/tasks/data/datasources/tasks_local_datasource.dart';
import 'package:smart_task_manager/features/tasks/data/datasources/tasks_remote_datasource.dart';
import 'package:smart_task_manager/features/tasks/data/models/task_model.dart';
import 'package:smart_task_manager/features/tasks/domain/entities/task.dart';
import 'package:smart_task_manager/features/tasks/domain/repositories/tasks_repository.dart';

class TasksRepositoryImpl implements TasksRepository {
  // Constructor: accept both remote and optional local datasource
  TasksRepositoryImpl(this._remoteDataSource, {TasksLocalDataSource? local}) : _local = local;

  final TasksRemoteDataSource _remoteDataSource;
  final TasksLocalDataSource? _local;

  @override
  Future<Task> createTask(Task task) async {
    try {
      final taskModelToSend = TaskModel(
        title: task.title,
        description: task.description,
        completed: task.completed,
      );

      final createdTaskModel = await _remoteDataSource.createTask(
        taskModelToSend,
      );

      // Update cache if available
      await _local?.cacheTask(createdTaskModel);

      return Task(
        id: createdTaskModel.id,
        title: createdTaskModel.title,
        description: createdTaskModel.description,
        completed: createdTaskModel.completed,
      );
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException('Fallo al crear la tarea: $e');
    }
  }

  @override
  Future<Task> getTaskDetails(int taskId) async {
    try {
      // Try local cache first
      if (_local != null) {
  final cached = await _local.getCachedTasks();
        final found = cached.firstWhere(
          (t) => t.id == taskId,
          orElse: () => const TaskModel(title: '', description: ''),
        );
        if (found.id != null) {
          return Task(
            id: found.id,
            title: found.title,
            description: found.description,
            completed: found.completed,
          );
        }
      }

      final taskModel = await _remoteDataSource.getTaskDetails(taskId);

      // Update cache with fresh data
      await _local?.cacheTask(taskModel);

      return Task(
        id: taskModel.id,
        title: taskModel.title,
        description: taskModel.description,
        completed: taskModel.completed,
      );
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException('Fallo al obtener los detalles de la tarea: $e');
    }
  }

  @override
  Future<void> deleteTask(int id) async {
    try {
      await _remoteDataSource.deleteTask(id);
      await _local?.deleteCachedTask(id);
      return;
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException('Fallo al eliminar la tarea: $e');
    }
  }


  @override
  Future<Task> updateTask(Task task) async {
    try {
      final taskModelToSend = TaskModel(
        id: task.id,
        title: task.title,
        description: task.description,
        completed: task.completed,
      );

      final updatedModel = await _remoteDataSource.updateTask(taskModelToSend);

      return Task(
        id: updatedModel.id,
        title: updatedModel.title,
        description: updatedModel.description,
        completed: updatedModel.completed,
      );
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException('Fallo al actualizar la tarea: $e');
    }
  }

  @override
  Future<List<Task>> getAllTasks({int page = 0, int pageSize = 10}) async {
    try {
      final models = await _remoteDataSource.getAllTasks(
        page: page,
        pageSize: pageSize,
      );

      // Optionally cache fetched tasks (overwrite existing entries).
      await _local?.cacheTasks(models);

      return models
          .map((m) => Task(
                id: m.id,
                title: m.title,
                description: m.description,
                completed: m.completed,
              ))
          .toList();
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException('Fallo al obtener todas las tareas: $e');
    }
  }
} // <- Asegúrate de que haya una línea en blanco después de esta llave

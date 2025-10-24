// Imports ordenados y usando 'package:'
import 'package:smart_task_manager/core/network/network_exceptions.dart';
import 'package:smart_task_manager/features/tasks/data/datasources/tasks_remote_datasource.dart';
import 'package:smart_task_manager/features/tasks/data/models/task_model.dart';
import 'package:smart_task_manager/features/tasks/domain/entities/task.dart';
import 'package:smart_task_manager/features/tasks/domain/repositories/tasks_repository.dart';

class TasksRepositoryImpl implements TasksRepository {
  // Constructor primero
  TasksRepositoryImpl(this._remoteDataSource);

  final TasksRemoteDataSource _remoteDataSource;

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
      final taskModel = await _remoteDataSource.getTaskDetails(taskId);

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
} // <- Asegúrate de que haya una línea en blanco después de esta llave

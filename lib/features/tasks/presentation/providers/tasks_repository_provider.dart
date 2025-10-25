import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_task_manager/core/network/dio_client.dart';
import 'package:smart_task_manager/features/tasks/data/datasources/tasks_local_datasource.dart';
import 'package:smart_task_manager/features/tasks/data/datasources/tasks_remote_datasource.dart';
import 'package:smart_task_manager/features/tasks/data/repositories/tasks_repository_impl.dart';
import 'package:smart_task_manager/features/tasks/domain/repositories/tasks_repository.dart';

/// Provider que expone la implementación de `TasksRepository`.
///
/// Construye una instancia simple con `DioClient` y el datasource remoto.
final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  final dioClient = DioClient();
  final remote = TasksRemoteDataSource(dioClient);
  final local = TasksLocalDataSource();
  // Do not initialize Hive here; it's initialized at app bootstrap.
  // Providers should not perform package-level initializations that
  // require an async bootstrap in tests. The local datasource will
  // open its box when needed (or after bootstrap completes).
  return TasksRepositoryImpl(remote, local: local);
});

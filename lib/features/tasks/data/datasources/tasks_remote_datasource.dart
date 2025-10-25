// --- CAMBIO: Usar import de paquete y ordenar ---
import 'package:smart_task_manager/core/network/dio_client.dart';
import 'package:smart_task_manager/features/tasks/data/models/task_model.dart';

/// Maneja las llamadas a la API remota para las tareas.
class TasksRemoteDataSource {
  // --- CAMBIO: Constructor primero ---
  TasksRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  /// POST: Crea una nueva tarea en el servidor.
  ///
  /// Usa el endpoint /posts de JSONPlaceholder como simulación.
  Future<TaskModel> createTask(TaskModel task) async {
    // --- CAMBIO: Usar final en lugar de Map<String, dynamic> ---
    final taskJson = task.toJson();
    // JSONPlaceholder espera 'body' en lugar de 'description'
    taskJson['body'] = taskJson.remove('description');
    // JSONPlaceholder también espera 'userId', añadimos uno por defecto
    taskJson['userId'] = 1;

    // --- CAMBIO: Usar final en lugar de Response<dynamic> ---
    final response = await _dioClient.post(
      '/posts', // Endpoint para crear posts (simulando tareas)
      data: taskJson,
    );

    // --- CAMBIO: Verificar tipo antes de usar y hacer cast ---
    if (response.data is Map<String, dynamic>) {
      // La API devuelve el objeto creado con su nuevo ID.
      // Mapeamos 'body' de vuelta a 'description' para nuestro modelo.
      final responseData = Map<String, dynamic>.from(
        response.data as Map,
      ); // Cast explícito
      responseData['description'] = responseData.remove('body');
      return TaskModel.fromJson(responseData);
    } else {
      throw Exception('Formato de respuesta inesperado al crear tarea');
    }
  }

  /// GET: Obtiene los detalles de una tarea específica por su ID.
  Future<TaskModel> getTaskDetails(int taskId) async {
    // --- CAMBIO: Usar final en lugar de Response<dynamic> ---
    final response = await _dioClient.get('/posts/$taskId');

    // --- CAMBIO: Verificar tipo antes de usar y hacer cast ---
    if (response.data is Map<String, dynamic>) {
      // Mapeamos 'body' de vuelta a 'description' para nuestro modelo.
      final responseData = Map<String, dynamic>.from(
        response.data as Map,
      ); // Cast explícito
      responseData['description'] = responseData.remove('body');
      return TaskModel.fromJson(responseData);
    } else {
      throw Exception(
        'Formato de respuesta inesperado al obtener detalles de tarea',
      );
    }
  }

  /// DELETE: Elimina una tarea por su ID en el servidor simulado.
  Future<void> deleteTask(int taskId) async {
    final response = await _dioClient.delete('/posts/$taskId');

  // JSONPlaceholder suele devolver 200 o 204.
  // Si ocurre un error, Dio lanzará y será mapeado por DioClient.
    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    }

    throw Exception(
      'Fallo al eliminar la tarea: ${response.statusCode}',
    );
  }

  /// PUT: Actualiza una tarea existente en el servidor simulado.
  Future<TaskModel> updateTask(TaskModel task) async {
    if (task.id == null) {
      throw Exception('Task id is required for update');
    }

    final taskJson = task.toJson();
    // Map 'description' back to 'body' for JSONPlaceholder
    taskJson['body'] = taskJson.remove('description');

  // Use PATCH instead of PUT to update partial fields. JSONPlaceholder
  // accepts PATCH for partial updates and is often more tolerant.
  final response = await _dioClient.patch('/posts/${task.id}', data: taskJson);

    if (response.data is Map<String, dynamic>) {
      final responseData = Map<String, dynamic>.from(response.data as Map);
      responseData['description'] = responseData.remove('body');
      return TaskModel.fromJson(responseData);
    }

    throw Exception('Formato de respuesta inesperado al actualizar tarea');
  }

  /// GET: Obtiene una página de tareas (simulado con /posts).
  /// Usa los parámetros `_start` y `_limit` de JSONPlaceholder para
  /// paginar resultados. `page` es 0-based.
  Future<List<TaskModel>> getAllTasks({int page = 0, int pageSize = 10}) async {
    final start = page * pageSize;
    final response = await _dioClient.get(
      '/posts',
      queryParams: {
        '_start': start,
        '_limit': pageSize,
      },
    );

    if (response.data is List) {
      final responseList = response.data as List;
      return responseList.map((json) {
        final mapData = Map<String, dynamic>.from(json as Map);
        mapData['description'] = mapData.remove('body');
        return TaskModel.fromJson(mapData);
      }).toList();
    }

    throw Exception(
      'Formato de respuesta inesperado al obtener todas las tareas',
    );
  }
}

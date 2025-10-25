import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_task_manager/features/tasks/data/models/task_model.dart';

class TasksLocalDataSource {
  static const String boxName = 'tasks_box';

  Future<void> init() async {
    // Hive is initialized in app bootstrap. Here we only ensure the box is open.
    await Hive.openBox<dynamic>(boxName);
  }

  Box<dynamic> get _box => Hive.box<dynamic>(boxName);

  Future<void> cacheTasks(List<TaskModel> tasks) async {
    final map = <String, dynamic>{};
    for (final t in tasks) {
      if (t.id != null) map[t.id!.toString()] = t.toJson();
    }
    await _box.putAll(map);
  }

  Future<List<TaskModel>> getCachedTasks() async {
    final values = _box.toMap().values;
    final list = values.map((e) {
      final json = Map<String, dynamic>.from(e as Map<String, dynamic>);
      return TaskModel.fromJson(json);
    }).toList();
    return list;
  }

  Future<void> cacheTask(TaskModel task) async {
    if (task.id == null) return;
    await _box.put(task.id!.toString(), task.toJson());
  }

  Future<void> updateCachedTask(TaskModel task) async {
    if (task.id == null) return;
    await _box.put(task.id!.toString(), task.toJson());
  }

  Future<void> deleteCachedTask(int id) async {
    await _box.delete(id.toString());
  }
}

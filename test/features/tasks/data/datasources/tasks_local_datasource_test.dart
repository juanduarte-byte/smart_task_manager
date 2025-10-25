import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:smart_task_manager/features/tasks/data/datasources/tasks_local_datasource.dart';
import 'package:smart_task_manager/features/tasks/data/models/task_model.dart';

void main() {
  late TasksLocalDataSource local;

  setUp(() async {
    await setUpTestHive();
    local = TasksLocalDataSource();
    await local.init();
  });

  tearDown(() async {
    await tearDownTestHive();
  });

  test('cacheTask and getCachedTasks should store and retrieve a task', () async {
    final task = TaskModel(id: 1, title: 'T1', description: 'd1');
    await local.cacheTask(task);

    final cached = await local.getCachedTasks();
    expect(cached.length, 1);
    expect(cached.first.id, 1);
    expect(cached.first.title, 'T1');
  });

  test('updateCachedTask should overwrite existing task', () async {
    final task = TaskModel(id: 2, title: 'Old', description: 'old');
    await local.cacheTask(task);

    final updated = TaskModel(id: 2, title: 'New', description: 'new');
    await local.updateCachedTask(updated);

    final cached = await local.getCachedTasks();
    expect(cached.length, 1);
    expect(cached.first.title, 'New');
  });

  test('deleteCachedTask should remove task', () async {
    final task = TaskModel(id: 3, title: 'T3', description: 'd3');
    await local.cacheTask(task);

    await local.deleteCachedTask(3);
    final cached = await local.getCachedTasks();
    expect(cached.where((t) => t.id == 3).isEmpty, true);
  });

  test('cacheTasks should store multiple tasks', () async {
    final tasks = [
      TaskModel(id: 4, title: 'A', description: 'a'),
      TaskModel(id: 5, title: 'B', description: 'b'),
    ];
    await local.cacheTasks(tasks);

    final cached = await local.getCachedTasks();
    expect(cached.length, 2);
    final ids = cached.map((t) => t.id).toSet();
    expect(ids.containsAll({4, 5}), true);
  });
}

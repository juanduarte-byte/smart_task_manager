import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_task_manager/features/tasks/presentation/providers/tasks_list_notifier.dart';

class TasksListPage extends ConsumerStatefulWidget {
  const TasksListPage({super.key});

  @override
  ConsumerState<TasksListPage> createState() => _TasksListPageState();
}

class _TasksListPageState extends ConsumerState<TasksListPage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    // fetch initial page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tasksListNotifierProvider.notifier).fetchInitial();
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    final notifier = ref.read(tasksListNotifierProvider.notifier);
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      notifier.fetchNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tasksListNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(tasksListNotifierProvider.notifier).refresh();
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                key: const Key('tasks_search_field'),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search tasks...',
                ),
                onChanged: (v) => ref.read(tasksListNotifierProvider.notifier).setQuery(v),
              ),
            ),
            Expanded(
              child: Builder(builder: (context) {
                if (state.isLoading && state.items.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final list = state.filteredItems;

                return ListView.builder(
                  key: const Key('tasks_list_view'),
                  controller: _scrollController,
                  itemCount: list.length + (state.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= list.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final item = list[index];
                    return ListTile(
                      title: Text(item.title),
                      subtitle: Text(item.description),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

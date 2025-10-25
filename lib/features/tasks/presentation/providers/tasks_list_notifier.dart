import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_task_manager/features/tasks/domain/entities/task.dart';
import 'package:smart_task_manager/features/tasks/domain/repositories/tasks_repository.dart';
import 'package:smart_task_manager/features/tasks/presentation/providers/tasks_repository_provider.dart';

class TasksListState {
  TasksListState({
    required this.items,
    required this.filteredItems,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    required this.page,
    required this.pageSize,
    required this.query,
    this.error,
  });

  factory TasksListState.initial() => TasksListState(
        items: const [],
        filteredItems: const [],
        isLoading: false,
        isLoadingMore: false,
        hasMore: true,
        page: 0,
        pageSize: 10,
        query: '',
      );

  final List<Task> items;
  final List<Task> filteredItems;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int page;
  final int pageSize;
  final String query;
  final String? error;

  TasksListState copyWith({
    List<Task>? items,
    List<Task>? filteredItems,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? page,
    int? pageSize,
    String? query,
    String? error,
  }) {
    return TasksListState(
      items: items ?? this.items,
      filteredItems: filteredItems ?? this.filteredItems,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      query: query ?? this.query,
      error: error,
    );
  }
}

class TasksListNotifier extends StateNotifier<TasksListState> {
  TasksListNotifier(this._repository) : super(TasksListState.initial());

  final TasksRepository _repository;
  Timer? _debounceTimer;

  Future<void> fetchInitial({int pageSize = 10}) async {
    state = state.copyWith(isLoading: true, page: 0, pageSize: pageSize);
    try {
      const page = 0;
      final results = await _repository.getAllTasks(pageSize: pageSize);
      final hasMore = results.length == pageSize;
      state = state.copyWith(
        items: results,
        filteredItems: _applyQueryFilter(results, state.query),
        isLoading: false,
        page: page,
        hasMore: hasMore,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchNextPage() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.page + 1;
    try {
      final results = await _repository.getAllTasks(page: nextPage, pageSize: state.pageSize);
      final hasMore = results.length == state.pageSize;
      final combined = List<Task>.from(state.items)..addAll(results);
      state = state.copyWith(
        items: combined,
        filteredItems: _applyQueryFilter(combined, state.query),
        isLoadingMore: false,
        page: nextPage,
        hasMore: hasMore,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    await fetchInitial(pageSize: state.pageSize);
  }

  void setQuery(String q) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 250), () {
      state = state.copyWith(query: q, filteredItems: _applyQueryFilter(state.items, q));
    });
  }

  List<Task> _applyQueryFilter(List<Task> items, String query) {
    if (query.isEmpty) return items;
    final q = query.toLowerCase();
    return items.where((t) {
      return t.title.toLowerCase().contains(q) || t.description.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

final tasksListNotifierProvider = StateNotifierProvider<TasksListNotifier, TasksListState>(
  (ref) => TasksListNotifier(ref.read(tasksRepositoryProvider)),
);

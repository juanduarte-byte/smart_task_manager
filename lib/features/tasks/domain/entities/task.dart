import 'package:equatable/equatable.dart';

class Task extends Equatable {
  // Avisos 'always_put_required_named_parameters_first' aquí son ignorables
  const Task({
    required this.title,
    required this.description,
    this.id,
    this.completed = false,
  });

  final int? id;
  final String title;
  final String description;
  final bool completed;

  @override
  List<Object?> get props => [id, title, description, completed];

  Task copyWith({
    int? id,
    String? title,
    String? description,
    bool? completed,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
    );
  }
} // Asegúrate de que haya una línea en blanco al final de este archivo// Asegúrate de que haya una línea en blanco al final de este archivo

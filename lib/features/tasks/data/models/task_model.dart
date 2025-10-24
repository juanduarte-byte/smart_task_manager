import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_model.freezed.dart'; // Generado por freezed
part 'task_model.g.dart'; // Generado por json_serializable

@freezed
class TaskModel with _$TaskModel {
  const factory TaskModel({
    required String title,
    required String description, // Usaremos 'body' de la API aquí
    int? id, // El ID puede ser nulo al crear, la API lo asigna
    @Default(false) bool completed, // Usaremos 'completed' si la API lo tuviera
    int? userId, // Campo extra de JSONPlaceholder
  }) = _TaskModel;

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);
}

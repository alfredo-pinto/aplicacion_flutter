import 'package:flutter/material.dart';

enum Priority { baja, media, alta }
enum TaskStatus { pendiente, enProgreso, completada }

class Task {
  final int id;
  String title;
  String category;
  String description;
  DateTime dueDate;
  TimeOfDay dueTime;

  Color tagColor;
  IconData categoryIcon;
  Priority priority;
  TaskStatus status;

  Task({
    required this.id,
    required this.title,
    required this.category,
    this.description = '',
    DateTime? dueDate,
    required this.dueTime,

    required this.tagColor,
    required this.categoryIcon,
    required this.priority,
    this.status = TaskStatus.pendiente,
  }) : dueDate = dueDate ?? DateTime.now();
}

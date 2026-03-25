import 'package:flutter/material.dart';

class TechnicianTask {
  final String id;
  final String title;
  final String priorityKey;
  final Color priorityColor;
  final String deadline;
  final String statusKey;
  final String imageUrl;
  final List<String> materials;
  final String notes;
  final String duration;

  TechnicianTask({
    required this.id,
    required this.title,
    required this.priorityKey,
    required this.priorityColor,
    required this.deadline,
    required this.statusKey,
    required this.imageUrl,
    required this.materials,
    required this.notes,
    required this.duration,
  });
}

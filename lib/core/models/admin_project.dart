import 'package:flutter/material.dart';

class AdminProject {
  final String name;
  final String location;
  final String teamAvatar;
  final String status;
  final Color statusColor;
  final Color statusTextColor;

  AdminProject({
    required this.name,
    required this.location,
    required this.teamAvatar,
    required this.status,
    required this.statusColor,
    required this.statusTextColor,
  });
}

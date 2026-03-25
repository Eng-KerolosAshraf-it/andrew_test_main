import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────
class AdminProjectModel {
  final int id;
  final String title;
  final String? description;
  final String status;
  final String? clientId;
  final String? clientName;
  final String? engineerName;
  final String? engineerId;
  final DateTime createdAt;

  const AdminProjectModel({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    this.clientId,
    this.clientName,
    this.engineerName,
    this.engineerId,
    required this.createdAt,
  });

  // ── الحالة بالعربي ────────────────────────
  String get statusAr {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'under_review':
        return 'تحت المراجعة';
      case 'active':
      case 'design_in_progress':
        return 'جاري التنفيذ';
      case 'waiting_client_approval':
        return 'انتظار موافقة العميل';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  // ── لون الحالة ────────────────────────────
  Color get statusColor {
    switch (status) {
      case 'pending':
        return Colors.grey.shade100;
      case 'under_review':
        return Colors.orange.shade50;
      case 'active':
      case 'design_in_progress':
        return Colors.blue.shade50;
      case 'waiting_client_approval':
        return Colors.purple.shade50;
      case 'completed':
        return Colors.green.shade50;
      case 'cancelled':
        return Colors.red.shade50;
      default:
        return Colors.grey.shade100;
    }
  }

  Color get statusTextColor {
    switch (status) {
      case 'pending':
        return Colors.grey.shade700;
      case 'under_review':
        return Colors.orange.shade700;
      case 'active':
      case 'design_in_progress':
        return Colors.blue.shade700;
      case 'waiting_client_approval':
        return Colors.purple.shade700;
      case 'completed':
        return Colors.green.shade700;
      case 'cancelled':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  factory AdminProjectModel.fromJson(Map<String, dynamic> json) {
    // client name من الـ join
    String? clientName;
    if (json['client'] != null) {
      clientName = json['client']['name'] as String?;
    }

    // engineer name من project_assignments → users
    String? engineerName;
    String? engineerId;
    final assignments = json['project_assignments'] as List?;
    if (assignments != null && assignments.isNotEmpty) {
      final firstAssignment = assignments.first as Map<String, dynamic>;
      final engineer = firstAssignment['users'] as Map<String, dynamic>?;
      engineerName = engineer?['name'] as String?;
      engineerId = firstAssignment['engineer_id'] as String?;
    }

    return AdminProjectModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'pending',
      clientId: json['client_id'] as String?,
      clientName: clientName,
      engineerName: engineerName,
      engineerId: engineerId,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

// ─────────────────────────────────────────────
// State
// ─────────────────────────────────────────────
class AdminProjectsState {
  final List<AdminProjectModel> projects;
  final bool isLoading;
  final String? errorMessage;
  final bool isActionLoading;
  final String searchQuery;

  const AdminProjectsState({
    this.projects = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isActionLoading = false,
    this.searchQuery = '',
  });

  // ── فلترة بالبحث ──────────────────────────
  List<AdminProjectModel> get filteredProjects {
    if (searchQuery.isEmpty) return projects;
    final q = searchQuery.toLowerCase();
    return projects.where((p) =>
      p.title.toLowerCase().contains(q) ||
      (p.clientName?.toLowerCase().contains(q) ?? false) ||
      (p.engineerName?.toLowerCase().contains(q) ?? false) ||
      p.statusAr.contains(q),
    ).toList();
  }

  AdminProjectsState copyWith({
    List<AdminProjectModel>? projects,
    bool? isLoading,
    String? errorMessage,
    bool? isActionLoading,
    String? searchQuery,
  }) {
    return AdminProjectsState(
      projects: projects ?? this.projects,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

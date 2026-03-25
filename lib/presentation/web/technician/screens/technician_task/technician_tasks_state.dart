class TechnicianTaskModel {
  final int id;
  final int projectId;
  final String? projectTitle;
  final String title;
  final String? description;
  final String status;
  final String priority;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final DateTime createdAt;

  const TechnicianTaskModel({
    required this.id,
    required this.projectId,
    this.projectTitle,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.dueDate,
    this.completedAt,
    required this.createdAt,
  });

  factory TechnicianTaskModel.fromJson(Map<String, dynamic> json) {
    return TechnicianTaskModel(
      id: json['id'] as int,
      projectId: json['project_id'] as int,
      projectTitle: json['project'] != null ? json['project']['title'] as String? : null,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'pending',
      priority: json['priority'] as String? ?? 'medium',
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  String statusLabel(bool isAr) {
    switch (status) {
      case 'pending':     return isAr ? 'قيد الانتظار' : 'Pending';
      case 'in_progress': return isAr ? 'جاري التنفيذ' : 'In Progress';
      case 'completed':   return isAr ? 'مكتمل'        : 'Completed';
      case 'cancelled':   return isAr ? 'ملغي'         : 'Cancelled';
      default:            return status;
    }
  }

  String priorityLabel(bool isAr) {
    switch (priority) {
      case 'low':    return isAr ? 'منخفض' : 'Low';
      case 'medium': return isAr ? 'متوسط' : 'Medium';
      case 'high':   return isAr ? 'عالي'  : 'High';
      default:       return priority;
    }
  }

  int get statusBgColor {
    switch (status) {
      case 'pending':     return 0xFFFFF8E1;
      case 'in_progress': return 0xFFE3F2FD;
      case 'completed':   return 0xFFE8F5E9;
      case 'cancelled':   return 0xFFFFEBEE;
      default:            return 0xFFF5F5F5;
    }
  }

  int get statusTextColor {
    switch (status) {
      case 'pending':     return 0xFFF59E0B;
      case 'in_progress': return 0xFF2196F3;
      case 'completed':   return 0xFF4CAF50;
      case 'cancelled':   return 0xFFF44336;
      default:            return 0xFF9E9E9E;
    }
  }

  int get priorityColor {
    switch (priority) {
      case 'low':    return 0xFF10B981;
      case 'medium': return 0xFFF59E0B;
      case 'high':   return 0xFFEF4444;
      default:       return 0xFF6B7280;
    }
  }

  bool get isOverdue {
    if (dueDate == null || status == 'completed') return false;
    return DateTime.now().isAfter(dueDate!);
  }
}

class TechnicianTasksState {
  final List<TechnicianTaskModel> tasks;
  final bool isLoading;
  final String? errorMessage;
  final String filterStatus;

  const TechnicianTasksState({
    this.tasks = const [],
    this.isLoading = false,
    this.errorMessage,
    this.filterStatus = 'all',
  });

  List<TechnicianTaskModel> get filteredTasks {
    if (filterStatus == 'all') return tasks;
    return tasks.where((t) => t.status == filterStatus).toList();
  }

  TechnicianTasksState copyWith({
    List<TechnicianTaskModel>? tasks,
    bool? isLoading,
    String? errorMessage,
    String? filterStatus,
  }) {
    return TechnicianTasksState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      filterStatus: filterStatus ?? this.filterStatus,
    );
  }
}

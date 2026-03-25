class TechnicianDashboardStats {
  final int totalTasks;
  final int pendingTasks;
  final int inProgressTasks;
  final int completedTasks;
  final int overdueTasks;

  const TechnicianDashboardStats({
    this.totalTasks = 0,
    this.pendingTasks = 0,
    this.inProgressTasks = 0,
    this.completedTasks = 0,
    this.overdueTasks = 0,
  });
}

class TechnicianDashboardTask {
  final int id;
  final String title;
  final String? description;
  final String status;
  final String priority;
  final String? projectTitle;
  final DateTime? dueDate;
  final DateTime createdAt;

  const TechnicianDashboardTask({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.projectTitle,
    this.dueDate,
    required this.createdAt,
  });

  factory TechnicianDashboardTask.fromJson(Map<String, dynamic> json) {
    return TechnicianDashboardTask(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'pending',
      priority: json['priority'] as String? ?? 'medium',
      projectTitle: json['project'] != null ? json['project']['title'] as String? : null,
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  String statusLabel(bool isAr) {
    switch (status) {
      case 'pending':     return isAr ? 'قيد الانتظار' : 'Pending';
      case 'in_progress': return isAr ? 'جاري التنفيذ' : 'In Progress';
      case 'completed':   return isAr ? 'مكتمل'        : 'Completed';
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

  int get priorityColor {
    switch (priority) {
      case 'low':    return 0xFF10B981;
      case 'medium': return 0xFFF59E0B;
      case 'high':   return 0xFFEF4444;
      default:       return 0xFF6B7280;
    }
  }

  int get statusBgColor {
    switch (status) {
      case 'pending':     return 0xFFFFF8E1;
      case 'in_progress': return 0xFFE3F2FD;
      case 'completed':   return 0xFFE8F5E9;
      default:            return 0xFFF5F5F5;
    }
  }

  int get statusTextColor {
    switch (status) {
      case 'pending':     return 0xFFF59E0B;
      case 'in_progress': return 0xFF2196F3;
      case 'completed':   return 0xFF10B981;
      default:            return 0xFF9E9E9E;
    }
  }

  bool get isOverdue {
    if (dueDate == null || status == 'completed') return false;
    return DateTime.now().isAfter(dueDate!);
  }
}

class TechnicianDashboardState {
  final TechnicianDashboardStats stats;
  final List<TechnicianDashboardTask> pendingTasks;
  final bool isLoading;
  final String? errorMessage;

  const TechnicianDashboardState({
    this.stats = const TechnicianDashboardStats(),
    this.pendingTasks = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  TechnicianDashboardState copyWith({
    TechnicianDashboardStats? stats,
    List<TechnicianDashboardTask>? pendingTasks,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TechnicianDashboardState(
      stats: stats ?? this.stats,
      pendingTasks: pendingTasks ?? this.pendingTasks,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

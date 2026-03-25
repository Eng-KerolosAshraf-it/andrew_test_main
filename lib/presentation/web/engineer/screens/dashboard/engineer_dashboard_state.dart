class EngineerDashboardStats {
  final int totalProjects;
  final int activeProjects;
  final int totalTasks;
  final int pendingTasks;
  final int completedTasks;
  final int totalReports;
  final int openIssues;

  const EngineerDashboardStats({
    this.totalProjects = 0,
    this.activeProjects = 0,
    this.totalTasks = 0,
    this.pendingTasks = 0,
    this.completedTasks = 0,
    this.totalReports = 0,
    this.openIssues = 0,
  });
}

class EngineerDashboardProject {
  final int id;
  final String title;
  final String? description;
  final String status;
  final String? clientName;
  final DateTime createdAt;

  const EngineerDashboardProject({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    this.clientName,
    required this.createdAt,
  });

  factory EngineerDashboardProject.fromJson(Map<String, dynamic> json) {
    return EngineerDashboardProject(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'pending',
      clientName: json['client'] != null ? json['client']['name'] as String? : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  String statusLabel(bool isAr) {
    switch (status) {
      case 'pending':                 return isAr ? 'قيد الانتظار'    : 'Pending';
      case 'under_review':            return isAr ? 'قيد المراجعة'    : 'Under Review';
      case 'active':                  return isAr ? 'نشط'             : 'Active';
      case 'waiting_client_approval': return isAr ? 'بانتظار الموافقة': 'Awaiting Approval';
      case 'completed':               return isAr ? 'مكتمل'           : 'Completed';
      case 'cancelled':               return isAr ? 'ملغي'            : 'Cancelled';
      default:                        return status;
    }
  }

  int get statusBgColor {
    switch (status) {
      case 'pending':                 return 0xFFFFF8E1;
      case 'under_review':            return 0xFFE3F2FD;
      case 'active':                  return 0xFFE8F5E9;
      case 'waiting_client_approval': return 0xFFFCE4EC;
      case 'completed':               return 0xFFEDE7F6;
      case 'cancelled':               return 0xFFFFEBEE;
      default:                        return 0xFFF5F5F5;
    }
  }

  int get statusTextColor {
    switch (status) {
      case 'pending':                 return 0xFFF59E0B;
      case 'under_review':            return 0xFF2196F3;
      case 'active':                  return 0xFF059669;
      case 'waiting_client_approval': return 0xFFE91E63;
      case 'completed':               return 0xFF7C3AED;
      case 'cancelled':               return 0xFFF44336;
      default:                        return 0xFF9E9E9E;
    }
  }
}

class EngineerDashboardTask {
  final int id;
  final String title;
  final String status;
  final String priority;
  final DateTime? dueDate;

  const EngineerDashboardTask({
    required this.id,
    required this.title,
    required this.status,
    required this.priority,
    this.dueDate,
  });

  factory EngineerDashboardTask.fromJson(Map<String, dynamic> json) {
    return EngineerDashboardTask(
      id: json['id'] as int,
      title: json['title'] as String,
      status: json['status'] as String? ?? 'pending',
      priority: json['priority'] as String? ?? 'medium',
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
    );
  }

  int get priorityColor {
    switch (priority) {
      case 'low':    return 0xFF10B981;
      case 'medium': return 0xFFF59E0B;
      case 'high':   return 0xFFEF4444;
      default:       return 0xFF6B7280;
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

  bool get isOverdue {
    if (dueDate == null || status == 'completed') return false;
    return DateTime.now().isAfter(dueDate!);
  }
}

class EngineerDashboardState {
  final EngineerDashboardStats stats;
  final List<EngineerDashboardProject> activeProjects;
  final List<EngineerDashboardTask> recentTasks;
  final bool isLoading;
  final String? errorMessage;

  const EngineerDashboardState({
    this.stats = const EngineerDashboardStats(),
    this.activeProjects = const [],
    this.recentTasks = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  EngineerDashboardState copyWith({
    EngineerDashboardStats? stats,
    List<EngineerDashboardProject>? activeProjects,
    List<EngineerDashboardTask>? recentTasks,
    bool? isLoading,
    String? errorMessage,
  }) {
    return EngineerDashboardState(
      stats: stats ?? this.stats,
      activeProjects: activeProjects ?? this.activeProjects,
      recentTasks: recentTasks ?? this.recentTasks,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

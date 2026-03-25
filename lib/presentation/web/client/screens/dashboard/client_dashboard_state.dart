class ClientDashboardStats {
  final int totalProjects;
  final int activeProjects;
  final int completedProjects;
  final int pendingReports;
  final int totalReports;

  const ClientDashboardStats({
    this.totalProjects = 0,
    this.activeProjects = 0,
    this.completedProjects = 0,
    this.pendingReports = 0,
    this.totalReports = 0,
  });
}

class ClientDashboardRecentReport {
  final int id;
  final String? reportType;
  final String? description;
  final String? status;
  final DateTime createdAt;
  final String? submittedByName;
  final String? projectTitle;

  const ClientDashboardRecentReport({
    required this.id,
    this.reportType,
    this.description,
    this.status,
    required this.createdAt,
    this.submittedByName,
    this.projectTitle,
  });

  factory ClientDashboardRecentReport.fromJson(Map<String, dynamic> json) {
    final submittedBy = json['submitted_by_user'] as Map<String, dynamic>?;
    final project = json['project'] as Map<String, dynamic>?;
    return ClientDashboardRecentReport(
      id: json['id'] as int,
      reportType: json['report_type'] as String?,
      description: json['description'] as String?,
      status: json['status'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      submittedByName: submittedBy?['name'] as String?,
      projectTitle: project?['title'] as String?,
    );
  }

  String reportTypeLabel(bool isAr) {
    switch (reportType) {
      case 'daily':   return isAr ? 'تقرير يومي'    : 'Daily Report';
      case 'weekly':  return isAr ? 'تقرير أسبوعي'  : 'Weekly Report';
      case 'monthly': return isAr ? 'تقرير شهري'    : 'Monthly Report';
      case 'issue':   return isAr ? 'بلاغ مشكلة'    : 'Issue Report';
      default:        return reportType ?? (isAr ? 'تقرير' : 'Report');
    }
  }

  int get statusColor {
    switch (status) {
      case 'pending':  return 0xFFF59E0B;
      case 'reviewed': return 0xFF2196F3;
      case 'approved': return 0xFF4CAF50;
      default:         return 0xFF9E9E9E;
    }
  }
}

class ClientDashboardActiveProject {
  final int id;
  final String title;
  final String? description;
  final String status;
  final DateTime createdAt;

  const ClientDashboardActiveProject({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.createdAt,
  });

  factory ClientDashboardActiveProject.fromJson(Map<String, dynamic> json) {
    return ClientDashboardActiveProject(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'active',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  String statusLabel(bool isAr) {
    switch (status) {
      case 'pending':                 return isAr ? 'قيد الانتظار'       : 'Pending';
      case 'under_review':            return isAr ? 'قيد المراجعة'       : 'Under Review';
      case 'active':                  return isAr ? 'نشط'                : 'Active';
      case 'waiting_client_approval': return isAr ? 'بانتظار موافقتك'    : 'Awaiting Approval';
      case 'completed':               return isAr ? 'مكتمل'              : 'Completed';
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
      default:                        return 0xFFF5F5F5;
    }
  }

  int get statusTextColor {
    switch (status) {
      case 'pending':                 return 0xFFF59E0B;
      case 'under_review':            return 0xFF2196F3;
      case 'active':                  return 0xFF4CAF50;
      case 'waiting_client_approval': return 0xFFE91E63;
      case 'completed':               return 0xFF7C3AED;
      default:                        return 0xFF9E9E9E;
    }
  }
}

class ClientDashboardState {
  final ClientDashboardStats stats;
  final List<ClientDashboardActiveProject> activeProjects;
  final List<ClientDashboardRecentReport> recentReports;
  final bool isLoading;
  final String? errorMessage;

  const ClientDashboardState({
    this.stats = const ClientDashboardStats(),
    this.activeProjects = const [],
    this.recentReports = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ClientDashboardState copyWith({
    ClientDashboardStats? stats,
    List<ClientDashboardActiveProject>? activeProjects,
    List<ClientDashboardRecentReport>? recentReports,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ClientDashboardState(
      stats: stats ?? this.stats,
      activeProjects: activeProjects ?? this.activeProjects,
      recentReports: recentReports ?? this.recentReports,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

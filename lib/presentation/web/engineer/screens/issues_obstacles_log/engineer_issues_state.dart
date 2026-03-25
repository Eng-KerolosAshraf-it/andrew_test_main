class EngineerIssueModel {
  final int id;
  final int projectId;
  final String? projectTitle;
  final String reportType; // 'issue'
  final String? description;
  final String status;
  final DateTime createdAt;

  const EngineerIssueModel({
    required this.id,
    required this.projectId,
    this.projectTitle,
    required this.reportType,
    this.description,
    required this.status,
    required this.createdAt,
  });

  factory EngineerIssueModel.fromJson(Map<String, dynamic> json) {
    return EngineerIssueModel(
      id: json['id'] as int,
      projectId: json['project_id'] as int,
      projectTitle: json['project'] != null ? json['project']['title'] as String? : null,
      reportType: json['report_type'] as String? ?? 'issue',
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'submitted',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  String statusLabel(bool isAr) {
    switch (status) {
      case 'submitted': return isAr ? 'مرسل'       : 'Submitted';
      case 'reviewed':  return isAr ? 'قيد المراجعة': 'Under Review';
      case 'resolved':  return isAr ? 'تم الحل'     : 'Resolved';
      default:          return status;
    }
  }

  int get statusBgColor {
    switch (status) {
      case 'submitted': return 0xFFE3F2FD;
      case 'reviewed':  return 0xFFFFF8E1;
      case 'resolved':  return 0xFFE8F5E9;
      default:          return 0xFFF5F5F5;
    }
  }

  int get statusTextColor {
    switch (status) {
      case 'submitted': return 0xFF2196F3;
      case 'reviewed':  return 0xFFF59E0B;
      case 'resolved':  return 0xFF4CAF50;
      default:          return 0xFF9E9E9E;
    }
  }
}

class EngineerIssuesState {
  final List<EngineerIssueModel> issues;
  final List<Map<String, dynamic>> assignedProjects;
  final bool isLoading;
  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage;
  // form fields
  final int? selectedProjectId;
  final String description;
  final bool showForm;

  const EngineerIssuesState({
    this.issues = const [],
    this.assignedProjects = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.errorMessage,
    this.selectedProjectId,
    this.description = '',
    this.showForm = false,
  });

  EngineerIssuesState copyWith({
    List<EngineerIssueModel>? issues,
    List<Map<String, dynamic>>? assignedProjects,
    bool? isLoading,
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
    int? selectedProjectId,
    String? description,
    bool? showForm,
  }) {
    return EngineerIssuesState(
      issues: issues ?? this.issues,
      assignedProjects: assignedProjects ?? this.assignedProjects,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
      selectedProjectId: selectedProjectId ?? this.selectedProjectId,
      description: description ?? this.description,
      showForm: showForm ?? this.showForm,
    );
  }
}

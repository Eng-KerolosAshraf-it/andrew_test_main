class EngineerReportModel {
  final int id;
  final int projectId;
  final String? projectTitle;
  final String reportType;
  final String? description;
  final String status;
  final DateTime createdAt;

  const EngineerReportModel({
    required this.id,
    required this.projectId,
    this.projectTitle,
    required this.reportType,
    this.description,
    required this.status,
    required this.createdAt,
  });

  factory EngineerReportModel.fromJson(Map<String, dynamic> json) {
    return EngineerReportModel(
      id: json['id'] as int,
      projectId: json['project_id'] as int,
      projectTitle: json['project'] != null ? json['project']['title'] as String? : null,
      reportType: json['report_type'] as String? ?? 'daily',
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'submitted',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  String reportTypeLabel(bool isAr) {
    switch (reportType) {
      case 'daily':    return isAr ? 'تقرير يومي'    : 'Daily Report';
      case 'weekly':   return isAr ? 'تقرير أسبوعي'  : 'Weekly Report';
      case 'issue':    return isAr ? 'تقرير مشكلة'   : 'Issue Report';
      default:         return reportType;
    }
  }

  String statusLabel(bool isAr) {
    switch (status) {
      case 'submitted': return isAr ? 'مرسل'    : 'Submitted';
      case 'reviewed':  return isAr ? 'مراجع'   : 'Reviewed';
      case 'approved':  return isAr ? 'موافق عليه' : 'Approved';
      default:          return status;
    }
  }

  int get statusColor {
    switch (status) {
      case 'submitted': return 0xFF2196F3;
      case 'reviewed':  return 0xFFF59E0B;
      case 'approved':  return 0xFF10B981;
      default:          return 0xFF9E9E9E;
    }
  }
}

class EngineerReportFormState {
  final int? selectedProjectId;
  final String reportType;
  final String description;
  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage;

  const EngineerReportFormState({
    this.selectedProjectId,
    this.reportType = 'daily',
    this.description = '',
    this.isSubmitting = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  EngineerReportFormState copyWith({
    int? selectedProjectId,
    String? reportType,
    String? description,
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return EngineerReportFormState(
      selectedProjectId: selectedProjectId ?? this.selectedProjectId,
      reportType: reportType ?? this.reportType,
      description: description ?? this.description,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
    );
  }
}

class DailyProgressReportState {
  final List<EngineerReportModel> recentReports;
  final List<Map<String, dynamic>> assignedProjects; // {id, title}
  final bool isLoading;
  final String? errorMessage;
  final EngineerReportFormState form;

  const DailyProgressReportState({
    this.recentReports = const [],
    this.assignedProjects = const [],
    this.isLoading = false,
    this.errorMessage,
    this.form = const EngineerReportFormState(),
  });

  DailyProgressReportState copyWith({
    List<EngineerReportModel>? recentReports,
    List<Map<String, dynamic>>? assignedProjects,
    bool? isLoading,
    String? errorMessage,
    EngineerReportFormState? form,
  }) {
    return DailyProgressReportState(
      recentReports: recentReports ?? this.recentReports,
      assignedProjects: assignedProjects ?? this.assignedProjects,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      form: form ?? this.form,
    );
  }
}

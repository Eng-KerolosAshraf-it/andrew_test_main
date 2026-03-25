class ClientReportModel {
  final int id;
  final int? projectId;
  final String? reportType;
  final String? description;
  final String? status;
  final DateTime createdAt;
  final String? submittedByName;

  const ClientReportModel({
    required this.id,
    this.projectId,
    this.reportType,
    this.description,
    this.status,
    required this.createdAt,
    this.submittedByName,
  });

  factory ClientReportModel.fromJson(Map<String, dynamic> json) {
    final submittedBy = json['submitted_by_user'] as Map<String, dynamic>?;
    return ClientReportModel(
      id: json['id'] as int,
      projectId: json['project_id'] as int?,
      reportType: json['report_type'] as String?,
      description: json['description'] as String?,
      status: json['status'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      submittedByName: submittedBy?['name'] as String?,
    );
  }

  String get reportTypeAr {
    switch (reportType) {
      case 'daily':    return 'تقرير يومي';
      case 'weekly':   return 'تقرير أسبوعي';
      case 'monthly':  return 'تقرير شهري';
      case 'issue':    return 'بلاغ مشكلة';
      default:         return reportType ?? 'تقرير';
    }
  }

  String get reportTypeEn {
    switch (reportType) {
      case 'daily':    return 'Daily Report';
      case 'weekly':   return 'Weekly Report';
      case 'monthly':  return 'Monthly Report';
      case 'issue':    return 'Issue Report';
      default:         return reportType ?? 'Report';
    }
  }

  String reportTypeLabel(bool isAr) => isAr ? reportTypeAr : reportTypeEn;

  String get statusAr {
    switch (status) {
      case 'pending':   return 'قيد الانتظار';
      case 'reviewed':  return 'تمت المراجعة';
      case 'approved':  return 'موافق عليه';
      default:          return status ?? '-';
    }
  }

  String get statusEn {
    switch (status) {
      case 'pending':   return 'Pending';
      case 'reviewed':  return 'Reviewed';
      case 'approved':  return 'Approved';
      default:          return status ?? '-';
    }
  }

  String statusLabel(bool isAr) => isAr ? statusAr : statusEn;

  int get statusColor {
    switch (status) {
      case 'pending':  return 0xFFF59E0B;
      case 'reviewed': return 0xFF2196F3;
      case 'approved': return 0xFF4CAF50;
      default:         return 0xFF9E9E9E;
    }
  }
}

class ClientReportsState {
  final List<ClientReportModel> reports;
  final bool isLoading;
  final String? errorMessage;
  final int currentPage;
  final int itemsPerPage;

  const ClientReportsState({
    this.reports = const [],
    this.isLoading = false,
    this.errorMessage,
    this.currentPage = 1,
    this.itemsPerPage = 5,
  });

  int get totalPages => (reports.length / itemsPerPage).ceil().clamp(1, 9999);

  List<ClientReportModel> get currentPageReports {
    final start = (currentPage - 1) * itemsPerPage;
    final end = (start + itemsPerPage).clamp(0, reports.length);
    return reports.sublist(start, end);
  }

  ClientReportsState copyWith({
    List<ClientReportModel>? reports,
    bool? isLoading,
    String? errorMessage,
    int? currentPage,
  }) {
    return ClientReportsState(
      reports: reports ?? this.reports,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage,
    );
  }
}

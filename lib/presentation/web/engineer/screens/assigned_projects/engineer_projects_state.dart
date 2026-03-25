class EngineerProjectModel {
  final int id;
  final String title;
  final String? description;
  final String status;
  final String? clientName;
  final double? budget;
  final double? actualCost;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? drawingUrl;
  final String? drawingType;
  final DateTime createdAt;

  const EngineerProjectModel({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    this.clientName,
    this.budget,
    this.actualCost,
    this.startDate,
    this.endDate,
    this.drawingUrl,
    this.drawingType,
    required this.createdAt,
  });

  factory EngineerProjectModel.fromJson(Map<String, dynamic> json) {
    return EngineerProjectModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'pending',
      clientName: json['client'] != null ? json['client']['name'] as String? : null,
      budget: json['budget'] != null ? (json['budget'] as num).toDouble() : null,
      actualCost: json['actual_cost'] != null ? (json['actual_cost'] as num).toDouble() : null,
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      drawingUrl: json['drawing_url'] as String?,
      drawingType: json['drawing_type'] as String?,
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
      case 'active':                  return 0xFF4CAF50;
      case 'waiting_client_approval': return 0xFFE91E63;
      case 'completed':               return 0xFF7C3AED;
      case 'cancelled':               return 0xFFF44336;
      default:                        return 0xFF9E9E9E;
    }
  }

  int? get durationDays {
    if (startDate == null || endDate == null) return null;
    return endDate!.difference(startDate!).inDays;
  }
}

class EngineerProjectsState {
  final List<EngineerProjectModel> projects;
  final bool isLoading;
  final String? errorMessage;
  final String filterStatus; // 'all', 'active', 'completed'

  const EngineerProjectsState({
    this.projects = const [],
    this.isLoading = false,
    this.errorMessage,
    this.filterStatus = 'all',
  });

  List<EngineerProjectModel> get filteredProjects {
    if (filterStatus == 'all') return projects;
    if (filterStatus == 'active') {
      return projects.where((p) =>
        p.status == 'active' ||
        p.status == 'under_review' ||
        p.status == 'waiting_client_approval').toList();
    }
    return projects.where((p) => p.status == filterStatus).toList();
  }

  EngineerProjectsState copyWith({
    List<EngineerProjectModel>? projects,
    bool? isLoading,
    String? errorMessage,
    String? filterStatus,
  }) {
    return EngineerProjectsState(
      projects: projects ?? this.projects,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      filterStatus: filterStatus ?? this.filterStatus,
    );
  }
}

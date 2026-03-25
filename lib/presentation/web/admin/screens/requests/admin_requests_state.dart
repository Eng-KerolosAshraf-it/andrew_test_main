/// يمثل طلب خدمة واحد قادم من project_service_forms
class ServiceFormRequest {
  final int id;
  final String formType;
  final Map<String, dynamic> formData;
  final String? clientId;
  final String? designFileUrl;
  final String? soilReportUrl;
  final bool isSubmitted;
  final DateTime createdAt;

  // بيانات مشتقة من formData للعرض
  String get clientName {
    final first = formData['first_name'] ?? '';
    final last = formData['last_name'] ?? '';
    return '$first $last'.trim();
  }

  String get phone => formData['phone'] ?? '';
  String get email => formData['email'] ?? '';
  String get location => formData['location'] ?? '';

  String get formTypeAr {
    switch (formType) {
      case 'Residential_structural_design':
        return 'تصميم إنشائي سكني';
      case 'Residential_construction':
        return 'تنفيذ إنشاء سكني';
      case 'Residential_supervision':
        return 'إشراف على إنشاء سكني';
      default:
        return formType;
    }
  }

  const ServiceFormRequest({
    required this.id,
    required this.formType,
    required this.formData,
    this.clientId,
    this.designFileUrl,
    this.soilReportUrl,
    required this.isSubmitted,
    required this.createdAt,
  });

  factory ServiceFormRequest.fromJson(Map<String, dynamic> json) {
    return ServiceFormRequest(
      id: json['id'] as int,
      formType: json['form_type'] as String,
      formData: Map<String, dynamic>.from(json['form_data'] ?? {}),
      clientId: json['client_id'] as String?,
      designFileUrl: json['design_file_url'] as String?,
      soilReportUrl: json['soil_report_url'] as String?,
      isSubmitted: json['is_submitted'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

// ─────────────────────────────────────────────
// State
// ─────────────────────────────────────────────
class AdminRequestsState {
  final List<ServiceFormRequest> requests;
  final bool isLoading;
  final String? errorMessage;
  final bool isActionLoading; // loading لما بيعمل accept/reject

  const AdminRequestsState({
    this.requests = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isActionLoading = false,
  });

  AdminRequestsState copyWith({
    List<ServiceFormRequest>? requests,
    bool? isLoading,
    String? errorMessage,
    bool? isActionLoading,
  }) {
    return AdminRequestsState(
      requests: requests ?? this.requests,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isActionLoading: isActionLoading ?? this.isActionLoading,
    );
  }
}

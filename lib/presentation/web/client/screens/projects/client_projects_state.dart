class ClientProjectModel {
  final int id;
  final String title;
  final String? description;
  final String status;
  final DateTime createdAt;

  const ClientProjectModel({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.createdAt,
  });

  factory ClientProjectModel.fromJson(Map<String, dynamic> json) {
    return ClientProjectModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  String get statusAr {
    switch (status) {
      case 'pending':           return 'قيد الانتظار';
      case 'under_review':      return 'قيد المراجعة';
      case 'active':            return 'نشط';
      case 'waiting_client_approval': return 'بانتظار موافقتك';
      case 'completed':         return 'مكتمل';
      case 'cancelled':         return 'ملغي';
      default:                  return status;
    }
  }

  String get statusEn {
    switch (status) {
      case 'pending':           return 'Pending';
      case 'under_review':      return 'Under Review';
      case 'active':            return 'Active';
      case 'waiting_client_approval': return 'Awaiting Your Approval';
      case 'completed':         return 'Completed';
      case 'cancelled':         return 'Cancelled';
      default:                  return status;
    }
  }

  String statusLabel(bool isAr) => isAr ? statusAr : statusEn;

  // ألوان الحالة
  static const _colors = {
    'pending':                  (0xFFFFF8E1, 0xFFF59E0B),
    'under_review':             (0xFFE3F2FD, 0xFF2196F3),
    'active':                   (0xFFE8F5E9, 0xFF4CAF50),
    'waiting_client_approval':  (0xFFFCE4EC, 0xFFE91E63),
    'completed':                (0xFFEDE7F6, 0xFF7C3AED),
    'cancelled':                (0xFFFFEBEE, 0xFFF44336),
  };

  int get statusBgColor  => _colors[status]?.$1 ?? 0xFFF5F5F5;
  int get statusTextColor => _colors[status]?.$2 ?? 0xFF9E9E9E;
}

class ClientProjectsState {
  final List<ClientProjectModel> projects;
  final bool isLoading;
  final String? errorMessage;

  const ClientProjectsState({
    this.projects = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ClientProjectsState copyWith({
    List<ClientProjectModel>? projects,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ClientProjectsState(
      projects: projects ?? this.projects,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

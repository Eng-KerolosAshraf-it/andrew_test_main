class ServiceRequest {
  final String? id;
  final String userId;
  final String
  serviceId; // e.g., 'structural_design', 'construction', 'supervision'
  final String firstName;
  final String? middleName;
  final String lastName;
  final String idNumber;
  final String address;
  final String phone;
  final String? altPhone;
  final String email;
  final String location;
  final String? detailedAddress;

  // Common numeric fields
  final double? landArea;
  final double? buildingArea;
  final int? floors;
  final int? units;

  // Specific fields stored as JSON or nullable fields
  final Map<String, dynamic> metadata;

  final String status; // 'pending', 'approved', 'rejected'
  final DateTime createdAt;

  ServiceRequest({
    this.id,
    required this.userId,
    required this.serviceId,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.idNumber,
    required this.address,
    required this.phone,
    this.altPhone,
    required this.email,
    required this.location,
    this.detailedAddress,
    this.landArea,
    this.buildingArea,
    this.floors,
    this.units,
    required this.metadata,
    this.status = 'pending',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'service_id': serviceId,
      'first_name': firstName,
      'middle_name': middleName,
      'last_name': lastName,
      'id_number': idNumber,
      'address': address,
      'phone_number': phone,
      'alt_phone_number': altPhone,
      'email': email,
      'location': location,
      'detailed_address': detailedAddress,
      'land_area': landArea,
      'building_area': buildingArea,
      'floors': floors,
      'units': units,
      'metadata': metadata,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'],
      userId: json['user_id'],
      serviceId: json['service_id'],
      firstName: json['first_name'],
      middleName: json['middle_name'],
      lastName: json['last_name'],
      idNumber: json['id_number'],
      address: json['address'],
      phone: json['phone_number'],
      altPhone: json['alt_phone_number'],
      email: json['email'],
      location: json['location'],
      detailedAddress: json['detailed_address'],
      landArea: (json['land_area'] as num?)?.toDouble(),
      buildingArea: (json['building_area'] as num?)?.toDouble(),
      floors: json['floors'],
      units: json['units'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

enum UserRole {
  client,
  admin,
  engineer,
  technician,
  unknown,
}

class AppUser {
  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final String? profileImageUrl;

  AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.profileImageUrl,
  });

  factory AppUser.fromMap(Map<String, dynamic> map, {required String email, required String id}) {
    return AppUser(
      id: id,
      email: email,
      fullName: map['name'] ?? '',
      role: _parseRole(map['role']),
      profileImageUrl: map['profile_image_url'],
    );
  }

  static UserRole _parseRole(String? role) {
    switch (role) {
      case 'client':
        return UserRole.client;
      case 'admin':
        return UserRole.admin;
      case 'engineer':
        return UserRole.engineer;
      case 'technician':
        return UserRole.technician;
      default:
        return UserRole.unknown;
    }
  }
}

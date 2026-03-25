// ─────────────────────────────────────────────
// State
// ─────────────────────────────────────────────
class AdminSettingsState {
  // ── بيانات الملف الشخصي ──────────────────
  final String name;
  final String email;
  final String phone;

  // ── تغيير الباسورد ────────────────────────
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  // ── إعدادات الإشعارات ────────────────────
  final bool emailNotif;
  final bool inAppNotif;
  final bool smsNotif;

  // ── حالة العمليات ─────────────────────────
  final bool isLoadingProfile;
  final bool isUpdatingProfile;
  final bool isChangingPassword;
  final bool isUpdatingNotifications;
  final String? errorMessage;
  final String? successMessage;

  const AdminSettingsState({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.currentPassword = '',
    this.newPassword = '',
    this.confirmPassword = '',
    this.emailNotif = true,
    this.inAppNotif = true,
    this.smsNotif = false,
    this.isLoadingProfile = false,
    this.isUpdatingProfile = false,
    this.isChangingPassword = false,
    this.isUpdatingNotifications = false,
    this.errorMessage,
    this.successMessage,
  });

  AdminSettingsState copyWith({
    String? name,
    String? email,
    String? phone,
    String? currentPassword,
    String? newPassword,
    String? confirmPassword,
    bool? emailNotif,
    bool? inAppNotif,
    bool? smsNotif,
    bool? isLoadingProfile,
    bool? isUpdatingProfile,
    bool? isChangingPassword,
    bool? isUpdatingNotifications,
    String? errorMessage,
    String? successMessage,
  }) {
    return AdminSettingsState(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      currentPassword: currentPassword ?? this.currentPassword,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      emailNotif: emailNotif ?? this.emailNotif,
      inAppNotif: inAppNotif ?? this.inAppNotif,
      smsNotif: smsNotif ?? this.smsNotif,
      isLoadingProfile: isLoadingProfile ?? this.isLoadingProfile,
      isUpdatingProfile: isUpdatingProfile ?? this.isUpdatingProfile,
      isChangingPassword: isChangingPassword ?? this.isChangingPassword,
      isUpdatingNotifications: isUpdatingNotifications ?? this.isUpdatingNotifications,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

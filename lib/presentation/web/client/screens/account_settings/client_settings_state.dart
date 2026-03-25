class ClientSettingsState {
  final String name;
  final String email;
  final String phone;
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;
  final bool emailNotif;
  final bool smsNotif;
  final bool isLoadingProfile;
  final bool isUpdatingProfile;
  final bool isChangingPassword;
  final bool isUpdatingNotifications;
  final String? errorMessage;
  final String? successMessage;

  const ClientSettingsState({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.currentPassword = '',
    this.newPassword = '',
    this.confirmPassword = '',
    this.emailNotif = true,
    this.smsNotif = false,
    this.isLoadingProfile = false,
    this.isUpdatingProfile = false,
    this.isChangingPassword = false,
    this.isUpdatingNotifications = false,
    this.errorMessage,
    this.successMessage,
  });

  ClientSettingsState copyWith({
    String? name,
    String? email,
    String? phone,
    String? currentPassword,
    String? newPassword,
    String? confirmPassword,
    bool? emailNotif,
    bool? smsNotif,
    bool? isLoadingProfile,
    bool? isUpdatingProfile,
    bool? isChangingPassword,
    bool? isUpdatingNotifications,
    String? errorMessage,
    String? successMessage,
  }) {
    return ClientSettingsState(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      currentPassword: currentPassword ?? this.currentPassword,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      emailNotif: emailNotif ?? this.emailNotif,
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

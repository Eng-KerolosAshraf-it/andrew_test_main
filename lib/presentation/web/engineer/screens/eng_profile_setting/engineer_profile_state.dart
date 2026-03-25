class EngineerProfileState {
  final String? name;
  final String? email;
  final String? phone;
  final String? department;
  final String? jobTitle;
  final bool isLoading;
  final bool isSaving;
  final bool isSuccess;
  final String? errorMessage;
  // password form
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;
  final bool isSavingPassword;
  final bool isPasswordSuccess;
  final String? passwordError;
  // notifications
  final bool projectUpdates;
  final bool teamComms;
  final bool systemAlerts;

  const EngineerProfileState({
    this.name,
    this.email,
    this.phone,
    this.department,
    this.jobTitle,
    this.isLoading = false,
    this.isSaving = false,
    this.isSuccess = false,
    this.errorMessage,
    this.currentPassword = '',
    this.newPassword = '',
    this.confirmPassword = '',
    this.isSavingPassword = false,
    this.isPasswordSuccess = false,
    this.passwordError,
    this.projectUpdates = true,
    this.teamComms = false,
    this.systemAlerts = false,
  });

  EngineerProfileState copyWith({
    String? name,
    String? email,
    String? phone,
    String? department,
    String? jobTitle,
    bool? isLoading,
    bool? isSaving,
    bool? isSuccess,
    String? errorMessage,
    String? currentPassword,
    String? newPassword,
    String? confirmPassword,
    bool? isSavingPassword,
    bool? isPasswordSuccess,
    String? passwordError,
    bool? projectUpdates,
    bool? teamComms,
    bool? systemAlerts,
  }) {
    return EngineerProfileState(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      jobTitle: jobTitle ?? this.jobTitle,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
      currentPassword: currentPassword ?? this.currentPassword,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isSavingPassword: isSavingPassword ?? this.isSavingPassword,
      isPasswordSuccess: isPasswordSuccess ?? this.isPasswordSuccess,
      passwordError: passwordError,
      projectUpdates: projectUpdates ?? this.projectUpdates,
      teamComms: teamComms ?? this.teamComms,
      systemAlerts: systemAlerts ?? this.systemAlerts,
    );
  }
}

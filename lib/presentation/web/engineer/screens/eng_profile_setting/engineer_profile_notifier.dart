import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:engineering_platform/core/services/supabase_service.dart';
import 'engineer_profile_state.dart';

final engineerProfileProvider =
    NotifierProvider.autoDispose<EngineerProfileNotifier, EngineerProfileState>(
  EngineerProfileNotifier.new,
);

class EngineerProfileNotifier extends AutoDisposeNotifier<EngineerProfileState> {
  @override
  EngineerProfileState build() {
    Future.microtask(() => fetchProfile());
    return const EngineerProfileState(isLoading: true);
  }

  Future<void> fetchProfile() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final currentUser = supabaseService.client.auth.currentUser;
      if (currentUser == null) throw Exception('غير مسجل الدخول');

      final res = await supabaseService.client
          .from('users')
          .select('name, email, phone, department, notification_settings')
          .eq('id', currentUser.id)
          .single();

      final notif = res['notification_settings'] as Map<String, dynamic>? ?? {};

      state = state.copyWith(
        name: res['name'] as String?,
        email: res['email'] as String?,
        phone: res['phone'] as String?,
        department: res['department'] as String?,
        isLoading: false,
        projectUpdates: notif['project_updates'] as bool? ?? true,
        teamComms: notif['team_comms'] as bool? ?? false,
        systemAlerts: notif['system_alerts'] as bool? ?? false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void updateName(String v)       => state = state.copyWith(name: v);
  void updatePhone(String v)      => state = state.copyWith(phone: v);
  void updateDepartment(String v) => state = state.copyWith(department: v);

  Future<void> saveProfile() async {
    state = state.copyWith(isSaving: true, errorMessage: null, isSuccess: false);
    try {
      final currentUser = supabaseService.client.auth.currentUser;
      if (currentUser == null) throw Exception('غير مسجل الدخول');

      await supabaseService.client.from('users').update({
        'name': state.name,
        'phone': state.phone,
        'department': state.department,
        'notification_settings': {
          'project_updates': state.projectUpdates,
          'team_comms': state.teamComms,
          'system_alerts': state.systemAlerts,
        },
      }).eq('id', currentUser.id);

      state = state.copyWith(isSaving: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.toString());
    }
  }

  void updateCurrentPassword(String v) => state = state.copyWith(currentPassword: v);
  void updateNewPassword(String v)     => state = state.copyWith(newPassword: v);
  void updateConfirmPassword(String v) => state = state.copyWith(confirmPassword: v);

  Future<void> changePassword() async {
    if (state.newPassword != state.confirmPassword) {
      state = state.copyWith(passwordError: 'كلمة المرور الجديدة غير متطابقة');
      return;
    }
    if (state.newPassword.length < 6) {
      state = state.copyWith(passwordError: 'كلمة المرور يجب أن تكون 6 أحرف على الأقل');
      return;
    }

    state = state.copyWith(isSavingPassword: true, passwordError: null);
    try {
      await supabaseService.client.auth.updateUser(
        UserAttributes(password: state.newPassword),
      );
      state = state.copyWith(
        isSavingPassword: false,
        isPasswordSuccess: true,
        currentPassword: '',
        newPassword: '',
        confirmPassword: '',
      );
    } catch (e) {
      state = state.copyWith(isSavingPassword: false, passwordError: e.toString());
    }
  }

  void toggleProjectUpdates(bool v) => state = state.copyWith(projectUpdates: v);
  void toggleTeamComms(bool v)      => state = state.copyWith(teamComms: v);
  void toggleSystemAlerts(bool v)   => state = state.copyWith(systemAlerts: v);
}

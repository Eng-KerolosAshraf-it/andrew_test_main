import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:engineering_platform/core/services/supabase_service.dart';
import 'client_settings_state.dart';

final clientSettingsProvider =
    NotifierProvider<ClientSettingsNotifier, ClientSettingsState>(
  ClientSettingsNotifier.new,
);

class ClientSettingsNotifier extends Notifier<ClientSettingsState> {
  @override
  ClientSettingsState build() {
    Future.microtask(() => loadProfile());
    return const ClientSettingsState(isLoadingProfile: true);
  }

  Future<void> loadProfile() async {
    state = const ClientSettingsState(isLoadingProfile: true);
    try {
      final currentUser = supabaseService.client.auth.currentUser;
      if (currentUser == null) throw Exception('غير مسجل الدخول');

      final response = await supabaseService.client
          .from('users')
          .select('name, email, phone, notification_settings')
          .eq('id', currentUser.id)
          .single();

      final notifSettings = response['notification_settings'] as Map<String, dynamic>? ?? {};

      state = ClientSettingsState(
        isLoadingProfile: false,
        name: response['name'] as String? ?? '',
        email: response['email'] as String? ?? currentUser.email ?? '',
        phone: response['phone'] as String? ?? '',
        emailNotif: notifSettings['email'] as bool? ?? true,
        smsNotif: notifSettings['sms'] as bool? ?? false,
      );
    } catch (e) {
      state = ClientSettingsState(isLoadingProfile: false, errorMessage: e.toString());
    }
  }

  void updateName(String v)            => state = state.copyWith(name: v);
  void updatePhone(String v)           => state = state.copyWith(phone: v);
  void updateCurrentPassword(String v) => state = state.copyWith(currentPassword: v);
  void updateNewPassword(String v)     => state = state.copyWith(newPassword: v);
  void updateConfirmPassword(String v) => state = state.copyWith(confirmPassword: v);

  Future<void> updateProfile() async {
    state = state.copyWith(isUpdatingProfile: true, errorMessage: null, successMessage: null);
    try {
      final currentUser = supabaseService.client.auth.currentUser;
      if (currentUser == null) throw Exception('غير مسجل الدخول');

      await supabaseService.client
          .from('users')
          .update({'name': state.name, 'phone': state.phone})
          .eq('id', currentUser.id);

      state = state.copyWith(isUpdatingProfile: false, successMessage: 'تم تحديث البيانات بنجاح');
    } catch (e) {
      state = state.copyWith(isUpdatingProfile: false, errorMessage: e.toString());
    }
  }

  Future<void> changePassword() async {
    if (state.newPassword != state.confirmPassword) {
      state = state.copyWith(errorMessage: 'كلمة المرور الجديدة غير متطابقة');
      return;
    }
    if (state.newPassword.length < 6) {
      state = state.copyWith(errorMessage: 'كلمة المرور يجب أن تكون 6 أحرف على الأقل');
      return;
    }
    state = state.copyWith(isChangingPassword: true, errorMessage: null, successMessage: null);
    try {
      await supabaseService.client.auth.updateUser(UserAttributes(password: state.newPassword));
      state = state.copyWith(isChangingPassword: false, currentPassword: '', newPassword: '', confirmPassword: '', successMessage: 'تم تغيير كلمة المرور بنجاح');
    } catch (e) {
      state = state.copyWith(isChangingPassword: false, errorMessage: e.toString());
    }
  }

  Future<void> toggleEmailNotif(bool val) async {
    state = state.copyWith(emailNotif: val);
    await _saveNotifications();
  }

  Future<void> toggleSmsNotif(bool val) async {
    state = state.copyWith(smsNotif: val);
    await _saveNotifications();
  }

  Future<void> _saveNotifications() async {
    state = state.copyWith(isUpdatingNotifications: true, errorMessage: null);
    try {
      final currentUser = supabaseService.client.auth.currentUser;
      if (currentUser == null) throw Exception('غير مسجل الدخول');

      await supabaseService.client.from('users').update({
        'notification_settings': {'email': state.emailNotif, 'sms': state.smsNotif},
      }).eq('id', currentUser.id);

      state = state.copyWith(isUpdatingNotifications: false);
    } catch (e) {
      state = state.copyWith(isUpdatingNotifications: false, errorMessage: e.toString());
    }
  }
}

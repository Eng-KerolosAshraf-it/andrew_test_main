import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:engineering_platform/core/constants/colors.dart';
import 'package:engineering_platform/core/constants/translations.dart';
import 'package:engineering_platform/core/state/language_state.dart';
import 'package:engineering_platform/core/state/user_state.dart';
import 'package:engineering_platform/presentation/web/client/widgets/client_layout.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'client_settings_notifier.dart';

class AccountSettingsPage extends ConsumerStatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  ConsumerState<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends ConsumerState<AccountSettingsPage> {
  final ImagePicker _picker = ImagePicker();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _currentPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      await userState.setUser(imageBytes: bytes);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppTranslations.get('request_success', clientLanguageNotifier.value)), backgroundColor: Colors.green),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(clientSettingsProvider);
    final notifier = ref.read(clientSettingsProvider.notifier);

    // تحميل البيانات في الـ controllers
    if (!_initialized && !state.isLoadingProfile && state.name.isNotEmpty) {
      _nameController.text = state.name;
      _emailController.text = state.email;
      _phoneController.text = state.phone;
      _initialized = true;
    }

    // رسائل النجاح والخطأ
    ref.listen(clientSettingsProvider, (prev, next) {
      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.successMessage!), backgroundColor: Colors.green));
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red));
      }
    });

    return ClientLayout(
      activeRoute: '/profile',
      child: ValueListenableBuilder<String>(
        valueListenable: clientLanguageNotifier,
        builder: (context, lang, _) {
          final isAr = lang == 'ar';
          final isDark = Theme.of(context).brightness == Brightness.dark;

          if (state.isLoadingProfile) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── العنوان + الصورة ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppTranslations.get('account_settings', lang),
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.textPrimary, letterSpacing: -1),
                        ),
                        Stack(
                          children: [
                            ValueListenableBuilder<Uint8List?>(
                              valueListenable: userState.profileImageBytes,
                              builder: (context, imageBytes, _) {
                                return Container(
                                  width: 80, height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.greyLight,
                                    border: Border.all(color: AppColors.accent, width: 2),
                                    image: imageBytes != null ? DecorationImage(image: MemoryImage(imageBytes), fit: BoxFit.cover) : null,
                                  ),
                                  child: imageBytes == null ? const Icon(Icons.person, size: 40, color: Colors.grey) : null,
                                );
                              },
                            ),
                            Positioned(
                              bottom: 0, right: 0,
                              child: InkWell(
                                onTap: _pickImage,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── بيانات الحساب ──
                    _SectionHeader(title: AppTranslations.get('information', lang), isDark: isDark),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(AppTranslations.get('full_name', lang), isDark),
                              _buildTextField(controller: _nameController, onChanged: notifier.updateName, isDark: isDark),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(AppTranslations.get('email', lang), isDark),
                              _buildTextField(controller: _emailController, isDark: isDark, readOnly: true),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(AppTranslations.get('phone_number', lang), isDark),
                              _buildTextField(controller: _phoneController, onChanged: notifier.updatePhone, isDark: isDark),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: isAr ? Alignment.centerLeft : Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: state.isUpdatingProfile ? null : notifier.updateProfile,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                        child: state.isUpdatingProfile
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(AppTranslations.get('save_changes', lang), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ── تغيير الباسورد ──
                    _SectionHeader(title: AppTranslations.get('change_password', lang), isDark: isDark),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(AppTranslations.get('current_password', lang), isDark),
                              _buildTextField(controller: _currentPasswordController, onChanged: notifier.updateCurrentPassword, isDark: isDark, isPassword: true),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(AppTranslations.get('new_password', lang), isDark),
                              _buildTextField(controller: _newPasswordController, onChanged: notifier.updateNewPassword, isDark: isDark, isPassword: true),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(AppTranslations.get('confirm_new_password', lang), isDark),
                              _buildTextField(controller: _confirmPasswordController, onChanged: notifier.updateConfirmPassword, isDark: isDark, isPassword: true),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: isAr ? Alignment.centerLeft : Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: state.isChangingPassword ? null : () {
                          notifier.updateCurrentPassword(_currentPasswordController.text);
                          notifier.updateNewPassword(_newPasswordController.text);
                          notifier.updateConfirmPassword(_confirmPasswordController.text);
                          notifier.changePassword();
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                        child: state.isChangingPassword
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(AppTranslations.get('change_password', lang), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ── الإشعارات ──
                    Row(
                      children: [
                        _SectionHeader(title: AppTranslations.get('notification_preferences', lang), isDark: isDark),
                        if (state.isUpdatingNotifications) ...[
                          const SizedBox(width: 12),
                          const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildNotificationItem(
                      title: AppTranslations.get('email_notifications', lang),
                      value: state.emailNotif,
                      isDark: isDark,
                      onChanged: notifier.toggleEmailNotif,
                    ),
                    const SizedBox(height: 12),
                    _buildNotificationItem(
                      title: AppTranslations.get('sms_notifications', lang),
                      value: state.smsNotif,
                      isDark: isDark,
                      onChanged: notifier.toggleSmsNotif,
                    ),
                    const SizedBox(height: 64),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : AppColors.textPrimary)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required bool isDark,
    Function(String)? onChanged,
    bool isPassword = false,
    bool readOnly = false,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: readOnly
            ? (isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade50)
            : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? Colors.white10 : AppColors.greyLight),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        readOnly: readOnly,
        onChanged: onChanged,
        style: TextStyle(fontSize: 15, color: readOnly ? (isDark ? Colors.white38 : Colors.grey) : (isDark ? Colors.white : AppColors.textPrimary)),
        decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), border: InputBorder.none, isDense: true),
      ),
    );
  }

  Widget _buildNotificationItem({required String title, required bool value, required bool isDark, required Function(bool) onChanged}) {
    return Row(
      children: [
        Expanded(child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary))),
        Switch(value: value, onChanged: onChanged, activeColor: AppColors.primary),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary));
  }
}

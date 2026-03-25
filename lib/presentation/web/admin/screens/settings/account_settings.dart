import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:engineering_platform/core/constants/colors.dart';
import 'package:engineering_platform/core/state/language_state.dart';
import 'package:engineering_platform/core/state/theme_state.dart';
import 'package:engineering_platform/core/utils/responsive.dart';
import 'package:engineering_platform/core/constants/translations.dart';
import 'package:engineering_platform/presentation/web/admin/widgets/admin_header.dart';
import 'package:engineering_platform/presentation/web/admin/widgets/admin_sidebar.dart';
import 'settings_notifier.dart';
import 'settings_state.dart';

// ─────────────────────────────────────────────
// Scaffold الرئيسي
// ─────────────────────────────────────────────
class AdminSettingsPage extends ConsumerWidget {
  const AdminSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder<String>(
      valueListenable: adminLanguageNotifier,
      builder: (context, lang, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: adminThemeNotifier,
          builder: (context, themeMode, _) {
            final bool isMobile = Responsive.isMobile(context);
            final isDark = themeMode == ThemeMode.dark;

            return ValueListenableBuilder<bool>(
              valueListenable: sidebarCollapsed,
              builder: (context, isCollapsed, _) {
                return Scaffold(
                  backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.background,
                  drawer: isMobile ? const AdminSidebar() : null,
                  body: Column(
                    children: [
                      AdminHeader(isMobile: isMobile),
                      Expanded(
                        child: Row(
                          children: [
                            if (!isMobile) const AdminSidebar(),
                            const Expanded(child: SettingsContent()),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// المحتوى الرئيسي
// ─────────────────────────────────────────────
class SettingsContent extends ConsumerStatefulWidget {
  const SettingsContent({super.key});

  @override
  ConsumerState<SettingsContent> createState() => _SettingsContentState();
}

class _SettingsContentState extends ConsumerState<SettingsContent> {
  // Controllers للـ profile
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  // Controllers للـ password
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminSettingsProvider);
    final notifier = ref.read(adminSettingsProvider.notifier);

    // تحميل البيانات في الـ controllers لما تجي من Supabase
    if (!_initialized && !state.isLoadingProfile && state.name.isNotEmpty) {
      _nameController.text = state.name;
      _emailController.text = state.email;
      _phoneController.text = state.phone;
      _initialized = true;
    }

    // عرض رسائل النجاح والخطأ
    ref.listen(adminSettingsProvider, (prev, next) {
      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.successMessage!),
          backgroundColor: Colors.green,
        ));
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.errorMessage!),
          backgroundColor: Colors.red,
        ));
      }
    });

    return ValueListenableBuilder<String>(
      valueListenable: adminLanguageNotifier,
      builder: (context, lang, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: adminThemeNotifier,
          builder: (context, themeMode, _) {
            final isDark = themeMode == ThemeMode.dark;

            if (state.isLoadingProfile) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: EdgeInsets.all(Responsive.isMobile(context) ? 16 : 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppTranslations.get('account_settings', lang),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── قسم الملف الشخصي ──────────────────────
                  _SectionTitle(
                    title: AppTranslations.get('profile_info', lang),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  _InputLabel(
                    label: AppTranslations.get('full_name', lang),
                    isDark: isDark,
                  ),
                  _SettingsTextField(
                    controller: _nameController,
                    onChanged: notifier.updateName,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  _InputLabel(
                    label: AppTranslations.get('email', lang),
                    isDark: isDark,
                  ),
                  // الإيميل readonly
                  _SettingsTextField(
                    controller: _emailController,
                    isDark: isDark,
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),
                  _InputLabel(
                    label: AppTranslations.get('phone_number', lang),
                    isDark: isDark,
                  ),
                  _SettingsTextField(
                    controller: _phoneController,
                    onChanged: notifier.updatePhone,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 24),
                  _BlueButton(
                    text: AppTranslations.get('update_profile', lang),
                    isLoading: state.isUpdatingProfile,
                    onPressed: notifier.updateProfile,
                  ),

                  const SizedBox(height: 48),

                  // ── قسم تغيير الباسورد ────────────────────
                  _SectionTitle(
                    title: AppTranslations.get('change_password', lang),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  _InputLabel(
                    label: AppTranslations.get('current_password', lang),
                    isDark: isDark,
                  ),
                  _SettingsTextField(
                    controller: _currentPasswordController,
                    onChanged: notifier.updateCurrentPassword,
                    hint: 'Enter current password',
                    obscureText: true,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  _InputLabel(
                    label: AppTranslations.get('new_password', lang),
                    isDark: isDark,
                  ),
                  _SettingsTextField(
                    controller: _newPasswordController,
                    onChanged: notifier.updateNewPassword,
                    hint: 'Enter new password',
                    obscureText: true,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  _InputLabel(
                    label: AppTranslations.get('confirm_new_password', lang),
                    isDark: isDark,
                  ),
                  _SettingsTextField(
                    controller: _confirmPasswordController,
                    onChanged: notifier.updateConfirmPassword,
                    hint: 'Confirm new password',
                    obscureText: true,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 24),
                  _BlueButton(
                    text: AppTranslations.get('change_password', lang),
                    isLoading: state.isChangingPassword,
                    onPressed: () {
                      notifier.updateCurrentPassword(_currentPasswordController.text);
                      notifier.updateNewPassword(_newPasswordController.text);
                      notifier.updateConfirmPassword(_confirmPasswordController.text);
                      notifier.changePassword();
                    },
                  ),

                  const SizedBox(height: 48),

                  // ── قسم الإشعارات ─────────────────────────
                  Row(
                    children: [
                      _SectionTitle(
                        title: AppTranslations.get('notification_preferences', lang),
                        isDark: isDark,
                      ),
                      if (state.isUpdatingNotifications) ...[
                        const SizedBox(width: 12),
                        const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  _CheckboxItem(
                    label: AppTranslations.get('email_notif_project', lang),
                    value: state.emailNotif,
                    isDark: isDark,
                    onChanged: (val) => notifier.toggleEmailNotif(val!),
                  ),
                  _CheckboxItem(
                    label: AppTranslations.get('in_app_notif_urgent', lang),
                    value: state.inAppNotif,
                    isDark: isDark,
                    onChanged: (val) => notifier.toggleInAppNotif(val!),
                  ),
                  _CheckboxItem(
                    label: AppTranslations.get('sms_notif_critical', lang),
                    value: state.smsNotif,
                    isDark: isDark,
                    onChanged: (val) => notifier.toggleSmsNotif(val!),
                  ),

                  const SizedBox(height: 64),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// Widgets مساعدة
// ─────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectionTitle({required this.title, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : AppColors.textPrimary,
      ),
    );
  }
}

class _InputLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const _InputLabel({required this.label, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white70 : AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _SettingsTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String? hint;
  final bool isDark;
  final bool obscureText;
  final bool readOnly;
  final ValueChanged<String>? onChanged;

  const _SettingsTextField({
    this.controller,
    this.initialValue,
    this.hint,
    this.isDark = false,
    this.obscureText = false,
    this.readOnly = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: readOnly
            ? (isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade50)
            : (isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F4F9)),
        borderRadius: BorderRadius.circular(8),
        border: isDark ? Border.all(color: Colors.white10) : null,
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        readOnly: readOnly,
        onChanged: onChanged,
        style: TextStyle(
          color: readOnly
              ? (isDark ? Colors.white38 : Colors.grey.shade500)
              : (isDark ? Colors.white : AppColors.textPrimary),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: isDark ? Colors.white38 : Colors.grey.shade400,
            fontSize: 13,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

class _BlueButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const _BlueButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2))
          : Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

class _CheckboxItem extends StatelessWidget {
  final String label;
  final bool value;
  final bool isDark;
  final ValueChanged<bool?> onChanged;

  const _CheckboxItem({
    required this.label,
    required this.value,
    required this.onChanged,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary,
              side: isDark ? const BorderSide(color: Colors.white38) : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

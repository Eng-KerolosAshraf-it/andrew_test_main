import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:engineering_platform/core/constants/colors.dart';
import 'package:engineering_platform/core/state/language_state.dart';
import 'package:engineering_platform/core/state/theme_state.dart';
import 'package:engineering_platform/core/utils/responsive.dart';
import 'package:engineering_platform/presentation/web/engineer/widgets/engineer_widgets.dart';
import 'engineer_profile_notifier.dart';
import 'engineer_profile_state.dart';

class EngProfileSettingsPage extends ConsumerWidget {
  const EngProfileSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder<String>(
      valueListenable: engineerLanguageNotifier,
      builder: (context, lang, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: engineerThemeNotifier,
          builder: (context, themeMode, _) {
            final isMobile = Responsive.isMobile(context);
            final isDark = themeMode == ThemeMode.dark;

            return Scaffold(
              backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.background,
              drawer: isMobile ? const EngineerSidebar() : null,
              body: Row(
                children: [
                  if (!isMobile) const EngineerSidebar(),
                  Expanded(
                    child: Column(
                      children: [
                        EngineerHeader(isMobile: isMobile),
                        Expanded(child: _ProfileContent(lang: lang, isDark: isDark, isMobile: isMobile)),
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
  }
}

class _ProfileContent extends ConsumerWidget {
  final String lang;
  final bool isDark, isMobile;
  const _ProfileContent({required this.lang, required this.isDark, required this.isMobile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(engineerProfileProvider);
    final notifier = ref.read(engineerProfileProvider.notifier);
    final isAr = lang == 'ar';

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isAr ? 'الإعدادات' : 'Settings',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppColors.textPrimary, letterSpacing: -1)),
          const SizedBox(height: 32),

          LayoutBuilder(builder: (context, constraints) {
            final wide = constraints.maxWidth > 900;
            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _ProfileSection(state: state, notifier: notifier, isDark: isDark, isAr: isAr)),
                  const SizedBox(width: 24),
                  Expanded(flex: 3, child: Column(children: [
                    _PasswordSection(state: state, notifier: notifier, isDark: isDark, isAr: isAr),
                    const SizedBox(height: 24),
                    _NotificationsSection(state: state, notifier: notifier, isDark: isDark, isAr: isAr),
                  ])),
                ],
              );
            }
            return Column(children: [
              _ProfileSection(state: state, notifier: notifier, isDark: isDark, isAr: isAr),
              const SizedBox(height: 24),
              _PasswordSection(state: state, notifier: notifier, isDark: isDark, isAr: isAr),
              const SizedBox(height: 24),
              _NotificationsSection(state: state, notifier: notifier, isDark: isDark, isAr: isAr),
            ]);
          }),
        ],
      ),
    );
  }
}

// ── Profile Section ───────────────────────────────────────
class _ProfileSection extends StatefulWidget {
  final EngineerProfileState state;
  final EngineerProfileNotifier notifier;
  final bool isDark, isAr;
  const _ProfileSection({required this.state, required this.notifier, required this.isDark, required this.isAr});

  @override
  State<_ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<_ProfileSection> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _deptCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl  = TextEditingController(text: widget.state.name ?? '');
    _phoneCtrl = TextEditingController(text: widget.state.phone ?? '');
    _deptCtrl  = TextEditingController(text: widget.state.department ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _deptCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _Card(
      isDark: widget.isDark,
      child: Column(
        crossAxisAlignment: widget.isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Avatar
          Center(
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                border: Border.all(color: const Color(0xFF2563EB), width: 2),
              ),
              child: Icon(Icons.person, size: 40, color: const Color(0xFF2563EB).withValues(alpha: 0.7)),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(widget.state.name ?? '', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                color: widget.isDark ? Colors.white : AppColors.textPrimary)),
          ),
          Center(
            child: Text(widget.state.email ?? '', style: TextStyle(fontSize: 13,
                color: widget.isDark ? Colors.white54 : AppColors.textSecondary)),
          ),
          const SizedBox(height: 24),

          _FieldLabel(label: widget.isAr ? 'الاسم الكامل' : 'Full Name', isDark: widget.isDark),
          const SizedBox(height: 8),
          _TextField(controller: _nameCtrl, isDark: widget.isDark, onChanged: widget.notifier.updateName),
          const SizedBox(height: 16),

          _FieldLabel(label: widget.isAr ? 'رقم الهاتف' : 'Phone', isDark: widget.isDark),
          const SizedBox(height: 8),
          _TextField(controller: _phoneCtrl, isDark: widget.isDark, onChanged: widget.notifier.updatePhone),
          const SizedBox(height: 16),

          _FieldLabel(label: widget.isAr ? 'القسم' : 'Department', isDark: widget.isDark),
          const SizedBox(height: 8),
          _TextField(controller: _deptCtrl, isDark: widget.isDark, onChanged: widget.notifier.updateDepartment),
          const SizedBox(height: 20),

          if (widget.state.errorMessage != null)
            _ErrorMsg(message: widget.state.errorMessage!),
          if (widget.state.isSuccess)
            _SuccessMsg(message: widget.isAr ? 'تم حفظ التغييرات' : 'Changes saved'),

          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.state.isSaving ? null : widget.notifier.saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: widget.state.isSaving
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(widget.isAr ? 'حفظ التغييرات' : 'Save Changes',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Password Section ──────────────────────────────────────
class _PasswordSection extends StatefulWidget {
  final EngineerProfileState state;
  final EngineerProfileNotifier notifier;
  final bool isDark, isAr;
  const _PasswordSection({required this.state, required this.notifier, required this.isDark, required this.isAr});

  @override
  State<_PasswordSection> createState() => _PasswordSectionState();
}

class _PasswordSectionState extends State<_PasswordSection> {
  late final TextEditingController _currCtrl;
  late final TextEditingController _newCtrl;
  late final TextEditingController _confCtrl;

  @override
  void initState() {
    super.initState();
    _currCtrl = TextEditingController();
    _newCtrl  = TextEditingController();
    _confCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _currCtrl.dispose();
    _newCtrl.dispose();
    _confCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _Card(
      isDark: widget.isDark,
      child: Column(
        crossAxisAlignment: widget.isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(widget.isAr ? 'أمان الحساب' : 'Account Security',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                color: widget.isDark ? Colors.white : AppColors.textPrimary)),
          const SizedBox(height: 20),

          _FieldLabel(label: widget.isAr ? 'كلمة المرور الحالية' : 'Current Password', isDark: widget.isDark),
          const SizedBox(height: 8),
          _TextField(controller: _currCtrl, isDark: widget.isDark, isPassword: true, onChanged: widget.notifier.updateCurrentPassword),
          const SizedBox(height: 16),

          _FieldLabel(label: widget.isAr ? 'كلمة المرور الجديدة' : 'New Password', isDark: widget.isDark),
          const SizedBox(height: 8),
          _TextField(controller: _newCtrl, isDark: widget.isDark, isPassword: true, onChanged: widget.notifier.updateNewPassword),
          const SizedBox(height: 16),

          _FieldLabel(label: widget.isAr ? 'تأكيد كلمة المرور' : 'Confirm Password', isDark: widget.isDark),
          const SizedBox(height: 8),
          _TextField(controller: _confCtrl, isDark: widget.isDark, isPassword: true, onChanged: widget.notifier.updateConfirmPassword),
          const SizedBox(height: 16),

          if (widget.state.passwordError != null)
            _ErrorMsg(message: widget.state.passwordError!),
          if (widget.state.isPasswordSuccess)
            _SuccessMsg(message: widget.isAr ? 'تم تغيير كلمة المرور' : 'Password changed'),

          const SizedBox(height: 8),
          Align(
            alignment: widget.isAr ? Alignment.centerLeft : Alignment.centerRight,
            child: ElevatedButton(
              onPressed: widget.state.isSavingPassword ? null : widget.notifier.changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: widget.state.isSavingPassword
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(widget.isAr ? 'تغيير كلمة المرور' : 'Change Password',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Notifications Section ─────────────────────────────────
class _NotificationsSection extends StatelessWidget {
  final EngineerProfileState state;
  final EngineerProfileNotifier notifier;
  final bool isDark, isAr;
  const _NotificationsSection({required this.state, required this.notifier, required this.isDark, required this.isAr});

  @override
  Widget build(BuildContext context) {
    return _Card(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(isAr ? 'تفضيلات الإشعارات' : 'Notification Preferences',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColors.textPrimary)),
          const SizedBox(height: 16),
          _NotifTile(
            label: isAr ? 'تحديثات المشاريع' : 'Project Updates',
            value: state.projectUpdates,
            onChanged: notifier.toggleProjectUpdates,
            isDark: isDark,
          ),
          _NotifTile(
            label: isAr ? 'تواصل الفريق' : 'Team Communications',
            value: state.teamComms,
            onChanged: notifier.toggleTeamComms,
            isDark: isDark,
          ),
          _NotifTile(
            label: isAr ? 'تنبيهات النظام' : 'System Alerts',
            value: state.systemAlerts,
            onChanged: notifier.toggleSystemAlerts,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final String label;
  final bool value, isDark;
  final ValueChanged<bool> onChanged;
  const _NotifTile({required this.label, required this.value, required this.onChanged, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : AppColors.textPrimary)),
          Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFF2563EB)),
        ],
      ),
    );
  }
}

// ── Shared Widgets ────────────────────────────────────────
class _Card extends StatelessWidget {
  final Widget child;
  final bool isDark;
  const _Card({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE5E7EB)),
      ),
      child: child,
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const _FieldLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
        color: isDark ? Colors.white70 : AppColors.textPrimary));
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final bool isPassword;
  final ValueChanged<String> onChanged;
  const _TextField({required this.controller, required this.isDark, this.isPassword = false, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.07) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        onChanged: onChanged,
        style: TextStyle(fontSize: 14, color: isDark ? Colors.white : AppColors.textPrimary),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

class _ErrorMsg extends StatelessWidget {
  final String message;
  const _ErrorMsg({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200)),
      child: Row(children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(message, style: const TextStyle(color: Colors.red, fontSize: 12))),
      ]),
    );
  }
}

class _SuccessMsg extends StatelessWidget {
  final String message;
  const _SuccessMsg({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.shade200)),
      child: Row(children: [
        const Icon(Icons.check_circle_outline, color: Colors.green, size: 16),
        const SizedBox(width: 8),
        Text(message, style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

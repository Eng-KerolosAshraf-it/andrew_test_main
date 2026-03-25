import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:engineering_platform/core/constants/colors.dart';
import 'package:engineering_platform/core/state/language_state.dart';
import 'package:engineering_platform/core/state/theme_state.dart';
import 'package:engineering_platform/core/utils/responsive.dart';
import 'package:engineering_platform/presentation/web/technician/widgets/technician_widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:engineering_platform/core/services/supabase_service.dart';

class TechnicianAccountSettingsPage extends ConsumerStatefulWidget {
  const TechnicianAccountSettingsPage({super.key});

  @override
  ConsumerState<TechnicianAccountSettingsPage> createState() => _TechnicianAccountSettingsPageState();
}

class _TechnicianAccountSettingsPageState extends ConsumerState<TechnicianAccountSettingsPage> {
  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _newPassCtrl  = TextEditingController();
  final _confPassCtrl = TextEditingController();

  bool _isLoading   = true;
  bool _isSaving    = false;
  bool _isSuccess   = false;
  bool _isPassSuccess = false;
  String? _error;
  String? _passError;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final currentUser = supabaseService.client.auth.currentUser;
      if (currentUser == null) return;
      final res = await supabaseService.client
          .from('users').select('name, phone').eq('id', currentUser.id).single();
      _nameCtrl.text  = res['name'] as String? ?? '';
      _phoneCtrl.text = res['phone'] as String? ?? '';
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveProfile() async {
    setState(() { _isSaving = true; _error = null; _isSuccess = false; });
    try {
      final currentUser = supabaseService.client.auth.currentUser;
      if (currentUser == null) throw Exception('غير مسجل الدخول');
      await supabaseService.client.from('users').update({
        'name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
      }).eq('id', currentUser.id);
      setState(() => _isSuccess = true);
    } catch (e) {
      setState(() => _error = e.toString());
    }
    setState(() => _isSaving = false);
  }

  Future<void> _changePassword() async {
    if (_newPassCtrl.text != _confPassCtrl.text) {
      setState(() => _passError = 'كلمة المرور غير متطابقة');
      return;
    }
    if (_newPassCtrl.text.length < 6) {
      setState(() => _passError = 'كلمة المرور يجب أن تكون 6 أحرف على الأقل');
      return;
    }
    setState(() { _passError = null; _isPassSuccess = false; });
    try {
      await supabaseService.client.auth.updateUser(UserAttributes(password: _newPassCtrl.text));
      _newPassCtrl.clear();
      _confPassCtrl.clear();
      setState(() => _isPassSuccess = true);
    } catch (e) {
      setState(() => _passError = e.toString());
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _phoneCtrl.dispose();
    _newPassCtrl.dispose(); _confPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: technicianLanguageNotifier,
      builder: (context, lang, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: technicianThemeNotifier,
          builder: (context, themeMode, _) {
            final isMobile = Responsive.isMobile(context);
            final isDark = themeMode == ThemeMode.dark;
            final isAr = lang == 'ar';

            return Scaffold(
              backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.background,
              drawer: isMobile ? const TechnicianSidebar() : null,
              body: Row(
                children: [
                  if (!isMobile) const TechnicianSidebar(),
                  Expanded(
                    child: Column(
                      children: [
                        TechnicianHeader(isMobile: isMobile, showSearch: false),
                        Expanded(
                          child: _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : SingleChildScrollView(
                                  padding: EdgeInsets.all(isMobile ? 16 : 32),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(isAr ? 'إعدادات الحساب' : 'Account Settings',
                                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900,
                                            color: isDark ? Colors.white : AppColors.textPrimary, letterSpacing: -0.5)),
                                      const SizedBox(height: 24),

                                      LayoutBuilder(builder: (context, constraints) {
                                        final wide = constraints.maxWidth > 800;
                                        if (wide) {
                                          return Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(child: _ProfileCard(nameCtrl: _nameCtrl, phoneCtrl: _phoneCtrl,
                                                isDark: isDark, isAr: isAr, isSaving: _isSaving, isSuccess: _isSuccess,
                                                error: _error, onSave: _saveProfile)),
                                              const SizedBox(width: 24),
                                              Expanded(child: _PasswordCard(newPassCtrl: _newPassCtrl, confPassCtrl: _confPassCtrl,
                                                isDark: isDark, isAr: isAr, isSuccess: _isPassSuccess,
                                                error: _passError, onSave: _changePassword)),
                                            ],
                                          );
                                        }
                                        return Column(children: [
                                          _ProfileCard(nameCtrl: _nameCtrl, phoneCtrl: _phoneCtrl,
                                            isDark: isDark, isAr: isAr, isSaving: _isSaving, isSuccess: _isSuccess,
                                            error: _error, onSave: _saveProfile),
                                          const SizedBox(height: 24),
                                          _PasswordCard(newPassCtrl: _newPassCtrl, confPassCtrl: _confPassCtrl,
                                            isDark: isDark, isAr: isAr, isSuccess: _isPassSuccess,
                                            error: _passError, onSave: _changePassword),
                                        ]);
                                      }),
                                    ],
                                  ),
                                ),
                        ),
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

class _ProfileCard extends StatelessWidget {
  final TextEditingController nameCtrl, phoneCtrl;
  final bool isDark, isAr, isSaving, isSuccess;
  final String? error;
  final VoidCallback onSave;
  const _ProfileCard({required this.nameCtrl, required this.phoneCtrl, required this.isDark,
    required this.isAr, required this.isSaving, required this.isSuccess, this.error, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return _Card(isDark: isDark, child: Column(
      crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(isAr ? 'المعلومات الشخصية' : 'Personal Info',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.textPrimary)),
        const SizedBox(height: 20),
        _Label(label: isAr ? 'الاسم الكامل' : 'Full Name', isDark: isDark),
        const SizedBox(height: 8),
        _Field(controller: nameCtrl, isDark: isDark),
        const SizedBox(height: 16),
        _Label(label: isAr ? 'رقم الهاتف' : 'Phone', isDark: isDark),
        const SizedBox(height: 8),
        _Field(controller: phoneCtrl, isDark: isDark),
        if (error != null) ...[const SizedBox(height: 12), _ErrorMsg(message: error!)],
        if (isSuccess) ...[const SizedBox(height: 12), _SuccessMsg(message: isAr ? 'تم الحفظ' : 'Saved')],
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: ElevatedButton(
          onPressed: isSaving ? null : onSave,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.white,
            elevation: 0, padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: isSaving
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(isAr ? 'حفظ التغييرات' : 'Save Changes', style: const TextStyle(fontWeight: FontWeight.w700)),
        )),
      ],
    ));
  }
}

class _PasswordCard extends StatelessWidget {
  final TextEditingController newPassCtrl, confPassCtrl;
  final bool isDark, isAr, isSuccess;
  final String? error;
  final VoidCallback onSave;
  const _PasswordCard({required this.newPassCtrl, required this.confPassCtrl, required this.isDark,
    required this.isAr, required this.isSuccess, this.error, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return _Card(isDark: isDark, child: Column(
      crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(isAr ? 'تغيير كلمة المرور' : 'Change Password',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.textPrimary)),
        const SizedBox(height: 20),
        _Label(label: isAr ? 'كلمة المرور الجديدة' : 'New Password', isDark: isDark),
        const SizedBox(height: 8),
        _Field(controller: newPassCtrl, isDark: isDark, isPassword: true),
        const SizedBox(height: 16),
        _Label(label: isAr ? 'تأكيد كلمة المرور' : 'Confirm Password', isDark: isDark),
        const SizedBox(height: 8),
        _Field(controller: confPassCtrl, isDark: isDark, isPassword: true),
        if (error != null) ...[const SizedBox(height: 12), _ErrorMsg(message: error!)],
        if (isSuccess) ...[const SizedBox(height: 12), _SuccessMsg(message: isAr ? 'تم تغيير كلمة المرور' : 'Password changed')],
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: ElevatedButton(
          onPressed: onSave,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.white,
            elevation: 0, padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: Text(isAr ? 'تغيير كلمة المرور' : 'Change Password', style: const TextStyle(fontWeight: FontWeight.w700)),
        )),
      ],
    ));
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final bool isDark;
  const _Card({required this.child, required this.isDark});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE5E7EB)),
      ),
      child: child,
    );
  }
}

class _Label extends StatelessWidget {
  final String label; final bool isDark;
  const _Label({required this.label, required this.isDark});
  @override
  Widget build(BuildContext context) => Text(label,
    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : AppColors.textPrimary));
}

class _Field extends StatelessWidget {
  final TextEditingController controller; final bool isDark, isPassword;
  const _Field({required this.controller, required this.isDark, this.isPassword = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.07) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE5E7EB)),
      ),
      child: TextField(controller: controller, obscureText: isPassword,
        style: TextStyle(fontSize: 14, color: isDark ? Colors.white : AppColors.textPrimary),
        decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12))),
    );
  }
}

class _ErrorMsg extends StatelessWidget {
  final String message;
  const _ErrorMsg({required this.message});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade200)),
    child: Row(children: [const Icon(Icons.error_outline, color: Colors.red, size: 16), const SizedBox(width: 8),
      Expanded(child: Text(message, style: const TextStyle(color: Colors.red, fontSize: 12)))]),
  );
}

class _SuccessMsg extends StatelessWidget {
  final String message;
  const _SuccessMsg({required this.message});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green.shade200)),
    child: Row(children: [const Icon(Icons.check_circle_outline, color: Colors.green, size: 16), const SizedBox(width: 8),
      Text(message, style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600))]),
  );
}

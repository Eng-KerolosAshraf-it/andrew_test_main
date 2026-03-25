import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:engineering_platform/core/constants/colors.dart';
import 'package:engineering_platform/core/constants/translations.dart';
import 'package:engineering_platform/core/constants/route_names.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/auth_screen_mixin.dart';
import '../providers/auth_notifier.dart';

class ForgetPasswordPage extends ConsumerStatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  ConsumerState<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends ConsumerState<ForgetPasswordPage> with AuthScreenMixin {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleResetPassword() {
    if (_formKey.currentState!.validate()) {
      ref.read(authActionProvider.notifier).resetPassword(
            _emailController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(authActionProvider);

    listenToAuthActionState(context, ref, onSuccess: () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset link sent!'), backgroundColor: Colors.green),
      );
      ref.read(authActionProvider.notifier).reset();
    });

    return AuthScaffold(
      builder: (context, lang, isDark) {
        return AuthLayout(
          title: AppTranslations.get('Forget Password', lang),
          subtitle: 'Enter your email to receive a reset link',
          isDark: isDark,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppTranslations.get('Forget Password', lang),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 40),

                AuthTextField(
                  controller: _emailController,
                  label: AppTranslations.get('email', lang),
                  icon: Icons.email_outlined,
                  isDark: isDark,
                  validator: (v) {
                    if (v == null || v.isEmpty) return AppTranslations.get('required_field', lang);
                    if (!v.contains('@')) return AppTranslations.get('invalid_email', lang);
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: actionState.status == AuthActionStatus.loading ? null : _handleResetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5046E5),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      actionState.status == AuthActionStatus.loading
                          ? AppTranslations.get('sending', lang)
                          : AppTranslations.get('Send Reset Link', lang),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                TextButton(
                  onPressed: () => Navigator.pushNamed(context, RouteNames.login),
                  child: Text(
                    AppTranslations.get('Back To Login', lang),
                    style: TextStyle(color: isDark ? Colors.white60 : Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

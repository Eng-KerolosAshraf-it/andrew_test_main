import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:engineering_platform/core/constants/colors.dart';
import 'package:engineering_platform/core/constants/translations.dart';
import 'package:engineering_platform/core/constants/assets.dart';
import 'package:engineering_platform/core/utils/validation_utils.dart';
import 'package:engineering_platform/core/data/auth_data.dart';
import 'package:engineering_platform/core/constants/route_names.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/auth_screen_mixin.dart';
import '../providers/auth_notifier.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> with AuthScreenMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignup() {
    if (_formKey.currentState!.validate()) {
      ref.read(authActionProvider.notifier).signup(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            fullName: _nameController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(authActionProvider);

    listenToAuthActionState(context, ref, onSuccess: () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful! Please check your email for confirmation.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacementNamed(context, RouteNames.login);
    });

    return AuthScaffold(
      builder: (context, lang, isDark) {
        final textColor = isDark ? Colors.white : AppColors.textPrimary;
        final subTextColor = isDark ? Colors.white60 : AppColors.textSecondary;

        return AuthLayout(
          title: AppTranslations.get('signup_title', lang),
          subtitle: AppTranslations.get('signup_subtitle', lang),
          isDark: isDark,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppTranslations.get('signup_btn', lang),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 30),

                AuthTextField(
                  controller: _nameController,
                  label: AppTranslations.get('full_name', lang),
                  icon: Icons.person_outline,
                  isDark: isDark,
                  validator: (v) => ValidationUtils.validateRequired(v, lang),
                ),
                const SizedBox(height: 20),

                AuthTextField(
                  controller: _emailController,
                  label: AppTranslations.get('email', lang),
                  icon: Icons.email_outlined,
                  isDark: isDark,
                  validator: (v) => ValidationUtils.validateEmail(v, lang),
                ),
                const SizedBox(height: 20),

                AuthTextField(
                  controller: _passwordController,
                  label: AppTranslations.get('password', lang),
                  icon: Icons.lock_outline,
                  isDark: isDark,
                  obscureText: !_isPasswordVisible,
                  validator: (v) => ValidationUtils.validatePassword(v, lang),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      color: isDark ? Colors.white70 : Colors.grey,
                    ),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                ),
                const SizedBox(height: 20),

                AuthTextField(
                  controller: _confirmPasswordController,
                  label: AppTranslations.get('confirm_password', lang),
                  icon: Icons.lock_reset_outlined,
                  isDark: isDark,
                  obscureText: !_isConfirmPasswordVisible,
                  validator: (v) {
                    if (v == null || v.isEmpty) return AppTranslations.get('required_field', lang);
                    if (v != _passwordController.text) return AppTranslations.get('passwords_not_match', lang);
                    return null;
                  },
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      color: isDark ? Colors.white70 : Colors.grey,
                    ),
                    onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                  ),
                ),
                const SizedBox(height: 30),

                Text(
                  AppTranslations.get('continue_with', lang),
                  style: TextStyle(color: subTextColor, fontSize: 14),
                ),
                const SizedBox(height: 20),

                Row(
                  children: AuthData.socialButtons
                      .map((btn) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: SocialButton(
                                icon: btn['icon'],
                                label: btn['label'],
                                onPressed: () {},
                                isDark: isDark,
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: actionState.status == AuthActionStatus.loading ? null : _handleSignup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.blue.shade700 : AppColors.primaryDark,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: actionState.status == AuthActionStatus.loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            AppTranslations.get('signup_btn', lang),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 30),

                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(AppTranslations.get('have_account', lang), style: TextStyle(color: subTextColor)),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, RouteNames.login),
                      child: Text(
                        AppTranslations.get('login_btn', lang),
                        style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, RouteNames.home),
                  child: Text(
                    AppTranslations.get('back_to_home', lang),
                    style: TextStyle(color: subTextColor),
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

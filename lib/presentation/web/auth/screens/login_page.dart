import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:engineering_platform/core/constants/colors.dart';
import 'package:engineering_platform/core/constants/translations.dart';
import 'package:engineering_platform/core/constants/assets.dart';
import 'package:engineering_platform/core/state/user_state.dart';
import 'package:engineering_platform/core/utils/validation_utils.dart';
import 'package:engineering_platform/core/data/auth_data.dart';
import 'package:engineering_platform/core/constants/route_names.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/auth_screen_mixin.dart';
import 'package:engineering_platform/domain/entities/app_user.dart';
import '../providers/auth_notifier.dart';
import '../providers/auth_state.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> with AuthScreenMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      ref.read(authNotifierProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text,
          );
    }
  }

  void _navigateToRoleDashboard(UserRole role) {
    if (!mounted) return;
    String route;
    switch (role) {
      case UserRole.client:
        route = RouteNames.clientHome;
        break;
      case UserRole.admin:
        route = RouteNames.adminDashboard;
        break;
      case UserRole.engineer:
        route = RouteNames.engineerDashboard;
        break;
      case UserRole.technician:
        route = RouteNames.technicianDashboard;
        break;
      default:
        route = RouteNames.login;
    }
    Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    listenToAuthState(context, ref, (authenticated) {
      _navigateToRoleDashboard(authenticated.user.role);
    });

    return AuthScaffold(
      builder: (context, lang, isDark) {
        final textColor = isDark ? Colors.white : AppColors.textPrimary;
        final subTextColor = isDark ? Colors.white60 : AppColors.textSecondary;

        return AuthLayout(
          title: AppTranslations.get('login_title', lang),
          subtitle: AppTranslations.get('login_subtitle', lang),
          isDark: isDark,
          brandingImage: ValueListenableBuilder(
            valueListenable: userState.profileImageBytes,
            builder: (context, imageBytes, _) {
              return Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 10,
                  ),
                  image: DecorationImage(
                    image: imageBytes != null
                        ? MemoryImage(imageBytes)
                        : const AssetImage(AppAssets.logo) as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppTranslations.get('login_btn', lang),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 40),

                AuthTextField(
                  controller: _emailController,
                  label: AppTranslations.get('email', lang),
                  icon: Icons.email_outlined,
                  isDark: isDark,
                  hint: AppTranslations.get('email_hint', lang),
                  validator: (v) => ValidationUtils.validateEmail(v, lang),
                ),
                const SizedBox(height: 30),

                AuthTextField(
                  controller: _passwordController,
                  label: AppTranslations.get('password', lang),
                  icon: Icons.lock_outline,
                  isDark: isDark,
                  hint: AppTranslations.get('password_hint', lang),
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
                const SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: true,
                          onChanged: (v) {},
                          activeColor: AppColors.accent,
                          side: isDark ? const BorderSide(color: Colors.white24) : null,
                        ),
                        Text(
                          AppTranslations.get('remember_me', lang),
                          style: TextStyle(fontSize: 14, color: textColor),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, RouteNames.forgetPassword),
                      child: Text(
                        AppTranslations.get('forgot_password', lang),
                        style: const TextStyle(color: AppColors.accent, fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: authState is AuthLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.blue.shade700 : AppColors.primaryDark,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: authState is AuthLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            AppTranslations.get('login_btn', lang),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
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

                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(AppTranslations.get('no_account', lang), style: TextStyle(color: subTextColor)),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, RouteNames.signup),
                      child: Text(
                        AppTranslations.get('signup_btn', lang),
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

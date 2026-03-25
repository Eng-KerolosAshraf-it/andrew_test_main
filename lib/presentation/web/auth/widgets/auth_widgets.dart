import 'package:flutter/material.dart';
import 'package:engineering_platform/core/constants/colors.dart';
import 'package:engineering_platform/core/state/language_state.dart';
import 'package:engineering_platform/core/state/theme_state.dart';
import 'package:engineering_platform/core/constants/assets.dart';
import 'package:engineering_platform/core/state/layout_state.dart';

// ── Language Toggle ───────────────────────────────────────
class LangToggle extends StatelessWidget {
  final String label;
  final String code;
  final bool isActive;

  const LangToggle({
    super.key,
    required this.label,
    required this.code,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => languageNotifier.value = code,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label,
          style: TextStyle(
            color: isActive ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          )),
      ),
    );
  }
}

// ── Theme Toggle ──────────────────────────────────────────
class AuthThemeToggle extends StatelessWidget {
  final bool isDark;

  const AuthThemeToggle({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => authThemeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          isDark ? Icons.light_mode : Icons.dark_mode,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

// ── Social Button ─────────────────────────────────────────
class SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isDark;

  const SocialButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon,
        color: icon == Icons.facebook ? const Color(0xFF1877F2) : Colors.red),
      label: Text(label,
        style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : null,
      ),
    );
  }
}

// ── Auth Text Field ───────────────────────────────────────
class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final bool isDark;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.isDark,
    this.hint,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.white70 : null),
        prefixIcon: Icon(icon, color: AppColors.accent),
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.grey.shade400),
        suffixIcon: suffixIcon,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade300),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.accent, width: 2),
        ),
      ),
    );
  }
}

// ── Auth Layout ───────────────────────────────────────────
class AuthLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final String subtitle;
  final bool isDark;
  final Widget? brandingImage;

  const AuthLayout({
    super.key,
    required this.child,
    required this.title,
    required this.subtitle,
    required this.isDark,
    this.brandingImage,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Layout.isMobile(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF0F172A), const Color(0xFF1E293B), const Color(0xFF334155)]
                : [AppColors.primary, const Color(0xFFA855F7), const Color(0xFFEC4899)],
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    constraints: BoxConstraints(maxWidth: isMobile ? 500 : 1000),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        )
                      ],
                    ),
                    child: Flex(
                      direction: isMobile ? Axis.vertical : Axis.horizontal,
                      children: [
                        // ── Left - Branding ──
                        Flexible(
                          flex: isMobile ? 0 : 1,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F172A) : AppColors.accent,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  title,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  subtitle,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                                const SizedBox(height: 40),
                                brandingImage ??
                                    Container(
                                      width: 220,
                                      height: 220,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          width: 10,
                                        ),
                                        image: const DecorationImage(
                                          image: AssetImage(AppAssets.logo),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                              ],
                            ),
                          ),
                        ),
                        // ── Right - Form ──
                        Flexible(
                          flex: isMobile ? 0 : 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
                            child: child,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Toggles
            Positioned(top: 20, left: 20, child: AuthThemeToggle(isDark: isDark)),
            Positioned(
              top: 20,
              right: 20,
              child: Row(
                children: [
                  ValueListenableBuilder<String>(
                    valueListenable: languageNotifier,
                    builder: (context, lang, _) => Row(
                      children: [
                        LangToggle(label: 'EN', code: 'en', isActive: lang == 'en'),
                        const SizedBox(width: 8),
                        LangToggle(label: 'AR', code: 'ar', isActive: lang == 'ar'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Auth Scaffold ──────────────────────────────────────────
// Wraps theme and language listeners to clean up screen code
class AuthScaffold extends StatelessWidget {
  final Widget Function(BuildContext context, String lang, bool isDark) builder;

  const AuthScaffold({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: languageNotifier,
      builder: (context, lang, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: authThemeNotifier,
          builder: (context, themeMode, _) {
            return builder(context, lang, themeMode == ThemeMode.dark);
          },
        );
      },
    );
  }
}

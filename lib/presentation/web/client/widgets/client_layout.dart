import 'package:flutter/material.dart';
import 'package:engineering_platform/core/constants/colors.dart';
import 'package:engineering_platform/core/constants/translations.dart';
import 'package:engineering_platform/core/state/language_state.dart';
import 'package:engineering_platform/core/state/theme_state.dart';
import 'package:engineering_platform/core/state/user_state.dart';
import 'package:engineering_platform/core/themes/app_theme.dart';
import 'package:engineering_platform/core/constants/app_constants.dart';
import 'package:engineering_platform/core/utils/responsive.dart';
import 'dart:typed_data';

class ClientLayout extends StatelessWidget {
  final Widget child;
  final String activeRoute;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ClientLayout({
    super.key,
    required this.child,
    this.activeRoute = '',
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: clientLanguageNotifier,
      builder: (context, lang, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: clientThemeNotifier,
          builder: (context, themeMode, _) {
            final isDark = themeMode == ThemeMode.dark;
            final isMobile = Responsive.isMobile(context);

            return Theme(
              data: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
              child: Scaffold(
                key: _scaffoldKey,
                backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.background,
                drawer: isMobile ? _ClientDrawer(lang: lang) : null,
                body: Column(
                  children: [
                    ClientHeader(
                      scaffoldKey: _scaffoldKey,
                      activeRoute: activeRoute,
                    ),
                    Expanded(
                      child: SingleChildScrollView(child: child),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ── Client Header ─────────────────────────────────────────
class ClientHeader extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String activeRoute;

  const ClientHeader({
    super.key,
    required this.scaffoldKey,
    this.activeRoute = '',
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: clientLanguageNotifier,
      builder: (context, lang, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: clientThemeNotifier,
          builder: (context, themeMode, _) {
            final isDark = themeMode == ThemeMode.dark;
            final isMobile = Responsive.isMobile(context);

            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 32,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.white10 : AppColors.greyLight,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // ── Mobile menu ──
                  if (isMobile) ...[
                    IconButton(
                      icon: Icon(Icons.menu_rounded, color: isDark ? Colors.white : AppColors.textPrimary),
                      onPressed: () => scaffoldKey.currentState?.openDrawer(),
                    ),
                    const SizedBox(width: 8),
                  ],

                  // ── Logo ──
                  InkWell(
                    onTap: () => navigatorKey.currentState?.pushNamed('/client/home'),
                    borderRadius: BorderRadius.circular(8),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.bar_chart, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          AppConstants.appName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // ── Nav Links (Desktop) ──
                  if (!isMobile) ...[
                    _ClientNavItem(
                      title: AppTranslations.get('dashboard', lang),
                      route: '/dashboard',
                      activeRoute: activeRoute,
                      isDark: isDark,
                    ),
                    _ClientNavItem(
                      title: AppTranslations.get('projects', lang),
                      route: '/projects',
                      activeRoute: activeRoute,
                      isDark: isDark,
                    ),
                    _ClientNavItem(
                      title: AppTranslations.get('daily_reports', lang),
                      route: '/daily-reports',
                      activeRoute: activeRoute,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 16),
                  ],

                  // ── User Avatar + Menu ──
                  ValueListenableBuilder<Uint8List?>(
                    valueListenable: userState.profileImageBytes,
                    builder: (context, imageBytes, _) {
                      return PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'dashboard':
                              navigatorKey.currentState?.pushNamed('/dashboard');
                              break;
                            case 'projects':
                              navigatorKey.currentState?.pushNamed('/projects');
                              break;
                            case 'profile':
                              navigatorKey.currentState?.pushNamed('/profile');
                              break;
                            case 'toggle_theme':
                              clientThemeNotifier.value = clientThemeNotifier.value == ThemeMode.light
                                  ? ThemeMode.dark
                                  : ThemeMode.light;
                              break;
                            case 'lang_ar':
                              clientLanguageNotifier.value = 'ar';
                              break;
                            case 'lang_en':
                              clientLanguageNotifier.value = 'en';
                              break;
                            case 'logout':
                              userState.logout();
                              break;
                          }
                        },
                        offset: const Offset(0, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        itemBuilder: (context) => [
                          _menuItem('dashboard', Icons.dashboard_outlined, AppTranslations.get('dashboard', lang)),
                          _menuItem('projects', Icons.folder_outlined, AppTranslations.get('projects', lang)),
                          _menuItem('profile', Icons.person_outline, AppTranslations.get('account_settings', lang)),
                          const PopupMenuDivider(),
                          // ── اللغة ──
                          PopupMenuItem(
                            enabled: false,
                            height: 40,
                            child: Row(
                              children: [
                                Icon(Icons.language, size: 18, color: isDark ? Colors.white54 : AppColors.textSecondary),
                                const SizedBox(width: 10),
                                _PopupLangBtn(label: 'AR', isActive: lang == 'ar', code: 'ar'),
                                const SizedBox(width: 8),
                                _PopupLangBtn(label: 'EN', isActive: lang == 'en', code: 'en'),
                              ],
                            ),
                          ),
                          // ── الثيم ──
                          PopupMenuItem(
                            value: 'toggle_theme',
                            child: Row(children: [
                              Icon(
                                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                                size: 18,
                                color: isDark ? Colors.amber : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 10),
                              Text(isDark ? (lang == 'ar' ? 'الوضع الفاتح' : 'Light Mode') : (lang == 'ar' ? 'الوضع الداكن' : 'Dark Mode')),
                            ]),
                          ),
                          const PopupMenuDivider(),
                          PopupMenuItem(
                            value: 'logout',
                            child: Row(children: [
                              const Icon(Icons.logout, size: 18, color: Colors.red),
                              const SizedBox(width: 10),
                              Text(AppTranslations.get('logout', lang), style: const TextStyle(color: Colors.red)),
                            ]),
                          ),
                        ],
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primary, width: 2),
                              color: isDark ? Colors.white10 : AppColors.greyLight,
                              image: imageBytes != null
                                  ? DecorationImage(image: MemoryImage(imageBytes), fit: BoxFit.cover)
                                  : null,
                            ),
                            child: imageBytes == null
                                ? Icon(Icons.person, size: 18, color: isDark ? Colors.white60 : Colors.grey)
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String label) {
    return PopupMenuItem(
      value: value,
      child: Row(children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Text(label),
      ]),
    );
  }
}

// ── Nav Item ──────────────────────────────────────────────
class _ClientNavItem extends StatefulWidget {
  final String title;
  final String route;
  final String activeRoute;
  final bool isDark;

  const _ClientNavItem({
    required this.title,
    required this.route,
    required this.activeRoute,
    required this.isDark,
  });

  @override
  State<_ClientNavItem> createState() => _ClientNavItemState();
}

class _ClientNavItemState extends State<_ClientNavItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.activeRoute == widget.route;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => navigatorKey.currentState?.pushNamed(widget.route),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive || isHovered ? FontWeight.bold : FontWeight.w500,
                  color: isActive || isHovered
                      ? AppColors.primary
                      : (widget.isDark ? Colors.white60 : AppColors.textSecondary),
                ),
                child: Text(widget.title),
              ),
              const SizedBox(height: 3),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 2,
                width: isActive ? 20 : (isHovered ? 14 : 0),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Popup Lang Button ─────────────────────────────────────
class _PopupLangBtn extends StatelessWidget {
  final String label;
  final bool isActive;
  final String code;

  const _PopupLangBtn({required this.label, required this.isActive, required this.code});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => clientLanguageNotifier.value = code,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isActive ? AppColors.primary : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

// ── Mobile Drawer ─────────────────────────────────────────
class _ClientDrawer extends StatelessWidget {
  final String lang;
  const _ClientDrawer({required this.lang});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: AppColors.primary),
            child: Row(
              children: [
                const Icon(Icons.bar_chart, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Text(AppConstants.appName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
          _drawerItem(context, Icons.dashboard_outlined,   AppTranslations.get('dashboard', lang),      '/dashboard'),
          _drawerItem(context, Icons.folder_outlined,      AppTranslations.get('projects', lang),        '/projects'),
          _drawerItem(context, Icons.description_outlined, AppTranslations.get('daily_reports', lang),   '/daily-reports'),
          _drawerItem(context, Icons.person_outline,       AppTranslations.get('account_settings', lang),'/profile'),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(AppTranslations.get('logout', lang), style: const TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              userState.logout();
            },
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: () {
        Navigator.pop(context);
        navigatorKey.currentState?.pushNamed(route);
      },
    );
  }
}

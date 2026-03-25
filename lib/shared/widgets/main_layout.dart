import 'package:flutter/material.dart';
import 'package:engineering_platform/core/constants/colors.dart';
import 'package:engineering_platform/core/constants/translations.dart';
import 'package:engineering_platform/core/state/language_state.dart';
import 'package:engineering_platform/core/utils/responsive.dart';
import 'package:engineering_platform/core/state/user_state.dart';
import 'package:engineering_platform/core/constants/app_constants.dart';
import 'package:engineering_platform/core/state/theme_state.dart';
import 'package:engineering_platform/core/themes/app_theme.dart';
import 'dart:typed_data';

// التنسيق الرئيسي للتطبيق: يوفر الهيكل العام (الجزء العلوي، المحتوى، والجزء السفلي)
class MainLayout extends StatelessWidget {
  final Widget child; // المحتوى المتغير لكل صفحة
  final List<String>? navItems; // عناصر الموقع الاختيارية
  final bool showDashboardShortcuts; // إظهار اختصارات لوحة التحكم
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static MainLayout? of(BuildContext context) {
    return context.findAncestorWidgetOfExactType<MainLayout>();
  }

  MainLayout({
    super.key,
    required this.child,
    this.navItems,
    this.showDashboardShortcuts = true,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: clientLanguageNotifier,
      builder: (context, lang, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: clientThemeNotifier,
          builder: (context, themeMode, _) {
            final bool isMobile = Responsive.isMobile(context);
            final bool isDark = themeMode == ThemeMode.dark;

            return Theme(
              data: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
              child: Scaffold(
                key: _scaffoldKey,
                backgroundColor: isDark
                    ? const Color(0xFF0F172A)
                    : AppColors.background,
                drawer: isMobile ? AppDrawer(lang: lang) : null,
                body: Column(
                  children: [
                    Header(
                      scaffoldKey: _scaffoldKey,
                      navItems: navItems,
                      showDashboardShortcuts: showDashboardShortcuts,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(children: [child, const Footer()]),
                      ),
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

// القائمة الجانبية (تظهر في وضع الجوال)
class AppDrawer extends StatelessWidget {
  final String lang;
  const AppDrawer({super.key, required this.lang});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // رأس القائمة الجانبية (يحتوي على الشعار واسم التطبيق)
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.black),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.bar_chart,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    AppConstants.appName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // عناصر القائمة الجانبية
          _DrawerItem(
            title: AppTranslations.get('home', lang),
            icon: Icons.home_rounded,
            onTap: () {
              Navigator.pop(context);
              navigatorKey.currentState?.pushNamed('/');
            },
          ),
          _DrawerItem(
            title: AppTranslations.get('services', lang),
            icon: Icons.engineering_rounded,
            onTap: () {
              Navigator.pop(context);
              navigatorKey.currentState?.pushNamed('/civil-services');
            },
          ),
          _DrawerItem(
            title: AppTranslations.get('about', lang),
            icon: Icons.info_outline_rounded,
          ),
          _DrawerItem(
            title: AppTranslations.get('contact', lang),
            icon: Icons.contact_support_outlined,
          ),
          const Divider(),
          // قسم الحساب (يتغير حسب ما إذا كان المستخدم مسجلاً للدخول أم لا)
          ValueListenableBuilder<bool>(
            valueListenable: userState.isLoggedIn,
            builder: (context, isLoggedIn, _) {
              if (isLoggedIn) {
                return Column(
                  children: [
                    _DrawerItem(
                      title: AppTranslations.get('information', lang),
                      icon: Icons.info_outline,
                      onTap: () {
                        Navigator.pop(context);
                        navigatorKey.currentState?.pushNamed('/profile');
                      },
                    ),
                    if (MainLayout.of(context)?.showDashboardShortcuts ?? true)
                      _DrawerItem(
                        title: AppTranslations.get('dashboard', lang),
                        icon: Icons.dashboard_outlined,
                        onTap: () {
                          Navigator.pop(context);
                          navigatorKey.currentState?.pushNamed('/dashboard');
                        },
                      ),
                    _DrawerItem(
                      title: AppTranslations.get('logout', lang),
                      icon: Icons.logout,
                      onTap: () {
                        Navigator.pop(context);
                        userState.logout();
                      },
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  _DrawerItem(
                    title: AppTranslations.get('login', lang),
                    icon: Icons.login_rounded,
                    onTap: () {
                      Navigator.pop(context);
                      navigatorKey.currentState?.pushNamed('/login');
                    },
                  ),
                  _DrawerItem(
                    title: AppTranslations.get('signup', lang),
                    icon: Icons.person_add_rounded,
                    onTap: () {
                      Navigator.pop(context);
                      navigatorKey.currentState?.pushNamed('/signup');
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// عنصر مفرد في القائمة الجانبية
class _DrawerItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const _DrawerItem({required this.title, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.accent),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: onTap ?? () {},
    );
  }
}

// الجزء العلوي (شريط التنقل): يحتوي على الشعار، روابط التنقل، تبديل اللغة، وحساب المستخدم
class Header extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final List<String>? navItems;
  final bool showDashboardShortcuts;
  const Header({
    super.key,
    required this.scaffoldKey,
    this.navItems,
    this.showDashboardShortcuts = true,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: clientLanguageNotifier,
      builder: (context, lang, child) {
        final bool isMobile = Responsive.isMobile(context);

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 32,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white10
                    : AppColors.greyLight,
              ),
            ),
          ),
          child: Row(
            children: [
              // زر القائمة الجانبية (يظهر فقط في الجوال)
              if (isMobile) ...[
                IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  onPressed: () => scaffoldKey.currentState?.openDrawer(),
                ),
                const SizedBox(width: 8),
              ],
              // الشعار واسم التطبيق (قابل للضغط للعودة للرئيسية)
              InkWell(
                onTap: () => navigatorKey.currentState?.pushNamed('/'),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        Icons.bar_chart,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black
                            : Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppConstants.appName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // روابط التنقل (تختفي في وضع الجوال لتنتقل للـ Drawer)
              if (!isMobile) ...[
                if (navItems != null)
                  ...navItems!.map(
                    (key) => NavItem(
                      title: AppTranslations.get(key, lang),
                      onTap: () {
                        if (key == 'home') {
                          navigatorKey.currentState?.pushNamed('/');
                        } else if (key == 'projects') {
                          navigatorKey.currentState?.pushNamed('/dashboard');
                        } else if (key == 'daily_reports') {
                          navigatorKey.currentState?.pushNamed(
                            '/daily-reports',
                          );
                        } else if (key == 'account_settings') {
                          navigatorKey.currentState?.pushNamed('/profile');
                        }
                      },
                    ),
                  )
                else ...[
                  NavItem(
                    title: AppTranslations.get('home', lang),
                    onTap: () => navigatorKey.currentState?.pushNamed('/'),
                  ),
                  NavItem(
                    title: AppTranslations.get('services', lang),
                    onTap: () =>
                        navigatorKey.currentState?.pushNamed('/civil-services'),
                  ),
                  NavItem(title: AppTranslations.get('about', lang)),
                  NavItem(title: AppTranslations.get('contact', lang)),
                ],
                const SizedBox(width: 24),
              ],

              if (showDashboardShortcuts) ...[
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.dashboard_customize_outlined,
                    color: AppColors.accent,
                  ),
                  tooltip: 'Dashboard Shortcuts',
                  offset: const Offset(0, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (route) {
                    if (route == 'admin') {
                      navigatorKey.currentState?.pushNamed('/admin');
                    } else if (route == 'engineer') {
                      navigatorKey.currentState?.pushNamed(
                        '/engineer/projects',
                      );
                    } else if (route == 'technician') {
                      navigatorKey.currentState?.pushNamed('/technician/tasks');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Navigating to: $route')),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'engineer',
                      child: Text('Engineer Dashboard'),
                    ),
                    PopupMenuItem(
                      value: 'admin',
                      child: Text(AppTranslations.get('admin', lang)),
                    ),
                    const PopupMenuItem(
                      value: 'technician',
                      child: Text('Technician Dashboard'),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
              ],

              // مبدل اللغة (EN / AR)
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.1)
                      : AppColors.greyLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _LangButton(
                      label: 'EN',
                      isActive: lang == 'en',
                      code: 'en',
                    ),
                    _LangButton(
                      label: 'AR',
                      isActive: lang == 'ar',
                      code: 'ar',
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),
              // زر تبديل الثيم
              IconButton(
                onPressed: () {
                  clientThemeNotifier.value =
                      clientThemeNotifier.value == ThemeMode.light
                      ? ThemeMode.dark
                      : ThemeMode.light;
                },
                icon: Icon(
                  clientThemeNotifier.value == ThemeMode.light
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.amber
                      : AppColors.textPrimary,
                ),
              ),

              // قسم تسجيل الدخول / الملف الشخصي
              ValueListenableBuilder<bool>(
                valueListenable: userState.isLoggedIn,
                builder: (context, isLoggedIn, _) {
                  return Row(
                    children: [
                      if (!isLoggedIn && !isMobile) ...[
                        const SizedBox(width: 24),
                        ElevatedButton(
                          onPressed: () =>
                              navigatorKey.currentState?.pushNamed('/signup'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: AppColors.primary,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            AppTranslations.get('signup', lang),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () =>
                              navigatorKey.currentState?.pushNamed('/login'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : AppColors.textPrimary,
                            backgroundColor:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white12
                                : AppColors.greyLight,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            AppTranslations.get('login', lang),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      // عند تسجيل الدخول: عرض صورة المستخدم وقائمة منسدلة
                      if (isLoggedIn)
                        ValueListenableBuilder<Uint8List?>(
                          valueListenable: userState.profileImageBytes,
                          builder: (context, imageBytes, _) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'dashboard') {
                                    navigatorKey.currentState?.pushNamed(
                                      '/dashboard',
                                    );
                                  } else if (value == 'info') {
                                    navigatorKey.currentState?.pushNamed(
                                      '/profile',
                                    );
                                  } else if (value == 'logout') {
                                    userState.logout();
                                  }
                                },
                                offset: const Offset(0, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'info',
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.info_outline,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          AppTranslations.get(
                                            'information',
                                            lang,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'dashboard',
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.dashboard_outlined,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          AppTranslations.get(
                                            'dashboard',
                                            lang,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuDivider(),
                                  PopupMenuItem(
                                    value: 'logout',
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.logout,
                                          size: 20,
                                          color: Colors.red,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          AppTranslations.get('logout', lang),
                                          style: const TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.accent,
                                      width: 2,
                                    ),
                                    image: imageBytes != null
                                        ? DecorationImage(
                                            image: MemoryImage(imageBytes),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: imageBytes == null
                                      ? const Icon(Icons.person)
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// زر تبديل اللغة (داخلي)
class _LangButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final String code;

  const _LangButton({
    required this.label,
    required this.isActive,
    required this.code,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => clientLanguageNotifier.value = code,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? (Theme.of(context).brightness == Brightness.dark
                    ? Colors.blue.shade600
                    : Colors.blue.shade800)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive
                ? Colors.white
                : (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.black54),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

// عنصر تنقل احترافي مع تأثيرات حركية عند تمرير الماوس
class NavItem extends StatefulWidget {
  final String title;
  final VoidCallback? onTap;
  final bool isActive;

  const NavItem({
    super.key,
    required this.title,
    this.onTap,
    this.isActive = false,
  });

  @override
  State<NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<NavItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: widget.isActive || isHovered
                      ? FontWeight.bold
                      : FontWeight.w500,
                  color: widget.isActive || isHovered
                      ? AppColors.primary
                      : (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : AppColors.textSecondary),
                  fontFamily: 'Inter',
                ),
                child: Text(widget.title),
              ),
              const SizedBox(height: 4),
              // خط سفلي متحرك يظهر عند التمرير أو النشاط
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 2,
                width: widget.isActive ? 20 : (isHovered ? 15 : 0),
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

// تذييل الصفحة (Footer): يحتوي على روابط سريعة، أيقونات التواصل الاجتماعي، وحقوق النشر
class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: clientLanguageNotifier,
      builder: (context, lang, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.isMobile(context) ? 16 : 32,
            vertical: 24,
          ),
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : AppColors.white,
          child: Column(
            children: [
              // روابط سريعة
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 20,
                runSpacing: 10,
                children: [
                  TextButton(
                    onPressed: () => navigatorKey.currentState?.pushNamed('/'),
                    child: Text(
                      AppTranslations.get('home', lang),
                      style: TextStyle(
                        color: isDark
                            ? Colors.white70
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        navigatorKey.currentState?.pushNamed('/civil-services'),
                    child: Text(
                      AppTranslations.get('services', lang),
                      style: TextStyle(
                        color: isDark
                            ? Colors.white70
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      AppTranslations.get('about', lang),
                      style: TextStyle(
                        color: isDark
                            ? Colors.white70
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      AppTranslations.get('contact', lang),
                      style: TextStyle(
                        color: isDark
                            ? Colors.white70
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // أيقونات التواصل الاجتماعي
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.share,
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.facebook,
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.link,
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // حقوق النشر
              Text(
                AppTranslations.get('copyright', lang),
                style: TextStyle(
                  color: isDark ? Colors.white38 : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

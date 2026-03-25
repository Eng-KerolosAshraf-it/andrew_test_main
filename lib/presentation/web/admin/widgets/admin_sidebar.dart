import 'package:flutter/material.dart';
import 'package:engineering_platform/core/constants/colors.dart';
import 'package:engineering_platform/core/state/language_state.dart';
import 'package:engineering_platform/core/state/theme_state.dart';
import 'package:engineering_platform/core/state/user_state.dart';
import 'dart:typed_data';

import 'package:engineering_platform/core/constants/route_names.dart';

final ValueNotifier<bool> sidebarCollapsed = ValueNotifier<bool>(false);

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return ValueListenableBuilder<bool>(
      valueListenable: sidebarCollapsed,
      builder: (context, isCollapsed, _) {
        return ValueListenableBuilder<String>(
          valueListenable: adminLanguageNotifier,
          builder: (context, lang, _) {
            return ValueListenableBuilder<ThemeMode>(
              valueListenable: adminThemeNotifier,
              builder: (context, themeMode, _) {
                final isDark = themeMode == ThemeMode.dark;
                final isAr = lang == 'ar';

                return ClipRect(
                  child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  width: isCollapsed ? 70 : 260,
                  color: isDark ? const Color(0xFF0F172A) : AppColors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── زر الطي فقط (اللوجو انتقل للهيدر) ──
                      SizedBox(
                        height: 70,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 16 : 16),
                          child: Row(
                            mainAxisAlignment: isCollapsed
                                ? MainAxisAlignment.center
                                : MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: () => sidebarCollapsed.value = !isCollapsed,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.greyLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    isCollapsed ? Icons.keyboard_arrow_right : Icons.keyboard_arrow_left,
                                    size: 20,
                                    color: isDark ? Colors.white60 : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ── بيانات المستخدم ──────────────────────
                      if (!isCollapsed) ...[
                        _UserInfo(isDark: isDark),
                        const SizedBox(height: 16),
                      ],

                      Divider(color: isDark ? Colors.white10 : AppColors.greyLight, height: 1),
                      const SizedBox(height: 8),

                      // ── عناصر القائمة ────────────────────────
                      _SidebarItem(
                        icon: Icons.dashboard_rounded,
                        title: isAr ? 'لوحة التحكم' : 'Dashboard',
                        isActive: currentRoute == RouteNames.adminDashboard,
                        isDark: isDark,
                        isCollapsed: isCollapsed,
                        onTap: () => currentRoute != RouteNames.adminDashboard ? Navigator.pushNamed(context, RouteNames.adminDashboard) : null,
                      ),
                      _SidebarItem(
                        icon: Icons.business_center_rounded,
                        title: isAr ? 'المشاريع' : 'Projects',
                        isActive: currentRoute == RouteNames.adminProjects,
                        isDark: isDark,
                        isCollapsed: isCollapsed,
                        onTap: () => currentRoute != RouteNames.adminProjects ? Navigator.pushNamed(context, RouteNames.adminProjects) : null,
                      ),
                      _SidebarItem(
                        icon: Icons.checklist_rtl_rounded,
                        title: isAr ? 'الطلبات' : 'Requests',
                        isActive: currentRoute == RouteNames.adminRequests,
                        isDark: isDark,
                        isCollapsed: isCollapsed,
                        onTap: () => currentRoute != RouteNames.adminRequests ? Navigator.pushNamed(context, RouteNames.adminRequests) : null,
                      ),
                      _SidebarItem(
                        icon: Icons.people_alt_rounded,
                        title: isAr ? 'الكوادر' : 'Staff',
                        isActive: currentRoute == RouteNames.adminStaff,
                        isDark: isDark,
                        isCollapsed: isCollapsed,
                        onTap: () => currentRoute != RouteNames.adminStaff ? Navigator.pushNamed(context, RouteNames.adminStaff) : null,
                      ),
                      _SidebarItem(
                        icon: Icons.person_outline_rounded,
                        title: isAr ? 'العملاء' : 'Clients',
                        isActive: currentRoute == RouteNames.adminClients,
                        isDark: isDark,
                        isCollapsed: isCollapsed,
                        onTap: () => currentRoute != RouteNames.adminClients ? Navigator.pushNamed(context, RouteNames.adminClients) : null,
                      ),
                      _SidebarItem(
                        icon: Icons.settings_rounded,
                        title: isAr ? 'الإعدادات' : 'Settings',
                        isActive: currentRoute == RouteNames.adminSettings,
                        isDark: isDark,
                        isCollapsed: isCollapsed,
                        onTap: () => currentRoute != RouteNames.adminSettings ? Navigator.pushNamed(context, RouteNames.adminSettings) : null,
                      ),

                      const Spacer(),

                      Divider(color: isDark ? Colors.white10 : AppColors.greyLight, height: 1),

                      // ── زر الخروج ────────────────────────────
                      Padding(
                        padding: EdgeInsets.all(isCollapsed ? 8 : 16),
                        child: Tooltip(
                          message: isCollapsed ? (isAr ? 'تسجيل الخروج' : 'Logout') : '',
                          child: InkWell(
                            onTap: () async {
                              await userState.logout();
                              Navigator.pushNamedAndRemoveUntil(context, RouteNames.login, (_) => false);
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 0 : 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: isCollapsed
                                  ? const Center(child: Icon(Icons.logout_rounded, color: Colors.red, size: 20))
                                  : Row(
                                      children: [
                                        const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
                                        const SizedBox(width: 12),
                                        Text(
                                          isAr ? 'تسجيل الخروج' : 'Logout',
                                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 14),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  ), // ClipRect
                );
              },
            );
          },
        );
      },
    );
  }
}

// ── بيانات المستخدم ───────────────────────────
class _UserInfo extends StatelessWidget {
  final bool isDark;
  const _UserInfo({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: userState.userName,
      builder: (context, name, _) {
        return ValueListenableBuilder<Uint8List?>(
          valueListenable: userState.profileImageBytes,
          builder: (context, imageBytes, _) {
            final initials = _getInitials(name);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.2),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 2),
                      image: imageBytes != null ? DecorationImage(image: MemoryImage(imageBytes), fit: BoxFit.cover) : null,
                    ),
                    child: imageBytes == null
                        ? Center(child: Text(initials, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.primary)))
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name ?? 'Admin', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary), overflow: TextOverflow.ellipsis),
                        Text(
                          adminLanguageNotifier.value == 'ar' ? 'مدير النظام' : 'System Admin',
                          style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : AppColors.textSecondary),
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

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return 'A';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name[0].toUpperCase();
  }
}

// ── عنصر مفرد في القائمة ──────────────────────
class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isActive;
  final bool isDark;
  final bool isCollapsed;
  final VoidCallback? onTap;

  const _SidebarItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isActive = false,
    this.isDark = false,
    this.isCollapsed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isCollapsed ? title : '',
      preferBelow: false,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: isCollapsed ? 8 : 12, vertical: 2),
        decoration: BoxDecoration(
          color: isActive
              ? (isDark ? AppColors.primary.withValues(alpha: 0.15) : AppColors.primary.withValues(alpha: 0.08))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isActive ? Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1) : null,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 48,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Icon(icon, color: isActive ? AppColors.primary : (isDark ? Colors.white60 : AppColors.textSecondary), size: 20),
                  if (!isCollapsed) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isActive ? (isDark ? Colors.white : AppColors.primary) : (isDark ? Colors.white60 : AppColors.textSecondary),
                          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (isActive)
                      Container(width: 3, height: 20, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

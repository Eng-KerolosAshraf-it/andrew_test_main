import 'package:flutter/material.dart';
import 'package:engineering_platform/core/constants/colors.dart';
import 'package:engineering_platform/core/state/language_state.dart';
import 'package:engineering_platform/core/state/theme_state.dart';
import 'package:engineering_platform/core/utils/responsive.dart';
import 'package:engineering_platform/presentation/web/admin/widgets/admin_header.dart';
import 'package:engineering_platform/presentation/web/admin/widgets/admin_sidebar.dart';

class AdminClientsPage extends StatelessWidget {
  const AdminClientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: sidebarCollapsed,
      builder: (context, isCollapsed, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: adminThemeNotifier,
          builder: (context, themeMode, _) {
            return ValueListenableBuilder<String>(
              valueListenable: adminLanguageNotifier,
              builder: (context, lang, _) {
                final isDark = themeMode == ThemeMode.dark;
                final isAr = lang == 'ar';
                final isMobile = Responsive.isMobile(context);

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
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isAr ? 'العملاء' : 'Clients',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(48),
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF1E293B) : AppColors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: isDark ? Colors.white10 : AppColors.greyBorder),
                                        ),
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.people_outline, size: 48, color: isDark ? Colors.white30 : Colors.grey),
                                              const SizedBox(height: 16),
                                              Text(
                                                isAr ? 'قائمة العملاء' : 'Clients List',
                                                style: TextStyle(fontSize: 16, color: isDark ? Colors.white38 : Colors.grey),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                isAr ? 'قريباً...' : 'Coming soon...',
                                                style: TextStyle(fontSize: 13, color: isDark ? Colors.white24 : Colors.grey.shade400),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
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
      },
    );
  }
}

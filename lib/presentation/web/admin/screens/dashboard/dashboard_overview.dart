import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:engineering_platform/core/constants/colors.dart';
import 'package:engineering_platform/core/state/language_state.dart';
import 'package:engineering_platform/core/state/theme_state.dart';
import 'package:engineering_platform/core/utils/responsive.dart';
import 'package:engineering_platform/presentation/web/admin/widgets/admin_header.dart';
import 'package:engineering_platform/presentation/web/admin/widgets/admin_sidebar.dart';
import 'dashboard_notifier.dart';
import 'dashboard_state.dart';

import 'package:engineering_platform/core/constants/route_names.dart';

class DashboardOverview extends ConsumerWidget {
  const DashboardOverview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder<bool>(
      valueListenable: sidebarCollapsed, // ✅ هنا الإضافة
      builder: (context, isCollapsed, _) {
        return ValueListenableBuilder<String>(
          valueListenable: adminLanguageNotifier,
          builder: (context, lang, _) {
            return ValueListenableBuilder<ThemeMode>(
              valueListenable: adminThemeNotifier,
              builder: (context, themeMode, _) {
                final bool isMobile = Responsive.isMobile(context);
                final isDark = themeMode == ThemeMode.dark;

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
                            const Expanded(child: DashboardContent()),
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

class DashboardContent extends ConsumerWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);
    final notifier = ref.read(dashboardProvider.notifier);

    return ValueListenableBuilder<String>(
      valueListenable: adminLanguageNotifier,
      builder: (context, lang, _) {
        final isAr = lang == 'ar';
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: adminThemeNotifier,
          builder: (context, themeMode, _) {
            final isDark = themeMode == ThemeMode.dark;

            return SingleChildScrollView(
              padding: EdgeInsets.all(Responsive.isMobile(context) ? 16 : 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isAr ? 'نظرة عامة على لوحة التحكم' : 'Dashboard Overview',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary),
                      ),
                      IconButton(
                        onPressed: state.isLoading ? null : notifier.fetchStats,
                        icon: Icon(Icons.refresh, color: isDark ? Colors.white60 : AppColors.textSecondary),
                        tooltip: isAr ? 'تحديث' : 'Refresh',
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  if (state.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 12),
                          Expanded(child: Text(state.errorMessage!, style: const TextStyle(color: Colors.red))),
                          IconButton(onPressed: notifier.fetchStats, icon: const Icon(Icons.refresh, color: Colors.red)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = 4;
                      if (constraints.maxWidth < 600) crossAxisCount = 1;
                      else if (constraints.maxWidth < 900) crossAxisCount = 2;

                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.5,
                        children: [
                          _StatCard(title: isAr ? 'إجمالي المشاريع' : 'Total Projects', value: state.stats.totalProjects, icon: Icons.folder_outlined, iconColor: Colors.blue, isLoading: state.isLoading, isDark: isDark, onTap: () => Navigator.pushNamed(context, RouteNames.adminProjects)),
                          _StatCard(title: isAr ? 'المهندسين' : 'Engineers', value: state.stats.totalEngineers, icon: Icons.engineering_outlined, iconColor: Colors.green, isLoading: state.isLoading, isDark: isDark, onTap: () => Navigator.pushNamed(context, RouteNames.adminStaff, arguments: 0)),
                          _StatCard(title: isAr ? 'الفنيين' : 'Technicians', value: state.stats.totalTechnicians, icon: Icons.build_outlined, iconColor: Colors.orange, isLoading: state.isLoading, isDark: isDark, onTap: () => Navigator.pushNamed(context, RouteNames.adminStaff, arguments: 1)),
                          _StatCard(title: isAr ? 'العملاء' : 'Clients', value: state.stats.totalClients, icon: Icons.people_outline, iconColor: Colors.purple, isLoading: state.isLoading, isDark: isDark, onTap: () => Navigator.pushNamed(context, RouteNames.adminClients)),
                          _StatCard(title: isAr ? 'طلبات جديدة' : 'New Requests', value: state.stats.newRequests, icon: Icons.inbox_outlined, iconColor: Colors.red, isLoading: state.isLoading, isDark: isDark, highlight: state.stats.newRequests > 0, onTap: () => Navigator.pushNamed(context, RouteNames.adminRequests)),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 900) {
                        return Column(
                          children: [
                            _ChartCard(title: isAr ? 'مراحل اكتمال المشروع' : 'Project Completion Stages', subtitle: '60%', trend: '+5%', isDark: isDark, child: const _BarChartPlaceholder()),
                            const SizedBox(height: 24),
                            _ChartCard(title: isAr ? 'استخدام الموارد الشهري' : 'Monthly Resource Utilization', subtitle: '85%', trend: '+3%', isDark: isDark, child: const _LineChartPlaceholder()),
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: _ChartCard(title: isAr ? 'مراحل اكتمال المشروع' : 'Project Completion Stages', subtitle: '60%', trend: '+5%', isDark: isDark, child: const _BarChartPlaceholder())),
                          const SizedBox(width: 24),
                          Expanded(flex: 2, child: _ChartCard(title: isAr ? 'استخدام الموارد الشهري' : 'Monthly Resource Utilization', subtitle: '85%', trend: '+3%', isDark: isDark, child: const _LineChartPlaceholder())),
                        ],
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
}

class _StatCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color iconColor;
  final bool isLoading;
  final bool isDark;
  final bool highlight;

  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.isLoading,
    this.isDark = false,
    this.highlight = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlight ? iconColor.withValues(alpha: 0.5) : (isDark ? Colors.white10 : AppColors.greyBorder),
          width: highlight ? 2 : 1,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const Spacer(),
              if (highlight) Container(width: 8, height: 8, decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle)),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : AppColors.textSecondary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          isLoading
              ? Container(width: 60, height: 24, decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.grey.shade200, borderRadius: BorderRadius.circular(4)))
              : Text(value.toString(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
        ],
      ),
    ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String trend;
  final Widget child;
  final bool isDark;

  const _ChartCard({required this.title, required this.subtitle, required this.trend, required this.child, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : AppColors.greyBorder),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(subtitle, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(trend, style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(height: 200, child: child),
        ],
      ),
    );
  }
}

class _BarChartPlaceholder extends StatelessWidget {
  const _BarChartPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(4, (index) {
        final heights = [0.7, 0.4, 0.8, 0.6];
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(width: 40, height: 150 * heights[index], decoration: BoxDecoration(color: AppColors.greyLight, borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 8),
            Text('Stage ${index + 1}', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ],
        );
      }),
    );
  }
}

class _LineChartPlaceholder extends StatelessWidget {
  const _LineChartPlaceholder();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.infinite, painter: _LineChartPainter());
  }
}

class _LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.cubicTo(size.width * 0.2, size.height * 0.1, size.width * 0.4, size.height * 0.9, size.width * 0.6, size.height * 0.4);
    path.cubicTo(size.width * 0.8, size.height * 0.1, size.width * 0.9, size.height * 0.8, size.width, size.height * 0.3);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

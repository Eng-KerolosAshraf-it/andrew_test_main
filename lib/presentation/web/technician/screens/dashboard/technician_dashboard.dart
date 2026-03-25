import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:engineering_platform/core/constants/colors.dart';
import 'package:engineering_platform/core/state/language_state.dart';
import 'package:engineering_platform/core/state/theme_state.dart';
import 'package:engineering_platform/core/state/user_state.dart';
import 'package:engineering_platform/core/utils/responsive.dart';
import 'package:engineering_platform/core/constants/app_constants.dart';
import 'package:engineering_platform/presentation/web/technician/widgets/technician_widgets.dart';
import 'technician_dashboard_notifier.dart';
import 'technician_dashboard_state.dart';

import 'package:engineering_platform/core/constants/route_names.dart';

const _teal = Color(0xFF0D9488);

class TechnicianDashboardPage extends ConsumerWidget {
  const TechnicianDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder<String>(
      valueListenable: technicianLanguageNotifier,
      builder: (context, lang, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: technicianThemeNotifier,
          builder: (context, themeMode, _) {
            final isMobile = Responsive.isMobile(context);
            final isDark = themeMode == ThemeMode.dark;

            return Scaffold(
              backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.background,
              drawer: isMobile ? const TechnicianSidebar() : null,
              body: Column(
                children: [
                  TechnicianHeader(isMobile: isMobile),
                  Expanded(
                    child: Row(
                      children: [
                        if (!isMobile) const TechnicianSidebar(),
                        Expanded(
                          child: _DashboardContent(lang: lang, isDark: isDark, isMobile: isMobile),
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

class _DashboardContent extends ConsumerWidget {
  final String lang;
  final bool isDark, isMobile;
  const _DashboardContent({required this.lang, required this.isDark, required this.isMobile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(technicianDashboardProvider);
    final notifier = ref.read(technicianDashboardProvider.notifier);
    final isAr = lang == 'ar';

    return SingleChildScrollView(
      child: Column(
        children: [
          // ── Hero ──
          _HeroSection(isDark: isDark, isAr: isAr),

          // ── Body ──
          Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.errorMessage != null)
                  _ErrorBanner(message: state.errorMessage!, onRetry: notifier.fetchDashboard),

                if (state.isLoading)
                  const SizedBox(height: 300, child: Center(child: CircularProgressIndicator()))
                else ...[
                  _StatsGrid(stats: state.stats, isAr: isAr, isDark: isDark),
                  const SizedBox(height: 40),
                  _PendingTasksSection(tasks: state.pendingTasks, isDark: isDark, isAr: isAr),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero ──────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  final bool isDark, isAr;
  const _HeroSection({required this.isDark, required this.isAr});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: userState.userName,
      builder: (context, name, _) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: isAr ? Alignment.centerRight : Alignment.centerLeft,
              end: isAr ? Alignment.centerLeft : Alignment.centerRight,
              colors: isDark
                  ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                  : [const Color(0xFF0F766E), const Color(0xFF0D9488)],
            ),
          ),
          child: Row(
            textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    isAr ? 'أهلاً، ${name ?? 'الفني'} 🔧' : 'Welcome, ${name ?? 'Technician'} 🔧',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isAr ? 'تابع مهامك المعينة من هنا' : 'Track your assigned tasks here',
                    style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.75)),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                    children: [
                      _HeroBtn(label: isAr ? 'مهامي' : 'My Tasks', icon: Icons.list_alt_outlined,
                        onTap: () => Navigator.pushNamed(context, RouteNames.technicianTasks), primary: true),
                      const SizedBox(width: 12),
                      _HeroBtn(label: isAr ? 'إثبات التنفيذ' : 'Upload Proof', icon: Icons.upload_outlined,
                        onTap: () => Navigator.pushNamed(context, RouteNames.technicianExecution), primary: false),
                    ],
                  ),
                ],
              ),
              Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.build_outlined, size: 46, color: Colors.white.withValues(alpha: 0.4)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool primary;
  const _HeroBtn({required this.label, required this.icon, required this.onTap, required this.primary});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: primary ? Colors.white : Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: primary ? null : Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 15, color: primary ? _teal : Colors.white),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13,
              color: primary ? _teal : Colors.white)),
        ]),
      ),
    );
  }
}

// ── Stats Grid ────────────────────────────────────────────
class _StatsGrid extends StatelessWidget {
  final TechnicianDashboardStats stats;
  final bool isAr, isDark;
  const _StatsGrid({required this.stats, required this.isAr, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatItem(label: isAr ? 'إجمالي المهام' : 'Total Tasks', value: stats.totalTasks,
          icon: Icons.list_alt_outlined, color: _teal, route: '/technician/tasks'),
      _StatItem(label: isAr ? 'قيد الانتظار' : 'Pending', value: stats.pendingTasks,
          icon: Icons.hourglass_empty_outlined, color: const Color(0xFFF59E0B), route: '/technician/tasks'),
      _StatItem(label: isAr ? 'جاري التنفيذ' : 'In Progress', value: stats.inProgressTasks,
          icon: Icons.play_circle_outline, color: const Color(0xFF2196F3), route: '/technician/tasks'),
      _StatItem(label: isAr ? 'مكتملة' : 'Completed', value: stats.completedTasks,
          icon: Icons.check_circle_outline, color: const Color(0xFF10B981), route: '/technician/tasks'),
    ];

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.8,
      children: items.map((item) => _StatCard(item: item, isDark: isDark,
          hasOverdue: item.route == '/technician/tasks' && stats.overdueTasks > 0 && item.value == stats.pendingTasks)).toList(),
    );
  }
}

class _StatItem {
  final String label, route;
  final int value;
  final IconData icon;
  final Color color;
  const _StatItem({required this.label, required this.value, required this.icon, required this.color, required this.route});
}

class _StatCard extends StatefulWidget {
  final _StatItem item;
  final bool isDark, hasOverdue;
  const _StatCard({required this.item, required this.isDark, this.hasOverdue = false});

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, widget.item.route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _hovered ? widget.item.color.withValues(alpha: 0.08)
                : (widget.isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hovered ? widget.item.color.withValues(alpha: 0.4)
                  : (widget.isDark ? Colors.white10 : const Color(0xFFE5E7EB)),
            ),
            boxShadow: _hovered
                ? [BoxShadow(color: widget.item.color.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, 6))]
                : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: widget.item.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(widget.item.icon, color: widget.item.color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${widget.item.value}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900,
                    color: widget.isDark ? Colors.white : AppColors.textPrimary, letterSpacing: -1)),
                Text(widget.item.label, style: TextStyle(fontSize: 11,
                    color: widget.isDark ? Colors.white54 : AppColors.textSecondary)),
              ],
            )),
            Icon(Icons.arrow_forward_ios, size: 11,
                color: _hovered ? widget.item.color : (widget.isDark ? Colors.white30 : Colors.grey.shade300)),
          ]),
        ),
      ),
    );
  }
}

// ── Pending Tasks ─────────────────────────────────────────
class _PendingTasksSection extends StatelessWidget {
  final List<TechnicianDashboardTask> tasks;
  final bool isDark, isAr;
  const _PendingTasksSection({required this.tasks, required this.isDark, required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(isAr ? 'المهام المعلقة' : 'Pending Tasks',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.textPrimary)),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/technician/tasks'),
              child: Text(isAr ? 'عرض الكل' : 'View All',
                style: const TextStyle(fontSize: 13, color: _teal, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (tasks.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE5E7EB)),
            ),
            child: Column(children: [
              Icon(Icons.task_alt, size: 48, color: _teal.withValues(alpha: 0.3)),
              const SizedBox(height: 10),
              Text(isAr ? 'ممتاز! لا توجد مهام معلقة' : 'Great! No pending tasks',
                style: TextStyle(fontSize: 14, color: isDark ? Colors.white38 : AppColors.textSecondary)),
            ]),
          )
        else
          ...tasks.map((t) => _TaskRow(task: t, isDark: isDark, isAr: isAr)),
      ],
    );
  }
}

class _TaskRow extends StatefulWidget {
  final TechnicianDashboardTask task;
  final bool isDark, isAr;
  const _TaskRow({required this.task, required this.isDark, required this.isAr});

  @override
  State<_TaskRow> createState() => _TaskRowState();
}

class _TaskRowState extends State<_TaskRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final priorityColor = Color(widget.task.priorityColor);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/technician/tasks'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.isDark
                ? Colors.white.withValues(alpha: _hovered ? 0.07 : 0.04)
                : (_hovered ? const Color(0xFFF0FDFA) : Colors.white),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hovered ? _teal.withValues(alpha: 0.3)
                  : (widget.isDark ? Colors.white10 : const Color(0xFFE5E7EB)),
            ),
          ),
          child: Row(
            textDirection: widget.isAr ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Container(width: 3, height: 44,
                decoration: BoxDecoration(color: priorityColor, borderRadius: BorderRadius.circular(4))),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: widget.isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(widget.task.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                      color: widget.isDark ? Colors.white : AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Row(
                    textDirection: widget.isAr ? TextDirection.rtl : TextDirection.ltr,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(color: priorityColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text(widget.task.priorityLabel(widget.isAr),
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: priorityColor)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(color: Color(widget.task.statusBgColor), borderRadius: BorderRadius.circular(4)),
                        child: Text(widget.task.statusLabel(widget.isAr),
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(widget.task.statusTextColor))),
                      ),
                      if (widget.task.isOverdue) ...[
                        const SizedBox(width: 6),
                        const Text('⚠️', style: TextStyle(fontSize: 11)),
                      ],
                    ],
                  ),
                ],
              )),
              if (widget.task.dueDate != null) ...[
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Icon(Icons.schedule, size: 12, color: widget.task.isOverdue ? Colors.red : (widget.isDark ? Colors.white38 : AppColors.textSecondary)),
                  Text('${widget.task.dueDate!.day}/${widget.task.dueDate!.month}',
                    style: TextStyle(fontSize: 11, color: widget.task.isOverdue ? Colors.red : (widget.isDark ? Colors.white38 : AppColors.textSecondary))),
                ]),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200)),
      child: Row(children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(message, style: const TextStyle(color: Colors.red, fontSize: 13))),
        IconButton(onPressed: onRetry, icon: const Icon(Icons.refresh, color: Colors.red, size: 18), padding: EdgeInsets.zero),
      ]),
    );
  }
}

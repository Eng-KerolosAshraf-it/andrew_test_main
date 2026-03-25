import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:engineering_platform/core/constants/colors.dart';
import 'package:engineering_platform/core/state/language_state.dart';
import 'package:engineering_platform/core/state/theme_state.dart';
import 'package:engineering_platform/core/state/user_state.dart';
import 'package:engineering_platform/core/utils/responsive.dart';
import 'package:engineering_platform/core/constants/app_constants.dart';
import 'package:engineering_platform/presentation/web/engineer/widgets/engineer_widgets.dart';
import 'engineer_dashboard_notifier.dart';
import 'engineer_dashboard_state.dart';

import 'package:engineering_platform/core/constants/route_names.dart';

const _green = Color(0xFF059669);

class EngineerDashboardPage extends ConsumerWidget {
  const EngineerDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder<String>(
      valueListenable: engineerLanguageNotifier,
      builder: (context, lang, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: engineerThemeNotifier,
          builder: (context, themeMode, _) {
            final isMobile = Responsive.isMobile(context);
            final isDark = themeMode == ThemeMode.dark;

            return Scaffold(
              backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.background,
              drawer: isMobile ? const EngineerSidebar() : null,
              body: Column(
                children: [
                  EngineerHeader(isMobile: isMobile),
                  Expanded(
                    child: Row(
                      children: [
                        if (!isMobile) const EngineerSidebar(),
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
    final state = ref.watch(engineerDashboardProvider);
    final notifier = ref.read(engineerDashboardProvider.notifier);
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
                  // ── Stats ──
                  _StatsGrid(stats: state.stats, isAr: isAr, isDark: isDark),
                  const SizedBox(height: 40),

                  // ── Projects + Tasks ──
                  LayoutBuilder(builder: (context, constraints) {
                    if (constraints.maxWidth > 800) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: _ActiveProjectsSection(
                            projects: state.activeProjects, isDark: isDark, isAr: isAr)),
                          const SizedBox(width: 24),
                          Expanded(flex: 2, child: _RecentTasksSection(
                            tasks: state.recentTasks, isDark: isDark, isAr: isAr)),
                        ],
                      );
                    }
                    return Column(children: [
                      _ActiveProjectsSection(projects: state.activeProjects, isDark: isDark, isAr: isAr),
                      const SizedBox(height: 24),
                      _RecentTasksSection(tasks: state.recentTasks, isDark: isDark, isAr: isAr),
                    ]);
                  }),
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
                  : [const Color(0xFF047857), const Color(0xFF059669)],
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
                    isAr ? 'أهلاً، ${name ?? 'المهندس'} 👷' : 'Welcome, ${name ?? 'Engineer'} 👷',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isAr ? 'تابع مشاريعك ومهامك من هنا' : 'Track your projects and tasks',
                    style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.75)),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                    children: [
                      _HeroBtn(label: isAr ? 'مشاريعي' : 'My Projects', icon: Icons.folder_outlined,
                        onTap: () => Navigator.pushNamed(context, RouteNames.engineerProjects), primary: true),
                      const SizedBox(width: 12),
                      _HeroBtn(label: isAr ? 'المهام' : 'Tasks', icon: Icons.checklist_outlined,
                        onTap: () => Navigator.pushNamed(context, RouteNames.engineerTasks), primary: false),
                      const SizedBox(width: 12),
                      _HeroBtn(label: isAr ? 'تقرير' : 'Report', icon: Icons.assessment_outlined,
                        onTap: () => Navigator.pushNamed(context, RouteNames.engineerProgress), primary: false),
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
                child: Icon(Icons.engineering_outlined, size: 48, color: Colors.white.withValues(alpha: 0.4)),
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
          Icon(icon, size: 15, color: primary ? _green : Colors.white),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: primary ? _green : Colors.white)),
        ]),
      ),
    );
  }
}

// ── Stats Grid ────────────────────────────────────────────
class _StatsGrid extends StatelessWidget {
  final EngineerDashboardStats stats;
  final bool isAr, isDark;
  const _StatsGrid({required this.stats, required this.isAr, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatItem(label: isAr ? 'إجمالي المشاريع' : 'Total Projects', value: stats.totalProjects,
          icon: Icons.folder_outlined, color: _green, route: '/engineer/projects'),
      _StatItem(label: isAr ? 'مشاريع نشطة' : 'Active Projects', value: stats.activeProjects,
          icon: Icons.play_circle_outline, color: const Color(0xFF2563EB), route: '/engineer/projects'),
      _StatItem(label: isAr ? 'مهام معلقة' : 'Pending Tasks', value: stats.pendingTasks,
          icon: Icons.checklist_outlined, color: const Color(0xFFF59E0B), route: '/engineer/tasks'),
      _StatItem(label: isAr ? 'مشاكل مفتوحة' : 'Open Issues', value: stats.openIssues,
          icon: Icons.warning_amber_outlined, color: const Color(0xFFEF4444), route: '/engineer/issues'),
    ];

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.8,
      children: items.map((item) => _StatCard(item: item, isDark: isDark)).toList(),
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
  final bool isDark;
  const _StatCard({required this.item, required this.isDark});

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
                Text(widget.item.label, style: TextStyle(fontSize: 11, color: widget.isDark ? Colors.white54 : AppColors.textSecondary)),
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

// ── Active Projects ───────────────────────────────────────
class _ActiveProjectsSection extends StatelessWidget {
  final List<EngineerDashboardProject> projects;
  final bool isDark, isAr;
  const _ActiveProjectsSection({required this.projects, required this.isDark, required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: isAr ? 'المشاريع النشطة' : 'Active Projects',
          actionLabel: isAr ? 'عرض الكل' : 'View All',
          onTap: () => Navigator.pushNamed(context, '/engineer/projects'),
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        if (projects.isEmpty)
          _EmptyCard(message: isAr ? 'لا توجد مشاريع نشطة' : 'No active projects', isDark: isDark)
        else
          ...projects.map((p) => _ProjectRow(project: p, isDark: isDark, isAr: isAr)),
      ],
    );
  }
}

class _ProjectRow extends StatefulWidget {
  final EngineerDashboardProject project;
  final bool isDark, isAr;
  const _ProjectRow({required this.project, required this.isDark, required this.isAr});

  @override
  State<_ProjectRow> createState() => _ProjectRowState();
}

class _ProjectRowState extends State<_ProjectRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/engineer/projects'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.isDark
                ? Colors.white.withValues(alpha: _hovered ? 0.07 : 0.04)
                : (_hovered ? const Color(0xFFF0FDF4) : Colors.white),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hovered ? _green.withValues(alpha: 0.3)
                  : (widget.isDark ? Colors.white10 : const Color(0xFFE5E7EB)),
            ),
          ),
          child: Row(
            textDirection: widget.isAr ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Container(width: 3, height: 40,
                decoration: BoxDecoration(color: Color(widget.project.statusTextColor), borderRadius: BorderRadius.circular(4))),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: widget.isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(widget.project.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                      color: widget.isDark ? Colors.white : AppColors.textPrimary)),
                  if (widget.project.clientName != null)
                    Text(widget.project.clientName!, style: TextStyle(fontSize: 12,
                        color: widget.isDark ? Colors.white38 : AppColors.textSecondary)),
                ],
              )),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Color(widget.project.statusBgColor), borderRadius: BorderRadius.circular(20)),
                child: Text(widget.project.statusLabel(widget.isAr),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(widget.project.statusTextColor))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Recent Tasks ──────────────────────────────────────────
class _RecentTasksSection extends StatelessWidget {
  final List<EngineerDashboardTask> tasks;
  final bool isDark, isAr;
  const _RecentTasksSection({required this.tasks, required this.isDark, required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: isAr ? 'المهام المعلقة' : 'Pending Tasks',
          actionLabel: isAr ? 'عرض الكل' : 'View All',
          onTap: () => Navigator.pushNamed(context, '/engineer/tasks'),
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        if (tasks.isEmpty)
          _EmptyCard(message: isAr ? 'لا توجد مهام معلقة' : 'No pending tasks', isDark: isDark)
        else
          ...tasks.map((t) => _TaskRow(task: t, isDark: isDark, isAr: isAr)),
      ],
    );
  }
}

class _TaskRow extends StatefulWidget {
  final EngineerDashboardTask task;
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
        onTap: () => Navigator.pushNamed(context, '/engineer/tasks'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: widget.isDark
                ? Colors.white.withValues(alpha: _hovered ? 0.07 : 0.04)
                : (_hovered ? const Color(0xFFF0FDF4) : Colors.white),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hovered ? priorityColor.withValues(alpha: 0.3)
                  : (widget.isDark ? Colors.white10 : const Color(0xFFE5E7EB)),
            ),
          ),
          child: Row(
            textDirection: widget.isAr ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: priorityColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(Icons.task_outlined, size: 14, color: priorityColor),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: widget.isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(widget.task.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                        color: widget.isDark ? Colors.white : AppColors.textPrimary)),
                  Row(
                    textDirection: widget.isAr ? TextDirection.rtl : TextDirection.ltr,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: priorityColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text(widget.task.priorityLabel(widget.isAr),
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: priorityColor)),
                      ),
                      if (widget.task.isOverdue) ...[
                        const SizedBox(width: 6),
                        const Text('⚠️', style: TextStyle(fontSize: 11)),
                      ],
                    ],
                  ),
                ],
              )),
              if (widget.task.dueDate != null)
                Text('${widget.task.dueDate!.day}/${widget.task.dueDate!.month}',
                  style: TextStyle(fontSize: 11, color: widget.task.isOverdue ? Colors.red
                      : (widget.isDark ? Colors.white38 : AppColors.textSecondary))),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared ────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title, actionLabel;
  final VoidCallback onTap;
  final bool isDark;
  const _SectionHeader({required this.title, required this.actionLabel, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColors.textPrimary, letterSpacing: -0.3)),
        TextButton(onPressed: onTap,
          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
          child: Text(actionLabel, style: const TextStyle(fontSize: 13, color: _green, fontWeight: FontWeight.w600))),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String message;
  final bool isDark;
  const _EmptyCard({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE5E7EB)),
      ),
      child: Column(children: [
        Icon(Icons.inbox_outlined, size: 36, color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.grey.shade300),
        const SizedBox(height: 8),
        Text(message, style: TextStyle(fontSize: 13, color: isDark ? Colors.white38 : AppColors.textSecondary)),
      ]),
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

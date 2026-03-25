import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:engineering_platform/core/constants/colors.dart';
import 'package:engineering_platform/core/state/language_state.dart';
import 'package:engineering_platform/core/state/user_state.dart';
import 'package:engineering_platform/presentation/web/client/widgets/client_layout.dart';
import 'client_dashboard_notifier.dart';
import 'client_dashboard_state.dart';

class ClientDashboardPage extends ConsumerWidget {
  const ClientDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(clientDashboardProvider);
    final notifier = ref.read(clientDashboardProvider.notifier);

    return ClientLayout(
      activeRoute: '/dashboard',
      child: ValueListenableBuilder<String>(
        valueListenable: clientLanguageNotifier,
        builder: (context, lang, _) {
          final isAr = lang == 'ar';
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeroSection(isAr: isAr, isDark: isDark, lang: lang),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.errorMessage != null)
                      _ErrorBanner(message: state.errorMessage!, onRetry: notifier.fetchDashboard),
                    if (state.isLoading)
                      const SizedBox(height: 300, child: Center(child: CircularProgressIndicator()))
                    else ...[
                      _StatsGrid(stats: state.stats, isAr: isAr, isDark: isDark),
                      const SizedBox(height: 48),
                      _TwoColumns(
                        left: _ActiveProjectsSection(projects: state.activeProjects, isAr: isAr, isDark: isDark),
                        right: _RecentReportsSection(reports: state.recentReports, isAr: isAr, isDark: isDark),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Hero ──────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  final bool isAr, isDark;
  final String lang;
  const _HeroSection({required this.isAr, required this.isDark, required this.lang});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: userState.userName,
      builder: (context, name, _) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 48),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: isAr ? Alignment.centerRight : Alignment.centerLeft,
              end: isAr ? Alignment.centerLeft : Alignment.centerRight,
              colors: isDark
                  ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                  : [const Color(0xFF1D4ED8), const Color(0xFF2563EB)],
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
                    isAr ? 'أهلاً، ${name ?? 'عزيزي العميل'} 👋' : 'Welcome, ${name ?? 'Client'} 👋',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isAr ? 'تابع مشاريعك وآخر التقارير من هنا' : 'Track your projects and latest reports',
                    style: TextStyle(fontSize: 15, color: Colors.white.withValues(alpha: 0.75)),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                    children: [
                      _HeroBtn(label: isAr ? 'مشاريعي' : 'My Projects', icon: Icons.folder_outlined,
                        onTap: () => navigatorKey.currentState?.pushNamed('/projects'), primary: true),
                      const SizedBox(width: 12),
                      _HeroBtn(label: isAr ? 'التقارير' : 'Reports', icon: Icons.description_outlined,
                        onTap: () => navigatorKey.currentState?.pushNamed('/daily-reports'), primary: false),
                    ],
                  ),
                ],
              ),
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), shape: BoxShape.circle),
                child: Icon(Icons.apartment_outlined, size: 50, color: Colors.white.withValues(alpha: 0.4)),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: primary ? Colors.white : Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: primary ? null : Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: primary ? const Color(0xFF1D4ED8) : Colors.white),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: primary ? const Color(0xFF1D4ED8) : Colors.white)),
        ]),
      ),
    );
  }
}

// ── Stats Grid ────────────────────────────────────────────
class _StatsGrid extends StatelessWidget {
  final ClientDashboardStats stats;
  final bool isAr, isDark;
  const _StatsGrid({required this.stats, required this.isAr, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatItem(label: isAr ? 'إجمالي المشاريع' : 'Total Projects', value: stats.totalProjects,
          icon: Icons.folder_outlined, color: const Color(0xFF3B82F6), filter: null),
      _StatItem(label: isAr ? 'مشاريع نشطة' : 'Active Projects', value: stats.activeProjects,
          icon: Icons.play_circle_outline, color: const Color(0xFF10B981), filter: 'active'),
      _StatItem(label: isAr ? 'مشاريع مكتملة' : 'Completed', value: stats.completedProjects,
          icon: Icons.check_circle_outline, color: const Color(0xFF7C3AED), filter: 'completed'),
      _StatItem(label: isAr ? 'آخر التقارير' : 'Recent Reports', value: stats.totalReports,
          icon: Icons.description_outlined, color: const Color(0xFFF59E0B), filter: null, route: '/daily-reports'),
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
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final String? filter; // null = كل المشاريع
  final String? route;  // null = /projects
  const _StatItem({required this.label, required this.value, required this.icon, required this.color, this.filter, this.route});
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
        onTap: () {
          final route = widget.item.route ?? '/projects';
          navigatorKey.currentState?.pushNamed(route, arguments: widget.item.filter);
        },
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
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${widget.item.value}',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900,
                        color: widget.isDark ? Colors.white : AppColors.textPrimary, letterSpacing: -1)),
                  Text(widget.item.label,
                    style: TextStyle(fontSize: 12, color: widget.isDark ? Colors.white54 : AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 12,
                color: _hovered ? widget.item.color : (widget.isDark ? Colors.white30 : Colors.grey.shade300)),
          ]),
        ),
      ),
    );
  }
}

// ── Two Columns ───────────────────────────────────────────
class _TwoColumns extends StatelessWidget {
  final Widget left, right;
  const _TwoColumns({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 800) {
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(flex: 3, child: left),
          const SizedBox(width: 24),
          Expanded(flex: 2, child: right),
        ]);
      }
      return Column(children: [left, const SizedBox(height: 32), right]);
    });
  }
}

// ── Active Projects ───────────────────────────────────────
class _ActiveProjectsSection extends StatelessWidget {
  final List<ClientDashboardActiveProject> projects;
  final bool isAr, isDark;
  const _ActiveProjectsSection({required this.projects, required this.isAr, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: isAr ? 'المشاريع النشطة' : 'Active Projects',
          actionLabel: isAr ? 'عرض الكل' : 'View All',
          onTap: () => navigatorKey.currentState?.pushNamed('/projects', arguments: 'active'),
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        if (projects.isEmpty)
          _EmptyCard(message: isAr ? 'لا توجد مشاريع نشطة' : 'No active projects', isDark: isDark)
        else
          ...projects.map((p) => _ProjectCard(project: p, isAr: isAr, isDark: isDark)),
      ],
    );
  }
}

class _ProjectCard extends StatefulWidget {
  final ClientDashboardActiveProject project;
  final bool isAr, isDark;
  const _ProjectCard({required this.project, required this.isAr, required this.isDark});

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => navigatorKey.currentState?.pushNamed('/projects', arguments: 'active'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.isDark
                ? Colors.white.withValues(alpha: _hovered ? 0.07 : 0.04)
                : (_hovered ? const Color(0xFFF8FAFF) : Colors.white),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hovered
                  ? Color(widget.project.statusTextColor).withValues(alpha: 0.4)
                  : (widget.isDark ? Colors.white10 : const Color(0xFFE5E7EB)),
            ),
          ),
          child: Row(
            textDirection: widget.isAr ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Container(width: 3, height: 40,
                decoration: BoxDecoration(color: Color(widget.project.statusTextColor), borderRadius: BorderRadius.circular(4))),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: widget.isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(widget.project.title,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                          color: widget.isDark ? Colors.white : AppColors.textPrimary)),
                    if (widget.project.description != null && widget.project.description!.isNotEmpty)
                      Text(widget.project.description!, maxLines: 1, overflow: TextOverflow.ellipsis,
                        textDirection: widget.isAr ? TextDirection.rtl : TextDirection.ltr,
                        style: TextStyle(fontSize: 12, color: widget.isDark ? Colors.white38 : AppColors.textSecondary)),
                  ],
                ),
              ),
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

// ── Recent Reports ────────────────────────────────────────
class _RecentReportsSection extends StatelessWidget {
  final List<ClientDashboardRecentReport> reports;
  final bool isAr, isDark;
  const _RecentReportsSection({required this.reports, required this.isAr, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: isAr ? 'آخر التقارير' : 'Recent Reports',
          actionLabel: isAr ? 'عرض الكل' : 'View All',
          onTap: () => navigatorKey.currentState?.pushNamed('/daily-reports'),
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        if (reports.isEmpty)
          _EmptyCard(message: isAr ? 'لا توجد تقارير' : 'No reports yet', isDark: isDark)
        else
          ...reports.map((r) => _ReportCard(report: r, isAr: isAr, isDark: isDark)),
      ],
    );
  }
}

class _ReportCard extends StatefulWidget {
  final ClientDashboardRecentReport report;
  final bool isAr, isDark;
  const _ReportCard({required this.report, required this.isAr, required this.isDark});

  @override
  State<_ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends State<_ReportCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = Color(widget.report.statusColor);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => navigatorKey.currentState?.pushNamed('/daily-reports'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: widget.isDark
                ? Colors.white.withValues(alpha: _hovered ? 0.07 : 0.04)
                : (_hovered ? const Color(0xFFF8FAFF) : Colors.white),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hovered ? color.withValues(alpha: 0.4) : (widget.isDark ? Colors.white10 : const Color(0xFFE5E7EB)),
            ),
          ),
          child: Row(
            textDirection: widget.isAr ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Container(width: 36, height: 36,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(Icons.description_outlined, size: 16, color: color)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: widget.isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(widget.report.reportTypeLabel(widget.isAr),
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                          color: widget.isDark ? Colors.white : AppColors.textPrimary)),
                    if (widget.report.projectTitle != null)
                      Text(widget.report.projectTitle!,
                        style: TextStyle(fontSize: 11, color: widget.isDark ? Colors.white38 : AppColors.textSecondary)),
                  ],
                ),
              ),
              Text('${widget.report.createdAt.day}/${widget.report.createdAt.month}',
                style: TextStyle(fontSize: 11, color: widget.isDark ? Colors.white38 : AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared Widgets ────────────────────────────────────────
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
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColors.textPrimary, letterSpacing: -0.3)),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
          child: Text(actionLabel, style: const TextStyle(fontSize: 13, color: Color(0xFF2563EB), fontWeight: FontWeight.w600)),
        ),
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
      padding: const EdgeInsets.symmetric(vertical: 36),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE5E7EB)),
      ),
      child: Column(children: [
        Icon(Icons.inbox_outlined, size: 40, color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.grey.shade300),
        const SizedBox(height: 10),
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

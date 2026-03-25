import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:engineering_platform/core/constants/colors.dart';
import 'package:engineering_platform/core/state/language_state.dart';
import 'package:engineering_platform/core/state/theme_state.dart';
import 'package:engineering_platform/core/utils/responsive.dart';
import 'package:engineering_platform/presentation/web/engineer/widgets/engineer_widgets.dart';
import 'engineer_projects_notifier.dart';
import 'engineer_projects_state.dart';

class AssignedProjectsPage extends ConsumerWidget {
  const AssignedProjectsPage({super.key});

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
              body: Row(
                children: [
                  if (!isMobile) const EngineerSidebar(),
                  Expanded(
                    child: Column(
                      children: [
                        EngineerHeader(isMobile: isMobile),
                        Expanded(
                          child: _ProjectsContent(lang: lang, isDark: isDark, isMobile: isMobile),
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

class _ProjectsContent extends ConsumerWidget {
  final String lang;
  final bool isDark, isMobile;
  const _ProjectsContent({required this.lang, required this.isDark, required this.isMobile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(engineerProjectsProvider);
    final notifier = ref.read(engineerProjectsProvider.notifier);
    final isAr = lang == 'ar';

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── العنوان ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isAr ? 'المشاريع المعينة' : 'Assigned Projects',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.textPrimary, letterSpacing: -1)),
              IconButton(
                onPressed: state.isLoading ? null : notifier.fetchProjects,
                icon: Icon(Icons.refresh, color: isDark ? Colors.white60 : AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── فلاتر ──
          _FilterRow(currentFilter: state.filterStatus, isDark: isDark, isAr: isAr,
            onFilter: notifier.setFilter),
          const SizedBox(height: 24),

          // ── Error ──
          if (state.errorMessage != null)
            _ErrorBanner(message: state.errorMessage!, onRetry: notifier.fetchProjects),

          // ── Loading ──
          if (state.isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(64), child: CircularProgressIndicator()))

          // ── فاضي ──
          else if (state.filteredProjects.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(64),
                child: Column(children: [
                  Icon(Icons.folder_open_outlined, size: 64, color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(isAr ? 'لا توجد مشاريع معينة' : 'No assigned projects',
                    style: TextStyle(fontSize: 18, color: isDark ? Colors.white54 : AppColors.textSecondary)),
                ]),
              ),
            )

          // ── القائمة ──
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.filteredProjects.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) => _ProjectCard(
                project: state.filteredProjects[index],
                isDark: isDark,
                isAr: isAr,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Filter Row ────────────────────────────────────────────
class _FilterRow extends StatelessWidget {
  final String currentFilter;
  final bool isDark, isAr;
  final ValueChanged<String> onFilter;
  const _FilterRow({required this.currentFilter, required this.isDark, required this.isAr, required this.onFilter});

  @override
  Widget build(BuildContext context) {
    final filters = [
      ('all', isAr ? 'الكل' : 'All'),
      ('active', isAr ? 'نشطة' : 'Active'),
      ('completed', isAr ? 'مكتملة' : 'Completed'),
    ];

    return Wrap(
      spacing: 8,
      children: filters.map((f) {
        final isSelected = currentFilter == f.$1;
        return InkWell(
          onTap: () => onFilter(f.$1),
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF2563EB) : (isDark ? Colors.white.withValues(alpha: 0.07) : const Color(0xFFF1F5F9)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(f.$2, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : (isDark ? Colors.white60 : AppColors.textSecondary))),
          ),
        );
      }).toList(),
    );
  }
}

// ── Project Card ──────────────────────────────────────────
class _ProjectCard extends StatefulWidget {
  final EngineerProjectModel project;
  final bool isDark, isAr;
  const _ProjectCard({required this.project, required this.isDark, required this.isAr});

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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: widget.isDark
              ? Colors.white.withValues(alpha: _hovered ? 0.07 : 0.05)
              : (_hovered ? const Color(0xFFF8FAFF) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _hovered
                ? Color(widget.project.statusTextColor).withValues(alpha: 0.4)
                : (widget.isDark ? Colors.white10 : const Color(0xFFE5E7EB)),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: widget.isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // ── العنوان + الحالة ──
            Row(
              textDirection: widget.isAr ? TextDirection.rtl : TextDirection.ltr,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(widget.project.title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                        color: widget.isDark ? Colors.white : AppColors.textPrimary)),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(color: Color(widget.project.statusBgColor), borderRadius: BorderRadius.circular(20)),
                  child: Text(widget.project.statusLabel(widget.isAr),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(widget.project.statusTextColor))),
                ),
              ],
            ),

            // ── الوصف ──
            if (widget.project.description != null && widget.project.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(widget.project.description!, maxLines: 2, overflow: TextOverflow.ellipsis,
                textDirection: widget.isAr ? TextDirection.rtl : TextDirection.ltr,
                style: TextStyle(fontSize: 14, color: widget.isDark ? Colors.white54 : AppColors.textSecondary, height: 1.5)),
            ],

            const SizedBox(height: 16),

            // ── المعلومات ──
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                if (widget.project.clientName != null)
                  _InfoChip(icon: Icons.person_outline, label: widget.project.clientName!, isDark: widget.isDark),
                if (widget.project.startDate != null)
                  _InfoChip(icon: Icons.calendar_today_outlined,
                    label: '${widget.project.startDate!.day}/${widget.project.startDate!.month}/${widget.project.startDate!.year}',
                    isDark: widget.isDark),
                if (widget.project.durationDays != null)
                  _InfoChip(icon: Icons.timer_outlined,
                    label: widget.isAr ? '${widget.project.durationDays} يوم' : '${widget.project.durationDays} days',
                    isDark: widget.isDark),
                if (widget.project.budget != null)
                  _InfoChip(icon: Icons.account_balance_wallet_outlined,
                    label: '${widget.project.budget!.toStringAsFixed(0)} EGP',
                    isDark: widget.isDark),
              ],
            ),

            const SizedBox(height: 16),

            // ── زرار التفاصيل ──
            Align(
              alignment: widget.isAr ? Alignment.centerLeft : Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/engineer/project-details',
                    arguments: widget.project.id),
                icon: const Icon(Icons.visibility_outlined, size: 16),
                label: Text(widget.isAr ? 'عرض التفاصيل' : 'View Details'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Info Chip ─────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  const _InfoChip({required this.icon, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: isDark ? Colors.white38 : AppColors.textSecondary),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 13, color: isDark ? Colors.white54 : AppColors.textSecondary)),
    ]);
  }
}

// ── Error Banner ──────────────────────────────────────────
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

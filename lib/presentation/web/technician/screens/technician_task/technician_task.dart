import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:engineering_platform/core/constants/colors.dart';
import 'package:engineering_platform/core/state/language_state.dart';
import 'package:engineering_platform/core/state/theme_state.dart';
import 'package:engineering_platform/core/utils/responsive.dart';
import 'package:engineering_platform/presentation/web/technician/widgets/technician_widgets.dart';
import 'technician_tasks_notifier.dart';
import 'technician_tasks_state.dart';

class TechnicianTaskPage extends ConsumerWidget {
  const TechnicianTaskPage({super.key});

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
              body: Row(
                children: [
                  if (!isMobile) const TechnicianSidebar(),
                  Expanded(
                    child: Column(
                      children: [
                        TechnicianHeader(isMobile: isMobile),
                        Expanded(child: _TasksContent(lang: lang, isDark: isDark, isMobile: isMobile)),
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

class _TasksContent extends ConsumerWidget {
  final String lang;
  final bool isDark, isMobile;
  const _TasksContent({required this.lang, required this.isDark, required this.isMobile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(technicianTasksProvider);
    final notifier = ref.read(technicianTasksProvider.notifier);
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
              Text(isAr ? 'مهامي' : 'My Tasks',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.textPrimary, letterSpacing: -1)),
              IconButton(
                onPressed: state.isLoading ? null : notifier.fetchTasks,
                icon: Icon(Icons.refresh, color: isDark ? Colors.white60 : AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── إحصائيات ──
          if (!state.isLoading && state.tasks.isNotEmpty)
            _StatsRow(tasks: state.tasks, isDark: isDark, isAr: isAr),
          const SizedBox(height: 16),

          // ── فلاتر ──
          _FilterRow(currentFilter: state.filterStatus, isDark: isDark, isAr: isAr, onFilter: notifier.setFilter),
          const SizedBox(height: 24),

          // ── Error ──
          if (state.errorMessage != null)
            _ErrorBanner(message: state.errorMessage!, onRetry: notifier.fetchTasks),

          // ── Loading ──
          if (state.isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(64), child: CircularProgressIndicator()))

          // ── فاضي ──
          else if (state.filteredTasks.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(64),
                child: Column(children: [
                  Icon(Icons.task_outlined, size: 64,
                    color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(isAr ? 'لا توجد مهام معينة' : 'No assigned tasks',
                    style: TextStyle(fontSize: 18, color: isDark ? Colors.white54 : AppColors.textSecondary)),
                ]),
              ),
            )

          // ── القائمة ──
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.filteredTasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _TaskCard(
                task: state.filteredTasks[index],
                isDark: isDark,
                isAr: isAr,
                onStatusChange: (s) => notifier.updateTaskStatus(state.filteredTasks[index].id, s),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Stats Row ─────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final List<TechnicianTaskModel> tasks;
  final bool isDark, isAr;
  const _StatsRow({required this.tasks, required this.isDark, required this.isAr});

  @override
  Widget build(BuildContext context) {
    final pending    = tasks.where((t) => t.status == 'pending').length;
    final inProgress = tasks.where((t) => t.status == 'in_progress').length;
    final completed  = tasks.where((t) => t.status == 'completed').length;

    return Wrap(spacing: 8, children: [
      _StatChip(label: isAr ? 'قيد الانتظار' : 'Pending',     value: pending,    color: const Color(0xFFF59E0B), isDark: isDark),
      _StatChip(label: isAr ? 'جاري'         : 'In Progress', value: inProgress, color: const Color(0xFF2196F3), isDark: isDark),
      _StatChip(label: isAr ? 'مكتملة'       : 'Completed',   value: completed,  color: const Color(0xFF10B981), isDark: isDark),
    ]);
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final bool isDark;
  const _StatChip({required this.label, required this.value, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text('$value', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, color: color)),
      ]),
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
      ('all',         isAr ? 'الكل'         : 'All'),
      ('pending',     isAr ? 'قيد الانتظار' : 'Pending'),
      ('in_progress', isAr ? 'جاري'         : 'In Progress'),
      ('completed',   isAr ? 'مكتملة'       : 'Completed'),
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
              color: isSelected ? const Color(0xFFF59E0B) : (isDark ? Colors.white.withValues(alpha: 0.07) : const Color(0xFFF1F5F9)),
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

// ── Task Card ─────────────────────────────────────────────
class _TaskCard extends StatefulWidget {
  final TechnicianTaskModel task;
  final bool isDark, isAr;
  final ValueChanged<String> onStatusChange;
  const _TaskCard({required this.task, required this.isDark, required this.isAr, required this.onStatusChange});

  @override
  State<_TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<_TaskCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final priorityColor = Color(widget.task.priorityColor);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: widget.isDark
              ? Colors.white.withValues(alpha: _hovered ? 0.07 : 0.05)
              : (_hovered ? const Color(0xFFFFFBF0) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered ? priorityColor.withValues(alpha: 0.4)
                : (widget.isDark ? Colors.white10 : const Color(0xFFE5E7EB)),
          ),
        ),
        child: Row(
          textDirection: widget.isAr ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Container(width: 3, height: 60,
              decoration: BoxDecoration(color: priorityColor, borderRadius: BorderRadius.circular(4))),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: widget.isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Row(
                    textDirection: widget.isAr ? TextDirection.rtl : TextDirection.ltr,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: priorityColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text(widget.task.priorityLabel(widget.isAr),
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: priorityColor)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: Color(widget.task.statusBgColor), borderRadius: BorderRadius.circular(6)),
                        child: Text(widget.task.statusLabel(widget.isAr),
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(widget.task.statusTextColor))),
                      ),
                      if (widget.task.isOverdue) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                          child: Text(widget.isAr ? 'متأخر' : 'Overdue',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.red)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(widget.task.title,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                        color: widget.isDark ? Colors.white : AppColors.textPrimary)),
                  if (widget.task.projectTitle != null) ...[
                    const SizedBox(height: 2),
                    Text(widget.task.projectTitle!,
                      style: TextStyle(fontSize: 12, color: widget.isDark ? Colors.white38 : AppColors.textSecondary)),
                  ],
                  if (widget.task.dueDate != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      textDirection: widget.isAr ? TextDirection.rtl : TextDirection.ltr,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.schedule, size: 12, color: widget.task.isOverdue ? Colors.red : (widget.isDark ? Colors.white38 : AppColors.textSecondary)),
                        const SizedBox(width: 4),
                        Text('${widget.task.dueDate!.day}/${widget.task.dueDate!.month}/${widget.task.dueDate!.year}',
                          style: TextStyle(fontSize: 11, color: widget.task.isOverdue ? Colors.red : (widget.isDark ? Colors.white38 : AppColors.textSecondary))),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                if (widget.task.status != 'completed') ...[
                  if (widget.task.status == 'pending')
                    _ActionBtn(label: widget.isAr ? 'ابدأ' : 'Start', color: const Color(0xFF2563EB),
                      onTap: () => widget.onStatusChange('in_progress')),
                  if (widget.task.status == 'in_progress') ...[
                    _ActionBtn(label: widget.isAr ? 'تفاصيل' : 'Details', color: const Color(0xFFF59E0B),
                      onTap: () => Navigator.pushNamed(context, '/technician/task-details', arguments: widget.task.id)),
                    const SizedBox(height: 8),
                    _ActionBtn(label: widget.isAr ? 'أنهِ' : 'Complete', color: const Color(0xFF10B981),
                      onTap: () => widget.onStatusChange('completed')),
                  ],
                ] else
                  Icon(Icons.check_circle, color: const Color(0xFF10B981), size: 28),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
        child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
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

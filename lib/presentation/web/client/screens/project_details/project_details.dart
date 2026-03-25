import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:engineering_platform/core/constants/colors.dart';
import 'package:engineering_platform/core/state/language_state.dart';
import 'package:engineering_platform/presentation/web/client/widgets/client_layout.dart';
import 'project_details_notifier.dart';
import 'project_details_state.dart';

class ProjectDetailsPage extends ConsumerWidget {
  final int projectId;
  const ProjectDetailsPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(projectDetailsProvider(projectId));
    final notifier = ref.read(projectDetailsProvider(projectId).notifier);

    return ClientLayout(
      activeRoute: '/projects',
      child: ValueListenableBuilder<String>(
        valueListenable: clientLanguageNotifier,
        builder: (context, lang, _) {
          final isAr = lang == 'ar';
          final isDark = Theme.of(context).brightness == Brightness.dark;

          if (state.isLoading) {
            return const SizedBox(height: 400, child: Center(child: CircularProgressIndicator()));
          }

          if (state.errorMessage != null) {
            return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.error_outline, size: 56, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(state.errorMessage!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: () => notifier.fetchProject(projectId), child: const Text('Retry')),
              ]),
            );
          }

          final project = state.project!;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 40),
            child: Column(
              crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // ── Back + العنوان ──
                Row(
                  textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(isAr ? Icons.arrow_forward : Icons.arrow_back, color: isDark ? Colors.white : AppColors.textPrimary),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        project.title,
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.textPrimary, letterSpacing: -1),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(color: Color(project.statusBgColor), borderRadius: BorderRadius.circular(20)),
                      child: Text(project.statusLabel(isAr), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(project.statusTextColor))),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // ── الرسمة + المعلومات ──
                LayoutBuilder(builder: (context, constraints) {
                  final wide = constraints.maxWidth > 900;
                  if (wide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                      children: [
                        Expanded(flex: 3, child: _DrawingSection(project: project, isDark: isDark, isAr: isAr)),
                        const SizedBox(width: 24),
                        Expanded(flex: 2, child: _InfoSection(project: project, isDark: isDark, isAr: isAr, lang: lang)),
                      ],
                    );
                  }
                  return Column(children: [
                    _DrawingSection(project: project, isDark: isDark, isAr: isAr),
                    const SizedBox(height: 24),
                    _InfoSection(project: project, isDark: isDark, isAr: isAr, lang: lang),
                  ]);
                }),

                // ── الوصف ──
                if (project.description != null && project.description!.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  _Section(
                    title: isAr ? 'وصف المشروع' : 'Project Description',
                    isDark: isDark,
                    child: Text(
                      project.description!,
                      style: TextStyle(fontSize: 15, color: isDark ? Colors.white70 : AppColors.textSecondary, height: 1.6),
                      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── قسم الرسمة ────────────────────────────────────────────
class _DrawingSection extends StatelessWidget {
  final ProjectDetailsModel project;
  final bool isDark, isAr;
  const _DrawingSection({required this.project, required this.isDark, required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
      ),
      child: project.drawingUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    project.drawingUrl!,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Center(child: CircularProgressIndicator(value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                          : null));
                    },
                    errorBuilder: (_, __, ___) => _NoDrawing(isDark: isDark, isAr: isAr),
                  ),
                  // Badge النوع
                  Positioned(
                    top: 12,
                    left: isAr ? null : 12,
                    right: isAr ? 12 : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: project.is3D ? const Color(0xFF7C3AED) : const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        project.is3D ? '3D' : '2D',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : _NoDrawing(isDark: isDark, isAr: isAr),
    );
  }
}

class _NoDrawing extends StatelessWidget {
  final bool isDark, isAr;
  const _NoDrawing({required this.isDark, required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.architecture, size: 64, color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.grey.shade300),
        const SizedBox(height: 12),
        Text(
          isAr ? 'لا توجد رسمة متاحة' : 'No drawing available',
          style: TextStyle(fontSize: 14, color: isDark ? Colors.white38 : AppColors.textSecondary),
        ),
      ]),
    );
  }
}

// ── قسم المعلومات ─────────────────────────────────────────
class _InfoSection extends StatelessWidget {
  final ProjectDetailsModel project;
  final bool isDark, isAr;
  final String lang;
  const _InfoSection({required this.project, required this.isDark, required this.isAr, required this.lang});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        // ── الميزانية والتكلفة ──
        _Section(
          title: isAr ? 'المالية' : 'Financials',
          isDark: isDark,
          child: Column(children: [
            _InfoRow(
              label: isAr ? 'الميزانية' : 'Budget',
              value: project.budget != null ? '${project.budget!.toStringAsFixed(0)} EGP' : '-',
              icon: Icons.account_balance_wallet_outlined,
              color: const Color(0xFF10B981),
              isDark: isDark,
              isAr: isAr,
            ),
            const SizedBox(height: 12),
            _InfoRow(
              label: isAr ? 'التكلفة الفعلية' : 'Actual Cost',
              value: project.actualCost != null ? '${project.actualCost!.toStringAsFixed(0)} EGP' : '-',
              icon: Icons.payments_outlined,
              color: const Color(0xFFF59E0B),
              isDark: isDark,
              isAr: isAr,
            ),
            if (project.costPercentage != null) ...[
              const SizedBox(height: 16),
              _CostBar(percentage: project.costPercentage!, isDark: isDark, isAr: isAr),
            ],
          ]),
        ),

        const SizedBox(height: 16),

        // ── الوقت ──
        _Section(
          title: isAr ? 'الجدول الزمني' : 'Timeline',
          isDark: isDark,
          child: Column(children: [
            _InfoRow(
              label: isAr ? 'تاريخ البدء' : 'Start Date',
              value: project.startDate != null
                  ? '${project.startDate!.day}/${project.startDate!.month}/${project.startDate!.year}'
                  : '-',
              icon: Icons.play_arrow_outlined,
              color: const Color(0xFF3B82F6),
              isDark: isDark,
              isAr: isAr,
            ),
            const SizedBox(height: 12),
            _InfoRow(
              label: isAr ? 'تاريخ الانتهاء' : 'End Date',
              value: project.endDate != null
                  ? '${project.endDate!.day}/${project.endDate!.month}/${project.endDate!.year}'
                  : '-',
              icon: Icons.flag_outlined,
              color: const Color(0xFF7C3AED),
              isDark: isDark,
              isAr: isAr,
            ),
            if (project.durationDays != null) ...[
              const SizedBox(height: 12),
              _InfoRow(
                label: isAr ? 'المدة الإجمالية' : 'Total Duration',
                value: isAr ? '${project.durationDays} يوم' : '${project.durationDays} days',
                icon: Icons.timer_outlined,
                color: const Color(0xFFE91E63),
                isDark: isDark,
                isAr: isAr,
              ),
            ],
          ]),
        ),
      ],
    );
  }
}

// ── Cost Progress Bar ─────────────────────────────────────
class _CostBar extends StatelessWidget {
  final double percentage;
  final bool isDark, isAr;
  const _CostBar({required this.percentage, required this.isDark, required this.isAr});

  @override
  Widget build(BuildContext context) {
    final capped = percentage.clamp(0.0, 100.0);
    final isOver = percentage > 100;
    final color = isOver ? Colors.red : (percentage > 80 ? Colors.orange : const Color(0xFF10B981));

    return Column(
      crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Text(isAr ? 'نسبة الصرف' : 'Cost Usage', style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : AppColors.textSecondary)),
            Text('${percentage.toStringAsFixed(1)}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: capped / 100,
            backgroundColor: isDark ? Colors.white10 : const Color(0xFFE5E7EB),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

// ── Shared Widgets ────────────────────────────────────────
class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  final bool isDark;
  const _Section({required this.title, required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.textPrimary)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  final bool isDark, isAr;
  const _InfoRow({required this.label, required this.value, required this.icon, required this.color, required this.isDark, required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: TextStyle(fontSize: 13, color: isDark ? Colors.white54 : AppColors.textSecondary))),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textPrimary)),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:engineering_platform/core/constants/colors.dart';
import 'package:engineering_platform/core/state/language_state.dart';
import 'package:engineering_platform/core/state/theme_state.dart';
import 'package:engineering_platform/core/utils/responsive.dart';
import 'package:engineering_platform/presentation/web/engineer/widgets/engineer_widgets.dart';
import 'engineer_reports_notifier.dart';
import 'engineer_reports_state.dart';

class DailyProgressReportPage extends ConsumerWidget {
  const DailyProgressReportPage({super.key});

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
                        Expanded(child: _ReportContent(lang: lang, isDark: isDark, isMobile: isMobile)),
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

class _ReportContent extends ConsumerWidget {
  final String lang;
  final bool isDark, isMobile;
  const _ReportContent({required this.lang, required this.isDark, required this.isMobile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dailyProgressReportProvider);
    final notifier = ref.read(dailyProgressReportProvider.notifier);
    final isAr = lang == 'ar';

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── العنوان ──
          Text(isAr ? 'تقرير التقدم اليومي' : 'Daily Progress Report',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppColors.textPrimary, letterSpacing: -1)),
          const SizedBox(height: 32),

          // ── Layout ──
          LayoutBuilder(builder: (context, constraints) {
            final wide = constraints.maxWidth > 900;
            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _ReportForm(state: state, notifier: notifier, isDark: isDark, isAr: isAr, lang: lang)),
                  const SizedBox(width: 32),
                  Expanded(flex: 2, child: _RecentReportsList(reports: state.recentReports, isDark: isDark, isAr: isAr)),
                ],
              );
            }
            return Column(children: [
              _ReportForm(state: state, notifier: notifier, isDark: isDark, isAr: isAr, lang: lang),
              const SizedBox(height: 32),
              _RecentReportsList(reports: state.recentReports, isDark: isDark, isAr: isAr),
            ]);
          }),
        ],
      ),
    );
  }
}

// ── فورم التقرير ──────────────────────────────────────────
class _ReportForm extends ConsumerWidget {
  final DailyProgressReportState state;
  final DailyProgressReportNotifier notifier;
  final bool isDark, isAr;
  final String lang;
  const _ReportForm({required this.state, required this.notifier, required this.isDark, required this.isAr, required this.lang});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(isAr ? 'تفاصيل التقرير' : 'Report Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColors.textPrimary)),
          const SizedBox(height: 24),

          // ── نوع التقرير ──
          _FieldLabel(label: isAr ? 'نوع التقرير' : 'Report Type', isDark: isDark),
          const SizedBox(height: 8),
          _ReportTypeSelector(
            currentType: state.form.reportType,
            isDark: isDark,
            isAr: isAr,
            onChanged: notifier.updateReportType,
          ),
          const SizedBox(height: 20),

          // ── اختيار المشروع ──
          if (state.assignedProjects.isNotEmpty) ...[
            _FieldLabel(label: isAr ? 'المشروع' : 'Project', isDark: isDark),
            const SizedBox(height: 8),
            _ProjectDropdown(
              projects: state.assignedProjects,
              selectedId: state.form.selectedProjectId,
              isDark: isDark,
              isAr: isAr,
              onChanged: notifier.updateSelectedProject,
            ),
            const SizedBox(height: 20),
          ],

          // ── التفاصيل ──
          _FieldLabel(label: isAr ? 'تفاصيل التقرير' : 'Report Details', isDark: isDark),
          const SizedBox(height: 8),
          _TextArea(
            hint: isAr ? 'اكتب تفاصيل ما تم إنجازه اليوم...' : 'Describe what was accomplished today...',
            isDark: isDark,
            onChanged: notifier.updateDescription,
          ),
          const SizedBox(height: 24),

          // ── Error ──
          if (state.form.errorMessage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200)),
              child: Row(children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(state.form.errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 13))),
              ]),
            ),

          // ── Success ──
          if (state.form.isSuccess)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.shade200)),
              child: Row(children: [
                const Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
                const SizedBox(width: 8),
                Text(isAr ? 'تم إرسال التقرير بنجاح' : 'Report submitted successfully',
                  style: const TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.w600)),
              ]),
            ),

          // ── زرار الإرسال ──
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.form.isSubmitting ? null : notifier.submitReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: state.form.isSubmitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(isAr ? 'إرسال التقرير' : 'Submit Report',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Report Type Selector ──────────────────────────────────
class _ReportTypeSelector extends StatelessWidget {
  final String currentType;
  final bool isDark, isAr;
  final ValueChanged<String> onChanged;
  const _ReportTypeSelector({required this.currentType, required this.isDark, required this.isAr, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final types = [
      ('daily',  isAr ? 'يومي'    : 'Daily'),
      ('weekly', isAr ? 'أسبوعي'  : 'Weekly'),
      ('issue',  isAr ? 'مشكلة'   : 'Issue'),
    ];

    return Wrap(
      spacing: 8,
      children: types.map((t) {
        final isSelected = currentType == t.$1;
        return InkWell(
          onTap: () => onChanged(t.$1),
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF2563EB) : (isDark ? Colors.white.withValues(alpha: 0.07) : const Color(0xFFF1F5F9)),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isSelected ? const Color(0xFF2563EB) : Colors.transparent),
            ),
            child: Text(t.$2, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : (isDark ? Colors.white60 : AppColors.textSecondary))),
          ),
        );
      }).toList(),
    );
  }
}

// ── Project Dropdown ──────────────────────────────────────
class _ProjectDropdown extends StatelessWidget {
  final List<Map<String, dynamic>> projects;
  final int? selectedId;
  final bool isDark, isAr;
  final ValueChanged<int> onChanged;
  const _ProjectDropdown({required this.projects, required this.selectedId, required this.isDark, required this.isAr, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.07) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedId,
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          style: TextStyle(fontSize: 14, color: isDark ? Colors.white : AppColors.textPrimary),
          items: projects.map((p) => DropdownMenuItem<int>(
            value: p['id'] as int,
            child: Text(p['title'] as String),
          )).toList(),
          onChanged: (val) { if (val != null) onChanged(val); },
        ),
      ),
    );
  }
}

// ── Text Area ─────────────────────────────────────────────
class _TextArea extends StatelessWidget {
  final String hint;
  final bool isDark;
  final ValueChanged<String> onChanged;
  const _TextArea({required this.hint, required this.isDark, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.07) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        maxLines: 6,
        onChanged: onChanged,
        style: TextStyle(fontSize: 14, color: isDark ? Colors.white : AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.grey.shade400, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}

// ── Recent Reports List ───────────────────────────────────
class _RecentReportsList extends StatelessWidget {
  final List<EngineerReportModel> reports;
  final bool isDark, isAr;
  const _RecentReportsList({required this.reports, required this.isDark, required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(isAr ? 'آخر التقارير' : 'Recent Reports',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.textPrimary)),
        const SizedBox(height: 16),
        if (reports.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE5E7EB)),
            ),
            child: Column(children: [
              Icon(Icons.description_outlined, size: 40, color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.grey.shade300),
              const SizedBox(height: 10),
              Text(isAr ? 'لا توجد تقارير' : 'No reports yet',
                style: TextStyle(fontSize: 13, color: isDark ? Colors.white38 : AppColors.textSecondary)),
            ]),
          )
        else
          ...reports.map((r) => _ReportItem(report: r, isDark: isDark, isAr: isAr)),
      ],
    );
  }
}

class _ReportItem extends StatelessWidget {
  final EngineerReportModel report;
  final bool isDark, isAr;
  const _ReportItem({required this.report, required this.isDark, required this.isAr});

  @override
  Widget build(BuildContext context) {
    final color = Color(report.statusColor);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE5E7EB)),
      ),
      child: Row(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Container(width: 36, height: 36,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(Icons.description_outlined, size: 16, color: color)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(report.reportTypeLabel(isAr),
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.textPrimary)),
                if (report.projectTitle != null)
                  Text(report.projectTitle!,
                    style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : AppColors.textSecondary)),
              ],
            ),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${report.createdAt.day}/${report.createdAt.month}',
              style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : AppColors.textSecondary)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
              child: Text(report.statusLabel(isAr),
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
            ),
          ]),
        ],
      ),
    );
  }
}

// ── Shared ────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const _FieldLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
        color: isDark ? Colors.white70 : AppColors.textPrimary));
  }
}

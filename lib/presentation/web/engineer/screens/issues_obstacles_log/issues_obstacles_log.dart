import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:engineering_platform/core/constants/colors.dart';
import 'package:engineering_platform/core/state/language_state.dart';
import 'package:engineering_platform/core/state/theme_state.dart';
import 'package:engineering_platform/core/utils/responsive.dart';
import 'package:engineering_platform/presentation/web/engineer/widgets/engineer_widgets.dart';
import 'engineer_issues_notifier.dart';
import 'engineer_issues_state.dart';

class IssuesObstaclesLogPage extends ConsumerWidget {
  const IssuesObstaclesLogPage({super.key});

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
                        Expanded(child: _IssuesContent(lang: lang, isDark: isDark, isMobile: isMobile)),
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

class _IssuesContent extends ConsumerWidget {
  final String lang;
  final bool isDark, isMobile;
  const _IssuesContent({required this.lang, required this.isDark, required this.isMobile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(engineerIssuesProvider);
    final notifier = ref.read(engineerIssuesProvider.notifier);
    final isAr = lang == 'ar';

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── العنوان + زرار إضافة ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isAr ? 'سجل المشاكل والعقبات' : 'Issues & Obstacles Log',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.textPrimary, letterSpacing: -0.5)),
              ElevatedButton.icon(
                onPressed: notifier.toggleForm,
                icon: Icon(state.showForm ? Icons.close : Icons.add, size: 18),
                label: Text(state.showForm
                    ? (isAr ? 'إلغاء' : 'Cancel')
                    : (isAr ? 'إضافة مشكلة' : 'Add Issue')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: state.showForm ? Colors.grey : const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Success Banner ──
          if (state.isSuccess)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200)),
              child: Row(children: [
                const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                const SizedBox(width: 10),
                Text(isAr ? 'تم إرسال المشكلة بنجاح' : 'Issue submitted successfully',
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
              ]),
            ),

          // ── فورم الإضافة ──
          if (state.showForm)
            _AddIssueForm(state: state, notifier: notifier, isDark: isDark, isAr: isAr),

          if (state.showForm) const SizedBox(height: 24),

          // ── Loading ──
          if (state.isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(64), child: CircularProgressIndicator()))

          // ── فاضي ──
          else if (state.issues.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(64),
                child: Column(children: [
                  Icon(Icons.check_circle_outline, size: 64,
                    color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(isAr ? 'لا توجد مشاكل مسجلة' : 'No issues reported',
                    style: TextStyle(fontSize: 18, color: isDark ? Colors.white54 : AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Text(isAr ? 'ممتاز! كل شيء يسير بشكل طبيعي' : 'Everything is running smoothly',
                    style: TextStyle(fontSize: 14, color: isDark ? Colors.white38 : AppColors.textSecondary)),
                ]),
              ),
            )

          // ── القائمة ──
          else ...[
            Text(isAr ? 'المشاكل المسجلة (${state.issues.length})' : 'Reported Issues (${state.issues.length})',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white70 : AppColors.textSecondary)),
            const SizedBox(height: 12),
            ...state.issues.map((issue) => _IssueCard(issue: issue, isDark: isDark, isAr: isAr)),
          ],
        ],
      ),
    );
  }
}

// ── فورم الإضافة ──────────────────────────────────────────
class _AddIssueForm extends StatelessWidget {
  final EngineerIssuesState state;
  final EngineerIssuesNotifier notifier;
  final bool isDark, isAr;
  const _AddIssueForm({required this.state, required this.notifier, required this.isDark, required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(isAr ? 'تفاصيل المشكلة' : 'Issue Details',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColors.textPrimary)),
          const SizedBox(height: 16),

          // اختيار المشروع
          if (state.assignedProjects.isNotEmpty) ...[
            Text(isAr ? 'المشروع' : 'Project',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : AppColors.textPrimary)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.07) : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE5E7EB)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: state.selectedProjectId,
                  isExpanded: true,
                  dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  style: TextStyle(fontSize: 14, color: isDark ? Colors.white : AppColors.textPrimary),
                  items: state.assignedProjects.map((p) => DropdownMenuItem<int>(
                    value: p['id'] as int,
                    child: Text(p['title'] as String),
                  )).toList(),
                  onChanged: (val) { if (val != null) notifier.updateSelectedProject(val); },
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // وصف المشكلة
          Text(isAr ? 'وصف المشكلة' : 'Issue Description',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : AppColors.textPrimary)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.07) : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE5E7EB)),
            ),
            child: TextField(
              maxLines: 4,
              onChanged: notifier.updateDescription,
              style: TextStyle(fontSize: 14, color: isDark ? Colors.white : AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: isAr ? 'اكتب وصفاً تفصيلياً للمشكلة...' : 'Describe the issue in detail...',
                hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.grey.shade400, fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
          ),

          if (state.errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200)),
              child: Row(children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(state.errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 12))),
              ]),
            ),
          ],

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.isSubmitting ? null : notifier.submitIssue,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: state.isSubmitting
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(isAr ? 'إرسال المشكلة' : 'Submit Issue',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Issue Card ────────────────────────────────────────────
class _IssueCard extends StatefulWidget {
  final EngineerIssueModel issue;
  final bool isDark, isAr;
  const _IssueCard({required this.issue, required this.isDark, required this.isAr});

  @override
  State<_IssueCard> createState() => _IssueCardState();
}

class _IssueCardState extends State<_IssueCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final statusColor = Color(widget.issue.statusTextColor);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: widget.isDark
              ? Colors.white.withValues(alpha: _hovered ? 0.07 : 0.05)
              : (_hovered ? const Color(0xFFFFF8F8) : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _hovered ? const Color(0xFFEF4444).withValues(alpha: 0.3)
                : (widget.isDark ? Colors.white10 : const Color(0xFFE5E7EB)),
          ),
        ),
        child: Row(
          textDirection: widget.isAr ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Container(width: 3, height: 50,
              decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(4))),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: widget.isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (widget.issue.projectTitle != null)
                    Text(widget.issue.projectTitle!,
                      style: TextStyle(fontSize: 12, color: widget.isDark ? Colors.white38 : AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(widget.issue.description ?? (widget.isAr ? 'بدون وصف' : 'No description'),
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    textDirection: widget.isAr ? TextDirection.rtl : TextDirection.ltr,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                        color: widget.isDark ? Colors.white : AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  Text('${widget.issue.createdAt.day}/${widget.issue.createdAt.month}/${widget.issue.createdAt.year}',
                    style: TextStyle(fontSize: 11, color: widget.isDark ? Colors.white38 : AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Color(widget.issue.statusBgColor),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(widget.issue.statusLabel(widget.isAr),
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor)),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:engineering_platform/core/constants/colors.dart';
import 'package:engineering_platform/core/constants/translations.dart';
import 'package:engineering_platform/core/state/language_state.dart';
import 'package:engineering_platform/presentation/web/client/widgets/client_layout.dart';
import 'client_reports_notifier.dart';
import 'client_reports_state.dart';

class DailyReportsPage extends ConsumerWidget {
  const DailyReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(clientReportsProvider);
    final notifier = ref.read(clientReportsProvider.notifier);

    return ClientLayout(
      activeRoute: '/daily-reports',
      child: ValueListenableBuilder<String>(
        valueListenable: clientLanguageNotifier,
        builder: (context, lang, _) {
          final isAr = lang == 'ar';
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 140, vertical: 64),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── العنوان + Refresh ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppTranslations.get('daily_report_title', lang),
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppTranslations.get('daily_report_subtitle', lang),
                          style: TextStyle(
                            fontSize: 18,
                            color: isDark ? Colors.white60 : AppColors.textSecondary.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: state.isLoading ? null : notifier.fetchReports,
                      icon: Icon(Icons.refresh, color: isDark ? Colors.white60 : AppColors.textSecondary),
                      tooltip: isAr ? 'تحديث' : 'Refresh',
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                // ── Error ──
                if (state.errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 12),
                        Expanded(child: Text(state.errorMessage!, style: const TextStyle(color: Colors.red))),
                        IconButton(onPressed: notifier.fetchReports, icon: const Icon(Icons.refresh, color: Colors.red)),
                      ],
                    ),
                  ),

                // ── Loading ──
                if (state.isLoading)
                  const SizedBox(height: 400, child: Center(child: CircularProgressIndicator()))

                // ── فاضي ──
                else if (state.reports.isEmpty)
                  SizedBox(
                    height: 300,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.description_outlined, size: 72, color: isDark ? Colors.white30 : Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            isAr ? 'لا توجد تقارير حتى الآن' : 'No reports yet',
                            style: TextStyle(fontSize: 20, color: isDark ? Colors.white60 : AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  )

                // ── التقارير ──
                else ...[
                  _buildTimeline(state.currentPageReports, isDark, isAr),
                  const SizedBox(height: 64),
                  _buildPagination(state, notifier, isDark),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeline(List<ClientReportModel> reports, bool isDark, bool isAr) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reports.length,
      itemBuilder: (context, index) => _TimelineItem(
        report: reports[index],
        isLast: index == reports.length - 1,
        isDark: isDark,
        isAr: isAr,
      ),
    );
  }

  Widget _buildPagination(ClientReportsState state, ClientReportsNotifier notifier, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _PageButton(
          icon: Icons.chevron_left,
          isDark: isDark,
          onPressed: state.currentPage > 1 ? () => notifier.goToPage(state.currentPage - 1) : () {},
        ),
        const SizedBox(width: 8),
        for (int i = 1; i <= state.totalPages; i++) ...[
          if (i == 1 || i == state.totalPages || (i >= state.currentPage - 1 && i <= state.currentPage + 1))
            _PageButton(
              label: i.toString(),
              isActive: state.currentPage == i,
              isDark: isDark,
              onPressed: () => notifier.goToPage(i),
            )
          else if (i == state.currentPage - 2 || i == state.currentPage + 2)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text('...', style: TextStyle(color: isDark ? Colors.white60 : AppColors.textSecondary)),
            ),
        ],
        const SizedBox(width: 8),
        _PageButton(
          icon: Icons.chevron_right,
          isDark: isDark,
          onPressed: state.currentPage < state.totalPages ? () => notifier.goToPage(state.currentPage + 1) : () {},
        ),
      ],
    );
  }
}

// ── Timeline Item ─────────────────────────────
class _TimelineItem extends StatelessWidget {
  final ClientReportModel report;
  final bool isLast;
  final bool isDark;
  final bool isAr;

  const _TimelineItem({required this.report, required this.isDark, required this.isAr, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── الخط والنقطة ──
          Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(report.statusColor).withValues(alpha: 0.15),
                  border: Border.all(color: Color(report.statusColor), width: 2),
                ),
                child: Icon(Icons.description_outlined, size: 20, color: Color(report.statusColor)),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: isDark ? Colors.white10 : AppColors.greyLight),
                ),
            ],
          ),
          const SizedBox(width: 24),

          // ── المحتوى ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.white10 : AppColors.greyBorder),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    // النوع + الحالة
                    Row(
                      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          report.reportTypeLabel(isAr),
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Color(report.statusColor).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(report.statusLabel(isAr), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(report.statusColor))),
                        ),
                      ],
                    ),

                    // الوصف
                    if (report.description != null && report.description!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        report.description!,
                        style: TextStyle(fontSize: 14, color: isDark ? Colors.white60 : AppColors.textSecondary, height: 1.5),
                        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                      ),
                    ],

                    const SizedBox(height: 12),

                    // التاريخ + المقدم
                    Row(
                      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 13, color: isDark ? Colors.white38 : AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '${report.createdAt.day}/${report.createdAt.month}/${report.createdAt.year}',
                          style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : AppColors.textSecondary),
                        ),
                        if (report.submittedByName != null) ...[
                          const SizedBox(width: 16),
                          Icon(Icons.person_outline, size: 13, color: isDark ? Colors.white38 : AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            report.submittedByName!,
                            style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : AppColors.textSecondary),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Page Button ───────────────────────────────
class _PageButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final bool isActive;
  final bool isDark;
  final VoidCallback onPressed;

  const _PageButton({this.label, this.icon, this.isActive = false, required this.isDark, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isActive ? (isDark ? Colors.white12 : AppColors.greyLight) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: icon != null
            ? Icon(icon, size: 20, color: isDark ? Colors.white : AppColors.textPrimary)
            : Text(label!, style: TextStyle(fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isDark ? Colors.white : AppColors.textPrimary)),
      ),
    );
  }
}

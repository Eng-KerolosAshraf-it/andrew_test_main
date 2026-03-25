import 'package:flutter/material.dart';
import 'package:engineering_platform/core/constants/colors.dart';
import 'package:engineering_platform/core/constants/translations.dart';
import 'package:engineering_platform/core/state/language_state.dart';
import 'package:engineering_platform/shared/widgets/main_layout.dart';
import 'package:engineering_platform/core/data/report_data.dart';

class DailyReport {
  final String day;
  final String title;
  final String date;
  final String image;

  DailyReport({
    required this.day,
    required this.title,
    required this.date,
    required this.image,
  });
}

class DailyReportsPage extends StatefulWidget {
  const DailyReportsPage({super.key});

  @override
  State<DailyReportsPage> createState() => _DailyReportsPageState();
}

class _DailyReportsPageState extends State<DailyReportsPage> {
  int currentPage = 1;
  final int itemsPerPage = 5;
  late Future<List<DailyReport>> _reportsFuture;

  @override
  void initState() {
    super.initState();
    _reportsFuture = _fetchReports();
  }

  Future<List<DailyReport>> _fetchReports() async {
    // Simulate server delay
    await Future.delayed(const Duration(milliseconds: 800));
    final lang = languageNotifier.value;
    final rawData = ReportData.getAllReports(lang);
    return rawData
        .map(
          (e) => DailyReport(
            day: e['day']!,
            title: e['title']!,
            date: e['date']!,
            image: e['image']!,
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      navItems: const ['home', 'projects', 'account_settings'],
      child: ValueListenableBuilder<String>(
        valueListenable: languageNotifier,
        builder: (context, lang, _) {
          return FutureBuilder<List<DailyReport>>(
            future: _reportsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 400,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final allReports = snapshot.data ?? [];
              final int totalPages = (allReports.length / itemsPerPage).ceil();

              // Calculate start and end indices for current page
              final int startIndex = (currentPage - 1) * itemsPerPage;
              final int endIndex = startIndex + itemsPerPage;
              final reportsOnPage = allReports.sublist(
                startIndex,
                endIndex > allReports.length ? allReports.length : endIndex,
              );

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 140,
                  vertical: 64,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppTranslations.get('daily_report_title', lang),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppTranslations.get('daily_report_subtitle', lang),
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 48),
                    _buildTimeline(reportsOnPage),
                    const SizedBox(height: 64),
                    _buildDynamicPagination(totalPages),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTimeline(List<DailyReport> reports) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        return _TimelineItem(
          report: reports[index],
          isLast: index == reports.length - 1,
        );
      },
    );
  }

  Widget _buildDynamicPagination(int totalPages) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _PageButton(
          icon: Icons.chevron_left,
          onPressed: currentPage > 1
              ? () => setState(() => currentPage--)
              : () {},
        ),
        const SizedBox(width: 8),
        for (int i = 1; i <= totalPages; i++) ...[
          if (i == 1 ||
              i == totalPages ||
              (i >= currentPage - 1 && i <= currentPage + 1))
            _PageButton(
              label: i.toString(),
              isActive: currentPage == i,
              onPressed: () => setState(() => currentPage = i),
            )
          else if (i == currentPage - 2 || i == currentPage + 2)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '...',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
        ],
        const SizedBox(width: 8),
        _PageButton(
          icon: Icons.chevron_right,
          onPressed: currentPage < totalPages
              ? () => setState(() => currentPage++)
              : () {},
        ),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final DailyReport report;
  final bool isLast;

  const _TimelineItem({required this.report, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.greyLight,
                  image: DecorationImage(
                    image: AssetImage(report.image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: AppColors.greyLight),
                ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${report.day}: ${report.title}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    report.date,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final bool isActive;
  final VoidCallback onPressed;

  const _PageButton({
    this.label,
    this.icon,
    this.isActive = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isActive ? AppColors.greyLight : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: icon != null
            ? Icon(icon, size: 20, color: AppColors.textPrimary)
            : Text(
                label!,
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: AppColors.textPrimary,
                ),
              ),
      ),
    );
  }
}

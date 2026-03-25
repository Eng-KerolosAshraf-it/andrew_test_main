import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:engineering_platform/core/constants/colors.dart';
import 'package:engineering_platform/core/constants/translations.dart';
import 'package:engineering_platform/core/state/language_state.dart';
import 'package:engineering_platform/presentation/web/client/widgets/client_layout.dart';
import 'client_projects_notifier.dart';
import 'client_projects_state.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // نجيب الـ filter من الـ route arguments
    final statusFilter = ModalRoute.of(context)?.settings.arguments as String?;
    final state = ref.watch(clientProjectsProvider);
    final notifier = ref.read(clientProjectsProvider.notifier);

    return ClientLayout(
      activeRoute: '/projects',
      child: ValueListenableBuilder<String>(
        valueListenable: clientLanguageNotifier,
        builder: (context, lang, _) {
          final isAr = lang == 'ar';
          final isDark = Theme.of(context).brightness == Brightness.dark;

          // نفلتر المشاريع حسب الـ status
          final filteredProjects = statusFilter == null
              ? state.projects
              : statusFilter == 'active'
                  ? state.projects.where((p) =>
                      p.status == 'active' ||
                      p.status == 'under_review' ||
                      p.status == 'waiting_client_approval').toList()
                  : state.projects.where((p) => p.status == statusFilter).toList();

          // عنوان الصفحة حسب الـ filter
          String pageTitle;
          if (statusFilter == 'active') {
            pageTitle = isAr ? 'المشاريع النشطة' : 'Active Projects';
          } else if (statusFilter == 'completed') {
            pageTitle = isAr ? 'المشاريع المكتملة' : 'Completed Projects';
          } else {
            pageTitle = isAr ? 'كل المشاريع' : 'All Projects';
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── العنوان + فلاتر ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(pageTitle,
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : AppColors.textPrimary, letterSpacing: -1)),
                    IconButton(
                      onPressed: state.isLoading ? null : notifier.fetchProjects,
                      icon: Icon(Icons.refresh, color: isDark ? Colors.white60 : AppColors.textSecondary),
                      tooltip: isAr ? 'تحديث' : 'Refresh',
                    ),
                  ],
                ),

                // ── فلاتر سريعة ──
                const SizedBox(height: 16),
                _FilterChips(currentFilter: statusFilter, isAr: isAr, isDark: isDark),
                const SizedBox(height: 32),

                // ── Error ──
                if (state.errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200)),
                    child: Row(children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(child: Text(state.errorMessage!, style: const TextStyle(color: Colors.red))),
                      IconButton(onPressed: notifier.fetchProjects, icon: const Icon(Icons.refresh, color: Colors.red)),
                    ]),
                  ),

                // ── Loading ──
                if (state.isLoading)
                  const Center(child: Padding(padding: EdgeInsets.all(64), child: CircularProgressIndicator()))

                // ── فاضي ──
                else if (filteredProjects.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(64),
                      child: Column(children: [
                        Icon(Icons.folder_open_outlined, size: 72, color: isDark ? Colors.white30 : Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(isAr ? 'لا توجد مشاريع' : 'No projects found',
                          style: TextStyle(fontSize: 20, color: isDark ? Colors.white60 : AppColors.textSecondary)),
                      ]),
                    ),
                  )

                // ── القائمة ──
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredProjects.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) => _ProjectCard(
                      project: filteredProjects[index],
                      lang: lang,
                      isDark: isDark,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── فلاتر سريعة ──────────────────────────────────────────
class _FilterChips extends StatelessWidget {
  final String? currentFilter;
  final bool isAr, isDark;
  const _FilterChips({required this.currentFilter, required this.isAr, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final filters = [
      (null, isAr ? 'الكل' : 'All', Icons.folder_outlined),
      ('active', isAr ? 'نشطة' : 'Active', Icons.play_circle_outline),
      ('completed', isAr ? 'مكتملة' : 'Completed', Icons.check_circle_outline),
    ];

    return Wrap(
      spacing: 8,
      children: filters.map((f) {
        final isSelected = currentFilter == f.$1;
        return InkWell(
          onTap: () => navigatorKey.currentState?.pushReplacementNamed('/projects', arguments: f.$1),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF2563EB) : (isDark ? Colors.white.withValues(alpha: 0.07) : const Color(0xFFF1F5F9)),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isSelected ? const Color(0xFF2563EB) : Colors.transparent),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(f.$3, size: 14, color: isSelected ? Colors.white : (isDark ? Colors.white60 : AppColors.textSecondary)),
              const SizedBox(width: 6),
              Text(f.$2, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : (isDark ? Colors.white60 : AppColors.textSecondary))),
            ]),
          ),
        );
      }).toList(),
    );
  }
}

// ── كارت المشروع ──────────────────────────────────────────
class _ProjectCard extends StatelessWidget {
  final ClientProjectModel project;
  final String lang;
  final bool isDark;
  const _ProjectCard({required this.project, required this.lang, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isAr = lang == 'ar';
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 6))],
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(project.title,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary)),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(color: Color(project.statusBgColor), borderRadius: BorderRadius.circular(20)),
                child: Text(project.statusLabel(isAr),
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(project.statusTextColor))),
              ),
            ],
          ),
          if (project.description != null && project.description!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(project.description!, maxLines: 2, overflow: TextOverflow.ellipsis,
              textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
              style: TextStyle(fontSize: 14, color: isDark ? Colors.white60 : AppColors.textSecondary, height: 1.5)),
          ],
          const SizedBox(height: 16),
          Row(
            textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Icon(Icons.calendar_today_outlined, size: 13, color: isDark ? Colors.white38 : AppColors.textSecondary),
                const SizedBox(width: 6),
                Text('${project.createdAt.day}/${project.createdAt.month}/${project.createdAt.year}',
                  style: TextStyle(fontSize: 13, color: isDark ? Colors.white38 : AppColors.textSecondary)),
              ]),
              ElevatedButton(
                onPressed: () => navigatorKey.currentState?.pushNamed('/project-details', arguments: project.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(isAr ? 'عرض التفاصيل' : 'View Details', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

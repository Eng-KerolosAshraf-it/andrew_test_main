import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:engineering_platform/core/constants/colors.dart';
import 'package:engineering_platform/core/state/language_state.dart';
import 'package:engineering_platform/core/state/theme_state.dart';
import 'package:engineering_platform/core/utils/responsive.dart';
import 'package:engineering_platform/presentation/web/admin/widgets/admin_header.dart';
import 'package:engineering_platform/presentation/web/admin/widgets/admin_sidebar.dart';
import 'admin_projects_notifier.dart';
import 'admin_projects_state.dart';

// ─────────────────────────────────────────────
// Scaffold الرئيسي
// ─────────────────────────────────────────────
class AdminProjectsPage extends ConsumerWidget {
  const AdminProjectsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder<String>(
      valueListenable: adminLanguageNotifier,
      builder: (context, lang, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: adminThemeNotifier,
          builder: (context, themeMode, _) {
            final bool isMobile = Responsive.isMobile(context);
            final isDark = themeMode == ThemeMode.dark;

            return ValueListenableBuilder<bool>(
              valueListenable: sidebarCollapsed,
              builder: (context, isCollapsed, _) {
                return Scaffold(
                  backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.background,
                  drawer: isMobile ? const AdminSidebar() : null,
                  body: Column(
                    children: [
                      AdminHeader(isMobile: isMobile),
                      Expanded(
                        child: Row(
                          children: [
                            if (!isMobile) const AdminSidebar(),
                            const Expanded(child: ProjectsContent()),
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
      },
    );
  }
}

// ─────────────────────────────────────────────
// المحتوى الرئيسي
// ─────────────────────────────────────────────
class ProjectsContent extends ConsumerWidget {
  const ProjectsContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminProjectsProvider);
    final notifier = ref.read(adminProjectsProvider.notifier);

    return ValueListenableBuilder<String>(
      valueListenable: adminLanguageNotifier,
      builder: (context, lang, _) {
        final isAr = lang == 'ar';
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: adminThemeNotifier,
          builder: (context, themeMode, _) {
            final isDark = themeMode == ThemeMode.dark;
            final bool isMobile = Responsive.isMobile(context);

            return Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── العنوان + زر إضافة ───────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isAr ? 'المشاريع' : 'Projects',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(isAr ? 'مشروع جديد' : 'New Project'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? Colors.blue : Colors.grey.shade100,
                          foregroundColor: isDark ? Colors.white : AppColors.textPrimary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: isDark ? Colors.transparent : Colors.grey.shade300)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Search ────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : AppColors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isDark ? Colors.white10 : AppColors.greyBorder),
                    ),
                    child: TextField(
                      onChanged: notifier.updateSearch,
                      style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        hintText: isAr ? 'بحث في المشاريع...' : 'Search projects...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Error ─────────────────────────────────
                  if (state.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade200)),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 12),
                          Expanded(child: Text(state.errorMessage!, style: const TextStyle(color: Colors.red))),
                          IconButton(onPressed: notifier.fetchProjects, icon: const Icon(Icons.refresh, color: Colors.red)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── المحتوى الرئيسي ───────────────────────
                  Expanded(
                    child: state.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : state.filteredProjects.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.folder_open_outlined, size: 64, color: isDark ? Colors.white30 : Colors.grey.shade300),
                                    const SizedBox(height: 16),
                                    Text(isAr ? 'لا توجد مشاريع' : 'No projects found', style: TextStyle(fontSize: 18, color: isDark ? Colors.white60 : AppColors.textSecondary)),
                                  ],
                                ),
                              )
                            : isMobile
                                ? ListView.separated(
                                    itemCount: state.filteredProjects.length,
                                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                                    itemBuilder: (context, index) => _ProjectCardMobile(
                                      project: state.filteredProjects[index],
                                      isDark: isDark,
                                      isAr: isAr,
                                      onStatusChange: (newStatus) => notifier.updateProjectStatus(state.filteredProjects[index].id, newStatus),
                                      onDelete: () => _confirmDelete(context: context, isAr: isAr, isDark: isDark, onConfirm: () => notifier.deleteProject(state.filteredProjects[index].id)),
                                    ),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF1E293B) : AppColors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: isDark ? Colors.white10 : AppColors.greyBorder),
                                    ),
                                    child: Column(
                                      children: [
                                        _TableHeader(isAr: isAr, isDark: isDark),
                                        Divider(height: 1, color: isDark ? Colors.white10 : AppColors.greyLight),
                                        Expanded(
                                          child: ListView.separated(
                                            itemCount: state.filteredProjects.length,
                                            separatorBuilder: (_, __) => Divider(height: 1, color: isDark ? Colors.white10 : AppColors.greyLight),
                                            itemBuilder: (context, index) => _ProjectRow(
                                              project: state.filteredProjects[index],
                                              isDark: isDark,
                                              isAr: isAr,
                                              onStatusChange: (newStatus) => notifier.updateProjectStatus(state.filteredProjects[index].id, newStatus),
                                              onDelete: () => _confirmDelete(context: context, isAr: isAr, isDark: isDark, onConfirm: () => notifier.deleteProject(state.filteredProjects[index].id)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
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

  void _confirmDelete({
    required BuildContext context,
    required bool isAr,
    required bool isDark,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        title: Text(isAr ? 'حذف المشروع' : 'Delete Project',
            style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary)),
        content: Text(
          isAr ? 'هل تريد حذف هذا المشروع؟' : 'Are you sure you want to delete this project?',
          style: TextStyle(color: isDark ? Colors.white70 : AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isAr ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () { Navigator.pop(ctx); onConfirm(); },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: Text(isAr ? 'حذف' : 'Delete'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Header الجدول
// ─────────────────────────────────────────────
class _TableHeader extends StatelessWidget {
  final bool isAr;
  final bool isDark;
  const _TableHeader({required this.isAr, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(child: Text(isAr ? 'اسم المشروع' : 'Project Name',
              style: _headerStyle(isDark))),
          Expanded(child: Text(isAr ? 'العميل' : 'Client',
              style: _headerStyle(isDark))),
          Expanded(child: Text(isAr ? 'المهندس' : 'Engineer',
              style: _headerStyle(isDark))),
          Expanded(child: Text(isAr ? 'الحالة' : 'Status',
              style: _headerStyle(isDark))),
          SizedBox(width: 100,
              child: Text(isAr ? 'العمليات' : 'Actions',
                  style: _headerStyle(isDark))),
        ],
      ),
    );
  }

  TextStyle _headerStyle(bool isDark) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: isDark ? Colors.white60 : AppColors.textSecondary,
  );
}

// ─────────────────────────────────────────────
// Row الجدول
// ─────────────────────────────────────────────
class _ProjectRow extends StatelessWidget {
  final AdminProjectModel project;
  final bool isDark;
  final bool isAr;
  final ValueChanged<String> onStatusChange;
  final VoidCallback onDelete;

  const _ProjectRow({
    required this.project,
    required this.isDark,
    required this.isAr,
    required this.onStatusChange,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // اسم المشروع
          Expanded(
            child: Text(
              project.title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
          // العميل
          Expanded(
            child: Text(
              project.clientName ?? '—',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
          ),
          // المهندس
          Expanded(
            child: Text(
              project.engineerName ?? (isAr ? 'غير معين' : 'Unassigned'),
              style: TextStyle(
                fontSize: 14,
                color: project.engineerName != null
                    ? (isDark ? Colors.white70 : AppColors.textSecondary)
                    : Colors.orange,
              ),
            ),
          ),
          // الحالة
          Expanded(
            child: _StatusBadge(project: project, isDark: isDark),
          ),
          // Actions
          SizedBox(
            width: 100,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _showStatusMenu(context),
                  icon: Icon(Icons.edit_outlined, size: 18,
                      color: isDark ? Colors.white60 : AppColors.textSecondary),
                  tooltip: isAr ? 'تغيير الحالة' : 'Change Status',
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                  tooltip: isAr ? 'حذف' : 'Delete',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusMenu(BuildContext context) {
    final statuses = [
      'pending', 'under_review', 'active',
      'waiting_client_approval', 'completed', 'cancelled'
    ];
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 100, 0, 0),
      items: statuses.map((s) {
        final temp = AdminProjectModel(
          id: 0, title: '', status: s, createdAt: DateTime.now());
        return PopupMenuItem(
          value: s,
          child: Text(temp.statusAr),
        );
      }).toList(),
    ).then((value) {
      if (value != null) onStatusChange(value);
    });
  }
}

// ─────────────────────────────────────────────
// كارت Mobile
// ─────────────────────────────────────────────
class _ProjectCardMobile extends StatelessWidget {
  final AdminProjectModel project;
  final bool isDark;
  final bool isAr;
  final ValueChanged<String> onStatusChange;
  final VoidCallback onDelete;

  const _ProjectCardMobile({
    required this.project,
    required this.isDark,
    required this.isAr,
    required this.onStatusChange,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white10 : AppColors.greyBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  project.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
              _StatusBadge(project: project, isDark: isDark),
            ],
          ),
          const SizedBox(height: 12),
          if (project.clientName != null)
            _InfoRow(
              icon: Icons.person_outline,
              label: isAr ? 'العميل' : 'Client',
              value: project.clientName!,
              isDark: isDark,
            ),
          _InfoRow(
            icon: Icons.engineering_outlined,
            label: isAr ? 'المهندس' : 'Engineer',
            value: project.engineerName ?? (isAr ? 'غير معين' : 'Unassigned'),
            isDark: isDark,
            valueColor: project.engineerName == null ? Colors.orange : null,
          ),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: isAr ? 'التاريخ' : 'Date',
            value: '${project.createdAt.day}/${project.createdAt.month}/${project.createdAt.year}',
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: Text(isAr ? 'حذف' : 'Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Widgets مساعدة
// ─────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final AdminProjectModel project;
  final bool isDark;

  const _StatusBadge({required this.project, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? project.statusColor.withValues(alpha: 0.15)
            : project.statusColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        project.statusAr,
        style: TextStyle(
          color: isDark ? project.statusTextColor : project.statusTextColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isDark = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16,
              color: isDark ? Colors.white38 : AppColors.textSecondary),
          const SizedBox(width: 8),
          Text('$label: ',
              style: TextStyle(fontSize: 13,
                  color: isDark ? Colors.white54 : AppColors.textSecondary)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? (isDark ? Colors.white : AppColors.textPrimary),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

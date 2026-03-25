import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:engineering_platform/core/constants/colors.dart';
import 'package:engineering_platform/core/state/language_state.dart';
import 'package:engineering_platform/core/state/theme_state.dart';
import 'package:engineering_platform/core/utils/responsive.dart';
import 'package:engineering_platform/presentation/web/technician/widgets/technician_widgets.dart';
import 'package:engineering_platform/presentation/web/technician/screens/technician_task/technician_tasks_notifier.dart';
import 'package:engineering_platform/presentation/web/technician/screens/technician_task/technician_tasks_state.dart';

class TaskDetailsPage extends ConsumerWidget {
  const TaskDetailsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskId = ModalRoute.of(context)!.settings.arguments as int;

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
                        Expanded(child: _TaskDetailsContent(taskId: taskId, lang: lang, isDark: isDark, isMobile: isMobile)),
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

class _TaskDetailsContent extends ConsumerWidget {
  final int taskId;
  final String lang;
  final bool isDark, isMobile;
  const _TaskDetailsContent({required this.taskId, required this.lang, required this.isDark, required this.isMobile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(technicianTasksProvider);
    final notifier = ref.read(technicianTasksProvider.notifier);
    final isAr = lang == 'ar';

    final task = state.tasks.where((t) => t.id == taskId).firstOrNull;

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (task == null) {
      return Center(
        child: Text(isAr ? 'المهمة غير موجودة' : 'Task not found',
          style: TextStyle(color: isDark ? Colors.white54 : AppColors.textSecondary)),
      );
    }

    final priorityColor = Color(task.priorityColor);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(
        crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // ── Back + العنوان ──
          Row(
            textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(isAr ? Icons.arrow_forward : Icons.arrow_back,
                  color: isDark ? Colors.white : AppColors.textPrimary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(isAr ? 'تفاصيل المهمة' : 'Task Details',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : AppColors.textPrimary, letterSpacing: -0.5)),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── معلومات المهمة ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Row(
                  textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: priorityColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(task.priorityLabel(isAr),
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: priorityColor)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: Color(task.statusBgColor), borderRadius: BorderRadius.circular(8)),
                      child: Text(task.statusLabel(isAr),
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(task.statusTextColor))),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(task.title,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.textPrimary)),
                if (task.projectTitle != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.folder_outlined, size: 14, color: isDark ? Colors.white38 : AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(task.projectTitle!, style: TextStyle(fontSize: 13, color: isDark ? Colors.white38 : AppColors.textSecondary)),
                    ],
                  ),
                ],
                if (task.description != null && task.description!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(isAr ? 'الوصف' : 'Description',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white70 : AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Text(task.description!,
                    textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                    style: TextStyle(fontSize: 14, color: isDark ? Colors.white54 : AppColors.textSecondary, height: 1.6)),
                ],
                if (task.dueDate != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule, size: 16, color: task.isOverdue ? Colors.red : (isDark ? Colors.white38 : AppColors.textSecondary)),
                      const SizedBox(width: 6),
                      Text(
                        '${isAr ? 'الموعد النهائي: ' : 'Due: '}${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                        style: TextStyle(fontSize: 13, color: task.isOverdue ? Colors.red : (isDark ? Colors.white38 : AppColors.textSecondary)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── أزرار الحالة ──
          if (task.status != 'completed')
            Row(
              textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
              children: [
                if (task.status == 'pending')
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () { notifier.updateTaskStatus(task.id, 'in_progress'); Navigator.pop(context); },
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: Text(isAr ? 'ابدأ التنفيذ' : 'Start'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white,
                        elevation: 0, padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                if (task.status == 'in_progress') ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/technician/execution', arguments: task.id),
                      icon: const Icon(Icons.upload_outlined, size: 18),
                      label: Text(isAr ? 'رفع إثبات التنفيذ' : 'Upload Proof'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.white,
                        elevation: 0, padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () { notifier.updateTaskStatus(task.id, 'completed'); Navigator.pop(context); },
                      icon: const Icon(Icons.check, size: 18),
                      label: Text(isAr ? 'إنهاء المهمة' : 'Complete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white,
                        elevation: 0, padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ],
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF10B981)),
                  const SizedBox(width: 8),
                  Text(isAr ? 'تم إنجاز هذه المهمة' : 'Task completed',
                    style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w700)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

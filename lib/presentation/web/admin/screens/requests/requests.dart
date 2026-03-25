import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:engineering_platform/core/constants/colors.dart';
import 'package:engineering_platform/core/state/language_state.dart';
import 'package:engineering_platform/core/state/theme_state.dart';
import 'package:engineering_platform/core/utils/responsive.dart';
import 'package:engineering_platform/presentation/web/admin/widgets/admin_header.dart';
import 'package:engineering_platform/presentation/web/admin/widgets/admin_sidebar.dart';
import 'admin_requests_notifier.dart';
import 'admin_requests_state.dart';

// ─────────────────────────────────────────────
// Scaffold الرئيسي
// ─────────────────────────────────────────────
class AdminRequestsPage extends ConsumerWidget {
  const AdminRequestsPage({super.key});

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
                            Expanded(
                              child: SingleChildScrollView(
                                padding: EdgeInsets.all(isMobile ? 16 : 32),
                                child: const RequestsContent(),
                              ),
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
      },
    );
  }
}

// ─────────────────────────────────────────────
// المحتوى الرئيسي
// ─────────────────────────────────────────────
class RequestsContent extends ConsumerWidget {
  const RequestsContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminRequestsProvider);
    final notifier = ref.read(adminRequestsProvider.notifier);

    return ValueListenableBuilder<String>(
      valueListenable: adminLanguageNotifier,
      builder: (context, lang, _) {
        final isAr = lang == 'ar';
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: adminThemeNotifier,
          builder: (context, themeMode, _) {
            final isDark = themeMode == ThemeMode.dark;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── العنوان ──────────────────────────────
                Text(
                  isAr ? 'طلبات العملاء الواردة' : 'Incoming Client Requests',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isAr
                      ? 'إدارة ومعالجة طلبات الخدمة الجديدة من العملاء'
                      : 'Manage and process new service requests from clients',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white60 : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),

                // ── error message ─────────────────────────
                if (state.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            state.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                        IconButton(
                          onPressed: notifier.fetchRequests,
                          icon: const Icon(Icons.refresh, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // ── Loading ───────────────────────────────
                if (state.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(48),
                      child: CircularProgressIndicator(),
                    ),
                  )

                // ── قائمة فاضية ───────────────────────────
                else if (state.requests.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(48),
                      child: Column(
                        children: [
                          Icon(Icons.inbox_outlined,
                              size: 64,
                              color: isDark ? Colors.white30 : Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            isAr ? 'لا توجد طلبات جديدة' : 'No new requests',
                            style: TextStyle(
                              fontSize: 18,
                              color: isDark ? Colors.white60 : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )

                // ── قائمة الطلبات ─────────────────────────
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.requests.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 24),
                    itemBuilder: (context, index) {
                      return RequestCard(
                        request: state.requests[index],
                        isDark: isDark,
                        isActionLoading: state.isActionLoading,
                        onAccept: () => _confirmAction(
                          context: context,
                          isAr: isAr,
                          isDark: isDark,
                          title: isAr ? 'قبول الطلب' : 'Accept Request',
                          message: isAr
                              ? 'هل تريد قبول هذا الطلب وتحويله إلى مشروع؟'
                              : 'Are you sure you want to accept this request?',
                          confirmColor: Colors.green,
                          onConfirm: () => notifier.acceptRequest(state.requests[index]),
                        ),
                        onReject: () => _confirmAction(
                          context: context,
                          isAr: isAr,
                          isDark: isDark,
                          title: isAr ? 'رفض الطلب' : 'Reject Request',
                          message: isAr
                              ? 'هل تريد رفض هذا الطلب؟'
                              : 'Are you sure you want to reject this request?',
                          confirmColor: Colors.red,
                          onConfirm: () => notifier.rejectRequest(state.requests[index]),
                        ),
                      );
                    },
                  ),
              ],
            );
          },
        );
      },
    );
  }

  // ── Dialog تأكيد القبول/الرفض ────────────────
  void _confirmAction({
    required BuildContext context,
    required bool isAr,
    required bool isDark,
    required String title,
    required String message,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        title: Text(title,
            style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary)),
        content: Text(message,
            style: TextStyle(color: isDark ? Colors.white70 : AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isAr ? 'إلغاء' : 'Cancel',
                style: TextStyle(color: isDark ? Colors.white60 : AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
            ),
            child: Text(isAr ? 'تأكيد' : 'Confirm'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// كارت الطلب
// ─────────────────────────────────────────────
class RequestCard extends StatelessWidget {
  final ServiceFormRequest request;
  final bool isDark;
  final bool isActionLoading;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const RequestCard({
    super.key,
    required this.request,
    required this.isDark,
    required this.isActionLoading,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

    return ValueListenableBuilder<String>(
      valueListenable: adminLanguageNotifier,
      builder: (context, lang, _) {
        final isAr = lang == 'ar';

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.white10 : AppColors.greyBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── رأس الكارت: نوع الخدمة + التاريخ ────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      request.formTypeAr,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Text(
                    _formatDate(request.createdAt),
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white38 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── بيانات العميل ─────────────────────────
              if (isMobile)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildClientInfo(isAr, isDark),
                    const SizedBox(height: 20),
                    _buildProjectDetails(isAr, isDark),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildClientInfo(isAr, isDark)),
                    const SizedBox(width: 32),
                    Expanded(flex: 3, child: _buildProjectDetails(isAr, isDark)),
                  ],
                ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // ── أزرار القبول والرفض ───────────────────
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: isActionLoading ? null : onAccept,
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: Text(isAr ? 'قبول وتحويل لمشروع' : 'Accept & Create Project'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton.icon(
                    onPressed: isActionLoading ? null : onReject,
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: Text(isAr ? 'رفض' : 'Reject'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                  if (isActionLoading) ...[
                    const SizedBox(width: 16),
                    const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ── بيانات العميل الشخصية ─────────────────────
  Widget _buildClientInfo(bool isAr, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isAr ? 'بيانات العميل' : 'Client Info',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white60 : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        _InfoRow(
          icon: Icons.person_outline,
          label: isAr ? 'الاسم' : 'Name',
          value: request.clientName.isEmpty ? '—' : request.clientName,
          isDark: isDark,
        ),
        _InfoRow(
          icon: Icons.phone_outlined,
          label: isAr ? 'الهاتف' : 'Phone',
          value: request.phone.isEmpty ? '—' : request.phone,
          isDark: isDark,
        ),
        _InfoRow(
          icon: Icons.email_outlined,
          label: isAr ? 'البريد' : 'Email',
          value: request.email.isEmpty ? '—' : request.email,
          isDark: isDark,
        ),
      ],
    );
  }

  // ── تفاصيل المشروع ────────────────────────────
  Widget _buildProjectDetails(bool isAr, bool isDark) {
    final metadata = request.formData['metadata'] as Map<String, dynamic>? ?? {};
    final buildingType = metadata['building_type'] ?? '—';
    final floors = request.formData['floors']?.toString() ?? '—';
    final landArea = request.formData['land_area']?.toString() ?? '—';
    final location = request.location;
    final notes = metadata['notes'] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isAr ? 'تفاصيل المشروع' : 'Project Details',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white60 : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        _InfoRow(
          icon: Icons.home_outlined,
          label: isAr ? 'نوع المبنى' : 'Building Type',
          value: buildingType,
          isDark: isDark,
        ),
        _InfoRow(
          icon: Icons.layers_outlined,
          label: isAr ? 'عدد الأدوار' : 'Floors',
          value: floors,
          isDark: isDark,
        ),
        _InfoRow(
          icon: Icons.square_foot_rounded,
          label: isAr ? 'مساحة الأرض' : 'Land Area',
          value: landArea.isEmpty ? '—' : '$landArea م²',
          isDark: isDark,
        ),
        if (location.isNotEmpty)
          _InfoRow(
            icon: Icons.location_on_outlined,
            label: isAr ? 'الموقع' : 'Location',
            value: location,
            isDark: isDark,
          ),
        if (notes.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            '${isAr ? 'ملاحظات' : 'Notes'}: $notes',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white54 : AppColors.textSecondary,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        // ملفات مرفقة
        if (request.designFileUrl != null || request.soilReportUrl != null) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              if (request.designFileUrl != null)
                _FileChip(
                  label: isAr ? 'ملف التصميم' : 'Design File',
                  url: request.designFileUrl!,
                  isDark: isDark,
                ),
              if (request.soilReportUrl != null)
                _FileChip(
                  label: isAr ? 'تقرير التربة' : 'Soil Report',
                  url: request.soilReportUrl!,
                  isDark: isDark,
                ),
            ],
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// ─────────────────────────────────────────────
// Widgets مساعدة
// ─────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isDark = false,
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
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white54 : AppColors.textSecondary,
              )),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _FileChip extends StatelessWidget {
  final String label;
  final String url;
  final bool isDark;

  const _FileChip({
    required this.label,
    required this.url,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: const Icon(Icons.attach_file, size: 14),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: isDark
          ? Colors.white.withValues(alpha: 0.08)
          : AppColors.primary.withValues(alpha: 0.08),
      labelStyle: TextStyle(
        color: isDark ? Colors.white70 : AppColors.primary,
      ),
      onPressed: () {
        // TODO: فتح الملف في browser
      },
    );
  }
}

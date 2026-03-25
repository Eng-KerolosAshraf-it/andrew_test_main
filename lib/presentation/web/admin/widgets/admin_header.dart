import 'package:flutter/material.dart';
import 'package:engineering_platform/core/constants/colors.dart';
import 'package:engineering_platform/core/state/language_state.dart';
import 'package:engineering_platform/core/state/theme_state.dart';
import 'package:engineering_platform/core/state/user_state.dart';
import 'package:engineering_platform/core/services/supabase_service.dart';
import 'package:engineering_platform/core/constants/app_constants.dart';
import 'dart:typed_data';

import 'package:engineering_platform/core/constants/route_names.dart';

class AdminHeader extends StatelessWidget {
  final bool isMobile;
  const AdminHeader({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: adminLanguageNotifier,
      builder: (context, lang, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: adminThemeNotifier,
          builder: (context, themeMode, _) {
            final isAr = lang == 'ar';
            final isDark = themeMode == ThemeMode.dark;

            return Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : AppColors.white,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.white10 : AppColors.greyLight,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // ── موبايل: زر القائمة ──
                  if (isMobile) ...[
                    IconButton(
                      icon: Icon(Icons.menu, color: isDark ? Colors.white : AppColors.textPrimary),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                    const SizedBox(width: 8),
                  ],

                  // ── ديسكتوب + موبايل: اللوجو + الاسم ──
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.bar_chart, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    AppConstants.appName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),

                  const Spacer(),

                  // ── سيرش (ديسكتوب فقط) ──
                  if (!isMobile)
                    Container(
                      constraints: const BoxConstraints(maxWidth: 250),
                      height: 38,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.greyLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 18),
                          hintText: isAr ? 'بحث...' : 'Search...',
                          hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 9),
                        ),
                      ),
                    ),
                  const SizedBox(width: 16),

                  // ── الإشعارات ──
                  _NotificationButton(isDark: isDark),
                  const SizedBox(width: 8),

                  // ── الأفاتار ──
                  const _UserAvatar(),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── زر الإشعارات ──────────────────────────────
class _NotificationButton extends StatefulWidget {
  final bool isDark;
  const _NotificationButton({required this.isDark});

  @override
  State<_NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<_NotificationButton> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final currentUser = supabaseService.client.auth.currentUser;
      if (currentUser == null) { setState(() => _isLoading = false); return; }
      final response = await supabaseService.client
          .from('notifications')
          .select()
          .eq('user_id', currentUser.id)
          .order('created_at', ascending: false)
          .limit(10);
      if (!mounted) return;
      setState(() {
        _notifications = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(int id) async {
    try {
      await supabaseService.client.from('notifications').update({'status': 'read'}).eq('id', id);
      if (!mounted) return;
      setState(() {
        final index = _notifications.indexWhere((n) => n['id'] == id);
        if (index != -1) _notifications[index] = {..._notifications[index], 'status': 'read'};
      });
    } catch (_) {}
  }

  Future<void> _markAllAsRead() async {
    try {
      final currentUser = supabaseService.client.auth.currentUser;
      if (currentUser == null) return;
      await supabaseService.client
          .from('notifications')
          .update({'status': 'read'})
          .eq('user_id', currentUser.id)
          .eq('status', 'unread');
      if (!mounted) return;
      setState(() { _notifications = _notifications.map((n) => {...n, 'status': 'read'}).toList(); });
    } catch (_) {}
  }

  int get _unreadCount => _notifications.where((n) => n['status'] == 'unread').length;

  void _showNotificationsPanel() {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Stack(
              children: [
                Positioned(
                  top: 70,
                  right: 80,
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(12),
                    color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
                    child: Container(
                      width: 320,
                      constraints: const BoxConstraints(maxHeight: 420),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: widget.isDark ? Colors.white10 : AppColors.greyLight),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  adminLanguageNotifier.value == 'ar' ? 'الإشعارات' : 'Notifications',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: widget.isDark ? Colors.white : AppColors.textPrimary),
                                ),
                                if (_unreadCount > 0)
                                  TextButton(
                                    onPressed: () async { await _markAllAsRead(); setDialogState(() {}); },
                                    child: Text(adminLanguageNotifier.value == 'ar' ? 'قراءة الكل' : 'Mark all read', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                                  ),
                              ],
                            ),
                          ),
                          Divider(height: 1, color: widget.isDark ? Colors.white10 : AppColors.greyLight),
                          if (_isLoading)
                            const Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())
                          else if (_notifications.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  Icon(Icons.notifications_none_outlined, size: 40, color: widget.isDark ? Colors.white30 : Colors.grey),
                                  const SizedBox(height: 8),
                                  Text(adminLanguageNotifier.value == 'ar' ? 'لا توجد إشعارات' : 'No notifications', style: TextStyle(color: widget.isDark ? Colors.white38 : Colors.grey)),
                                ],
                              ),
                            )
                          else
                            Flexible(
                              child: ListView.separated(
                                shrinkWrap: true,
                                itemCount: _notifications.length,
                                separatorBuilder: (_, __) => Divider(height: 1, color: widget.isDark ? Colors.white10 : AppColors.greyLight),
                                itemBuilder: (context, index) {
                                  final notif = _notifications[index];
                                  final isUnread = notif['status'] == 'unread';
                                  return InkWell(
                                    onTap: () async { await _markAsRead(notif['id']); setDialogState(() {}); },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      color: isUnread ? AppColors.primary.withValues(alpha: 0.05) : Colors.transparent,
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 36, height: 36,
                                            decoration: BoxDecoration(color: _getTypeColor(notif['type']).withValues(alpha: 0.1), shape: BoxShape.circle),
                                            child: Icon(_getTypeIcon(notif['type']), size: 18, color: _getTypeColor(notif['type'])),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(notif['message'] ?? '', style: TextStyle(fontSize: 13, color: widget.isDark ? Colors.white : AppColors.textPrimary, fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal)),
                                                const SizedBox(height: 4),
                                                Text(_formatDate(notif['created_at']), style: TextStyle(fontSize: 11, color: widget.isDark ? Colors.white38 : Colors.grey)),
                                              ],
                                            ),
                                          ),
                                          if (isUnread) Container(width: 8, height: 8, margin: const EdgeInsets.only(top: 4), decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle)),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Color _getTypeColor(String? type) {
    switch (type) {
      case 'request_accepted': return Colors.green;
      case 'request_rejected': return Colors.red;
      default: return Colors.blue;
    }
  }

  IconData _getTypeIcon(String? type) {
    switch (type) {
      case 'request_accepted': return Icons.check_circle_outline;
      case 'request_rejected': return Icons.cancel_outlined;
      default: return Icons.notifications_none_outlined;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) { return ''; }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(Icons.notifications_none_outlined, color: widget.isDark ? Colors.white : AppColors.textPrimary),
          onPressed: _showNotificationsPanel,
        ),
        if (_unreadCount > 0)
          Positioned(
            top: 8, right: 8,
            child: Container(
              width: 16, height: 16,
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: Center(child: Text(_unreadCount > 9 ? '9+' : '$_unreadCount', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))),
            ),
          ),
      ],
    );
  }
}

// ── الأفاتار + اسم المستخدم ───────────────────
class _UserAvatar extends StatelessWidget {
  const _UserAvatar();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: adminThemeNotifier,
      builder: (context, themeMode, _) {
        final isDark = themeMode == ThemeMode.dark;
        return ValueListenableBuilder<String>(
          valueListenable: adminLanguageNotifier,
          builder: (context, lang, _) {
            return ValueListenableBuilder<String?>(
              valueListenable: userState.userName,
              builder: (context, name, _) {
                return ValueListenableBuilder<Uint8List?>(
                  valueListenable: userState.profileImageBytes,
                  builder: (context, imageBytes, _) {
                    final initials = _getInitials(name);
                    return Theme(
                      data: isDark ? ThemeData.dark() : ThemeData.light(),
                      child: PopupMenuButton<String>(
                        offset: const Offset(0, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        onSelected: (value) {
                          if (value == 'settings') {
                            Navigator.pushNamed(context, RouteNames.adminSettings);
                          } else if (value == 'logout') {
                            userState.logout().then((_) {
                              Navigator.pushNamedAndRemoveUntil(context, RouteNames.login, (_) => false);
                            });
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            enabled: false,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name ?? 'Admin', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
                                Text(userState.userEmail.value ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(),
                          PopupMenuItem(
                            onTap: () => adminThemeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark,
                            child: Row(
                              children: [
                                Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined, size: 18, color: isDark ? Colors.amber : AppColors.textPrimary),
                                const SizedBox(width: 12),
                                Text(isDark ? (adminLanguageNotifier.value == 'ar' ? 'الوضع النهاري' : 'Light Mode') : (adminLanguageNotifier.value == 'ar' ? 'الوضع الليلي' : 'Dark Mode'), style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary)),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            enabled: false,
                            child: Row(
                              children: [
                                Icon(Icons.language, size: 18, color: isDark ? Colors.white : AppColors.textPrimary),
                                const SizedBox(width: 12),
                                GestureDetector(
                                  onTap: () => adminLanguageNotifier.value = 'ar',
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: adminLanguageNotifier.value == 'ar' ? AppColors.primary : Colors.transparent,
                                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(6)),
                                      border: Border.all(color: AppColors.primary),
                                    ),
                                    child: Text('AR', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: adminLanguageNotifier.value == 'ar' ? Colors.white : AppColors.primary)),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => adminLanguageNotifier.value = 'en',
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: adminLanguageNotifier.value == 'en' ? AppColors.primary : Colors.transparent,
                                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(6)),
                                      border: Border.all(color: AppColors.primary),
                                    ),
                                    child: Text('EN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: adminLanguageNotifier.value == 'en' ? Colors.white : AppColors.primary)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(),
                          PopupMenuItem(
                            value: 'settings',
                            child: Row(
                              children: [
                                Icon(Icons.settings_outlined, size: 18, color: isDark ? Colors.white : AppColors.textPrimary),
                                const SizedBox(width: 12),
                                Text(adminLanguageNotifier.value == 'ar' ? 'الإعدادات' : 'Settings'),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(),
                          PopupMenuItem(
                            value: 'logout',
                            child: Row(
                              children: [
                                const Icon(Icons.logout, size: 18, color: Colors.red),
                                const SizedBox(width: 12),
                                Text(adminLanguageNotifier.value == 'ar' ? 'تسجيل الخروج' : 'Logout', style: const TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                        child: Row(
                          children: [
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary.withValues(alpha: 0.2),
                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 2),
                                image: imageBytes != null ? DecorationImage(image: MemoryImage(imageBytes), fit: BoxFit.cover) : null,
                              ),
                              child: imageBytes == null
                                  ? Center(child: Text(initials, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.primary)))
                                  : null,
                            ),
                            if (MediaQuery.of(context).size.width > 900) ...[
                              const SizedBox(width: 8),
                              Text(name ?? 'Admin', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? Colors.white : AppColors.textPrimary)),
                              const SizedBox(width: 4),
                              Icon(Icons.keyboard_arrow_down, size: 16, color: isDark ? Colors.white60 : AppColors.textSecondary),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return 'A';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name[0].toUpperCase();
  }
}

import 'package:flutter/material.dart';
import 'package:engineering_platform/core/constants/colors.dart';
import 'package:engineering_platform/core/state/language_state.dart';
import 'package:engineering_platform/core/state/theme_state.dart';
import 'package:engineering_platform/core/state/user_state.dart';
import 'package:engineering_platform/core/constants/app_constants.dart';
import 'package:engineering_platform/core/services/supabase_service.dart';
import 'dart:typed_data';

import 'package:engineering_platform/core/constants/route_names.dart';

const _engineerColor = Color(0xFF059669);

final ValueNotifier<bool> engineerSidebarCollapsed = ValueNotifier<bool>(false);

// ── Sidebar ───────────────────────────────────────────────
class EngineerSidebar extends StatelessWidget {
  const EngineerSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return ValueListenableBuilder<bool>(
      valueListenable: engineerSidebarCollapsed,
      builder: (context, isCollapsed, _) {
        return ValueListenableBuilder<String>(
          valueListenable: engineerLanguageNotifier,
          builder: (context, lang, _) {
            return ValueListenableBuilder<ThemeMode>(
              valueListenable: engineerThemeNotifier,
              builder: (context, themeMode, _) {
                final isDark = themeMode == ThemeMode.dark;
                final isAr = lang == 'ar';

                return ClipRect(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    width: isCollapsed ? 70 : 260,
                    color: isDark ? const Color(0xFF0F172A) : AppColors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── زر الطي ──
                        SizedBox(
                          height: 70,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () => engineerSidebarCollapsed.value = !isCollapsed,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    width: 32, height: 32,
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.greyLight,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      isCollapsed ? Icons.keyboard_arrow_right : Icons.keyboard_arrow_left,
                                      size: 20,
                                      color: isDark ? Colors.white60 : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // ── بيانات المستخدم ──
                        if (!isCollapsed) ...[
                          _UserInfo(isDark: isDark, isAr: isAr),
                          const SizedBox(height: 16),
                        ],

                        Divider(color: isDark ? Colors.white10 : AppColors.greyLight, height: 1),
                        const SizedBox(height: 8),

                        // ── Nav Items ──
                        _SidebarItem(icon: Icons.dashboard_rounded,
                          title: isAr ? 'لوحة التحكم' : 'Dashboard',
                          isActive: currentRoute == RouteNames.engineerDashboard,
                          isDark: isDark, isCollapsed: isCollapsed,
                          onTap: () => currentRoute != RouteNames.engineerDashboard ? Navigator.pushNamed(context, RouteNames.engineerDashboard) : null),

                        _SidebarItem(icon: Icons.folder_open_rounded,
                          title: isAr ? 'المشاريع' : 'Projects',
                          isActive: currentRoute == RouteNames.engineerProjects,
                          isDark: isDark, isCollapsed: isCollapsed,
                          onTap: () => currentRoute != RouteNames.engineerProjects ? Navigator.pushReplacementNamed(context, RouteNames.engineerProjects) : null),

                        _SidebarItem(icon: Icons.checklist_rounded,
                          title: isAr ? 'المهام اليومية' : 'Daily Tasks',
                          isActive: currentRoute == RouteNames.engineerTasks,
                          isDark: isDark, isCollapsed: isCollapsed,
                          onTap: () => currentRoute != RouteNames.engineerTasks ? Navigator.pushReplacementNamed(context, RouteNames.engineerTasks) : null),

                        _SidebarItem(icon: Icons.assessment_rounded,
                          title: isAr ? 'تقرير التقدم' : 'Progress Report',
                          isActive: currentRoute == RouteNames.engineerProgress,
                          isDark: isDark, isCollapsed: isCollapsed,
                          onTap: () => currentRoute != RouteNames.engineerProgress ? Navigator.pushReplacementNamed(context, RouteNames.engineerProgress) : null),

                        _SidebarItem(icon: Icons.warning_amber_rounded,
                          title: isAr ? 'المشاكل والعقبات' : 'Issues & Obstacles',
                          isActive: currentRoute == RouteNames.engineerLogs,
                          isDark: isDark, isCollapsed: isCollapsed,
                          onTap: () => currentRoute != RouteNames.engineerLogs ? Navigator.pushReplacementNamed(context, RouteNames.engineerLogs) : null),

                        _SidebarItem(icon: Icons.settings_rounded,
                          title: isAr ? 'الإعدادات' : 'Settings',
                          isActive: currentRoute == RouteNames.engineerSettings,
                          isDark: isDark, isCollapsed: isCollapsed,
                          onTap: () => currentRoute != RouteNames.engineerSettings ? Navigator.pushReplacementNamed(context, RouteNames.engineerSettings) : null),

                        const Spacer(),

                        Divider(color: isDark ? Colors.white10 : AppColors.greyLight, height: 1),

                        // ── Logout ──
                        Padding(
                          padding: EdgeInsets.all(isCollapsed ? 8 : 16),
                          child: Tooltip(
                            message: isCollapsed ? (isAr ? 'تسجيل الخروج' : 'Logout') : '',
                            child: InkWell(
                              onTap: () async {
                                await userState.logout();
                                Navigator.pushNamedAndRemoveUntil(context, RouteNames.login, (_) => false);
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 0 : 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: isCollapsed
                                    ? const Center(child: Icon(Icons.logout_rounded, color: Colors.red, size: 20))
                                    : Row(children: [
                                        const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
                                        const SizedBox(width: 12),
                                        Text(isAr ? 'تسجيل الخروج' : 'Logout',
                                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 14)),
                                      ]),
                              ),
                            ),
                          ),
                        ),
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
  }
}

// ── User Info ─────────────────────────────────────────────
class _UserInfo extends StatelessWidget {
  final bool isDark, isAr;
  const _UserInfo({required this.isDark, required this.isAr});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: userState.userName,
      builder: (context, name, _) {
        return ValueListenableBuilder<Uint8List?>(
          valueListenable: userState.profileImageBytes,
          builder: (context, imageBytes, _) {
            final initials = _getInitials(name);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _engineerColor.withValues(alpha: 0.15),
                    border: Border.all(color: _engineerColor.withValues(alpha: 0.4), width: 2),
                    image: imageBytes != null ? DecorationImage(image: MemoryImage(imageBytes), fit: BoxFit.cover) : null,
                  ),
                  child: imageBytes == null
                      ? Center(child: Text(initials, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : _engineerColor)))
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name ?? 'Engineer', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary), overflow: TextOverflow.ellipsis),
                    Text(isAr ? 'مهندس' : 'Engineer', style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : AppColors.textSecondary)),
                  ],
                )),
              ]),
            );
          },
        );
      },
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return 'E';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name[0].toUpperCase();
  }
}

// ── Sidebar Item ──────────────────────────────────────────
class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isActive, isDark, isCollapsed;
  final VoidCallback? onTap;

  const _SidebarItem({
    required this.icon, required this.title, required this.onTap,
    this.isActive = false, this.isDark = false, this.isCollapsed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isCollapsed ? title : '',
      preferBelow: false,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: isCollapsed ? 8 : 12, vertical: 2),
        decoration: BoxDecoration(
          color: isActive
              ? (isDark ? _engineerColor.withValues(alpha: 0.15) : _engineerColor.withValues(alpha: 0.08))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isActive ? Border.all(color: _engineerColor.withValues(alpha: 0.3)) : null,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 48,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(children: [
                Icon(icon, color: isActive ? _engineerColor : (isDark ? Colors.white60 : AppColors.textSecondary), size: 20),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(child: Text(title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isActive ? (isDark ? Colors.white : _engineerColor) : (isDark ? Colors.white60 : AppColors.textSecondary),
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                      fontSize: 14,
                    ))),
                  if (isActive)
                    Container(width: 3, height: 20, decoration: BoxDecoration(color: _engineerColor, borderRadius: BorderRadius.circular(2))),
                ],
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────
class EngineerHeader extends StatelessWidget {
  final bool isMobile;
  const EngineerHeader({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: engineerLanguageNotifier,
      builder: (context, lang, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: engineerThemeNotifier,
          builder: (context, themeMode, _) {
            final isAr = lang == 'ar';
            final isDark = themeMode == ThemeMode.dark;
            final textColor = isDark ? Colors.white : AppColors.textPrimary;
            final subColor = isDark ? Colors.white60 : AppColors.textSecondary;

            return Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : AppColors.white,
                border: Border(bottom: BorderSide(color: isDark ? Colors.white10 : AppColors.greyBorder)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Row(children: [
                // Mobile menu
                if (isMobile) ...[
                  IconButton(icon: Icon(Icons.menu, color: textColor), onPressed: () => Scaffold.of(context).openDrawer()),
                  const SizedBox(width: 8),
                ],

                // Logo → dashboard
                InkWell(
                  onTap: () => Navigator.pushNamed(context, '/engineer/dashboard'),
                  borderRadius: BorderRadius.circular(8),
                  child: Row(children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(color: _engineerColor, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.architecture, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Text(AppConstants.appName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                  ]),
                ),

                const Spacer(),

                // Search
                if (!isMobile)
                  Container(
                    width: 240, height: 38,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.07) : AppColors.greyLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      style: TextStyle(fontSize: 13, color: textColor),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search, size: 18, color: subColor),
                        hintText: isAr ? 'بحث...' : 'Search...',
                        hintStyle: TextStyle(fontSize: 13, color: subColor),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 9),
                      ),
                    ),
                  ),

                const SizedBox(width: 16),

                // Notifications
                _NotificationButton(isDark: isDark),
                const SizedBox(width: 8),

                // Avatar + menu
                _UserAvatar(isDark: isDark, lang: lang),
              ]),
            );
          },
        );
      },
    );
  }
}

// ── Notification Button ───────────────────────────────────
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
          .from('notifications').select()
          .eq('user_id', currentUser.id)
          .order('created_at', ascending: false).limit(10);
      if (!mounted) return;
      setState(() { _notifications = List<Map<String, dynamic>>.from(response); _isLoading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final currentUser = supabaseService.client.auth.currentUser;
      if (currentUser == null) return;
      await supabaseService.client.from('notifications')
          .update({'status': 'read'}).eq('user_id', currentUser.id).eq('status', 'unread');
      if (!mounted) return;
      setState(() { _notifications = _notifications.map((n) => {...n, 'status': 'read'}).toList(); });
    } catch (_) {}
  }

  int get _unreadCount => _notifications.where((n) => n['status'] == 'unread').length;

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m';
      if (diff.inHours < 24) return '${diff.inHours}h';
      return '${diff.inDays}d';
    } catch (_) { return ''; }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = engineerLanguageNotifier.value == 'ar';
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(Icons.notifications_none_outlined, color: widget.isDark ? Colors.white70 : AppColors.textSecondary),
          onPressed: () {
            showDialog(
              context: context,
              barrierColor: Colors.transparent,
              builder: (context) => StatefulBuilder(
                builder: (context, setDialogState) => Stack(
                  children: [
                    Positioned(
                      top: 70, right: 80,
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
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Text(isAr ? 'الإشعارات' : 'Notifications',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: widget.isDark ? Colors.white : AppColors.textPrimary)),
                                if (_unreadCount > 0)
                                  TextButton(onPressed: () async { await _markAllAsRead(); setDialogState(() {}); },
                                    child: Text(isAr ? 'قراءة الكل' : 'Mark all read', style: const TextStyle(fontSize: 12, color: _engineerColor))),
                              ]),
                            ),
                            Divider(height: 1, color: widget.isDark ? Colors.white10 : AppColors.greyLight),
                            if (_isLoading)
                              const Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())
                            else if (_notifications.isEmpty)
                              Padding(padding: const EdgeInsets.all(24), child: Column(children: [
                                Icon(Icons.notifications_none_outlined, size: 40, color: widget.isDark ? Colors.white30 : Colors.grey),
                                const SizedBox(height: 8),
                                Text(isAr ? 'لا توجد إشعارات' : 'No notifications',
                                  style: TextStyle(color: widget.isDark ? Colors.white38 : Colors.grey)),
                              ]))
                            else
                              Flexible(child: ListView.separated(
                                shrinkWrap: true,
                                itemCount: _notifications.length,
                                separatorBuilder: (_, __) => Divider(height: 1, color: widget.isDark ? Colors.white10 : AppColors.greyLight),
                                itemBuilder: (context, index) {
                                  final notif = _notifications[index];
                                  final isUnread = notif['status'] == 'unread';
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    color: isUnread ? _engineerColor.withValues(alpha: 0.05) : Colors.transparent,
                                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Container(width: 36, height: 36,
                                        decoration: BoxDecoration(color: _engineerColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                                        child: const Icon(Icons.notifications_none_outlined, size: 18, color: _engineerColor)),
                                      const SizedBox(width: 12),
                                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Text(notif['message'] ?? '', style: TextStyle(fontSize: 13,
                                          color: widget.isDark ? Colors.white : AppColors.textPrimary,
                                          fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal)),
                                        const SizedBox(height: 4),
                                        Text(_formatDate(notif['created_at']), style: TextStyle(fontSize: 11, color: widget.isDark ? Colors.white38 : Colors.grey)),
                                      ])),
                                      if (isUnread) Container(width: 8, height: 8, margin: const EdgeInsets.only(top: 4),
                                        decoration: const BoxDecoration(color: _engineerColor, shape: BoxShape.circle)),
                                    ]),
                                  );
                                },
                              )),
                          ]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        if (_unreadCount > 0)
          Positioned(
            top: 8, right: 8,
            child: Container(
              width: 16, height: 16,
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: Center(child: Text(_unreadCount > 9 ? '9+' : '$_unreadCount',
                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))),
            ),
          ),
      ],
    );
  }
}

// ── User Avatar ───────────────────────────────────────────
class _UserAvatar extends StatelessWidget {
  final bool isDark;
  final String lang;
  const _UserAvatar({required this.isDark, required this.lang});

  @override
  Widget build(BuildContext context) {
    final isAr = lang == 'ar';
    return ValueListenableBuilder<String?>(
      valueListenable: userState.userName,
      builder: (context, name, _) {
        return ValueListenableBuilder<Uint8List?>(
          valueListenable: userState.profileImageBytes,
          builder: (context, imageBytes, _) {
            final initials = _getInitials(name);
            return PopupMenuButton<String>(
              offset: const Offset(0, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (value) {
                if (value == 'settings') Navigator.pushNamed(context, '/engineer/settings');
                if (value == 'logout') userState.logout().then((_) => Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false));
              },
              itemBuilder: (_) => [
                PopupMenuItem(enabled: false, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name ?? 'Engineer', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
                  Text(userState.userEmail.value ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ])),
                const PopupMenuDivider(),
                // Dark mode toggle
                PopupMenuItem(
                  onTap: () => engineerThemeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark,
                  child: Row(children: [
                    Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined, size: 18, color: isDark ? Colors.amber : AppColors.textPrimary),
                    const SizedBox(width: 12),
                    Text(isDark ? (isAr ? 'الوضع النهاري' : 'Light Mode') : (isAr ? 'الوضع الليلي' : 'Dark Mode'),
                      style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary)),
                  ]),
                ),
                // Language toggle
                PopupMenuItem(enabled: false, child: Row(children: [
                  Icon(Icons.language, size: 18, color: isDark ? Colors.white : AppColors.textPrimary),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => engineerLanguageNotifier.value = 'ar',
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: engineerLanguageNotifier.value == 'ar' ? _engineerColor : Colors.transparent,
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(6)),
                        border: Border.all(color: _engineerColor),
                      ),
                      child: Text('AR', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
                        color: engineerLanguageNotifier.value == 'ar' ? Colors.white : _engineerColor)),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => engineerLanguageNotifier.value = 'en',
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: engineerLanguageNotifier.value == 'en' ? _engineerColor : Colors.transparent,
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(6)),
                        border: Border.all(color: _engineerColor),
                      ),
                      child: Text('EN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
                        color: engineerLanguageNotifier.value == 'en' ? Colors.white : _engineerColor)),
                    ),
                  ),
                ])),
                const PopupMenuDivider(),
                PopupMenuItem(value: 'settings', child: Row(children: [
                  Icon(Icons.settings_outlined, size: 18, color: isDark ? Colors.white : AppColors.textPrimary),
                  const SizedBox(width: 12),
                  Text(isAr ? 'الإعدادات' : 'Settings', style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary)),
                ])),
                const PopupMenuDivider(),
                PopupMenuItem(value: 'logout', child: Row(children: [
                  const Icon(Icons.logout, size: 18, color: Colors.red),
                  const SizedBox(width: 12),
                  Text(isAr ? 'تسجيل الخروج' : 'Logout', style: const TextStyle(color: Colors.red)),
                ])),
              ],
              child: Row(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _engineerColor.withValues(alpha: 0.15),
                    border: Border.all(color: _engineerColor.withValues(alpha: 0.5), width: 2),
                    image: imageBytes != null ? DecorationImage(image: MemoryImage(imageBytes), fit: BoxFit.cover) : null,
                  ),
                  child: imageBytes == null
                      ? Center(child: Text(initials, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : _engineerColor)))
                      : null,
                ),
                const SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down, size: 16, color: isDark ? Colors.white60 : AppColors.textSecondary),
              ]),
            );
          },
        );
      },
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return 'E';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name[0].toUpperCase();
  }
}

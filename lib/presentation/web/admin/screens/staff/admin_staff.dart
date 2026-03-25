import 'package:flutter/material.dart';
import 'package:engineering_platform/core/constants/colors.dart';
import 'package:engineering_platform/core/state/language_state.dart';
import 'package:engineering_platform/core/state/theme_state.dart';
import 'package:engineering_platform/core/utils/responsive.dart';
import 'package:engineering_platform/core/services/supabase_service.dart';
import 'package:engineering_platform/presentation/web/admin/widgets/admin_header.dart';
import 'package:engineering_platform/presentation/web/admin/widgets/admin_sidebar.dart';

class AdminStaffPage extends StatelessWidget {
  const AdminStaffPage({super.key});

  @override
  Widget build(BuildContext context) {
    final initialTab = ModalRoute.of(context)?.settings.arguments as int? ?? 0;

    return ValueListenableBuilder<bool>(
      valueListenable: sidebarCollapsed,
      builder: (context, isCollapsed, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: adminThemeNotifier,
          builder: (context, themeMode, _) {
            return ValueListenableBuilder<String>(
              valueListenable: adminLanguageNotifier,
              builder: (context, lang, _) {
                final isDark = themeMode == ThemeMode.dark;
                final isAr = lang == 'ar';
                final isMobile = Responsive.isMobile(context);

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
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isAr ? 'الكوادر البشرية' : 'Staff',
                                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary),
                                    ),
                                    const SizedBox(height: 24),
                                    Expanded(child: _StaffTabs(isDark: isDark, isAr: isAr, initialTab: initialTab)),
                                  ],
                                ),
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

// ── Tabs ──────────────────────────────────────
class _StaffTabs extends StatefulWidget {
  final bool isDark;
  final bool isAr;
  final int initialTab;
  const _StaffTabs({required this.isDark, required this.isAr, this.initialTab = 0});

  @override
  State<_StaffTabs> createState() => _StaffTabsState();
}

class _StaffTabsState extends State<_StaffTabs> {
  late int _selectedTab;
  List<Map<String, dynamic>> _engineers = [];
  List<Map<String, dynamic>> _technicians = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
    _fetchStaff();
  }

  Future<void> _fetchStaff() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final engineers = await supabaseService.client
          .from('users').select().eq('role', 'engineer').eq('is_deleted', false).order('created_at', ascending: false);
      final technicians = await supabaseService.client
          .from('users').select().eq('role', 'technician').eq('is_deleted', false).order('created_at', ascending: false);
      if (!mounted) return;
      setState(() {
        _engineers = List<Map<String, dynamic>>.from(engineers);
        _technicians = List<Map<String, dynamic>>.from(technicians);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _isLoading = false; _error = e.toString(); });
    }
  }

  Future<void> _deleteUser(String id) async {
    final isAr = widget.isAr;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isAr ? 'تأكيد الحذف' : 'Confirm Delete'),
        content: Text(isAr ? 'هل أنت متأكد من الحذف؟' : 'Are you sure you want to delete?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(isAr ? 'إلغاء' : 'Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(isAr ? 'حذف' : 'Delete', style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await supabaseService.client.from('users').update({'is_deleted': true}).eq('id', id);
      _fetchStaff();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    }
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (ctx) => _StaffFormDialog(
        isDark: widget.isDark,
        isAr: widget.isAr,
        role: _selectedTab == 0 ? 'engineer' : 'technician',
        onSaved: _fetchStaff,
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (ctx) => _StaffFormDialog(
        isDark: widget.isDark,
        isAr: widget.isAr,
        role: _selectedTab == 0 ? 'engineer' : 'technician',
        user: user,
        onSaved: _fetchStaff,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _selectedTab == 0 ? _engineers : _technicians;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Tabs + Add + Refresh ──
        Row(
          children: [
            _TabButton(label: widget.isAr ? 'المهندسين' : 'Engineers', count: _engineers.length, isSelected: _selectedTab == 0, isDark: widget.isDark, onTap: () => setState(() => _selectedTab = 0)),
            const SizedBox(width: 8),
            _TabButton(label: widget.isAr ? 'الفنيين' : 'Technicians', count: _technicians.length, isSelected: _selectedTab == 1, isDark: widget.isDark, onTap: () => setState(() => _selectedTab = 1)),
            const Spacer(),
            IconButton(onPressed: _isLoading ? null : _fetchStaff, icon: Icon(Icons.refresh, color: widget.isDark ? Colors.white60 : AppColors.textSecondary)),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _showAddDialog,
              icon: const Icon(Icons.add, size: 18),
              label: Text(widget.isAr ? 'إضافة' : 'Add'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                  : list.isEmpty
                      ? _EmptyState(isDark: widget.isDark, isAr: widget.isAr, isEngineer: _selectedTab == 0)
                      : _StaffTable(
                          users: list,
                          isDark: widget.isDark,
                          isAr: widget.isAr,
                          onEdit: _showEditDialog,
                          onDelete: (id) => _deleteUser(id),
                        ),
        ),
      ],
    );
  }
}

// ── Form Dialog (إضافة / تعديل) ───────────────
class _StaffFormDialog extends StatefulWidget {
  final bool isDark;
  final bool isAr;
  final String role;
  final Map<String, dynamic>? user;
  final VoidCallback onSaved;

  const _StaffFormDialog({required this.isDark, required this.isAr, required this.role, required this.onSaved, this.user});

  @override
  State<_StaffFormDialog> createState() => _StaffFormDialogState();
}

class _StaffFormDialogState extends State<_StaffFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name, _email, _phone, _department, _salary, _password;
  bool _isActive = true;
  bool _isSaving = false;
  bool _obscurePassword = true;
  DateTime? _hireDate;

  bool get isEdit => widget.user != null;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _name = TextEditingController(text: u?['name'] ?? '');
    _email = TextEditingController(text: u?['email'] ?? '');
    _phone = TextEditingController(text: u?['phone'] ?? '');
    _department = TextEditingController(text: u?['department'] ?? '');
    _salary = TextEditingController(text: u?['salary']?.toString() ?? '');
    _password = TextEditingController();
    _isActive = u?['is_active'] ?? true;
    if (u?['hire_date'] != null) {
      _hireDate = DateTime.tryParse(u!['hire_date']);
    }
  }

  @override
  void dispose() {
    _name.dispose(); _email.dispose(); _phone.dispose();
    _department.dispose(); _salary.dispose(); _password.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      if (isEdit) {
        // تعديل بيانات موجودة فقط
        final data = {
          'name': _name.text.trim(),
          'phone': _phone.text.trim(),
          'department': _department.text.trim(),
          'salary': double.tryParse(_salary.text.trim()),
          'is_active': _isActive,
          'hire_date': _hireDate?.toIso8601String().substring(0, 10),
          'role': widget.role,
          'user_type': widget.role,
          'is_deleted': false,
        };
        await supabaseService.client.from('users').update(data).eq('id', widget.user!['id']);
      }   else {
  final response = await supabaseService.client.functions.invoke(
    'create-staff',
    body: {
      'email': _email.text.trim(),
      'password': _password.text.trim(),
      'name': _name.text.trim(),
      'role': widget.role,
    },
  );

  if (response.data['error'] != null) {
    throw Exception(response.data['error']);
  }

  final userId = response.data['id'] as String;

  await supabaseService.client.from('users').insert({
    'id': userId,
    'name': _name.text.trim(),
    'email': _email.text.trim(),
    'phone': _phone.text.trim(),
    'department': _department.text.trim(),
    'salary': double.tryParse(_salary.text.trim()),
    'is_active': _isActive,
    'hire_date': _hireDate?.toIso8601String().substring(0, 10),
    'role': widget.role,
    'user_type': widget.role == 'engineer' ? 'employee' : 'technician',
    'is_deleted': false,
  });
}

      if (!mounted) return;
      Navigator.pop(context);
      widget.onSaved();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    }
    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final isAr = widget.isAr;
    final isDark = widget.isDark;
    final roleLabel = widget.role == 'engineer' ? (isAr ? 'مهندس' : 'Engineer') : (isAr ? 'فني' : 'Technician');

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEdit ? (isAr ? 'تعديل $roleLabel' : 'Edit $roleLabel') : (isAr ? 'إضافة $roleLabel' : 'Add $roleLabel'),
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary),
                    ),
                    IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close, color: isDark ? Colors.white60 : Colors.grey)),
                  ],
                ),
                const SizedBox(height: 20),

                _FormField(controller: _name, label: isAr ? 'الاسم' : 'Name', isDark: isDark, required: true),
                const SizedBox(height: 12),
                _FormField(controller: _email, label: isAr ? 'البريد الإلكتروني' : 'Email', isDark: isDark, required: !isEdit, readOnly: isEdit, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 12),
                _FormField(controller: _phone, label: isAr ? 'الهاتف' : 'Phone', isDark: isDark),
                const SizedBox(height: 12),
                _FormField(controller: _department, label: isAr ? 'القسم' : 'Department', isDark: isDark),
                const SizedBox(height: 12),
                _FormField(controller: _salary, label: isAr ? 'الراتب' : 'Salary', isDark: isDark, keyboardType: TextInputType.number),
                const SizedBox(height: 12),

                // حقل كلمة المرور (فقط عند الإضافة)
                if (!isEdit) ...[
                  TextFormField(
                    controller: _password,
                    obscureText: _obscurePassword,
                    style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: isAr ? 'كلمة المرور المؤقتة' : 'Temporary Password',
                      labelStyle: TextStyle(color: isDark ? Colors.white60 : Colors.grey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? Colors.white24 : AppColors.greyBorder)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? Colors.white24 : AppColors.greyBorder)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.primary)),
                      filled: true,
                      fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.transparent,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: isDark ? Colors.white60 : Colors.grey),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (v) => (v == null || v.length < 6) ? (isAr ? 'كلمة المرور 6 أحرف على الأقل' : 'Password must be at least 6 characters') : null,
                  ),
                  const SizedBox(height: 12),
                ],

                // Hire Date
                GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _hireDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) setState(() => _hireDate = date);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: isDark ? Colors.white24 : AppColors.greyBorder),
                      borderRadius: BorderRadius.circular(8),
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.transparent,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: isDark ? Colors.white60 : Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          _hireDate != null ? _hireDate!.toIso8601String().substring(0, 10) : (isAr ? 'تاريخ التعيين' : 'Hire Date'),
                          style: TextStyle(color: isDark ? Colors.white70 : AppColors.textSecondary, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Is Active
                Row(
                  children: [
                    Switch(value: _isActive, onChanged: (v) => setState(() => _isActive = v), activeColor: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(isAr ? 'نشط' : 'Active', style: TextStyle(color: isDark ? Colors.white70 : AppColors.textPrimary)),
                  ],
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(isAr ? 'إلغاء' : 'Cancel', style: TextStyle(color: isDark ? Colors.white60 : Colors.grey)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      child: _isSaving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(isEdit ? (isAr ? 'حفظ' : 'Save') : (isAr ? 'إضافة' : 'Add')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isDark;
  final bool required;
  final bool readOnly;
  final TextInputType? keyboardType;

  const _FormField({required this.controller, required this.label, required this.isDark, this.required = false, this.readOnly = false, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.white60 : Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? Colors.white24 : AppColors.greyBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? Colors.white24 : AppColors.greyBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.primary)),
        filled: true,
        fillColor: readOnly
            ? (isDark ? Colors.white.withValues(alpha: 0.02) : Colors.grey.shade100)
            : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.transparent),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      validator: required ? (v) => (v == null || v.isEmpty) ? '$label required' : null : null,
    );
  }
}

// ── Tab Button ────────────────────────────────
class _TabButton extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _TabButton({required this.label, required this.count, required this.isSelected, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? AppColors.primary : (isDark ? Colors.white24 : AppColors.greyBorder)),
        ),
        child: Row(
          children: [
            Text(label, style: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.white60 : AppColors.textSecondary), fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 14)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: isSelected ? Colors.white.withValues(alpha: 0.2) : (isDark ? Colors.white10 : AppColors.greyLight), borderRadius: BorderRadius.circular(12)),
              child: Text('$count', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : (isDark ? Colors.white60 : AppColors.textSecondary))),
            ),
          ],
        ),
      ),
    );
  }
}

// ── جدول البيانات ─────────────────────────────
class _StaffTable extends StatelessWidget {
  final List<Map<String, dynamic>> users;
  final bool isDark;
  final bool isAr;
  final Function(Map<String, dynamic>) onEdit;
  final Function(String) onDelete;

  const _StaffTable({required this.users, required this.isDark, required this.isAr, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : AppColors.greyBorder),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.greyLight,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                _HeaderCell(label: isAr ? 'الاسم' : 'Name', flex: 2, isDark: isDark),
                _HeaderCell(label: isAr ? 'البريد' : 'Email', flex: 2, isDark: isDark),
                _HeaderCell(label: isAr ? 'الهاتف' : 'Phone', flex: 1, isDark: isDark),
                _HeaderCell(label: isAr ? 'القسم' : 'Department', flex: 1, isDark: isDark),
                _HeaderCell(label: isAr ? 'التعيين' : 'Hire Date', flex: 1, isDark: isDark),
                _HeaderCell(label: isAr ? 'الراتب' : 'Salary', flex: 1, isDark: isDark),
                _HeaderCell(label: isAr ? 'الحالة' : 'Status', flex: 1, isDark: isDark),
                _HeaderCell(label: isAr ? 'إجراءات' : 'Actions', flex: 1, isDark: isDark),
              ],
            ),
          ),
          // Rows
          Expanded(
            child: ListView.separated(
              itemCount: users.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: isDark ? Colors.white10 : AppColors.greyBorder),
              itemBuilder: (context, index) {
                final user = users[index];
                final isActive = user['is_active'] == true;
                final hireDate = user['hire_date'] != null ? user['hire_date'].toString().substring(0, 10) : '-';
                final salary = user['salary'] != null ? '${user['salary']} EGP' : '-';

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      // Name + Avatar
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Container(
                              width: 34, height: 34,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withValues(alpha: 0.15)),
                              child: Center(child: Text((user['name'] as String? ?? 'U')[0].toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13))),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(user['name'] ?? '-', style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.textPrimary, fontSize: 13), overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      ),
                      _DataCell(label: user['email'] ?? '-', flex: 2, isDark: isDark),
                      _DataCell(label: user['phone'] ?? '-', flex: 1, isDark: isDark),
                      _DataCell(label: user['department'] ?? '-', flex: 1, isDark: isDark),
                      _DataCell(label: hireDate, flex: 1, isDark: isDark),
                      _DataCell(label: salary, flex: 1, isDark: isDark),
                      // Status
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isActive ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isActive ? (isAr ? 'نشط' : 'Active') : (isAr ? 'غير نشط' : 'Inactive'),
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isActive ? Colors.green : Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      // Actions
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => onEdit(user),
                              icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.blue),
                              tooltip: isAr ? 'تعديل' : 'Edit',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () => onDelete(user['id'].toString()),
                              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                              tooltip: isAr ? 'حذف' : 'Delete',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final int flex;
  final bool isDark;
  const _HeaderCell({required this.label, required this.flex, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Expanded(flex: flex, child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white60 : AppColors.textSecondary)));
  }
}

class _DataCell extends StatelessWidget {
  final String label;
  final int flex;
  final bool isDark;
  const _DataCell({required this.label, required this.flex, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Expanded(flex: flex, child: Text(label, style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : AppColors.textSecondary), overflow: TextOverflow.ellipsis));
  }
}

class _EmptyState extends StatelessWidget {
  final bool isDark;
  final bool isAr;
  final bool isEngineer;
  const _EmptyState({required this.isDark, required this.isAr, required this.isEngineer});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: isDark ? const Color(0xFF1E293B) : AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: isDark ? Colors.white10 : AppColors.greyBorder)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isEngineer ? Icons.engineering_outlined : Icons.build_outlined, size: 48, color: isDark ? Colors.white30 : Colors.grey),
            const SizedBox(height: 16),
            Text(isEngineer ? (isAr ? 'لا يوجد مهندسين' : 'No Engineers Found') : (isAr ? 'لا يوجد فنيين' : 'No Technicians Found'), style: TextStyle(fontSize: 16, color: isDark ? Colors.white38 : Colors.grey)),
          ],
        ),
      ),
    );
  }
}

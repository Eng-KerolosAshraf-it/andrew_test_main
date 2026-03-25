import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:engineering_platform/core/services/supabase_service.dart';
import 'technician_dashboard_state.dart';

final technicianDashboardProvider =
    NotifierProvider.autoDispose<TechnicianDashboardNotifier, TechnicianDashboardState>(
  TechnicianDashboardNotifier.new,
);

class TechnicianDashboardNotifier extends AutoDisposeNotifier<TechnicianDashboardState> {
  @override
  TechnicianDashboardState build() {
    Future.microtask(() => fetchDashboard());
    return const TechnicianDashboardState(isLoading: true);
  }

  Future<void> fetchDashboard() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final currentUser = supabaseService.client.auth.currentUser;
      if (currentUser == null) throw Exception('غير مسجل الدخول');

      final tasksRes = await supabaseService.client
          .from('tasks')
          .select('id, title, description, status, priority, due_date, created_at, project:project_id(title)')
          .eq('assigned_technician', currentUser.id)
          .eq('is_deleted', false)
          .order('created_at', ascending: false);

      final allTasks = (tasksRes as List)
          .map((e) => TechnicianDashboardTask.fromJson(e))
          .toList();

      final now = DateTime.now();
      final overdue = allTasks.where((t) =>
        t.dueDate != null && t.status != 'completed' && now.isAfter(t.dueDate!)).length;

      final pendingTasks = allTasks
          .where((t) => t.status == 'pending' || t.status == 'in_progress')
          .take(5)
          .toList();

      state = state.copyWith(
        stats: TechnicianDashboardStats(
          totalTasks: allTasks.length,
          pendingTasks: allTasks.where((t) => t.status == 'pending').length,
          inProgressTasks: allTasks.where((t) => t.status == 'in_progress').length,
          completedTasks: allTasks.where((t) => t.status == 'completed').length,
          overdueTasks: overdue,
        ),
        pendingTasks: pendingTasks,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

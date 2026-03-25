import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:engineering_platform/core/services/supabase_service.dart';
import 'engineer_tasks_state.dart';

final engineerTasksProvider =
    NotifierProvider.autoDispose<EngineerTasksNotifier, EngineerTasksState>(
  EngineerTasksNotifier.new,
);

class EngineerTasksNotifier extends AutoDisposeNotifier<EngineerTasksState> {
  @override
  EngineerTasksState build() {
    Future.microtask(() => fetchTasks());
    return const EngineerTasksState(isLoading: true);
  }

  Future<void> fetchTasks() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final currentUser = supabaseService.client.auth.currentUser;
      if (currentUser == null) throw Exception('غير مسجل الدخول');

      final response = await supabaseService.client
          .from('tasks')
          .select('id, project_id, title, description, status, priority, due_date, completed_at, created_at')
          .eq('assigned_to', currentUser.id)
          .eq('is_deleted', false)
          .order('created_at', ascending: false);

      final tasks = (response as List)
          .map((e) => EngineerTaskModel.fromJson(e))
          .toList();

      state = state.copyWith(tasks: tasks, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setFilter(String filter) {
    state = state.copyWith(filterStatus: filter);
  }

  Future<void> updateTaskStatus(int taskId, String newStatus) async {
    try {
      final completedAt = newStatus == 'completed' ? DateTime.now().toIso8601String() : null;

      await supabaseService.client
          .from('tasks')
          .update({'status': newStatus, 'completed_at': completedAt})
          .eq('id', taskId);

      final updated = state.tasks.map((t) {
        if (t.id == taskId) {
          return EngineerTaskModel(
            id: t.id,
            projectId: t.projectId,
            title: t.title,
            description: t.description,
            status: newStatus,
            priority: t.priority,
            dueDate: t.dueDate,
            completedAt: newStatus == 'completed' ? DateTime.now() : null,
            createdAt: t.createdAt,
          );
        }
        return t;
      }).toList();

      state = state.copyWith(tasks: updated);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}

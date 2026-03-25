import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:engineering_platform/core/services/supabase_service.dart';
import 'engineer_dashboard_state.dart';

final engineerDashboardProvider =
    NotifierProvider.autoDispose<EngineerDashboardNotifier, EngineerDashboardState>(
  EngineerDashboardNotifier.new,
);

class EngineerDashboardNotifier extends AutoDisposeNotifier<EngineerDashboardState> {
  @override
  EngineerDashboardState build() {
    Future.microtask(() => fetchDashboard());
    return const EngineerDashboardState(isLoading: true);
  }

  Future<void> fetchDashboard() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final currentUser = supabaseService.client.auth.currentUser;
      if (currentUser == null) throw Exception('غير مسجل الدخول');

      // المشاريع المعينة
      final assignmentsRes = await supabaseService.client
          .from('project_assignments')
          .select('project_id')
          .eq('engineer_id', currentUser.id);

      final projectIds = (assignmentsRes as List).map((e) => e['project_id'] as int).toList();

      List<EngineerDashboardProject> activeProjects = [];
      int totalProjects = 0;
      int activeProjectsCount = 0;

      if (projectIds.isNotEmpty) {
        final projectsRes = await supabaseService.client
            .from('projects')
            .select('id, title, description, status, created_at, client:users!projects_client_id_fkey(name)')
            .inFilter('id', projectIds)
            .eq('is_deleted', false)
            .order('created_at', ascending: false);

        final allProjects = (projectsRes as List)
            .map((e) => EngineerDashboardProject.fromJson(e))
            .toList();

        totalProjects = allProjects.length;
        activeProjectsCount = allProjects.where((p) =>
          p.status == 'active' || p.status == 'under_review').length;

        activeProjects = allProjects
            .where((p) => p.status == 'active' || p.status == 'under_review')
            .take(3)
            .toList();
      }

      // المهام
      final tasksRes = await supabaseService.client
          .from('tasks')
          .select('id, title, status, priority, due_date')
          .eq('assigned_to', currentUser.id)
          .eq('is_deleted', false)
          .order('created_at', ascending: false);

      final allTasks = (tasksRes as List)
          .map((e) => EngineerDashboardTask.fromJson(e))
          .toList();

      final recentTasks = allTasks
          .where((t) => t.status != 'completed')
          .take(5)
          .toList();

      // التقارير
      final reportsRes = await supabaseService.client
          .from('reports')
          .select('id')
          .eq('submitted_by', currentUser.id)
          .eq('is_deleted', false);

      // المشاكل المفتوحة
      final issuesRes = await supabaseService.client
          .from('reports')
          .select('id')
          .eq('submitted_by', currentUser.id)
          .eq('report_type', 'issue')
          .eq('status', 'submitted')
          .eq('is_deleted', false);

      state = state.copyWith(
        stats: EngineerDashboardStats(
          totalProjects: totalProjects,
          activeProjects: activeProjectsCount,
          totalTasks: allTasks.length,
          pendingTasks: allTasks.where((t) => t.status == 'pending' || t.status == 'in_progress').length,
          completedTasks: allTasks.where((t) => t.status == 'completed').length,
          totalReports: (reportsRes as List).length,
          openIssues: (issuesRes as List).length,
        ),
        activeProjects: activeProjects,
        recentTasks: recentTasks,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

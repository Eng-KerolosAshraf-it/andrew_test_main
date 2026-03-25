import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:engineering_platform/core/services/supabase_service.dart';
import 'client_dashboard_state.dart';

final clientDashboardProvider =
    NotifierProvider.autoDispose<ClientDashboardNotifier, ClientDashboardState>(
  ClientDashboardNotifier.new,
);

class ClientDashboardNotifier extends AutoDisposeNotifier<ClientDashboardState> {
  @override
  ClientDashboardState build() {
    Future.microtask(() => fetchDashboard());
    return const ClientDashboardState(isLoading: true);
  }

  Future<void> fetchDashboard() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final currentUser = supabaseService.client.auth.currentUser;
      if (currentUser == null) throw Exception('غير مسجل الدخول');

      final projectsRes = await supabaseService.client
          .from('projects')
          .select('id, title, description, status, created_at')
          .eq('client_id', currentUser.id)
          .eq('is_deleted', false)
          .order('created_at', ascending: false);

      final allProjects = (projectsRes as List)
          .map((e) => ClientDashboardActiveProject.fromJson(e))
          .toList();

      final activeProjects = allProjects
          .where((p) => p.status == 'active' || p.status == 'under_review' || p.status == 'waiting_client_approval')
          .take(3)
          .toList();

      final stats = ClientDashboardStats(
        totalProjects: allProjects.length,
        activeProjects: allProjects.where((p) => p.status == 'active').length,
        completedProjects: allProjects.where((p) => p.status == 'completed').length,
      );

      List<ClientDashboardRecentReport> recentReports = [];
      if (allProjects.isNotEmpty) {
        final projectIds = allProjects.map((p) => p.id).toList();
        final reportsRes = await supabaseService.client
            .from('reports')
            .select('*, submitted_by_user:submitted_by(name), project:project_id(title)')
            .inFilter('project_id', projectIds)
            .eq('is_deleted', false)
            .order('created_at', ascending: false)
            .limit(5);

        recentReports = (reportsRes as List)
            .map((e) => ClientDashboardRecentReport.fromJson(e))
            .toList();
      }

      state = state.copyWith(
        stats: stats,
        activeProjects: activeProjects,
        recentReports: recentReports,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

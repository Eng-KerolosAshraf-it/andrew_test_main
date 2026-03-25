import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:engineering_platform/core/services/supabase_service.dart';
import 'engineer_projects_state.dart';

final engineerProjectsProvider =
    NotifierProvider.autoDispose<EngineerProjectsNotifier, EngineerProjectsState>(
  EngineerProjectsNotifier.new,
);

class EngineerProjectsNotifier extends AutoDisposeNotifier<EngineerProjectsState> {
  @override
  EngineerProjectsState build() {
    Future.microtask(() => fetchProjects());
    return const EngineerProjectsState(isLoading: true);
  }

  Future<void> fetchProjects() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final currentUser = supabaseService.client.auth.currentUser;
      if (currentUser == null) throw Exception('غير مسجل الدخول');

      // نجيب المشاريع المعينة للمهندس عن طريق project_assignments
      final assignmentsRes = await supabaseService.client
          .from('project_assignments')
          .select('project_id')
          .eq('engineer_id', currentUser.id);

      final projectIds = (assignmentsRes as List)
          .map((e) => e['project_id'] as int)
          .toList();

      if (projectIds.isEmpty) {
        state = state.copyWith(projects: [], isLoading: false);
        return;
      }

      final projectsRes = await supabaseService.client
          .from('projects')
          .select('''
            id, title, description, status, created_at,
            budget, actual_cost, start_date, end_date,
            drawing_url, drawing_type,
            client:users!projects_client_id_fkey(name)
          ''')
          .inFilter('id', projectIds)
          .eq('is_deleted', false)
          .order('created_at', ascending: false);

      final projects = (projectsRes as List)
          .map((e) => EngineerProjectModel.fromJson(e))
          .toList();

      state = state.copyWith(projects: projects, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setFilter(String filter) {
    state = state.copyWith(filterStatus: filter);
  }
}

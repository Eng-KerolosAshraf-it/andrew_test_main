import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:engineering_platform/core/services/supabase_service.dart';
import 'admin_projects_state.dart';

final adminProjectsProvider =
    NotifierProvider<AdminProjectsNotifier, AdminProjectsState>(
  AdminProjectsNotifier.new,
);

class AdminProjectsNotifier extends Notifier<AdminProjectsState> {
  @override
  AdminProjectsState build() {
    Future.microtask(() => fetchProjects());
    return const AdminProjectsState(isLoading: true);
  }

  Future<void> fetchProjects() async {
    state = const AdminProjectsState(isLoading: true);
    try {
      final response = await supabaseService.client
          .from('projects')
          .select('''
            id,
            title,
            description,
            status,
            client_id,
            created_at,
            client:users!projects_client_id_fkey(name),
            project_assignments(
              engineer_id,
              users!project_assignments_engineer_id_fkey(name)
            )
          ''')
          .eq('is_deleted', false)
          .order('created_at', ascending: false);

      final projects = (response as List)
          .map((json) => AdminProjectModel.fromJson(
                Map<String, dynamic>.from(json),
              ))
          .toList();

      state = AdminProjectsState(isLoading: false, projects: projects);
    } catch (e) {
      state = AdminProjectsState(isLoading: false, errorMessage: e.toString());
    }
  }

  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> updateProjectStatus(int projectId, String newStatus) async {
    state = state.copyWith(isActionLoading: true, errorMessage: null);
    try {
      final currentUser = supabaseService.client.auth.currentUser;

      await supabaseService.client
          .from('projects')
          .update({
            'status': newStatus,
            'updated_by': currentUser?.id,
          })
          .eq('id', projectId);

      final updated = state.projects.map((p) {
        if (p.id == projectId) {
          return AdminProjectModel(
            id: p.id,
            title: p.title,
            description: p.description,
            status: newStatus,
            clientId: p.clientId,
            clientName: p.clientName,
            engineerName: p.engineerName,
            engineerId: p.engineerId,
            createdAt: p.createdAt,
          );
        }
        return p;
      }).toList();

      state = state.copyWith(isActionLoading: false, projects: updated);
    } catch (e) {
      state = state.copyWith(isActionLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> assignEngineer(int projectId, String engineerId) async {
    state = state.copyWith(isActionLoading: true, errorMessage: null);
    try {
      await supabaseService.client
          .from('project_assignments')
          .delete()
          .eq('project_id', projectId);

      await supabaseService.client
          .from('project_assignments')
          .insert({
            'project_id': projectId,
            'engineer_id': engineerId,
          });

      state = state.copyWith(isActionLoading: false);
      await fetchProjects();
    } catch (e) {
      state = state.copyWith(isActionLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> deleteProject(int projectId) async {
    state = state.copyWith(isActionLoading: true, errorMessage: null);
    try {
      await supabaseService.client
          .from('projects')
          .update({'is_deleted': true})
          .eq('id', projectId);

      final updated = state.projects.where((p) => p.id != projectId).toList();
      state = state.copyWith(isActionLoading: false, projects: updated);
    } catch (e) {
      state = state.copyWith(isActionLoading: false, errorMessage: e.toString());
    }
  }
}

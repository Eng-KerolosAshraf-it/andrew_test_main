import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:engineering_platform/core/services/supabase_service.dart';
import 'project_details_state.dart';

final projectDetailsProvider =
    NotifierProviderFamily<ProjectDetailsNotifier, ProjectDetailsState, int>(
  ProjectDetailsNotifier.new,
);

class ProjectDetailsNotifier extends FamilyNotifier<ProjectDetailsState, int> {
  @override
  ProjectDetailsState build(int projectId) {
    Future.microtask(() => fetchProject(projectId));
    return const ProjectDetailsState(isLoading: true);
  }

  Future<void> fetchProject(int projectId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await supabaseService.client
          .from('projects')
          .select(
            'id, title, description, status, start_date, end_date, budget, actual_cost, drawing_url, drawing_type, created_at',
          )
          .eq('id', projectId)
          .eq('is_deleted', false)
          .single();

      state = state.copyWith(
        project: ProjectDetailsModel.fromJson(response),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

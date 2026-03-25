import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:engineering_platform/core/services/supabase_service.dart';
import 'client_projects_state.dart';

final clientProjectsProvider =
    NotifierProvider.autoDispose<ClientProjectsNotifier, ClientProjectsState>(
  ClientProjectsNotifier.new,
);

class ClientProjectsNotifier extends AutoDisposeNotifier<ClientProjectsState> {
  @override
  ClientProjectsState build() {
    Future.microtask(() => fetchProjects());
    return const ClientProjectsState(isLoading: true);
  }

  Future<void> fetchProjects() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final currentUser = supabaseService.client.auth.currentUser;
      if (currentUser == null) throw Exception('غير مسجل الدخول');

      final response = await supabaseService.client
          .from('projects')
          .select('id, title, description, status, created_at')
          .eq('client_id', currentUser.id)
          .eq('is_deleted', false)
          .order('created_at', ascending: false);

      final projects = (response as List)
          .map((e) => ClientProjectModel.fromJson(e))
          .toList();

      state = state.copyWith(projects: projects, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

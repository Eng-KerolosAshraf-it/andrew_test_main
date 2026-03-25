import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:engineering_platform/core/services/supabase_service.dart';
import 'client_reports_state.dart';

final clientReportsProvider =
    NotifierProvider.autoDispose<ClientReportsNotifier, ClientReportsState>(
  ClientReportsNotifier.new,
);

class ClientReportsNotifier extends AutoDisposeNotifier<ClientReportsState> {
  @override
  ClientReportsState build() {
    Future.microtask(() => fetchReports());
    return const ClientReportsState(isLoading: true);
  }

  Future<void> fetchReports() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final currentUser = supabaseService.client.auth.currentUser;
      if (currentUser == null) throw Exception('غير مسجل الدخول');

      final projectsRes = await supabaseService.client
          .from('projects')
          .select('id')
          .eq('client_id', currentUser.id)
          .eq('is_deleted', false);

      final projectIds = (projectsRes as List).map((e) => e['id'] as int).toList();

      if (projectIds.isEmpty) {
        state = state.copyWith(reports: [], isLoading: false);
        return;
      }

      final reportsRes = await supabaseService.client
          .from('reports')
          .select('*, submitted_by_user:submitted_by(name)')
          .inFilter('project_id', projectIds)
          .eq('is_deleted', false)
          .order('created_at', ascending: false);

      final reports = (reportsRes as List)
          .map((e) => ClientReportModel.fromJson(e))
          .toList();

      state = state.copyWith(reports: reports, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void goToPage(int page) => state = state.copyWith(currentPage: page);
}

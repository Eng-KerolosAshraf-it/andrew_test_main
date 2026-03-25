import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:engineering_platform/core/services/supabase_service.dart';
import 'engineer_issues_state.dart';

final engineerIssuesProvider =
    NotifierProvider.autoDispose<EngineerIssuesNotifier, EngineerIssuesState>(
  EngineerIssuesNotifier.new,
);

class EngineerIssuesNotifier extends AutoDisposeNotifier<EngineerIssuesState> {
  @override
  EngineerIssuesState build() {
    Future.microtask(() => fetchData());
    return const EngineerIssuesState(isLoading: true);
  }

  Future<void> fetchData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final currentUser = supabaseService.client.auth.currentUser;
      if (currentUser == null) throw Exception('غير مسجل الدخول');

      // المشاريع المعينة
      final assignmentsRes = await supabaseService.client
          .from('project_assignments')
          .select('project_id, projects(id, title)')
          .eq('engineer_id', currentUser.id);

      final assignedProjects = (assignmentsRes as List).map((e) {
        final project = e['projects'];
        return {'id': project['id'] as int, 'title': project['title'] as String};
      }).toList();

      // المشاكل المرسلة
      final issuesRes = await supabaseService.client
          .from('reports')
          .select('*, project:project_id(title)')
          .eq('submitted_by', currentUser.id)
          .eq('report_type', 'issue')
          .eq('is_deleted', false)
          .order('created_at', ascending: false);

      final issues = (issuesRes as List)
          .map((e) => EngineerIssueModel.fromJson(e))
          .toList();

      final defaultProjectId = assignedProjects.isNotEmpty
          ? assignedProjects.first['id'] as int
          : null;

      state = state.copyWith(
        issues: issues,
        assignedProjects: assignedProjects,
        isLoading: false,
        selectedProjectId: defaultProjectId,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void toggleForm() => state = state.copyWith(showForm: !state.showForm, isSuccess: false, errorMessage: null);

  void updateDescription(String val) => state = state.copyWith(description: val);

  void updateSelectedProject(int id) => state = state.copyWith(selectedProjectId: id);

  Future<void> submitIssue() async {
    if (state.description.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'يرجى وصف المشكلة');
      return;
    }
    if (state.selectedProjectId == null) {
      state = state.copyWith(errorMessage: 'يرجى اختيار المشروع');
      return;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final currentUser = supabaseService.client.auth.currentUser;
      if (currentUser == null) throw Exception('غير مسجل الدخول');

      await supabaseService.client.from('reports').insert({
        'project_id': state.selectedProjectId,
        'submitted_by': currentUser.id,
        'report_type': 'issue',
        'description': state.description.trim(),
        'status': 'submitted',
      });

      state = state.copyWith(
        isSubmitting: false,
        isSuccess: true,
        description: '',
        showForm: false,
      );

      await fetchData();
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
    }
  }
}

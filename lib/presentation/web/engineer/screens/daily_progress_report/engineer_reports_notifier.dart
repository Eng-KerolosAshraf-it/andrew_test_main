import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:engineering_platform/core/services/supabase_service.dart';
import 'engineer_reports_state.dart';

final dailyProgressReportProvider =
    NotifierProvider.autoDispose<DailyProgressReportNotifier, DailyProgressReportState>(
  DailyProgressReportNotifier.new,
);

class DailyProgressReportNotifier extends AutoDisposeNotifier<DailyProgressReportState> {
  @override
  DailyProgressReportState build() {
    Future.microtask(() => fetchData());
    return const DailyProgressReportState(isLoading: true);
  }

  Future<void> fetchData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final currentUser = supabaseService.client.auth.currentUser;
      if (currentUser == null) throw Exception('غير مسجل الدخول');

      // نجيب المشاريع المعينة للمهندس
      final assignmentsRes = await supabaseService.client
          .from('project_assignments')
          .select('project_id, projects(id, title)')
          .eq('engineer_id', currentUser.id);

      final assignedProjects = (assignmentsRes as List).map((e) {
        final project = e['projects'];
        return {'id': project['id'] as int, 'title': project['title'] as String};
      }).toList();

      // نجيب آخر التقارير
      final reportsRes = await supabaseService.client
          .from('reports')
          .select('*, project:project_id(title)')
          .eq('submitted_by', currentUser.id)
          .eq('is_deleted', false)
          .order('created_at', ascending: false)
          .limit(10);

      final reports = (reportsRes as List)
          .map((e) => EngineerReportModel.fromJson(e))
          .toList();

      // نحدد أول مشروع افتراضي
      final defaultProjectId = assignedProjects.isNotEmpty
          ? assignedProjects.first['id'] as int
          : null;

      state = state.copyWith(
        recentReports: reports,
        assignedProjects: assignedProjects,
        isLoading: false,
        form: state.form.copyWith(selectedProjectId: defaultProjectId),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void updateDescription(String value) {
    state = state.copyWith(form: state.form.copyWith(description: value));
  }

  void updateReportType(String value) {
    state = state.copyWith(form: state.form.copyWith(reportType: value));
  }

  void updateSelectedProject(int projectId) {
    state = state.copyWith(form: state.form.copyWith(selectedProjectId: projectId));
  }

  Future<void> submitReport() async {
    if (state.form.description.trim().isEmpty) {
      state = state.copyWith(form: state.form.copyWith(errorMessage: 'يرجى كتابة تفاصيل التقرير'));
      return;
    }
    if (state.form.selectedProjectId == null) {
      state = state.copyWith(form: state.form.copyWith(errorMessage: 'يرجى اختيار المشروع'));
      return;
    }

    state = state.copyWith(form: state.form.copyWith(isSubmitting: true, errorMessage: null));
    try {
      final currentUser = supabaseService.client.auth.currentUser;
      if (currentUser == null) throw Exception('غير مسجل الدخول');

      await supabaseService.client.from('reports').insert({
        'project_id': state.form.selectedProjectId,
        'submitted_by': currentUser.id,
        'report_type': state.form.reportType,
        'description': state.form.description.trim(),
        'status': 'submitted',
      });

      state = state.copyWith(
        form: const EngineerReportFormState(isSuccess: true),
      );

      // نرجع نجيب التقارير بعد الإرسال
      await fetchData();
    } catch (e) {
      state = state.copyWith(form: state.form.copyWith(isSubmitting: false, errorMessage: e.toString()));
    }
  }
}

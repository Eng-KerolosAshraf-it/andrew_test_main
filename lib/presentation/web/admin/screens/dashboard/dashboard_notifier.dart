import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:engineering_platform/core/services/supabase_service.dart';
import 'dashboard_state.dart';

// ─────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────
final dashboardProvider =
    NotifierProvider<DashboardNotifier, DashboardState>(
  DashboardNotifier.new,
);

// ─────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────
class DashboardNotifier extends Notifier<DashboardState> {
  @override
  DashboardState build() {
    Future.microtask(() => fetchStats());
    return const DashboardState(isLoading: true);
  }

  Future<void> fetchStats() async {
    state = const DashboardState(isLoading: true);
    try {
      final results = await Future.wait([
        // إجمالي المشاريع
        supabaseService.client
            .from('projects')
            .select('id')
            .eq('is_deleted', false),

        // عدد المهندسين
        supabaseService.client
            .from('users')
            .select('id')
            .eq('role', 'engineer')
            .eq('is_active', true)
            .eq('is_deleted', false),

        // عدد الفنيين
        supabaseService.client
            .from('users')
            .select('id')
            .eq('role', 'technician')
            .eq('is_active', true)
            .eq('is_deleted', false),

        // عدد العملاء
        supabaseService.client
            .from('users')
            .select('id')
            .eq('role', 'client')
            .eq('is_active', true)
            .eq('is_deleted', false),

        // الطلبات الجديدة
        supabaseService.client
            .from('project_service_forms')
            .select('id')
            .eq('is_submitted', true)
            .filter('project_id', 'is', null),
      ]);

      state = DashboardState(
        isLoading: false,
        stats: DashboardStats(
          totalProjects:    (results[0] as List).length,
          totalEngineers:   (results[1] as List).length,
          totalTechnicians: (results[2] as List).length,
          totalClients:     (results[3] as List).length,
          newRequests:      (results[4] as List).length,
        ),
      );
    } catch (e) {
      state = DashboardState(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
}

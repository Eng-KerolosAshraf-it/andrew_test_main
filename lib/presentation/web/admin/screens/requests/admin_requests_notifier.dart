import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:engineering_platform/core/services/supabase_service.dart';
import 'admin_requests_state.dart';

final adminRequestsProvider =
    NotifierProvider<AdminRequestsNotifier, AdminRequestsState>(
  AdminRequestsNotifier.new,
);

class AdminRequestsNotifier extends Notifier<AdminRequestsState> {
  @override
  AdminRequestsState build() {
    Future.microtask(() => fetchRequests());
    return const AdminRequestsState(isLoading: true);
  }

  Future<void> fetchRequests() async {
    state = const AdminRequestsState(isLoading: true);
    try {
      final response = await supabaseService.client
          .from('project_service_forms')
          .select()
          .eq('is_submitted', true)
          .filter('project_id', 'is', null)
          .order('created_at', ascending: false);

      final requests = (response as List)
          .map((json) => ServiceFormRequest.fromJson(
                Map<String, dynamic>.from(json),
              ))
          .toList();

      state = AdminRequestsState(isLoading: false, requests: requests);
    } catch (e) {
      state = AdminRequestsState(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> acceptRequest(ServiceFormRequest request) async {
    state = state.copyWith(isActionLoading: true, errorMessage: null);
    try {
      final currentUser = supabaseService.client.auth.currentUser;
      if (currentUser == null) throw Exception('غير مسجل الدخول');

      final projectResponse = await supabaseService.client
          .from('projects')
          .insert({
            'title': request.formTypeAr,
            'description': 'طلب رقم ${request.id} - ${request.clientName}',
            'status': 'under_review',
            'client_id': request.clientId,
            'created_by': currentUser.id,
          })
          .select()
          .single();

      final projectId = projectResponse['id'] as int;

      await supabaseService.client
          .from('project_service_forms')
          .update({'project_id': projectId})
          .eq('id', request.id);

      if (request.clientId != null) {
        await supabaseService.client.from('notifications').insert({
          'user_id': request.clientId,
          'type': 'request_accepted',
          'message': 'تم قبول طلبك وتحويله إلى مشروع جاري المراجعة',
          'status': 'unread',
        });
      }

      final updated = state.requests.where((r) => r.id != request.id).toList();
      state = state.copyWith(isActionLoading: false, requests: updated);
    } catch (e) {
      state = state.copyWith(isActionLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> rejectRequest(ServiceFormRequest request) async {
    state = state.copyWith(isActionLoading: true, errorMessage: null);
    try {
      await supabaseService.client
          .from('project_service_forms')
          .update({'is_submitted': false})
          .eq('id', request.id);

      if (request.clientId != null) {
        await supabaseService.client.from('notifications').insert({
          'user_id': request.clientId,
          'type': 'request_rejected',
          'message': 'نأسف، تم رفض طلبك. يمكنك التواصل معنا لمزيد من التفاصيل',
          'status': 'unread',
        });
      }

      final updated = state.requests.where((r) => r.id != request.id).toList();
      state = state.copyWith(isActionLoading: false, requests: updated);
    } catch (e) {
      state = state.copyWith(isActionLoading: false, errorMessage: e.toString());
    }
  }
}

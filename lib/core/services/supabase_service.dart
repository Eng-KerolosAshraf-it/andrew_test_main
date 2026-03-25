import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/service_request.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';

// خدمة Supabase: المسؤولة عن التواصل مع قاعدة البيانات وخدمات المصادقة (Auth)
class SupabaseService {
  // الحصول على كائن العميل (Client) للتواصل مع API الخاص بـ Supabase
  SupabaseClient get _client => Supabase.instance.client;

  SupabaseClient get client => _client;
  // --- عمليات جدول الطلبات (service_requests) ---

  // إرسال طلب خدمة جديد إلى قاعدة البيانات
  Future<void> submitServiceRequest(ServiceRequest request) async {
    try {
      await _client.from('service_requests').insert(request.toJson());
    } catch (e) {
      throw Exception('Failed to submit request: $e');
    }
  }

  // جلب كافة الطلبات الخاصة بمستخدم معين
  Future<List<ServiceRequest>> getUserRequests(String userId) async {
    try {
      final response = await _client
          .from('service_requests')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false); // ترتيب من الأحدث للأقدم

      return (response as List)
          .map((data) => ServiceRequest.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch requests: $e');
    }
  }

  // --- عمليات المصادقة (Authentication) ---

  // إنشاء حساب جديد (Email & Password)
Future<AuthResponse> signUp({
  required String email,
  required String password,
  required String fullName,
  String role = 'client', // الدور الافتراضي
}) async {
  try {
    // تسجيل الحساب في Supabase Auth مع الدور
    final AuthResponse response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'role': role, // ✅ إضافة الدور هنا
      },
    );

    final user = response.user;
    if (user != null) {
      // حفظ بيانات المستخدم في جدولنا المخصص
      await _client.from('users').insert({
        'id': user.id,
        'name': fullName,
        'email': email,
        'role': role, // 🔥 مهم جدًا
        
      });
      debugPrint('User registered with role: $role');
    }

    return response;
  } catch (e) {
    debugPrint('Signup Error: $e');
    rethrow;
  }
}

  // تسجيل الدخول
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // الحصول على المستخدم الحالي (إذا كان مسجلاً للدخول)
  User? get currentUser => _client.auth.currentUser;
}

// نسخة عالمية من الخدمة للاستخدام في جميع أنحاء التطبيق
final supabaseService = SupabaseService();

// مستودع المصادقة العالمي
final AuthRepository authRepository = AuthRepositoryImpl(supabaseService);

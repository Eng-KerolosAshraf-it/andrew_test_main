import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import 'dart:convert';
import '../services/supabase_service.dart';

class UserState {
  final ValueNotifier<Uint8List?> profileImageBytes = ValueNotifier<Uint8List?>(null);
  final ValueNotifier<String?> userName = ValueNotifier<String?>(null);
  final ValueNotifier<String?> userEmail = ValueNotifier<String?>(null);
  final ValueNotifier<bool> isLoggedIn = ValueNotifier<bool>(false);
  final ValueNotifier<String?> userRole = ValueNotifier<String?>(null);

  // ── مسح البيانات المحلية بس (بدون signOut) ──
  Future<void> _clearLocalData() async {
    userName.value = null;
    userEmail.value = null;
    profileImageBytes.value = null;
    userRole.value = null;
    isLoggedIn.value = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('profile_image');
    await prefs.remove('user_role');
    await prefs.remove('is_logged_in');
  }

  // ── تحميل بيانات المستخدم عند بدء التطبيق ──
  Future<void> loadUser() async {
    final session = supabaseService.client.auth.currentSession;

    // لو مفيش session → مسح البيانات المحلية بس بدون signOut
    if (session == null) {
      await _clearLocalData();
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    // قراءة الدور والتحقق من صحته
    final role = prefs.getString('user_role');
    if (role == null || !['client', 'engineer', 'admin', 'technician'].contains(role)) {
      await _clearLocalData();
      return;
    }

    // تحميل باقي البيانات
    userName.value = prefs.getString('user_name');
    userEmail.value = prefs.getString('user_email');
    userRole.value = role;
    isLoggedIn.value = prefs.getBool('is_logged_in') ?? false;

    final imageBase64 = prefs.getString('profile_image');
    if (imageBase64 != null) {
      profileImageBytes.value = base64Decode(imageBase64);
    }
  }

  // ── تحديث بيانات المستخدم ───────────────────
  Future<void> setUser({
    String? name,
    String? email,
    String? password,
    Uint8List? imageBytes,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (name != null) {
      userName.value = name;
      await prefs.setString('user_name', name);
    }

    if (email != null) {
      userEmail.value = email;
      await prefs.setString('user_email', email);
    }

    if (imageBytes != null) {
      profileImageBytes.value = imageBytes;
      await prefs.setString('profile_image', base64Encode(imageBytes));
    }
  }

  Future<void> login(String email, String password) async {
    // يتم التعامل مع تسجيل الدخول عبر SupabaseService
  }

  // ── تحديث البيانات من Supabase بعد تسجيل الدخول ──
  Future<void> updateFromSupabase(User user) async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final response = await supabaseService.client
          .from('users')
          .select('name, role')
          .eq('id', user.id)
          .single();

      final name = response['name'] as String?;
      final role = response['role'] as String?;

      if (role == null || role.isEmpty) {
        await _clearLocalData();
        return;
      }

      userName.value = name;
      userEmail.value = user.email;
      userRole.value = role;
      isLoggedIn.value = true;

      await prefs.setString('user_name', name ?? '');
      await prefs.setString('user_email', user.email ?? '');
      await prefs.setString('user_role', role);
      await prefs.setBool('is_logged_in', true);
    } catch (e) {
      await _clearLocalData();
    }
  }

  // ── تسجيل الخروج الكامل (signOut + مسح البيانات) ──
  Future<void> logout() async {
    await supabaseService.signOut();
    await _clearLocalData();
  }
}

final userState = UserState();

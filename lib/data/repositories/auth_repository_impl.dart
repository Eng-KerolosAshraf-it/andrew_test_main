import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabaseClient;

  AuthRepositoryImpl(this._supabaseClient);

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('User not found');
      }

      return await _getUserProfile(response.user!);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      final user = response.user;
      if (user != null) {
        await _supabaseClient.from('users').insert({
          'id': user.id,
          'name': fullName,
          'email': email,
          'role': 'client', // Default role
        });
      }
    } catch (e) {
      throw Exception('Signup failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return null;
    return await _getUserProfile(user);
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _supabaseClient.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Failed to send reset link: $e');
    }
  }

  Future<AppUser> _getUserProfile(User user) async {
    try {
      final userData = await _supabaseClient
          .from('users')
          .select()
          .eq('id', user.id)
          .single();

      return AppUser.fromMap(
        userData,
        email: user.email ?? '',
        id: user.id,
      );
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }
}

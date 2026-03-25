import '../entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser> signIn({
    required String email,
    required String password,
  });

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  });

  Future<void> signOut();

  Future<AppUser?> getCurrentUser();
  
  Future<void> resetPassword(String email);
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../data/repositories/auth_repository_impl.dart';
import '../../../domain/failures/auth_failure.dart';
import 'auth_state.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthRepositoryImpl(client);
});

// ── PERSISTENT IDENTITY PROVIDER ───────────────────────────
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Check auth status on initialization
    Future.microtask(() => checkAuth());
    return const AuthInitial();
  }

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  Future<void> checkAuth() async {
    state = const AuthLoading();
    try {
      final user = await _repository.getCurrentUser();
      if (user != null) {
        state = Authenticated(user);
      } else {
        state = const Unauthenticated();
      }
    } catch (e) {
      state = AuthError(AuthFailure.fromException(e));
    }
  }

  Future<void> login(String email, String password) async {
    state = const AuthLoading();
    try {
      final user = await _repository.signIn(email: email, password: password);
      state = Authenticated(user);
    } catch (e) {
      state = AuthError(AuthFailure.fromException(e));
    }
  }

  Future<void> logout() async {
    await _repository.signOut();
    state = const Unauthenticated();
  }
}

// ── TRANSIENT ACTION PROVIDER ──────────────────────────────
// Used for Signup, Reset Password, etc. to avoid polluting global identity
enum AuthActionStatus { initial, loading, success, error }

class AuthActionState {
  final AuthActionStatus status;
  final AuthFailure? failure;
  const AuthActionState({this.status = AuthActionStatus.initial, this.failure});
}

final authActionProvider = StateNotifierProvider<AuthActionNotifier, AuthActionState>((ref) {
  return AuthActionNotifier(ref.read(authRepositoryProvider));
});

class AuthActionNotifier extends StateNotifier<AuthActionState> {
  final AuthRepository _repository;
  AuthActionNotifier(this._repository) : super(const AuthActionState());

  Future<void> signup({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = const AuthActionState(status: AuthActionStatus.loading);
    try {
      await _repository.signUp(email: email, password: password, fullName: fullName);
      state = const AuthActionState(status: AuthActionStatus.success);
    } catch (e) {
      state = AuthActionState(status: AuthActionStatus.error, failure: AuthFailure.fromException(e));
    }
  }

  Future<void> resetPassword(String email) async {
    state = const AuthActionState(status: AuthActionStatus.loading);
    try {
      await _repository.resetPassword(email);
      state = const AuthActionState(status: AuthActionStatus.success);
    } catch (e) {
      state = AuthActionState(status: AuthActionStatus.error, failure: AuthFailure.fromException(e));
    }
  }

  void reset() => state = const AuthActionState();
}

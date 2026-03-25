import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_notifier.dart';
import '../providers/auth_state.dart';

mixin AuthScreenMixin {
  void listenToAuthState(BuildContext context, WidgetRef ref, void Function(Authenticated) onAuthenticated) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next is Authenticated) {
        onAuthenticated(next);
      } else if (next is AuthError) {
        _showErrorSnackBar(context, next.failure.message);
      }
    });
  }

  void listenToAuthActionState(BuildContext context, WidgetRef ref, {required void Function() onSuccess}) {
    ref.listen<AuthActionState>(authActionProvider, (previous, next) {
      if (next.status == AuthActionStatus.success) {
        onSuccess();
      } else if (next.status == AuthActionStatus.error && next.failure != null) {
        _showErrorSnackBar(context, next.failure!.message);
      }
    });
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

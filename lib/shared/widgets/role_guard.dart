import 'package:flutter/material.dart';
import '../../core/state/user_state.dart';
import '../../presentation/web/auth/screens/login_page.dart';

class RoleGuard extends StatelessWidget {
  final Widget child;
  final List<String> allowedRoles;

  const RoleGuard({
    required this.child,
    required this.allowedRoles,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: userState.isLoggedIn,
      builder: (context, loggedIn, _) {
        if (!loggedIn) {
          return const LoginPage();
        }

        return ValueListenableBuilder<String?>(
          valueListenable: userState.userRole,
          builder: (context, role, _) {
            if (role == null || !allowedRoles.contains(role)) {
              return const Scaffold(
                body: Center(
                  child: Text(
                    'Unauthorized',
                    style: TextStyle(fontSize: 20, color: Colors.red),
                  ),
                ),
              );
            }

            return child;
          },
        );
      },
    );
  }
}
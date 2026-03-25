sealed class AuthFailure {
  final String message;
  const AuthFailure(this.message);

  factory AuthFailure.fromException(Object e) {
    final errorStr = e.toString().toLowerCase();
    if (errorStr.contains('invalid login credentials') || errorStr.contains('invalid_credentials')) {
      return const InvalidCredentials();
    } else if (errorStr.contains('email already in use') || errorStr.contains('user_already_exists')) {
      return const EmailAlreadyInUse();
    } else if (errorStr.contains('network') || errorStr.contains('connection')) {
      return const NetworkFailure();
    } else if (errorStr.contains('too many requests')) {
      return const TooManyRequests();
    }
    return UnknownAuthFailure(e.toString());
  }
}

class InvalidCredentials extends AuthFailure {
  const InvalidCredentials() : super('Invalid email or password');
}

class EmailAlreadyInUse extends AuthFailure {
  const EmailAlreadyInUse() : super('An account with this email already exists');
}

class NetworkFailure extends AuthFailure {
  const NetworkFailure() : super('Network connection error. Please try again.');
}

class TooManyRequests extends AuthFailure {
  const TooManyRequests() : super('Too many attempts. Please try again later.');
}

class UnknownAuthFailure extends AuthFailure {
  const UnknownAuthFailure(super.message);
}

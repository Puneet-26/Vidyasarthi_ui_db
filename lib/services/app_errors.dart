library app_errors;

/// Centralized error message abstraction for the app.
/// All user-facing error strings live here — never show raw exceptions to users.

enum AuthErrorType {
  noInternet,
  emailNotFound,
  wrongPassword,
  invalidCredentials,
  serverError,
  unknown,
}

class AppErrors {
  // ── Auth errors ────────────────────────────────────────────────────────────
  static const String noInternet =
      'No internet connection. Please check your network and try again.';
  static const String emailNotFound =
      'No account found with this email address.';
  static const String wrongPassword = 'Incorrect password. Please try again.';
  static const String invalidCredentials = 'Invalid email or password.';
  static const String serverError =
      'Something went wrong on our end. Please try again shortly.';
  static const String unknown =
      'An unexpected error occurred. Please try again.';

  /// Maps a raw exception or error string to a clean user-facing message.
  static String fromRaw(String raw) {
    final lower = raw.toLowerCase();
    if (_isNetworkError(lower)) return noInternet;
    if (lower.contains('email not found') || lower.contains('not found')) {
      return emailNotFound;
    }
    if (lower.contains('incorrect password') || lower.contains('password')) {
      return wrongPassword;
    }
    if (lower.contains('invalid') || lower.contains('credentials')) {
      return invalidCredentials;
    }
    if (lower.contains('server') ||
        lower.contains('500') ||
        lower.contains('503')) {
      return serverError;
    }
    return unknown;
  }

  static bool _isNetworkError(String lower) {
    return lower.contains('socketexception') ||
        lower.contains('failed host lookup') ||
        lower.contains('failed to fetch') ||
        lower.contains('clientexception') ||
        lower.contains('network') ||
        lower.contains('no address associated') ||
        lower.contains('connection refused') ||
        lower.contains('connection timed out') ||
        lower.contains('errno = 7') ||
        lower.contains('os error');
  }
}

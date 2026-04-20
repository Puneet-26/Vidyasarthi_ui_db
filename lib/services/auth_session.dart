/// Global auth session - stores the logged-in user's info
/// Access from anywhere: AuthSession.email, AuthSession.role, AuthSession.name
class AuthSession {
  static String? email;
  static String? role;
  static String? name;

  static void set({required String email, required String role, String? name}) {
    AuthSession.email = email;
    AuthSession.role = role;
    AuthSession.name = name;
  }

  static void clear() {
    email = null;
    role = null;
    name = null;
  }
}

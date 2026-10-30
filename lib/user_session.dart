class UserSession {
  static String userName = 'Tree Plantation User';
  static String userEmail = '';
  static String userRole = 'USER';
  static String? userId;

  // Store the JWT authentication token
  static String? token;

  // Check whether the logged-in user is an administrator
  static bool get isAdmin => userRole.toUpperCase() == 'ADMIN';

  // Check whether a token is available
  static bool get isLoggedIn => token != null && token!.isNotEmpty;

  // Save logged-in user information
  static void setUser({
    required String name,
    required String email,
    String role = 'USER',
    String? authToken,
    String? userIdValue,
  }) {
    userName = name;
    userEmail = email;
    userRole = role.toUpperCase();
    userId = userIdValue;
    token = authToken;
  }

  // Clear user information during logout
  static void clear() {
    userName = 'Tree Plantation User';
    userEmail = '';
    userRole = 'USER';
    userId = null;
    token = null;
  }
}

class UserSession {
  static Map<String, dynamic>? currentUser;

  static void fromJson(Map<String, dynamic> user) {
    currentUser = user;
  }


  static void logout() {
    currentUser = null;
  }


  static bool get isLoggedIn => currentUser != null;
  static int? get userId => currentUser?['id'];
  static String? get role => currentUser?['role'];
  static String? get username => currentUser?['username'];
}
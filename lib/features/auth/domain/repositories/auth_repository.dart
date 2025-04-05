abstract class AuthRepository {
  Future<bool> isLoggedIn();
  Future<void> login(String username, String password); // We won't validate, just save state
  Future<void> logout();
} 
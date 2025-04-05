abstract class AuthRepository {
  Future<bool> isLoggedIn();

  Future<void> login(String username, String password);

  Future<void> logout();
}

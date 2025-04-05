import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDataSource {
  Future<void> saveLoginState(bool isLoggedIn);
  Future<bool> getLoginState();
  Future<void> clearLoginState();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _loggedInKey = 'isLoggedIn';

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> saveLoginState(bool isLoggedIn) async {
    await sharedPreferences.setBool(_loggedInKey, isLoggedIn);
  }

  @override
  Future<bool> getLoginState() async {
    return sharedPreferences.getBool(_loggedInKey) ?? false;
  }

  @override
  Future<void> clearLoginState() async {
    await sharedPreferences.remove(_loggedInKey);
  }
} 
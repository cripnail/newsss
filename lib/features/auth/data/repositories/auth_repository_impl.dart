import '../datasources/auth_local_data_source.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({required this.localDataSource});

  @override
  Future<bool> isLoggedIn() async {
    // Просто проверяем сохраненное состояние
    return await localDataSource.getLoginState();
  }

  @override
  Future<void> login(String username, String password) async {
    // Имитируем вход - просто сохраняем состояние
    // В реальном приложении здесь был бы вызов API
    print('Simulating login for $username'); // Для наглядности
    await localDataSource.saveLoginState(true);
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearLoginState();
  }
} 
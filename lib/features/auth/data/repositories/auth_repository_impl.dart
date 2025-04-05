import 'package:newsss/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:newsss/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({required this.localDataSource});

  @override
  Future<bool> isLoggedIn() async {
    return await localDataSource.getLoginState();
  }

  @override
  Future<void> login(String username, String password) async {
    await localDataSource.saveLoginState(true);
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearLoginState();
  }
}

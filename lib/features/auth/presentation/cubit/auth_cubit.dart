import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsss/features/auth/domain/repositories/auth_repository.dart';
import 'package:newsss/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(const AuthState()) {
    checkInitialAuthState();
  }

  Future<void> checkInitialAuthState() async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));
      final loggedIn = await _authRepository.isLoggedIn();
      if (loggedIn) {
        emit(state.copyWith(status: AuthStatus.authenticated));
      } else {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    } catch (e) {
      emit(state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'Failed to check auth status'));
    }
  }

  Future<void> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      emit(state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'Username and password cannot be empty'));
      emit(state.copyWith(status: AuthStatus.unauthenticated));
      return;
    }
    try {
      emit(state.copyWith(status: AuthStatus.loading));
      await _authRepository.login(username, password);
      emit(state.copyWith(status: AuthStatus.authenticated));
    } catch (e) {
      emit(state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'Login failed: ${e.toString()}'));
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> logout() async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));
      await _authRepository.logout();
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    } catch (e) {
      emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Logout failed but state cleared'));
    }
  }
}

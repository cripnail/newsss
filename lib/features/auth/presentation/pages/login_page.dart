import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injector.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../../../../core/router/app_routes.dart'; // Import routes

// TODO: Import NewsListPage
// import '../../../news/presentation/pages/news_list_page.dart'; 

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthCubit>(), // Получаем AuthCubit из DI
      child: const LoginView(),
    );
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.failure && state.errorMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
          }
          if (state.status == AuthStatus.authenticated) {
            // Переходим на страницу новостей и удаляем LoginPage из стека
            Navigator.of(context).pushReplacementNamed(AppRoutes.newsList);
            print("Login Successful! Navigating to News List..."); 
          }
        },
        builder: (context, state) {
          if (state.status == AuthStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } 
          // Показываем форму входа если не аутентифицирован или произошла ошибка (чтобы можно было попробовать снова)
          // Мы также можем попасть сюда из initial состояния
          if (state.status == AuthStatus.unauthenticated || state.status == AuthStatus.initial || state.status == AuthStatus.failure) {
             return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onEditingComplete: () => _login(context),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => _login(context),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48), // Stretch button
                      ),
                      child: const Text('Login'),
                    ),
                  ],
                ),
              );
          }
          // Если статус authenticated, но навигация еще не произошла (или произошла ошибка навигации)
          // Можно показать пустой контейнер или индикатор, пока listener не сработает
          // Но в нашем случае listener должен сработать почти мгновенно
          return const SizedBox.shrink(); // Или индикатор для подстраховки
        },
      ),
    );
  }

  void _login(BuildContext context) {
    // Скрываем клавиатуру
    FocusScope.of(context).unfocus(); 
    context.read<AuthCubit>().login(
          _usernameController.text,
          _passwordController.text,
        );
  }
} 
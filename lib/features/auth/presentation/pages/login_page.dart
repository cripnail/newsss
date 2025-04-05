import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsss/core/di/injector.dart';
import 'package:newsss/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:newsss/features/auth/presentation/cubit/auth_state.dart';
import 'package:newsss/core/router/app_routes.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthCubit>(),
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
          if (state.status == AuthStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
          }
          if (state.status == AuthStatus.authenticated) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.newsList);
            if (kDebugMode) {
              if (kDebugMode) {
                print("Login Successful! Navigating to News List...");
              }
            }
          }
        },
        builder: (context, state) {
          if (state.status == AuthStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == AuthStatus.unauthenticated ||
              state.status == AuthStatus.initial ||
              state.status == AuthStatus.failure) {
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
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('Login'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _login(BuildContext context) {
    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().login(
          _usernameController.text,
          _passwordController.text,
        );
  }
}

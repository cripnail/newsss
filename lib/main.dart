import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newsss/core/di/injector.dart' as di;
import 'package:newsss/core/router/app_router.dart';
import 'package:newsss/core/router/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await di.initializeDependencies();

  final bool isLoggedIn =
      di.sl<SharedPreferences>().getBool('isLoggedIn') ?? false;
  final String initialRoute = isLoggedIn ? AppRoutes.newsList : AppRoutes.login;

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: initialRoute,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Needed to check login state
import 'core/di/injector.dart' as di;
import 'core/router/app_router.dart'; // Import Router
import 'core/router/app_routes.dart'; // Import Routes

// TODO: Import Auth feature entry point (e.g., AuthGate or LoginPage)
// import 'features/auth/presentation/pages/login_page.dart'; 

// TODO: Import News feature entry point (e.g., NewsListPage)
// import 'features/news/presentation/pages/news_list_page.dart';

// TODO: Import Router setup
// import 'core/router/app_router.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  await di.initializeDependencies();

  // Определяем начальный маршрут
  final bool isLoggedIn = di.sl<SharedPreferences>().getBool('isLoggedIn') ?? false;
  final String initialRoute = isLoggedIn ? AppRoutes.newsList : AppRoutes.login;

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News App',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      onGenerateRoute: AppRouter.generateRoute, // Use the router
      initialRoute: initialRoute, // Set the initial route
      // home: PlaceholderWidget(), // home is not needed when using initialRoute and onGenerateRoute
    );
  }
}

// PlaceholderWidget is no longer needed
/*
class PlaceholderWidget extends StatelessWidget {
  const PlaceholderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('App Initializing...'),
      ),
    );
  }
}
*/

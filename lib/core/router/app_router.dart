import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import BlocProvider
import 'package:shared_preferences/shared_preferences.dart'; // Needed for checking auth state
import 'package:newsss/core/di/injector.dart'; // Import sl (GetIt instance)
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/news/presentation/pages/news_list_page.dart';
import '../../features/news/presentation/pages/news_detail_page.dart';
import '../../features/news/domain/entities/news_article.dart'; // Needed for detail arguments
import '../../features/news/presentation/bloc/news_bloc.dart'; // Import NewsBloc
import 'app_routes.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Handle the root route explicitly
      case '/':
        final bool isLoggedIn = sl<SharedPreferences>().getBool('isLoggedIn') ?? false;
        if (isLoggedIn) {
            // If logged in, root should lead to news list
            return MaterialPageRoute(builder: (_) => const NewsListPage());
        } else {
            // If not logged in, root should lead to login
             return MaterialPageRoute(builder: (_) => const LoginPage());
        }
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case AppRoutes.newsList:
        // NewsListPage сама предоставляет свой Bloc через MultiBlocProvider
        return MaterialPageRoute(builder: (_) => const NewsListPage());
      case AppRoutes.newsDetail:
        final args = settings.arguments as Map<String, dynamic>?; // Get arguments as Map
        if (args != null && 
            args['article'] is NewsArticle && 
            args['newsBloc'] is NewsBloc) { 
            
            final article = args['article'] as NewsArticle;
            final scrollToComments = args['scrollToComments'] as bool? ?? false;
            final newsBloc = args['newsBloc'] as NewsBloc; // Извлекаем Bloc
            
            return MaterialPageRoute(
              // Оборачиваем NewsDetailPage в BlocProvider.value
              builder: (_) => BlocProvider.value(
                 value: newsBloc, // Предоставляем существующий экземпляр
                 child: NewsDetailPage(
                    article: article, 
                    scrollToComments: scrollToComments,
                 ),
              ),
            );
        } else {
            // Handle error case: missing or invalid arguments
             return _errorRoute('Missing or invalid arguments for ${settings.name}');
        }
      default:
        return _errorRoute('No route defined for ${settings.name}');
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: Center(child: Text(message)),
        );
      },
    );
  }

  // Prevent instantiation
  AppRouter._();
} 
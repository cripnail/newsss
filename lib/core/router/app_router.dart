import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import BlocProvider
import 'package:shared_preferences/shared_preferences.dart'; // Needed for checking auth state
import 'package:newsss/core/di/injector.dart'; // Import sl (GetIt instance)
import 'package:newsss/features/auth/presentation/pages/login_page.dart';
import 'package:newsss/features/news/presentation/pages/news_list_page.dart';
import 'package:newsss/features/news/domain/entities/news_article.dart'; // Needed for detail arguments
import 'package:newsss/features/news/presentation/bloc/news_bloc.dart'; // Import NewsBloc
import 'package:newsss/features/news/presentation/pages/news_detail_page.dart';
import 'app_routes.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        final bool isLoggedIn =
            sl<SharedPreferences>().getBool('isLoggedIn') ?? false;
        if (isLoggedIn) {
          return MaterialPageRoute(builder: (_) => const NewsListPage());
        } else {
          return MaterialPageRoute(builder: (_) => const LoginPage());
        }
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case AppRoutes.newsList:
        return MaterialPageRoute(builder: (_) => const NewsListPage());
      case AppRoutes.newsDetail:
        final args =
            settings.arguments as Map<String, dynamic>?; // Get arguments as Map
        if (args != null &&
            args['article'] is NewsArticle &&
            args['newsBloc'] is NewsBloc) {
          final article = args['article'] as NewsArticle;
          final scrollToComments = args['scrollToComments'] as bool? ?? false;
          final newsBloc = args['newsBloc'] as NewsBloc;

          return MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: newsBloc,
              child: NewsDetailPage(
                article: article,
                scrollToComments: scrollToComments,
              ),
            ),
          );
        } else {
          return _errorRoute(
              'Missing or invalid arguments for ${settings.name}');
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

  AppRouter._();
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/entities/news_article.dart';
import '../bloc/news_bloc.dart';
import '../widgets/news_card_widget.dart';

class NewsListPage extends StatelessWidget {
  const NewsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<NewsBloc>()..add(const GetNewsListEvent()),
        ),
        BlocProvider.value(value: sl<AuthCubit>()),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.unauthenticated) {
            Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.login, (Route<dynamic> route) => false);
          }
        },
        child: const NewsListView(),
      ),
    );
  }
}

class NewsListView extends StatefulWidget {
  const NewsListView({super.key});

  @override
  State<NewsListView> createState() => _NewsListViewState();
}

class _NewsListViewState extends State<NewsListView> {
  final _searchController = TextEditingController();
  // Можно добавить ScrollController для пагинации в будущем
  // final _scrollController = ScrollController(); 

  @override
  void initState() {
    super.initState();
    // Добавляем listener для отправки события поиска при изменении текста
    _searchController.addListener(_onSearchChanged);
    // TODO: Add listener for scroll controller for pagination
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    // _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Отправляем событие поиска в BLoC
    context.read<NewsBloc>().add(SearchNewsEvent(_searchController.text));
  }

  void _navigateToDetail(BuildContext context, NewsArticle article, {bool scrollToComments = false}) {
    // Получаем экземпляр NewsBloc из текущего контекста
    final newsBloc = BlocProvider.of<NewsBloc>(context);
    Navigator.of(context).pushNamed(
        AppRoutes.newsDetail,
        arguments: {
           'article': article,
           'scrollToComments': scrollToComments,
           'newsBloc': newsBloc, // Передаем экземпляр Bloc
        },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                    TextButton(
                      child: const Text('Logout'),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        context.read<AuthCubit>().logout();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search news...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none, // No border
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                // Кнопка очистки поля
                suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        // Отправляем событие с пустым запросом, чтобы сбросить поиск
                         context.read<NewsBloc>().add(const SearchNewsEvent(''));
                      },
                    )
                  : null,
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<NewsBloc, NewsState>(
        builder: (context, state) {
          switch (state.status) {
            case NewsStatus.initial:
            case NewsStatus.loading:
              // Показываем индикатор загрузки только при первой загрузке
              return const LoadingIndicator(message: 'Fetching news...');

            case NewsStatus.searching:
              // Можно показывать другой индикатор во время поиска или оставить старый список
              // Для мгновенного отклика оставим предыдущий список
              // Если нужно показывать индикатор поиска, раскомментировать:
              // return const LoadingIndicator(message: 'Searching...');
              // Или просто отображаем текущий список, пока идет поиск
              if (state.articles.isEmpty) {
                  return const Center(child: Text('Searching...'));
              } else {
                  // Fallthrough to show the list while searching in background
              } 
              // Continue to loaded state rendering
              return _buildNewsList(context, state.articles);

            case NewsStatus.error:
              return ErrorDisplay(
                message: state.errorMessage ?? 'Failed to load news.',
                onRetry: () => context.read<NewsBloc>().add(const GetNewsListEvent(forceRefresh: true)),
              );

            case NewsStatus.loaded:
              if (state.articles.isEmpty) {
                return ErrorDisplay(
                  message: 'No news articles found.',
                  onRetry: () => context.read<NewsBloc>().add(const GetNewsListEvent(forceRefresh: true)),
                );
              }
              // Отображаем список новостей
              return _buildNewsList(context, state.articles);
          }
        },
      ),
    );
  }

  Widget _buildNewsList(BuildContext context, List<NewsArticle> articles) {
    return RefreshIndicator(
      onRefresh: () async {
        // Запускаем событие обновления при pull-to-refresh
        context.read<NewsBloc>().add(const GetNewsListEvent(forceRefresh: true));
        // Дожидаемся завершения (хотя BLoC сам обновит UI)
        // Можно использовать BlocListener для ожидания завершения обновления,
        // но для RefreshIndicator достаточно просто запустить событие.
      },
      child: ListView.builder(
        // controller: _scrollController, // Add for pagination later
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return NewsCardWidget(
            article: article,
            onTapArticle: () => _navigateToDetail(context, article),
            onTapComments: () => _navigateToDetail(context, article, scrollToComments: true),
          );
        },
      ),
    );
  }
} 
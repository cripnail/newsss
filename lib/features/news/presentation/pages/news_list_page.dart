import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsss/core/di/injector.dart';
import 'package:newsss/core/router/app_routes.dart';
import 'package:newsss/core/widgets/error_display.dart';
import 'package:newsss/core/widgets/loading_indicator.dart';
import 'package:newsss/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:newsss/features/auth/presentation/cubit/auth_state.dart';
import 'package:newsss/features/news/domain/entities/news_article.dart';
import 'package:newsss/features/news/presentation/bloc/news_bloc.dart';
import 'package:newsss/features/news/presentation/widgets/news_card_widget.dart';

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

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<NewsBloc>().add(SearchNewsEvent(_searchController.text));
  }

  void _navigateToDetail(BuildContext context, NewsArticle article,
      {bool scrollToComments = false}) {
    final newsBloc = BlocProvider.of<NewsBloc>(context);
    Navigator.of(context).pushNamed(
      AppRoutes.newsDetail,
      arguments: {
        'article': article,
        'scrollToComments': scrollToComments,
        'newsBloc': newsBloc,
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
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search news...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context
                              .read<NewsBloc>()
                              .add(const SearchNewsEvent(''));
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
              return const LoadingIndicator(message: 'Fetching news...');
            case NewsStatus.searching:
              if (state.articles.isEmpty) {
                return const Center(child: Text('Searching...'));
              }
              return _buildNewsList(context, state.articles);
            case NewsStatus.error:
              return ErrorDisplay(
                message: state.errorMessage ?? 'Failed to load news.',
                onRetry: () => context
                    .read<NewsBloc>()
                    .add(const GetNewsListEvent(forceRefresh: true)),
              );
            case NewsStatus.loaded:
              if (state.articles.isEmpty) {
                return ErrorDisplay(
                  message: 'No news articles found.',
                  onRetry: () => context
                      .read<NewsBloc>()
                      .add(const GetNewsListEvent(forceRefresh: true)),
                );
              }
              return _buildNewsList(context, state.articles);
          }
        },
      ),
    );
  }

  Widget _buildNewsList(BuildContext context, List<NewsArticle> articles) {
    return RefreshIndicator(
      onRefresh: () async {
        context
            .read<NewsBloc>()
            .add(const GetNewsListEvent(forceRefresh: true));
      },
      child: ListView.builder(
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return NewsCardWidget(
            article: article,
            onTapArticle: () => _navigateToDetail(context, article),
            onTapComments: () =>
                _navigateToDetail(context, article, scrollToComments: true),
          );
        },
      ),
    );
  }
}

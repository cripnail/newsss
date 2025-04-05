part of 'news_bloc.dart';

enum NewsStatus { initial, loading, loaded, searching, error }

class NewsState extends Equatable {
  final NewsStatus status;
  final List<NewsArticle> articles;
  final bool hasReachedMax;
  final String? errorMessage;

  const NewsState({
    this.status = NewsStatus.initial,
    this.articles = const <NewsArticle>[],
    this.hasReachedMax = false,
    this.errorMessage,
  });

  NewsState copyWith({
    NewsStatus? status,
    List<NewsArticle>? articles,
    bool? hasReachedMax,
    String? errorMessage,
  }) {
    return NewsState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: (status != NewsStatus.error && errorMessage == null)
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        articles,
        hasReachedMax,
        errorMessage,
      ];
}

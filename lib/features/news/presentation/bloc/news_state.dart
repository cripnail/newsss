part of 'news_bloc.dart'; // Link to the BLoC file

enum NewsStatus { initial, loading, loaded, searching, error }

class NewsState extends Equatable {
  final NewsStatus status;
  final List<NewsArticle> articles; // Current list of articles (either all or search results)
  final bool hasReachedMax; // For pagination later, maybe
  final String? errorMessage;
  // Keep track of comments for the currently viewed article
  // Map<articleId, List<Comment>> commentsByArticle; // Or load them on demand

  const NewsState({
    this.status = NewsStatus.initial,
    this.articles = const <NewsArticle>[],
    this.hasReachedMax = false,
    this.errorMessage,
    // this.commentsByArticle = const {},
  });

  NewsState copyWith({
    NewsStatus? status,
    List<NewsArticle>? articles,
    bool? hasReachedMax,
    String? errorMessage,
    // Map<articleId, List<Comment>>? commentsByArticle,
  }) {
    return NewsState(
      // If status is explicitly set to error, clear the message unless a new one is provided
      status: status ?? this.status,
      articles: articles ?? this.articles,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      // Clear error message if status is not error, unless a new message is provided
      errorMessage: (status != NewsStatus.error && errorMessage == null) ? null : errorMessage ?? this.errorMessage,
      // commentsByArticle: commentsByArticle ?? this.commentsByArticle,
    );
  }

  @override
  List<Object?> get props => [
        status,
        articles,
        hasReachedMax,
        errorMessage,
        // commentsByArticle,
      ];
} 
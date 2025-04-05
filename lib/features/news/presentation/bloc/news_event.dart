part of 'news_bloc.dart'; // Link to the BLoC file

abstract class NewsEvent extends Equatable {
  const NewsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to fetch the initial list of news or refresh it.
class GetNewsListEvent extends NewsEvent {
  final bool forceRefresh;

  const GetNewsListEvent({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

/// Event to search news locally based on a query.
class SearchNewsEvent extends NewsEvent {
  final String query;

  const SearchNewsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Event to add a comment to a specific article.
class AddCommentEvent extends NewsEvent {
  final String articleUrl;
  final String userName; // In real app, get from user state
  final String text;

  const AddCommentEvent({
    required this.articleUrl,
    required this.userName,
    required this.text,
  });

  @override
  List<Object?> get props => [articleUrl, userName, text];
}

/// Event specifically to load comments for an article 
/// (could be triggered when opening details).
class LoadCommentsEvent extends NewsEvent {
    final String articleUrl;

    const LoadCommentsEvent(this.articleUrl);

     @override
    List<Object?> get props => [articleUrl];
} 
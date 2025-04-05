part of 'news_bloc.dart';

abstract class NewsEvent extends Equatable {
  const NewsEvent();

  @override
  List<Object?> get props => [];
}

class GetNewsListEvent extends NewsEvent {
  final bool forceRefresh;

  const GetNewsListEvent({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class SearchNewsEvent extends NewsEvent {
  final String query;

  const SearchNewsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class AddCommentEvent extends NewsEvent {
  final String articleUrl;
  final String userName;
  final String text;

  const AddCommentEvent({
    required this.articleUrl,
    required this.userName,
    required this.text,
  });

  @override
  List<Object?> get props => [articleUrl, userName, text];
}

class LoadCommentsEvent extends NewsEvent {
  final String articleUrl;

  const LoadCommentsEvent(this.articleUrl);

  @override
  List<Object?> get props => [articleUrl];
}

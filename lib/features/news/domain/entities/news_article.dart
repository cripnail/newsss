import 'package:equatable/equatable.dart';
import 'comment.dart';

class NewsArticle extends Equatable {
  final String id;
  final String? sourceName;
  final String? author;
  final String title;
  final String description;
  final String url;
  final String? urlToImage;
  final DateTime? publishedAt;
  final String content;
  final List<Comment> comments;

  const NewsArticle({
    required this.id,
    this.sourceName,
    this.author,
    required this.title,
    required this.description,
    required this.url,
    this.urlToImage,
    this.publishedAt,
    required this.content,
    this.comments = const [],
  });

  @override
  List<Object?> get props => [
        id,
        sourceName,
        author,
        title,
        description,
        url,
        urlToImage,
        publishedAt,
        content,
        comments,
      ];
}

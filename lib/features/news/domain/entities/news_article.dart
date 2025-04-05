import 'package:equatable/equatable.dart';
import 'comment.dart';

class NewsArticle extends Equatable {
  final String id; // Use a unique ID for DB lookup, could be URL or generated
  final String? sourceName;
  final String? author;
  final String title;
  final String description;
  final String url;
  final String? urlToImage;
  final DateTime? publishedAt;
  final String content; // Full content
  final List<Comment> comments; // Comments associated with this article

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
    this.comments = const [], // Default to empty list
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
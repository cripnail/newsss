import 'package:equatable/equatable.dart';

class Comment extends Equatable {
  final String id; // Unique ID for the comment
  final String articleId; // ID of the article this comment belongs to
  final String userName;
  final String text;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.articleId,
    required this.userName,
    required this.text,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, articleId, userName, text, createdAt];
} 
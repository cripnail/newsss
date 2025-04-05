import 'package:equatable/equatable.dart';

class Comment extends Equatable {
  final String id;
  final String articleId;
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

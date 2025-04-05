import 'package:isar/isar.dart';

part 'news_db_model.g.dart'; // Isar generator part file

@collection
class NewsDbModel {
  Id id = Isar.autoIncrement; // Auto increment primary key

  @Index(unique: true, replace: true, caseSensitive: false)
  String? url; // Use URL as a unique identifier, ignore case

  String? sourceName;
  String? author;

  @Index(type: IndexType.value, caseSensitive: false)
  String? title;

  @Index(type: IndexType.value, caseSensitive: false)
  String? description; // Index for searching

  String? urlToImage;
  DateTime? publishedAt;
  String? content;

  // Note: Comments will be handled in a separate collection (CommentDbModel)
  // and linked via articleId.
} 
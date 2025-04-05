import 'package:isar/isar.dart';

part 'news_db_model.g.dart';

@collection
class NewsDbModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true, caseSensitive: false)
  String? url;

  String? sourceName;
  String? author;

  @Index(type: IndexType.value, caseSensitive: false)
  String? title;

  @Index(type: IndexType.value, caseSensitive: false)
  String? description;

  String? urlToImage;
  DateTime? publishedAt;
  String? content;
}

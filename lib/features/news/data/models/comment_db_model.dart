import 'package:isar/isar.dart';

part 'comment_db_model.g.dart';

@collection
class CommentDbModel {
  Id id = Isar.autoIncrement;

  @Index()
  String? articleUrl;

  String? userName;
  String? text;
  DateTime? createdAt;
}

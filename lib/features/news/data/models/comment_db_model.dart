import 'package:isar/isar.dart';

part 'comment_db_model.g.dart'; // Isar generator part file

@collection
class CommentDbModel {
  Id id = Isar.autoIncrement;

  @Index() // Index for querying comments by article
  String? articleUrl; // Link to the NewsDbModel using its unique URL

  String? userName;
  String? text;
  DateTime? createdAt;
} 
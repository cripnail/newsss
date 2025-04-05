import 'package:isar/isar.dart';

// Import collection schemas now that they should be generated
import 'package:newsss/features/news/data/models/news_db_model.dart';
import 'package:newsss/features/news/data/models/comment_db_model.dart';

class IsarService {
  late final Isar _isar;

  Isar get db => _isar;

  IsarService(this._isar);

  static Future<Isar> openDB(String directory) async {
    if (Isar.instanceNames.isEmpty) {
      return await Isar.open(
        [
          NewsDbModelSchema,
          CommentDbModelSchema,
        ],
        directory: directory,
        inspector: true, // Keep inspector enabled for debugging
      );
    }
    return Future.value(Isar.getInstance());
  }
}

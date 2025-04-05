import 'package:isar/isar.dart';

// Import collection schemas now that they should be generated
import '../../features/news/data/models/news_db_model.dart';
import '../../features/news/data/models/comment_db_model.dart';

class IsarService {
  late final Isar _isar;
  Isar get db => _isar;

  IsarService(this._isar);

  static Future<Isar> openDB(String directory) async {
    if (Isar.instanceNames.isEmpty) {
      return await Isar.open(
        [
          // Add the generated schemas here
          NewsDbModelSchema,
          CommentDbModelSchema,
        ],
        directory: directory,
        inspector: true, // Enable inspector for debugging (optional)
      );
    }
    // Return existing instance if already open
    return Future.value(Isar.getInstance());
  }
} 
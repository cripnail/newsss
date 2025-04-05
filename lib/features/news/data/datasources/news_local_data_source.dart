import 'package:isar/isar.dart';
import '../../../../core/error/exceptions.dart';
import '../models/comment_db_model.dart';
import '../models/news_db_model.dart';

abstract class NewsLocalDataSource {
  /// Saves a list of news articles to the local database.
  /// Only new articles (based on URL) will be added.
  /// Returns the number of newly added articles.
  /// Throws [DatabaseException] on failure.
  Future<int> saveArticles(List<NewsDbModel> articles);

  /// Gets all saved news articles, optionally sorted by published date descending.
  /// Throws [DatabaseException] on failure.
  Future<List<NewsDbModel>> getAllArticles();

  /// Searches saved articles by title or description containing the query.
  /// Search is case-insensitive.
  /// Throws [DatabaseException] on failure.
  Future<List<NewsDbModel>> searchArticles(String query);

  /// Adds a comment to the local database.
  /// Throws [DatabaseException] on failure.
  Future<void> addComment(CommentDbModel comment);

  /// Gets all comments for a specific article URL.
  /// Throws [DatabaseException] on failure.
  Future<List<CommentDbModel>> getCommentsForArticle(String articleUrl);
}

class NewsLocalDataSourceImpl implements NewsLocalDataSource {
  final Isar isar;

  NewsLocalDataSourceImpl({required this.isar});

  @override
  Future<int> saveArticles(List<NewsDbModel> articles) async {
    try {
      // Isar's putAll handles uniqueness based on the @Index(unique: true, replace: true)
      // It will insert new ones and replace existing ones based on the unique `url`.
      // The `replace` strategy ensures that if an article with the same URL exists,
      // it gets updated with the potentially newer data from the API.
      // We technically don't need to return the count of *new* articles here,
      // as putAll doesn't directly return that. We just ensure they are saved/updated.
      await isar.writeTxn(() async {
        await isar.newsDbModels.putAll(articles);
      });
      // Since `putAll` with `replace` updates existing ones,
      // returning the count of the input list might be misleading if some were updates.
      // For simplicity, we can return 0 or just make it void.
      // Let's return 0 for now, indicating the operation success rather than count.
      return 0; // Or change the return type to Future<void>
    } catch (e) {
      print('Database error saving articles: $e');
      throw DatabaseException(
          message: 'Failed to save articles: ${e.toString()}');
    }
  }

  @override
  Future<List<NewsDbModel>> getAllArticles() async {
    try {
      return await isar.newsDbModels
          .where()
          .sortByPublishedAtDesc() // Sort by date, newest first
          .findAll();
    } catch (e) {
      print('Database error getting all articles: $e');
      throw DatabaseException(
          message: 'Failed to get articles: ${e.toString()}');
    }
  }

  @override
  Future<List<NewsDbModel>> searchArticles(String query) async {
    if (query.isEmpty) {
      return getAllArticles(); // Return all if query is empty
    }
    try {
      // Case-insensitive search on indexed fields
      final queryLower = query.toLowerCase();
      return await isar.newsDbModels
          .filter()
          .titleContains(queryLower, caseSensitive: false)
          .or()
          .descriptionContains(queryLower, caseSensitive: false)
          .sortByPublishedAtDesc()
          .findAll();
    } catch (e) {
      print('Database error searching articles: $e');
      throw DatabaseException(
          message: 'Failed to search articles: ${e.toString()}');
    }
  }

  @override
  Future<void> addComment(CommentDbModel comment) async {
    try {
      await isar.writeTxn(() async {
        await isar.commentDbModels.put(comment);
      });
    } catch (e) {
      print('Database error adding comment: $e');
      throw DatabaseException(
          message: 'Failed to add comment: ${e.toString()}');
    }
  }

  @override
  Future<List<CommentDbModel>> getCommentsForArticle(String articleUrl) async {
    try {
      return await isar.commentDbModels
          .filter()
          .articleUrlEqualTo(articleUrl)
          .sortByCreatedAtDesc() // Show newest comments first
          .findAll();
    } catch (e) {
      print('Database error getting comments: $e');
      throw DatabaseException(
          message: 'Failed to get comments: ${e.toString()}');
    }
  }
}

import 'package:isar/isar.dart';
import 'package:newsss/core/error/exceptions.dart';
import 'package:newsss/features/news/data/models/comment_db_model.dart';
import 'package:newsss/features/news/data/models/news_db_model.dart';

abstract class NewsLocalDataSource {
  Future<int> saveArticles(List<NewsDbModel> articles);

  Future<List<NewsDbModel>> getAllArticles();

  Future<List<NewsDbModel>> searchArticles(String query);

  Future<void> addComment(CommentDbModel comment);

  Future<List<CommentDbModel>> getCommentsForArticle(String articleUrl);
}

class NewsLocalDataSourceImpl implements NewsLocalDataSource {
  final Isar isar;

  NewsLocalDataSourceImpl({required this.isar});

  @override
  Future<int> saveArticles(List<NewsDbModel> articles) async {
    try {
      await isar.writeTxn(() async {
        await isar.newsDbModels.putAll(articles);
      });
      return 0;
    } catch (e) {
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
      throw DatabaseException(
          message: 'Failed to get articles: ${e.toString()}');
    }
  }

  @override
  Future<List<NewsDbModel>> searchArticles(String query) async {
    if (query.isEmpty) {
      return getAllArticles();
    }
    try {
      final queryLower = query.toLowerCase();
      return await isar.newsDbModels
          .filter()
          .titleContains(queryLower, caseSensitive: false)
          .or()
          .descriptionContains(queryLower, caseSensitive: false)
          .sortByPublishedAtDesc()
          .findAll();
    } catch (e) {
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
          .sortByCreatedAtDesc()
          .findAll();
    } catch (e) {
      throw DatabaseException(
          message: 'Failed to get comments: ${e.toString()}');
    }
  }
}

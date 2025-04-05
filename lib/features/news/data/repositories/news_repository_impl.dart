import 'package:flutter/foundation.dart';
import 'package:newsss/core/error/exceptions.dart'; // Assuming NetworkException is here now
import 'package:newsss/features/news/domain/entities/comment.dart';
import 'package:newsss/features/news/domain/entities/news_article.dart';
import 'package:newsss/features/news/domain/repositories/news_repository.dart';
import 'package:newsss/features/news/data/datasources/news_local_data_source.dart';
import 'package:newsss/features/news/data/datasources/news_remote_data_source.dart';
import 'package:newsss/features/news/data/models/mappers.dart';

class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource remoteDataSource;
  final NewsLocalDataSource localDataSource;

  NewsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<NewsArticle>> getNews({bool forceRefresh = false}) async {
    bool needsFetch = forceRefresh;
    if (!forceRefresh) {
      final localArticles = await localDataSource.getAllArticles();
      if (localArticles.isEmpty) {
        needsFetch = true;
      }
    }

    if (needsFetch) {
      try {
        final remoteArticles = await remoteDataSource.getTopHeadlines();
        final dbModels = articleApiModelListToDbModelList(remoteArticles);
        await localDataSource.saveArticles(dbModels);
      } on ServerException catch (e) {
        if (kDebugMode) {
          print(
              'Server error during fetch: $e. Returning local data if available.');
        }
      }
    }

    try {
      final localArticles = await localDataSource.getAllArticles();
      final List<NewsArticle> articlesWithComments = [];
      for (final dbModel in localArticles) {
        if (dbModel.url != null) {
          final comments = await getComments(dbModel.url!);
          articlesWithComments.add(newsDbModelToEntity(dbModel, comments));
        }
      }
      return articlesWithComments;
    } catch (e) {
      throw DatabaseException(
          message: 'Failed to load news from local storage.');
    }
  }

  @override
  Future<List<NewsArticle>> searchNewsLocally(String query) async {
    try {
      final localArticles = await localDataSource.searchArticles(query);
      // Fetch comments for each searched article
      final List<NewsArticle> articlesWithComments = [];
      for (final dbModel in localArticles) {
        if (dbModel.url != null) {
          final comments = await getComments(dbModel.url!);
          articlesWithComments.add(newsDbModelToEntity(dbModel, comments));
        }
      }
      return articlesWithComments;
    } on DatabaseException {
      rethrow;
    } catch (e) {
      throw DatabaseException(message: 'Failed to search news locally.');
    }
  }

  @override
  Future<void> addComment(
      String articleUrl, String userName, String text) async {
    try {
      final commentDbModel = createCommentDbModel(articleUrl, userName, text);
      await localDataSource.addComment(commentDbModel);
    } on DatabaseException {
      rethrow;
    } catch (e) {
      throw DatabaseException(message: 'Failed to add comment.');
    }
  }

  @override
  Future<List<Comment>> getComments(String articleUrl) async {
    try {
      final dbComments =
          await localDataSource.getCommentsForArticle(articleUrl);
      return dbComments.map(commentDbModelToEntity).toList();
    } on DatabaseException {
      rethrow;
    } catch (e) {
      throw DatabaseException(message: 'Failed to get comments.');
    }
  }
}

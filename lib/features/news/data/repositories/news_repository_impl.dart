import '../../../../core/error/exceptions.dart'; // Assuming NetworkException is here now
import '../../domain/entities/comment.dart';
import '../../domain/entities/news_article.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/news_local_data_source.dart';
import '../datasources/news_remote_data_source.dart';
import '../models/mappers.dart';

class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource remoteDataSource;
  final NewsLocalDataSource localDataSource;
  // Optional: Add NetworkInfo check later if needed
  // final NetworkInfo networkInfo;

  NewsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    // required this.networkInfo,
  });

  @override
  Future<List<NewsArticle>> getNews({bool forceRefresh = false}) async {
    // TODO: Implement network check using NetworkInfo if added
    // if (await networkInfo.isConnected) { ... }

    bool needsFetch = forceRefresh;
    if (!forceRefresh) {
        // Simple check: If local DB is empty, fetch.
        // More sophisticated logic could involve checking timestamps.
        final localArticles = await localDataSource.getAllArticles();
        if (localArticles.isEmpty) {
            needsFetch = true;
        }
    }

    if (needsFetch) {
        try {
            print('Fetching news from remote...');
            final remoteArticles = await remoteDataSource.getTopHeadlines();
            final dbModels = articleApiModelListToDbModelList(remoteArticles);
            await localDataSource.saveArticles(dbModels);
            print('Saved ${dbModels.length} articles to local DB (includes potential updates).');
        } on NetworkException { // Catch specific exceptions if needed
            print('Network error during fetch. Returning local data if available.');
             // Don't rethrow yet, try returning local data first
        } on ServerException catch (e) {
             print('Server error during fetch: $e. Returning local data if available.');
             // Don't rethrow yet, try returning local data first
        } 
        // If fetch or save fails, we proceed to return whatever is in the local DB.
    }
    
    // Always return data from the local database after potential fetch/save
    try {
        print('Loading news from local DB...');
        final localArticles = await localDataSource.getAllArticles();
        // Fetch comments for each article separately (can be optimized if needed)
        final List<NewsArticle> articlesWithComments = [];
        for (final dbModel in localArticles) {
            if (dbModel.url != null) {
                final comments = await getComments(dbModel.url!); // Use existing getComments method
                articlesWithComments.add(newsDbModelToEntity(dbModel, comments));
            }
        }
        print('Loaded ${articlesWithComments.length} articles from DB.');
        return articlesWithComments;
    } catch (e) {
        print('Error loading news from local DB: $e');
        // If local DB also fails, rethrow the exception
        throw DatabaseException(message: 'Failed to load news from local storage.');
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
    } on DatabaseException { // Catch and rethrow specific exceptions
        rethrow;
    } catch (e) {
        print('Unexpected error during local search: $e');
        throw DatabaseException(message: 'Failed to search news locally.');
    }
  }

  @override
  Future<void> addComment(String articleUrl, String userName, String text) async {
    try {
      final commentDbModel = createCommentDbModel(articleUrl, userName, text);
      await localDataSource.addComment(commentDbModel);
    } on DatabaseException { // Catch and rethrow specific exceptions
        rethrow;
    } catch (e) {
        print('Unexpected error adding comment: $e');
        throw DatabaseException(message: 'Failed to add comment.');
    }
  }

  @override
  Future<List<Comment>> getComments(String articleUrl) async {
     try {
        final dbComments = await localDataSource.getCommentsForArticle(articleUrl);
        return dbComments.map(commentDbModelToEntity).toList();
     } on DatabaseException { // Catch and rethrow specific exceptions
        rethrow;
     } catch (e) {
        print('Unexpected error getting comments: $e');
        throw DatabaseException(message: 'Failed to get comments.');
     }
  }
} 
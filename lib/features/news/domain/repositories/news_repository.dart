import '../entities/comment.dart';
import '../entities/news_article.dart';

// Тут можно использовать Either<Failure, T> для возвращаемых типов,
// но для упрощения пока будем пробрасывать Exceptions из DataSource

abstract class NewsRepository {
  /// Fetches news from remote, saves them to local DB, and returns them from DB.
  /// Returns list of [NewsArticle] from local storage after update.
  /// Throws [NetworkException], [ServerException], [DatabaseException]
  Future<List<NewsArticle>> getNews({bool forceRefresh = false});

  /// Searches articles locally based on the query.
  /// Returns list of [NewsArticle] matching the query from local storage.
  /// Throws [DatabaseException]
  Future<List<NewsArticle>> searchNewsLocally(String query);

  /// Adds a comment for a given article URL.
  /// `userName` can be taken from a hypothetical user profile later.
  /// Throws [DatabaseException]
  Future<void> addComment(String articleUrl, String userName, String text);

  /// Gets comments for a specific article from local storage.
  /// Returns list of [Comment].
  /// Throws [DatabaseException]
  Future<List<Comment>> getComments(String articleUrl);

  // Optional: Get a single article (if needed, e.g., for detail page refresh)
  // Future<NewsArticle> getArticle(String articleUrl); 
} 
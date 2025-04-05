import 'package:newsss/features/news/domain/entities/comment.dart';
import 'package:newsss/features/news/domain/entities/news_article.dart';

abstract class NewsRepository {
  Future<List<NewsArticle>> getNews({bool forceRefresh = false});

  Future<List<NewsArticle>> searchNewsLocally(String query);

  Future<void> addComment(String articleUrl, String userName, String text);

  Future<List<Comment>> getComments(String articleUrl);
}

import 'package:newsss/features/news/domain/entities/comment.dart';
import 'package:newsss/features/news/domain/entities/news_article.dart';
import 'package:newsss/features/news/data/models/comment_db_model.dart';
import 'package:newsss/features/news/data/models/news_api_model.dart';
import 'package:newsss/features/news/data/models/news_db_model.dart';

DateTime? _parseDateTimeSafe(String? dateString) {
  if (dateString == null) return null;
  try {
    return DateTime.tryParse(dateString);
  } catch (_) {
    return null;
  }
}

NewsDbModel articleApiModelToDbModel(ArticleApiModel apiModel) {
  if (apiModel.url == null) {
    throw ArgumentError(
        'Cannot map ArticleApiModel to NewsDbModel: URL is null');
  }
  return NewsDbModel()
    ..url = apiModel.url
    ..sourceName = apiModel.source?.name
    ..author = apiModel.author
    ..title = apiModel.title ?? ''
    ..description = apiModel.description ?? ''
    ..urlToImage = apiModel.urlToImage
    ..publishedAt = _parseDateTimeSafe(apiModel.publishedAt)
    ..content = apiModel.content ?? '';
}

List<NewsDbModel> articleApiModelListToDbModelList(
    List<ArticleApiModel> apiModels) {
  return apiModels
      .where((apiModel) => apiModel.url != null && apiModel.title != null)
      .map(articleApiModelToDbModel)
      .toList();
}

NewsArticle newsDbModelToEntity(NewsDbModel dbModel, List<Comment> comments) {
  if (dbModel.url == null) {
    throw ArgumentError('Cannot map NewsDbModel to NewsArticle: URL is null');
  }
  return NewsArticle(
    id: dbModel.url!,
    sourceName: dbModel.sourceName,
    author: dbModel.author,
    title: dbModel.title ?? '',
    description: dbModel.description ?? '',
    url: dbModel.url!,
    urlToImage: dbModel.urlToImage,
    publishedAt: dbModel.publishedAt,
    content: dbModel.content ?? '',
    comments: comments,
  );
}

Comment commentDbModelToEntity(CommentDbModel dbModel) {
  if (dbModel.articleUrl == null ||
      dbModel.userName == null ||
      dbModel.text == null ||
      dbModel.createdAt == null) {
    throw ArgumentError(
        'Cannot map CommentDbModel to Comment: Required field is null');
  }
  return Comment(
    id: dbModel.id.toString(),
    articleId: dbModel.articleUrl!,
    userName: dbModel.userName!,
    text: dbModel.text!,
    createdAt: dbModel.createdAt!,
  );
}

CommentDbModel createCommentDbModel(
    String articleUrl, String userName, String text) {
  return CommentDbModel()
    ..articleUrl = articleUrl
    ..userName = userName
    ..text = text
    ..createdAt = DateTime.now();
}

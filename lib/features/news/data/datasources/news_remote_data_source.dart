import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:newsss/core/constants/api_constants.dart';
import 'package:newsss/core/error/exceptions.dart';
import 'package:newsss/features/news/data/models/news_api_model.dart';

abstract class NewsRemoteDataSource {
  Future<List<ArticleApiModel>> getTopHeadlines(
      {String country = ApiConstants.defaultCountry});

  Future<List<ArticleApiModel>> searchNews(String query);
}

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  final http.Client client;

  NewsRemoteDataSourceImpl({required this.client});

  Uri _buildUri(String endpoint, Map<String, String> queryParams) {
    final Map<String, String> paramsWithKey = {
      ...queryParams,
      'apiKey': ApiConstants.newsApiKey,
    };
    return Uri.parse('${ApiConstants.newsApiBaseUrl}$endpoint')
        .replace(queryParameters: paramsWithKey);
  }

  Future<List<ArticleApiModel>> _fetchNews(Uri uri) async {
    try {
      final response = await client.get(uri, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final newsApiResponse = NewsApiResponse.fromJsonString(response.body);
        if (newsApiResponse.status == 'ok') {
          return newsApiResponse.articles;
        } else {
          throw ServerException(
              message: 'NewsAPI error: ${newsApiResponse.status}');
        }
      } else {
        throw ServerException(message: 'Server error: ${response.statusCode}');
      }
    } on SocketException {
      throw NetworkException();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
          message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<List<ArticleApiModel>> getTopHeadlines(
      {String country = ApiConstants.defaultCountry}) async {
    final uri = _buildUri(ApiConstants.topHeadlines, {'country': country});
    return await _fetchNews(uri);
  }

  @override
  Future<List<ArticleApiModel>> searchNews(String query) async {
    final uri = _buildUri(ApiConstants.everything, {'q': query});
    return await _fetchNews(uri);
  }
}

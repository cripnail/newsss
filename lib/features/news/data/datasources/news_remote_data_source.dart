import 'dart:convert';
import 'dart:io'; // For SocketException
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/news_api_model.dart';

abstract class NewsRemoteDataSource {
  /// Fetches top headlines for a given country.
  /// Throws [ServerException] for server errors.
  /// Throws [NetworkException] for network errors.
  Future<List<ArticleApiModel>> getTopHeadlines({String country = ApiConstants.defaultCountry});

  /// Searches news articles based on a query.
  /// Throws [ServerException] for server errors.
  /// Throws [NetworkException] for network errors.
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
    return Uri.parse('${ApiConstants.newsApiBaseUrl}$endpoint').replace(queryParameters: paramsWithKey);
  }

  Future<List<ArticleApiModel>> _fetchNews(Uri uri) async {
     print('Fetching news from: $uri'); // Logging the request URL
    try {
      final response = await client.get(uri, headers: {
        'Content-Type': 'application/json',
      });

      print('API Response Status Code: ${response.statusCode}');
      // print('API Response Body: ${response.body}'); // Uncomment for detailed debugging

      if (response.statusCode == 200) {
        final newsApiResponse = NewsApiResponse.fromJsonString(response.body);
        if (newsApiResponse.status == 'ok') {
          return newsApiResponse.articles;
        } else {
          // NewsAPI often returns 200 OK even for errors like rate limits, check 'status' field
          print('NewsAPI error status: ${newsApiResponse.status}, message might be in the JSON');
          throw ServerException(message: 'NewsAPI error: ${newsApiResponse.status}'); // Or parse a specific message if available
        }
      } else {
         // Handle non-200 HTTP status codes
         print('Server error: ${response.statusCode}, Body: ${response.body}');
        throw ServerException(message: 'Server error: ${response.statusCode}');
      }
    } on SocketException catch (e) {
       print('Network error: $e');
      throw NetworkException(message: 'Network error: Please check your connection.');
    } on ServerException { // Re-throw specific exceptions if needed
       rethrow;
    } catch (e) {
       print('Unexpected error during API call: $e');
      // Catch-all for other errors like JSON parsing issues
      throw ServerException(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<List<ArticleApiModel>> getTopHeadlines({String country = ApiConstants.defaultCountry}) async {
    final uri = _buildUri(ApiConstants.topHeadlines, {'country': country});
    return await _fetchNews(uri);
  }

  @override
  Future<List<ArticleApiModel>> searchNews(String query) async {
    // NewsAPI might require URL encoding for the query
    final uri = _buildUri(ApiConstants.everything, {'q': query}); 
    return await _fetchNews(uri);
  }
} 
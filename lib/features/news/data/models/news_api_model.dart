import 'dart:convert';

// Helper function to safely parse DateTime
DateTime? _parseDateTime(String? dateString) {
  if (dateString == null) return null;
  try {
    return DateTime.parse(dateString);
  } catch (e) {
    // Handle potential parsing errors, return null or default
    print('Error parsing date: $dateString, Error: $e');
    return null;
  }
}

class NewsApiResponse {
  final String status;
  final int totalResults;
  final List<ArticleApiModel> articles;

  NewsApiResponse({
    required this.status,
    required this.totalResults,
    required this.articles,
  });

  factory NewsApiResponse.fromJson(Map<String, dynamic> json) {
    return NewsApiResponse(
      status: json['status'] ?? 'error',
      totalResults: json['totalResults'] ?? 0,
      articles: (json['articles'] as List<dynamic>? ?? [])
          .map((articleJson) => ArticleApiModel.fromJson(articleJson as Map<String, dynamic>))
          .toList(),
    );
  }

  // Optional: Helper to decode directly from JSON string
  factory NewsApiResponse.fromJsonString(String jsonString) {
     try {
      return NewsApiResponse.fromJson(json.decode(jsonString));
    } catch (e) {
      print('Error decoding NewsApiResponse JSON: $e');
      // Return an empty/error response or rethrow
      return NewsApiResponse(status: 'error', totalResults: 0, articles: []);
    }
  }
}

class ArticleApiModel {
  final SourceApiModel? source;
  final String? author;
  final String? title;
  final String? description;
  final String? url;
  final String? urlToImage;
  final String? publishedAt; // Keep as String for now, parse later
  final String? content;

  ArticleApiModel({
    this.source,
    this.author,
    this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
  });

  factory ArticleApiModel.fromJson(Map<String, dynamic> json) {
    return ArticleApiModel(
      source: json['source'] != null ? SourceApiModel.fromJson(json['source']) : null,
      author: json['author'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      url: json['url'] as String?,
      urlToImage: json['urlToImage'] as String?,
      publishedAt: json['publishedAt'] as String?, // Keep as String
      content: json['content'] as String?, // Often partial in NewsAPI free tier
    );
  }
}

class SourceApiModel {
  final String? id;
  final String? name;

  SourceApiModel({this.id, this.name});

  factory SourceApiModel.fromJson(Map<String, dynamic> json) {
    return SourceApiModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
    );
  }
} 
class ApiConstants {
  static const String newsApiBaseUrl = 'https://newsapi.org/v2';

  static const String newsApiKey = String.fromEnvironment('NEWS_API_KEY',
      defaultValue: '21be3053956f4dd5a7c78a2ef00c9510');

  static const String defaultCountry = 'us';
  static const int defaultPageSize = 20;

  static const String topHeadlines = '/top-headlines';
  static const String everything = '/everything';

  ApiConstants._();

  static bool get isApiKeyAvailable =>
      newsApiKey.isNotEmpty &&
      newsApiKey != '21be3053956f4dd5a7c78a2ef00c9510' &&
      newsApiKey != '';
}

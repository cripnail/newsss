/// Exception thrown when a server error occurs during an API call.
class ServerException implements Exception {
  final String message;
  ServerException({this.message = 'A server error occurred.'});

  @override
  String toString() => message;
}

/// Exception thrown when a local database operation fails.
class DatabaseException implements Exception {
   final String message;
  DatabaseException({this.message = 'A database error occurred.'});

  @override
  String toString() => message;
}

/// Exception thrown when the requested data is not found.
class NotFoundException implements Exception {
   final String message;
  NotFoundException({this.message = 'Data not found.'});

  @override
  String toString() => message;
}

/// Exception for network-related issues.
class NetworkException implements Exception {
   final String message;
  NetworkException({this.message = 'Network error occurred. Please check your connection.'});

  @override
  String toString() => message;
} 
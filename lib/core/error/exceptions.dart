class ServerException implements Exception {
  final String message;

  ServerException({this.message = 'A server error occurred.'});

  @override
  String toString() => message;
}

class DatabaseException implements Exception {
  final String message;

  DatabaseException({this.message = 'A database error occurred.'});

  @override
  String toString() => message;
}

class NotFoundException implements Exception {
  final String message;

  NotFoundException({this.message = 'Data not found.'});

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;

  NetworkException(
      {this.message = 'Network error occurred. Please check your connection.'});

  @override
  String toString() => message;
}

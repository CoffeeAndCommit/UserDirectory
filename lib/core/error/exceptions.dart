class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Server Error']);
  
  @override
  String toString() => message;
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'Cache Error']);
  
  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'No Internet Connection']);
  
  @override
  String toString() => message;
}

class CachedDataException implements Exception {
  final List<dynamic> cachedData;
  final String message;
  CachedDataException(this.cachedData, this.message);
  
  @override
  String toString() => message;
}

import '../../domain/models/user_model.dart';
import '../../domain/repositories/user_repository.dart';
import '../sources/user_local_data_source.dart';
import '../sources/user_remote_data_source.dart';
import '../../core/error/exceptions.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<User>> getUsers() async {
    try {
      final remoteUsers = await remoteDataSource.getUsers();
    
      await localDataSource.cacheUsers(remoteUsers);
      return remoteUsers;
    } on NetworkException {
      try {
        final localUsers = await localDataSource.getCachedUsers();
        throw CachedDataException(localUsers, 'You are offline. Showing cached users.');
      } on CacheException {
        throw NetworkException('No internet connection and no cached data available.');
      }
    } on ServerException catch (e) {
      try {
        final localUsers = await localDataSource.getCachedUsers();
        throw CachedDataException(localUsers, 'Server error. Showing cached users: ${e.message}');
      } on CacheException {
        throw ServerException(e.message);
      }
    }
  }
}

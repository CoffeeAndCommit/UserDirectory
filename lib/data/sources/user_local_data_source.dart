import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/user_model.dart';
import '../../core/error/exceptions.dart';

abstract class UserLocalDataSource {
  Future<List<User>> getCachedUsers();
  Future<void> cacheUsers(List<User> usersToCache);
}

const cachedUsersKey = 'CACHED_USERS';

class UserLocalDataSourceImpl implements UserLocalDataSource {
  final SharedPreferences sharedPreferences;

  UserLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<User>> getCachedUsers() async {
    final jsonString = sharedPreferences.getString(cachedUsersKey);
    if (jsonString != null) {
      return User.listFromJson(jsonString);
    } else {
      throw CacheException('No cached users found');
    }
  }

  @override
  Future<void> cacheUsers(List<User> usersToCache) async {
    final jsonString = User.listToJson(usersToCache);
    await sharedPreferences.setString(cachedUsersKey, jsonString);
  }
}

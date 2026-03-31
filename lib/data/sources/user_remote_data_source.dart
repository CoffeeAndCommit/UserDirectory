import 'package:http/http.dart' as http;
import '../../domain/models/user_model.dart';
import '../../core/error/exceptions.dart';

abstract class UserRemoteDataSource {
  Future<List<User>> getUsers();
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final http.Client client;

  UserRemoteDataSourceImpl({required this.client});

  @override
  Future<List<User>> getUsers() async {
    try {
      final response = await client.get(
        Uri.parse('https://jsonplaceholder.typicode.com/users'),
      );

      if (response.statusCode == 200) {
        return User.listFromJson(response.body);
      } else {
        throw ServerException('Failed to load users from API: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Network error occurred: $e');
    }
  }
}

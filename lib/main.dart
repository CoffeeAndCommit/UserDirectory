import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'data/repositories/user_repository_impl.dart';
import 'data/sources/user_local_data_source.dart';
import 'data/sources/user_remote_data_source.dart';
import 'presentation/viewmodels/user_viewmodel.dart';
import 'presentation/views/user_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();
  final client = http.Client();
  
  final localDataSource = UserLocalDataSourceImpl(sharedPreferences: sharedPreferences);
  final remoteDataSource = UserRemoteDataSourceImpl(client: client);
  
  final userRepository = UserRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserViewModel(repository: userRepository),
        ),
      ],
      child: const UserDirectoryApp(),
    ),
  );
}

class UserDirectoryApp extends StatelessWidget {
  const UserDirectoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Directory',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.black,
        ),
      ),
      home: const UserListScreen(),
    );
  }
}

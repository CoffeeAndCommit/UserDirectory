import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/error/exceptions.dart';
import '../../core/state/ui_state.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/user_repository.dart';

class UserViewModel extends ChangeNotifier {
  final UserRepository repository;

  UserViewModel({required this.repository});

  UIState<List<User>> _state = UIInitial();
  UIState<List<User>> get state => _state;

  String? _snackBarMessage;
  String? get snackBarMessage => _snackBarMessage;

  void clearSnackBarMessage() {
    _snackBarMessage = null;
  }

  List<User> _allUsers = [];
  List<User> _filteredUsers = [];
  List<User> _visibleUsers = [];

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  final int _batchSize = 5;
  int _currentOffset = 0;

  Timer? _debounce;
  String _currentQuery = '';

  Future<void> fetchUsers() async {
    _state = UILoading<List<User>>();
    notifyListeners();

    try {
      _allUsers = await repository.getUsers();
      _filteredUsers = List.from(_allUsers);
      _currentOffset = 0;
      _visibleUsers = [];
      _loadNextBatch();
    } on CachedDataException catch (e) {
      _snackBarMessage = e.message;
      _allUsers = e.cachedData.cast<User>();
      _filteredUsers = List.from(_allUsers);
      _currentOffset = 0;
      _visibleUsers = [];
      _loadNextBatch(); // This sets _state to UISuccess!
    } catch (e) {
      _state = UIError<List<User>>(e.toString());
      notifyListeners();
    }
  }

  void _loadNextBatch() {
    if (_currentOffset >= _filteredUsers.length) {
      _hasMore = false;
    } else {
      final end = (_currentOffset + _batchSize < _filteredUsers.length)
          ? _currentOffset + _batchSize
          : _filteredUsers.length;

      _visibleUsers.addAll(_filteredUsers.sublist(_currentOffset, end));
      _currentOffset = end;
      _hasMore = end < _filteredUsers.length;
    }

    if (_visibleUsers.isEmpty) {
      _state = UIEmpty<List<User>>();
    } else {
      _state = UISuccess<List<User>>(List.from(_visibleUsers));
    }
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore) return;

    _isLoadingMore = true;
    notifyListeners();

    // Simulate network delay for infinite scroll loading effect
    await Future.delayed(const Duration(milliseconds: 800));
    print("HIIIIIIIIIIIIIIII");
    _loadNextBatch();

    _isLoadingMore = false;
    notifyListeners();
  }

  void search(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      _currentQuery = query.toLowerCase();

      if (_currentQuery.isEmpty) {
        _filteredUsers = List.from(_allUsers);
      } else {
        _filteredUsers = _allUsers
            .where((user) => user.name.toLowerCase().contains(_currentQuery))
            .toList();
      }

      _currentOffset = 0;
      _visibleUsers = [];
      _hasMore = true;
      _loadNextBatch();
    });
  }

  void retry() {
    fetchUsers();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/state/ui_state.dart';
import '../../domain/models/user_model.dart';
import '../viewmodels/user_viewmodel.dart';
import '../widgets/user_card.dart';
import '../widgets/glass_background.dart';
import 'user_detail_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  UIState<List<User>>? _previousState;
  late UserViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<UserViewModel>();
    _viewModel.addListener(_onViewModelChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.fetchUsers();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _viewModel.loadMore();
      }
    });
  }

  void _onViewModelChange() {
    final currentState = _viewModel.state;
    
    // 1. Check for independent snackbar messages (like offline caching warning)
    if (_viewModel.snackBarMessage != null) {
      final msg = _viewModel.snackBarMessage!;
      _viewModel.clearSnackBarMessage();
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              msg,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.orangeAccent, // distinct color for offline warning
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
          ),
        );
      });
    }

    // 2error
    if (currentState is UIError && _previousState != currentState) {
      _previousState = currentState;
      final errorState = currentState as UIError<List<User>>;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorState.message,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
          ),
        );
      });
    } else if (currentState is! UIError) {
      _previousState = currentState;
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChange);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'User Directory',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const Icon(Icons.group, color: Colors.white),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search users by name...',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 16,
                  ),
                ),
                onChanged: (value) {
                  context.read<UserViewModel>().search(value);
                },
              ),
            ),
            Expanded(
              child: Consumer<UserViewModel>(
                builder: (context, viewModel, child) {
                  final state = viewModel.state;

                  if (state is UIInitial || state is UILoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  } else if (state is UIError) {
                    final errorState = state as UIError<List<User>>;
                    return _buildErrorWidget(errorState.message, viewModel);
                  } else if (state is UIEmpty) {
                    return Center(
                      child: Text(
                        'No users found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    );
                  } else if (state is UISuccess) {
                    final data = (state as UISuccess<List<User>>).data;
                    return _buildUserList(data, viewModel);
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message, UserViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: () async => viewModel.retry(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Oops! Something went wrong.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => viewModel.retry(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserList(List<User> users, UserViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: () async => viewModel.retry(),
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: users.length + (viewModel.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == users.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          }

          final user = users[index];
          return UserCard(
            user: user,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserDetailScreen(user: user),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

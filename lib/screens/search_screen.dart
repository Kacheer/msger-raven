import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/datasources/remote/api_client.dart';
import '../theme/app_theme.dart';
import 'chat_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchUsers(String searchTerm) async {
    if (searchTerm.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final apiClient = context.read<ApiClient>();
      final response = await apiClient.searchUsers(
        searchTerm: searchTerm.trim(),
        page: 1,
        pageSize: 50,
      );

      setState(() {
        if (response.data is List) {
          _searchResults = response.data as List<dynamic>;
        } else if (response.data is Map) {
          _searchResults = (response.data['users'] as List?)?.cast<dynamic>() ?? [];
        } else {
          _searchResults = [];
        }
        _hasSearched = true;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка поиска: $e')),
        );
      }
    }
  }

  void _openUserChat(dynamic user) {
    final userId = user['id'] ?? user['userId'];
    final username = user['username'] ?? 
        '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'.trim();
    final avatarUrl = user['avatarUrl'] as String?;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка: ID пользователя не найден')),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          userId: userId.toString(),
          username: username.isNotEmpty ? username : 'Пользователь',
          avatarUrl: avatarUrl,
          isNewChat: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Поиск'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Введите никнейм или имя...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchResults = [];
                            _hasSearched = false;
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {});
                if (value.isNotEmpty) {
                  _searchUsers(value);
                }
              },
            ),
          ),
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            const SizedBox(height: 16),
            Text(
              'Введите имя или никнейм',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search,
              size: 64,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            const SizedBox(height: 16),
            Text(
              'Пользователи не найдены',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: _searchResults.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        indent: 72,
        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.1),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        final username = user['username'] ?? 
            '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'.trim();
        final avatarUrl = user['avatarUrl'] as String?;
        final description = user['description'] as String?;

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
            backgroundColor: AppTheme.lightButtonBg.withOpacity(0.3),
            child: avatarUrl == null
                ? Text(
                    username.isNotEmpty ? username[0].toUpperCase() : '?',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          title: Text(username),
          subtitle: description != null
              ? Text(
                  description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          trailing: Icon(
            Icons.message,
            color: AppTheme.lightButtonBg,
          ),
          onTap: () => _openUserChat(user),
        );
      },
    );
  }
}

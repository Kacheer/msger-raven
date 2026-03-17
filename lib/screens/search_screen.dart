import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/datasources/remote/api_client.dart';
import '../theme/app_theme.dart';
import 'chat_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final apiClient = context.read<ApiClient>();
      final response = await apiClient.get(
        '/Users/list/search/user?SearchTerm=$query&Page=1&PageSize=25',
      );

      if (!mounted) return;
      setState(() {
        if (response.data is Map) {
          _searchResults = (response.data['users'] as List?)?.cast<dynamic>() ?? [];
        } else if (response.data is List) {
          _searchResults = response.data as List<dynamic>;
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка поиска: $e')),
      );
    }
  }

  void _openChat(dynamic user) {
    final userId = user['id'] ?? user['userId'];
    final displayName = user['username'] ?? '${user['firstName']} ${user['lastName']}';
    final avatarUrl = user['avatarUrl'] as String?;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          chatId: userId.toString(),
          username: displayName,
          avatarUrl: avatarUrl,
          isNewChat: true,
        ),
      ),
    ).then((_) {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Поиск пользователей'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Поле поиска
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDarkMode
                      ? AppTheme.darkBg3
                      : AppTheme.lightBg2,
                ),
              ),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _searchUsers,
              decoration: InputDecoration(
                hintText: 'Введите имя или никнейм...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ),

          // Результаты поиска
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_search,
                              size: 80,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'Начните поиск'
                                  : 'Пользователи не найдены',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: _searchResults.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          indent: 72,
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.1),
                        ),
                        itemBuilder: (context, index) {
                          final user = _searchResults[index];
                          final username = user['username'] ?? 'Unknown';
                          final displayName =
                              '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'
                                  .trim();
                          final avatarUrl = user['avatarUrl'] as String?;

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: avatarUrl != null &&
                                      avatarUrl.isNotEmpty
                                  ? NetworkImage(avatarUrl)
                                  : null,
                              backgroundColor:
                                  AppTheme.lightButtonBg.withOpacity(0.3),
                              child: avatarUrl == null || avatarUrl.isEmpty
                                  ? Text(
                                      username.isNotEmpty
                                          ? username[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                              onBackgroundImageError: (exception, stackTrace) {
                                // Ошибка загрузки - показываем букву
                              },
                            ),
                            title: Text(username),
                            subtitle: Text(displayName),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _openChat(user),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/datasources/remote/api_client.dart';
import '../theme/app_theme.dart';
import '../main.dart';
import 'chat_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const HomeScreen({Key? key, required this.onLogout}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _chats = [];
  bool _isLoading = false;
  dynamic _userProfile;
  bool _showProfileSidebar = false;

  @override
  void initState() {
    super.initState();
    _loadChats();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final apiClient = context.read<ApiClient>();
      final response = await apiClient.get('/Users/profile');
      setState(() {
        _userProfile = response.data;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _loadChats() async {
    setState(() => _isLoading = true);
    try {
      final apiClient = context.read<ApiClient>();
      final response = await apiClient.getChats(page: 1, pageSize: 100);

      setState(() {
        if (response.data is Map) {
          _chats = (response.data['chats'] as List?)?.cast<dynamic>() ?? [];
        } else if (response.data is List) {
          _chats = response.data as List<dynamic>;
        } else {
          _chats = [];
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteChat(String chatId) async {
    try {
      await context.read<ApiClient>().delete('/Chats/$chatId');
      await _loadChats();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Чат удалён')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }

  void _showDeleteConfirmation(dynamic chat) {
    final chatId = chat['id'] ?? chat['chatId'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить чат?'),
        content: const Text('Вы уверены, что хотите удалить чат?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Чат остаётся в списке (Dismissible уже вернул его)
            },
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteChat(chatId.toString());
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _openSearchScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchScreen()),
    ).then((_) => _loadChats());
  }

  void _openChat(dynamic chat) {
    final chatId = chat['id'] ?? chat['chatId'];
    final chatName = chat['name'] ?? 'Чат';
    final avatarUrl = chat['avatarUrl'] as String?;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          chatId: chatId.toString(),
          username: chatName,
          avatarUrl: avatarUrl,
          isNewChat: false,
        ),
      ),
    ).then((_) => _loadChats());
  }

  void _toggleProfileSidebar() {
    setState(() => _showProfileSidebar = !_showProfileSidebar);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // ✅ Добавить логотип вместо иконки
            Image.asset(
              isDarkMode
                  ? 'assets/images/logo_light.png'
                  : 'assets/images/logo_dark.png',
              height: 40,
              width: 40,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.lightButtonBg.withOpacity(0.2),
                  ),
                  child: Icon(
                    Icons.chat_rounded,
                    size: 20,
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            const Text('Raven'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _openSearchScreen,
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _toggleProfileSidebar,
          ),
        ],
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 500) {
            _toggleProfileSidebar();
          }
        },
        child: Stack(
          children: [
            // Основной контент
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _chats.isEmpty
                    ? _buildEmptyState(context)
                    : RefreshIndicator(
                        onRefresh: _loadChats,
                        child: ListView.separated(
                          itemCount: _chats.length,
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
                            final chat = _chats[index];
                            final chatName = chat['name'] ?? 'Чат';
                            final avatarUrl = chat['avatarUrl'] as String?;
                            final lastMessage =
                                chat['lastMessage'] ?? 'Нет сообщений';
                            final unreadCount = chat['unreadCount'] ?? 0;

                            return Dismissible(
                              key: Key(chat['id'] ?? chat['chatId'] ?? 'unknown'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 16),
                                color: Colors.red,
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              onDismissed: (direction) {
                                // ✅ Сначала удаляем из списка
                                setState(() {
                                  _chats.removeAt(index);
                                });
                                // Показать подтверждение
                                _showDeleteConfirmation(chat);
                              },
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                                      ? NetworkImage(avatarUrl)
                                      : null,
                                  backgroundColor:
                                      AppTheme.lightButtonBg.withOpacity(0.3),
                                  radius: 28,
                                  child: avatarUrl == null || avatarUrl.isEmpty
                                      ? Text(
                                          chatName.isNotEmpty
                                              ? chatName[0].toUpperCase()
                                              : '?',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        )
                                      : null,
                                  onBackgroundImageError: (exception, stackTrace) {
                                    // Ошибка загрузки аватарки - показываем букву
                                  },
                                ),
                                title: Text(
                                  chatName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                ),
                                subtitle: Text(
                                  lastMessage,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _formatTime(chat['updatedAt']),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                    if (unreadCount > 0) ...[
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.lightButtonBg,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          unreadCount.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                onTap: () => _openChat(chat),
                              ),
                            );
                          },
                        ),
                      ),

            // Полупрозрачный фон при открытой боковой панели
            if (_showProfileSidebar)
              GestureDetector(
                onTap: _toggleProfileSidebar,
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                ),
              ),

            // Боковая панель профиля (слева)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              left: _showProfileSidebar ? 0 : -350,
              top: 0,
              bottom: 0,
              width: 350,
              child: _buildProfileSidebar(context, isDarkMode),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openSearchScreen,
        child: const Icon(Icons.edit),
      ),
    );
  }

  Widget _buildProfileSidebar(BuildContext context, bool isDarkMode) {
    final username = _userProfile?['username'] ?? 'Пользователь';
    final firstName = _userProfile?['firstName'] ?? '';
    final lastName = _userProfile?['lastName'] ?? '';
    final avatarUrl = _userProfile?['avatarUrl'] as String?;

    return Container(
      color: isDarkMode ? AppTheme.darkBg2 : AppTheme.lightBg,
      child: Column(
        children: [
          // Закрытие боковой панели
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Профиль',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _toggleProfileSidebar,
                ),
              ],
            ),
          ),
          Divider(
              color: isDarkMode ? AppTheme.darkBg3 : AppTheme.lightBg2,
              height: 1),

          // Содержимое профиля
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Аватарка
                  CircleAvatar(
                    backgroundImage:
                        avatarUrl != null ? NetworkImage(avatarUrl) : null,
                    backgroundColor: AppTheme.lightButtonBg.withOpacity(0.3),
                    radius: 60,
                    child: avatarUrl == null
                        ? Text(
                            username.isNotEmpty
                                ? username[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 24),

                  // Никнейм
                  Text(
                    '@$username',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Имя и фамилия
                  Text(
                    '$firstName $lastName'.trim(),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Кнопки внизу
          Divider(
              color: isDarkMode ? AppTheme.darkBg3 : AppTheme.lightBg2,
              height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Кнопка переключения темы
                ListTile(
                  leading: Icon(
                    isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    color: AppTheme.lightButtonBg,
                  ),
                  title: Text(
                    isDarkMode ? 'Светлая тема' : 'Тёмная тема',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  onTap: () {
                    context.read<ThemeProvider>().toggleTheme();
                  },
                ),
                const SizedBox(height: 12),

                // Кнопка выхода
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: Text(
                    'Выйти из аккаунта',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.red,
                    ),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Выход'),
                        content:
                            const Text('Вы уверены, что хотите выйти?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Отмена'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              context.read<ApiClient>().clearToken();
                              widget.onLogout();
                            },
                            child: const Text('Выход',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
          const SizedBox(height: 16),
          Text(
            'Нет чатов',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Начните новый разговор',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _openSearchScreen,
            icon: const Icon(Icons.search),
            label: const Text('Найти человека'),
          ),
        ],
      ),
    );
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      final date = DateTime.parse(timestamp.toString());
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays == 0) {
        return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else if (diff.inDays == 1) {
        return 'Вчера';
      } else if (diff.inDays < 7) {
        return '${diff.inDays}д';
      } else {
        return '${date.day}.${date.month}';
      }
    } catch (e) {
      return '';
    }
  }
}

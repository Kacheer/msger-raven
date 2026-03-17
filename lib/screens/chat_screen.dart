import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../data/datasources/remote/api_client.dart';
import '../theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String username;
  final String? avatarUrl;
  final bool isNewChat;

  const ChatScreen({
    Key? key,
    required this.chatId,
    required this.username,
    this.avatarUrl,
    required this.isNewChat,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<dynamic> _messages = [];
  bool _isLoading = false;
  late TextEditingController _messageController;
  String? _actualChatId;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _actualChatId = widget.chatId;
    
    if (widget.isNewChat) {
      _createPersonalChat();
    } else {
      _loadMessages();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _createPersonalChat() async {
    try {
      final apiClient = context.read<ApiClient>();
      final response = await apiClient.post(
        '/Chats/personal/${widget.chatId}',
      );

      if (!mounted) return;
      
      final chatId = response.data['id'] ?? response.data['chatId'];
      setState(() {
        _actualChatId = chatId.toString();
      });
      
      await _loadMessages();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка создания чата: $e')),
      );
    }
  }

  Future<void> _loadMessages() async {
    if (!mounted || _actualChatId == null) return;
    setState(() => _isLoading = true);
    try {
      final apiClient = context.read<ApiClient>();
      final response = await apiClient.get(
        '/Messages/$_actualChatId?page=1&pageSize=50',
      );

      if (!mounted) return;
      setState(() {
        if (response.data is Map) {
          _messages = List.from(
            (response.data['messages'] as List?)?.cast<dynamic>() ?? [],
          ).reversed.toList();
        } else if (response.data is List) {
          _messages = List.from(response.data as List<dynamic>).reversed.toList();
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _actualChatId == null) return;

    _messageController.clear();

    try {
      final apiClient = context.read<ApiClient>();
      final formData = FormData.fromMap({
        'ChatId': _actualChatId,
        'Content': content,
      });

      final response = await apiClient.dio.post(
        '/Messages/send?targetUserId=$_actualChatId',
        data: formData,
      );

      // ✅ Добавляем реальное сообщение с сервера вместо перезагрузки
      if (mounted && response.statusCode == 200) {
        setState(() {
          _messages.insert(0, response.data);
        });
      }
    } catch (e) {
      if (!mounted) return;
      _messageController.text = content;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка отправки: $e')),
      );
    }
  }

  Future<void> _deleteMessage(String messageId) async {
    try {
      final apiClient = context.read<ApiClient>();
      await apiClient.delete('/Messages/delete/$messageId');
      
      if (mounted) {
        setState(() {
          _messages.removeWhere((m) => (m['id'] ?? m['messageId']) == messageId);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка удаления: $e')),
      );
    }
  }

  void _showMessageContextMenu(dynamic message, Offset position) {
    final messageId = message['id'] ?? message['messageId'];
    final senderId = message['senderId'] ?? '';
    final currentUserId = context.read<ApiClient>().currentUserId ?? '';
    final isOwnMessage = senderId == currentUserId;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + 50, // ✅ Смещаем вниз под сообщение
        MediaQuery.of(context).size.width - position.dx,
        0,
      ),
      items: [
        if (isOwnMessage)
          PopupMenuItem(
            child: const Row(
              children: [
                Icon(Icons.edit, size: 20),
                SizedBox(width: 8),
                Text('Редактировать'),
              ],
            ),
            onTap: () {
              _showEditMessageDialog(messageId, message['content']);
            },
          ),
        if (isOwnMessage)
          PopupMenuItem(
            child: const Row(
              children: [
                Icon(Icons.delete, size: 20, color: Colors.red),
                SizedBox(width: 8),
                Text('Удалить', style: TextStyle(color: Colors.red)),
              ],
            ),
            onTap: () {
              _showDeleteConfirmation(messageId);
            },
          ),
        PopupMenuItem(
          child: const Row(
            children: [
              Icon(Icons.reply, size: 20),
              SizedBox(width: 8),
              Text('Ответить'),
            ],
          ),
          onTap: () {
            // TODO: Reply to message
          },
        ),
        PopupMenuItem(
          child: const Row(
            children: [
              Icon(Icons.copy, size: 20),
              SizedBox(width: 8),
              Text('Копировать'),
            ],
          ),
          onTap: () {
            // TODO: Copy message
          },
        ),
      ],
    );
  }

  void _showEditMessageDialog(String messageId, String currentContent) {
    final controller = TextEditingController(text: currentContent);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редактировать сообщение'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          minLines: 1,
          decoration: InputDecoration(
            hintText: 'Новый текст',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _editMessage(messageId, controller.text.trim());
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  Future<void> _editMessage(String messageId, String newContent) async {
    try {
      final apiClient = context.read<ApiClient>();
      final response = await apiClient.put(
        '/Messages/edit/$messageId',
        data: {'content': newContent},
      );

      if (mounted) {
        final index = _messages.indexWhere((m) => (m['id'] ?? m['messageId']) == messageId);
        if (index != -1) {
          setState(() {
            _messages[index]['content'] = newContent;
            _messages[index]['isEdited'] = true;
          });
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сообщение отредактировано')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка редактирования: $e')),
      );
    }
  }

  void _showDeleteConfirmation(String messageId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить сообщение?'),
        content: const Text('Это действие нельзя отменить'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteMessage(messageId);
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.lightButtonBg.withOpacity(0.2),
              ),
              child: widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        widget.avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Text(
                              widget.username.isNotEmpty
                                  ? widget.username[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Center(
                      child: Text(
                        widget.username.isNotEmpty
                            ? widget.username[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.username,
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(
                        child: Text(
                          'Нет сообщений',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : ListView.builder(
                        reverse: true,
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final content = message['content'] ?? '';
                          final timestamp = message['createdAt'] ?? '';
                          final senderId = message['senderId'] ?? '';
                          final currentUserId = 
                              context.read<ApiClient>().currentUserId ?? '';
                          final isOwnMessage = senderId == currentUserId;
                          final isEdited = message['isEdited'] ?? false;

                          return GestureDetector(
                            onLongPress: () {
                              // ✅ Получаем позицию контекста сообщения
                              final renderBox = context.findRenderObject() as RenderBox;
                              final offset = renderBox.localToGlobal(Offset.zero);
                              
                              _showMessageContextMenu(
                                message,
                                Offset(
                                  isOwnMessage 
                                    ? MediaQuery.of(context).size.width - 200
                                    : 16,
                                  offset.dy + (index * 100),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: Align(
                                alignment: isOwnMessage
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isOwnMessage
                                        ? AppTheme.lightButtonBg
                                        : (isDarkMode
                                            ? AppTheme.darkBg3
                                            : AppTheme.lightBg2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: isOwnMessage
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        content,
                                        style: TextStyle(
                                          color: isOwnMessage
                                              ? Colors.white
                                              : (isDarkMode
                                                  ? Colors.white
                                                  : Colors.black),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _formatTime(timestamp),
                                            style: TextStyle(
                                              color: isOwnMessage
                                                  ? Colors.white70
                                                  : (isDarkMode
                                                      ? Colors.grey[400]
                                                      : Colors.grey[600]),
                                              fontSize: 11,
                                            ),
                                          ),
                                          if (isEdited) ...[
                                            const SizedBox(width: 4),
                                            Text(
                                              '(отредактировано)',
                                              style: TextStyle(
                                                color: isOwnMessage
                                                    ? Colors.white70
                                                    : (isDarkMode
                                                        ? Colors.grey[400]
                                                        : Colors.grey[600]),
                                                fontSize: 10,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDarkMode ? AppTheme.darkBg3 : AppTheme.lightBg2,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Напишите сообщение...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    maxLines: 3,
                    minLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  mini: true,
                  onPressed: _sendMessage,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null || timestamp.toString().isEmpty) {
      return DateTime.now().add(const Duration(hours: 5)).toString().substring(11, 16);
    }
    try {
      final dateStr = timestamp.toString().replaceAll('Z', '+00:00');
      var date = DateTime.parse(dateStr);
      // ✅ Добавляем 5 часов к серверному времени
      date = date.add(const Duration(hours: 5));
      final now = DateTime.now();
      final diff = now.difference(date);

      final timeStr = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      
      if (diff.inSeconds < 60) {
        return timeStr;
      } else if (diff.inMinutes < 60) {
        return timeStr;
      } else if (diff.inHours < 24) {
        return timeStr;
      } else if (diff.inDays == 1) {
        return 'вчера $timeStr';
      } else if (diff.inDays < 7) {
        return '${diff.inDays}д назад $timeStr';
      } else {
        return '${date.day}.${date.month}.${date.year} $timeStr';
      }
    } catch (e) {
      return DateTime.now().add(const Duration(hours: 5)).toString().substring(11, 16);
    }
  }
}

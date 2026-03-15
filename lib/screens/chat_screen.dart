import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/datasources/remote/api_client.dart';
import '../theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  final String? chatId;
  final String? userId;
  final String username;
  final String? avatarUrl;
  final bool isNewChat;

  const ChatScreen({
    Key? key,
    this.chatId,
    this.userId,
    required this.username,
    this.avatarUrl,
    this.isNewChat = false,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  late String _chatId;
  bool _isLoading = false;
  bool _isSending = false;
  late String _currentUserId;
  bool _showEmojiPicker = false;

  @override
  void initState() {
    super.initState();
    _chatId = widget.chatId ?? '';
    final apiClient = context.read<ApiClient>();
    _currentUserId = apiClient.currentUserId ?? '';

    if (!widget.isNewChat && _chatId.isNotEmpty) {
      _loadMessages();
    }
  }

  Future<void> _loadMessages() async {
    if (_chatId.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final apiClient = context.read<ApiClient>();
      final response = await apiClient.get(
        '/Messages/$_chatId',
        queryParameters: {'page': 1, 'pageSize': 50},
      );

      setState(() {
        _messages.clear();
        if (response.data is Map) {
          final msgList = (response.data['messages'] as List?)?.cast<dynamic>() ?? [];
          for (final msg in msgList.reversed) {
            _messages.add(_parseMessage(msg));
          }
        } else if (response.data is List) {
          for (final msg in (response.data as List).reversed) {
            _messages.add(_parseMessage(msg));
          }
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки сообщений: $e')),
        );
      }
    }
  }

  Map<String, dynamic> _parseMessage(dynamic msg) {
    final senderId = msg['senderId'].toString();
    return {
      'id': msg['id'],
      'content': msg['content'],
      'createdAt': msg['createdAt'],
      'senderId': senderId,
      'isOwn': senderId == _currentUserId,
    };
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final messageContent = _messageController.text;
    _messageController.clear();
    setState(() => _showEmojiPicker = false);

    setState(() => _isSending = true);

    try {
      final apiClient = context.read<ApiClient>();

      final response = await apiClient.sendMessage(
        chatId: _chatId.isNotEmpty ? _chatId : '',
        content: messageContent,
        targetUserId: widget.isNewChat && widget.userId != null ? widget.userId : null,
      );

      if (widget.isNewChat && _chatId.isEmpty && response.data is Map) {
        final newChatId = response.data['chatId'] ?? response.data['id'];
        if (newChatId != null) {
          setState(() => _chatId = newChatId.toString());
        }
      }

      setState(() {
        _messages.insert(0, {
          'id': response.data is Map ? (response.data['id'] ?? response.data['messageId']) : 'local_${DateTime.now().millisecondsSinceEpoch}',
          'content': messageContent,
          'createdAt': DateTime.now().toIso8601String(),
          'senderId': _currentUserId,
          'isOwn': true,
        });
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка отправки: ${e.toString()}')),
        );
      }
      _messageController.text = messageContent;
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              CircleAvatar(
                backgroundImage: widget.avatarUrl != null
                    ? NetworkImage(widget.avatarUrl!)
                    : null,
                backgroundColor: AppTheme.lightButtonBg.withOpacity(0.3),
                radius: 16,
                child: widget.avatarUrl == null
                    ? Text(
                        widget.username.isNotEmpty ? widget.username[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.username,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'В сети',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightButtonBg,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          elevation: 0,
          backgroundColor: isDarkMode ? AppTheme.darkBg2 : AppTheme.lightBg,
        ),
        body: Column(
          children: [
            // Список сообщений
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Начните разговор',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          reverse: true,
                          itemCount: _messages.length,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            final isOwn = message['isOwn'] as bool;

                            return Align(
                              alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                                ),
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? AppTheme.darkBg3
                                      : AppTheme.lightBg,
                                  border: Border.all(
                                    color: isDarkMode
                                        ? AppTheme.darkBg3
                                        : const Color(0xFFEFEFEF),
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Column(
                                  crossAxisAlignment: isOwn
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      message['content'] ?? '',
                                      style: TextStyle(
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatMessageTime(message['createdAt']),
                                      style: TextStyle(
                                        color: isDarkMode
                                            ? AppTheme.darkAccent
                                            : AppTheme.lightAccent,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),

            // Поле ввода сообщения
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? AppTheme.darkBg2 : AppTheme.lightBg,
                border: Border(
                  top: BorderSide(
                    color: isDarkMode
                        ? AppTheme.darkBg3
                        : const Color(0xFFEFEFEF),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // Кнопка прикрепления медиа
                      IconButton(
                        icon: Icon(
                          Icons.attach_file,
                          color: AppTheme.lightButtonBg,
                        ),
                        onPressed: () {
                          // TODO: Реализовать выбор медиа
                        },
                        tooltip: 'Прикрепить файл',
                      ),

                      // Кнопка эмодзи
                      IconButton(
                        icon: Icon(
                          Icons.emoji_emotions_outlined,
                          color: AppTheme.lightButtonBg,
                        ),
                        onPressed: () {
                          setState(() => _showEmojiPicker = !_showEmojiPicker);
                        },
                        tooltip: 'Эмодзи',
                      ),

                      // Поле ввода сообщения
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDarkMode ? AppTheme.darkBg3 : AppTheme.lightBg3,
                            border: Border.all(
                              color: isDarkMode
                                  ? AppTheme.darkAccent.withOpacity(0.3)
                                  : AppTheme.lightBg2,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: 'Сообщение...',
                              border: InputBorder.none,
                              filled: false,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            maxLines: null,
                            onChanged: (value) => setState(() {}),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Кнопка отправки
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.lightButtonBg,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: _isSending
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      isDarkMode
                                          ? AppTheme.darkButtonText
                                          : AppTheme.lightButtonText,
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.send_rounded,
                                  color: isDarkMode
                                      ? AppTheme.darkButtonText
                                      : AppTheme.lightButtonText,
                                ),
                          onPressed:
                              (_isSending || _messageController.text.isEmpty)
                                  ? null
                                  : _sendMessage,
                        ),
                      ),
                    ],
                  ),
                  // TODO: Добавить picker эмодзи когда _showEmojiPicker == true
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMessageTime(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      final date = DateTime.parse(timestamp.toString());
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }
}

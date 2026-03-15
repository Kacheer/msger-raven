class Chat {
  final String id;
  final String name;
  final String? description;
  final String? avatarUrl;
  final int type; // 0 = personal, 1 = group

  const Chat({
    required this.id,
    required this.name,
    this.description,
    this.avatarUrl,
    this.type = 0,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      avatarUrl: json['avatarUrl'],
      type: json['type'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'avatarUrl': avatarUrl,
    'type': type,
  };
}

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final DateTime createdAt;
  final bool isRead;

  const Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.isRead = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',
      chatId: json['chatId'] ?? '',
      senderId: json['senderId'] ?? '',
      content: json['content'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'chatId': chatId,
    'senderId': senderId,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'isRead': isRead,
  };
}

class CreateChatRequest {
  final String? name;
  final String? description;
  final int type;
  final List<String>? memberIds;
  final bool isPublic;

  CreateChatRequest({
    this.name,
    this.description,
    required this.type,
    this.memberIds,
    required this.isPublic,
  });

  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (description != null) 'description': description,
    'type': type,
    if (memberIds != null) 'memberIds': memberIds,
    'isPublic': isPublic,
  };
}

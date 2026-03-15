import 'package:flutter/material.dart';
import '../../data/models/chat_models.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChatItem extends StatelessWidget {
  final Chat chat;
  final VoidCallback onTap;

  const ChatItem({
    super.key,
    required this.chat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        backgroundImage: chat.avatarUrl != null
            ? CachedNetworkImageProvider(chat.avatarUrl!)
            : null,
        child: chat.avatarUrl == null
            ? Icon(
          chat.type == 0 ? Icons.person : Icons.people,
          color: Theme.of(context).colorScheme.primary,
        )
            : null,
      ),
      title: Text(
        chat.name ?? 'Chat',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        chat.description ?? 'No description',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Theme.of(context).colorScheme.outline,
      ),
      onTap: onTap,
    );
  }
}

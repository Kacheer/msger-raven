import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/chat_models.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/custom_text_field.dart';
import 'chats_page.dart';

class CreateChatPage extends ConsumerStatefulWidget {
  const CreateChatPage({super.key});

  @override
  ConsumerState<CreateChatPage> createState() => _CreateChatPageState();
}

class _CreateChatPageState extends ConsumerState<CreateChatPage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _userIdController;
  int _chatType = 0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _userIdController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);

    ref.listen(chatNotifierProvider, (previous, next) {
      next.when(
        data: (_) {
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ChatsPage()),
          );
        },
        loading: () {},
        error: (error, stack) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error')),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Chat'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chat Type',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: RadioListTile(
                    title: const Text('Personal'),
                    value: 0,
                    groupValue: _chatType,
                    onChanged: (value) =>
                        setState(() => _chatType = value ?? 0),
                  ),
                ),
                Expanded(
                  child: RadioListTile(
                    title: const Text('Group'),
                    value: 1,
                    groupValue: _chatType,
                    onChanged: (value) =>
                        setState(() => _chatType = value ?? 0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_chatType == 0) ...[
              CustomTextField(
                controller: _userIdController,
                label: 'User ID',
                hintText: 'Enter user ID',
              ),
            ] else ...[
              CustomTextField(
                controller: _nameController,
                label: 'Group Name',
                hintText: 'Enter group name',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                hintText: 'Enter group description',
                maxLines: 3,
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: chatState.isLoading ? null : () => _createChat(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: chatState.isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Create Chat'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createChat() {
    if (_chatType == 0) {
      final userId = _userIdController.text.trim();
      
      if (userId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter user ID')),
        );
        return;
      }
      
      final uuidPattern = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        caseSensitive: false,
      );
      
      if (!uuidPattern.hasMatch(userId)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid User ID format. Expected UUID format.'),
          ),
        );
        return;
      }
      
      ref.read(chatNotifierProvider.notifier)
          .createPersonalChat(userId);
    } else {
      if (_nameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter group name')),
        );
        return;
      }
      ref.read(chatNotifierProvider.notifier).createChat(
        name: _nameController.text,
        description: _descriptionController.text,
        type: 1,
      );
    }
  }
}

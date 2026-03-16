import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/datasources/remote/api_client.dart';
import 'chats_page.dart';

class CreateChatPage extends StatefulWidget {
  const CreateChatPage({super.key});

  @override
  State<CreateChatPage> createState() => _CreateChatPageState();
}

class _CreateChatPageState extends State<CreateChatPage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _userIdController;
  int _chatType = 0;
  bool _isLoading = false;

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

  Future<void> _createChat() async {
    if (_chatType == 0) {
      final userId = _userIdController.text.trim();
      
      if (userId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter user ID')),
        );
        return;
      }
      
      setState(() => _isLoading = true);
      try {
        final apiClient = context.read<ApiClient>();
        await apiClient.post('/Chats/personal/$userId', data: {});
        
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ChatsPage()),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      if (_nameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter group name')),
        );
        return;
      }
      
      setState(() => _isLoading = true);
      try {
        final apiClient = context.read<ApiClient>();
        await apiClient.post('/Chats/group', data: {
          'name': _nameController.text,
          'description': _descriptionController.text,
          'type': 1,
          'isPublic': false,
        });
        
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ChatsPage()),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              TextField(
                controller: _userIdController,
                decoration: InputDecoration(
                  labelText: 'User ID',
                  hintText: 'Enter user ID',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ] else ...[
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Group Name',
                  hintText: 'Enter group name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter group description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createChat,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Text('Create Chat'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

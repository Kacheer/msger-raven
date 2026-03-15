import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/api_client.dart';
import '../../data/datasources/remote/chat_remote_datasource.dart';
import '../../data/models/chat_models.dart';
import '../../domain/repositories/chat_repository.dart';
import 'auth_provider.dart';

final apiClientProvider = Provider((ref) => ApiClient());

final chatRemoteDataSourceProvider = Provider((ref) {
  // Используй apiClient из auth_provider, чтобы получить с токеном
  final apiClient = ref.watch(apiClientProvider);
  return ChatRemoteDataSource(apiClient);
});

final chatRepositoryProvider = Provider((ref) {
  final remoteDataSource = ref.watch(chatRemoteDataSourceProvider);
  return ChatRepository(remoteDataSource);
});

final chatsProvider = FutureProvider.family<List<Chat>, int>((ref, page) async {
  final chatRepo = ref.watch(chatRepositoryProvider);
  return chatRepo.getChats(page: page);
});

final chatProvider = FutureProvider.family<Chat, String>((ref, chatId) async {
  final chatRepo = ref.watch(chatRepositoryProvider);
  return chatRepo.getChat(chatId);
});

final messagesProvider = FutureProvider.family<List<Message>, String>((ref, chatId) async {
  final chatRepo = ref.watch(chatRepositoryProvider);
  return chatRepo.getMessages(chatId);
});

class ChatNotifier extends StateNotifier<AsyncValue<Chat>> {
  final ChatRepository _chatRepository;

  ChatNotifier(this._chatRepository) 
    : super(const AsyncValue.data(Chat(
        id: '',
        name: '',
        type: 0,
      )));

  Future<void> createChat({
    required String name,
    String? description,
    int type = 1,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _chatRepository.createGroupChat(CreateChatRequest(
        name: name,
        description: description,
        type: type,
        isPublic: false,
      ));
    });
  }

  Future<void> createPersonalChat(String targetUserId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _chatRepository.createPersonalChat(targetUserId),
    );
  }

  Future<void> createGroupChat(CreateChatRequest request) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _chatRepository.createGroupChat(request),
    );
  }
}

final chatNotifierProvider = StateNotifierProvider<ChatNotifier, AsyncValue<Chat>>((ref) {
  final chatRepo = ref.watch(chatRepositoryProvider);
  return ChatNotifier(chatRepo);
});

class MessagesNotifier extends StateNotifier<AsyncValue<List<Message>>> {
  final ChatRepository _chatRepository;

  MessagesNotifier(this._chatRepository) : super(const AsyncValue.data([]));

  Future<void> loadMessages(String chatId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _chatRepository.getMessages(chatId),
    );
  }

  Future<void> sendMessage(Message message, {String? filePath}) async {
    final currentState = state;
    if (currentState is AsyncData<List<Message>>) {
      try {
        final newMessage = await _chatRepository.sendMessage(message, filePath: filePath);
        state = AsyncData([...currentState.value, newMessage]);
      } catch (e) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await _chatRepository.deleteMessage(messageId);
      final currentState = state;
      if (currentState is AsyncData<List<Message>>) {
        state = AsyncData(
          currentState.value.where((m) => m.id != messageId).toList(),
        );
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> editMessage(String messageId, String content) async {
    try {
      final updatedMessage = await _chatRepository.editMessage(messageId, content);
      final currentState = state;
      if (currentState is AsyncData<List<Message>>) {
        state = AsyncData(
          currentState.value.map((m) => m.id == messageId ? updatedMessage : m).toList(),
        );
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final messagesNotifierProvider = 
    StateNotifierProvider<MessagesNotifier, AsyncValue<List<Message>>>((ref) {
  final chatRepo = ref.watch(chatRepositoryProvider);
  return MessagesNotifier(chatRepo);
});

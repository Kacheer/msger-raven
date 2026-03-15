import 'package:dio/dio.dart';
import '../../models/chat_models.dart';
import 'api_client.dart';

class ChatRemoteDataSource {
  final ApiClient _apiClient;

  ChatRemoteDataSource(this._apiClient);

  Future<List<Chat>> getChats({int page = 1, int pageSize = 25}) async {
    try {
      final response = await _apiClient.get(
        'Chats',
        queryParameters: {'page': page, 'pageSize': pageSize},
      );
      
      if (response.data == null) {
        return [];
      }
      
      // Парсим ответ - может быть список или объект с items
      List<dynamic> chatsData = [];
      if (response.data is List) {
        chatsData = response.data as List;
      } else if (response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        if (data['items'] is List) {
          chatsData = data['items'] as List;
        } else if (data['data'] is List) {
          chatsData = data['data'] as List;
        }
      }
      
      return chatsData
          .map((e) => Chat.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to get chats: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Failed to get chats: $e');
    }
  }

  Future<Chat> getChat(String chatId) async {
    try {
      final response = await _apiClient.get('Chats/$chatId');
      if (response.data is Map) {
        return Chat.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Invalid response format');
    } on DioException catch (e) {
      throw Exception('Failed to get chat: ${e.response?.data ?? e.message}');
    }
  }

  Future<Chat> createPersonalChat(String targetUserId) async {
    try {
      final response = await _apiClient.post('Chats/personal/$targetUserId');
      if (response.data == null) {
        throw Exception('Empty response from server');
      }
      if (response.data is Map) {
        return Chat.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Invalid response format');
    } on DioException catch (e) {
      throw Exception('Failed to create personal chat: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Failed to create personal chat: $e');
    }
  }

  Future<Chat> createGroupChat(CreateChatRequest request) async {
    try {
      final response = await _apiClient.post('Chats/group', data: request.toJson());
      if (response.data == null) {
        throw Exception('Empty response from server');
      }
      if (response.data is Map) {
        return Chat.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Invalid response format');
    } on DioException catch (e) {
      throw Exception('Failed to create group chat: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Failed to create group chat: $e');
    }
  }

  Future<List<Message>> getMessages(String chatId, {int page = 1, int pageSize = 25}) async {
    try {
      final response = await _apiClient.get(
        'Messages/$chatId',
        queryParameters: {'page': page, 'pageSize': pageSize},
      );
      
      if (response.data is List) {
        return (response.data as List).map((e) => Message.fromJson(e as Map<String, dynamic>)).toList();
      } else if (response.data is Map && response.data['items'] != null) {
        return (response.data['items'] as List).map((e) => Message.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Failed to get messages: ${e.message}');
    }
  }

  Future<Message> sendMessage(Message message, {String? filePath}) async {
    try {
      final formData = FormData.fromMap({
        'ChatId': message.chatId,
        'Content': message.content ?? '',
      });
      
      if (filePath != null) {
        formData.files.add(MapEntry(
          'File',
          await MultipartFile.fromFile(filePath),
        ));
      }
      
      final response = await _apiClient.post('Messages/send', data: formData);
      return Message.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await _apiClient.delete('Messages/delete/$messageId');
    } on DioException catch (e) {
      throw Exception('Failed to delete message: ${e.message}');
    }
  }

  Future<Message> editMessage(String messageId, String content) async {
    try {
      final response = await _apiClient.put(
        'Messages/edit/$messageId',
        data: {'content': content},
      );
      return Message.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to edit message: ${e.message}');
    }
  }
}

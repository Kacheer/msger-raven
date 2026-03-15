import '../../data/datasources/remote/chat_remote_datasource.dart';
import '../../data/models/chat_models.dart';

class ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;

  ChatRepository(this._remoteDataSource);

  Future<List<Chat>> getChats({int page = 1, int pageSize = 25}) =>
      _remoteDataSource.getChats(page: page, pageSize: pageSize);

  Future<Chat> getChat(String chatId) =>
      _remoteDataSource.getChat(chatId);

  Future<Chat> createPersonalChat(String targetUserId) =>
      _remoteDataSource.createPersonalChat(targetUserId);

  Future<Chat> createGroupChat(CreateChatRequest request) =>
      _remoteDataSource.createGroupChat(request);

  Future<List<Message>> getMessages(String chatId, {int page = 1, int pageSize = 25}) =>
      _remoteDataSource.getMessages(chatId, page: page, pageSize: pageSize);

  Future<Message> sendMessage(Message message, {String? filePath}) =>
      _remoteDataSource.sendMessage(message, filePath: filePath);

  Future<void> deleteMessage(String messageId) =>
      _remoteDataSource.deleteMessage(messageId);

  Future<Message> editMessage(String messageId, String content) =>
      _remoteDataSource.editMessage(messageId, content);
}

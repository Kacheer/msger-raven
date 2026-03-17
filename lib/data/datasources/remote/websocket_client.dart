import 'dart:async';
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketClient {
  static const String _baseUrl = 'wss://ravenapp.ru/ws';
  
  WebSocketChannel? _channel;
  final Logger _logger = Logger();
  String? _token;
  
  // Stream контроллеры для различных событий
  final StreamController<Map<String, dynamic>> _messageStreamController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _statusStreamController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<bool> _connectionStreamController =
      StreamController<bool>.broadcast();
  
  // Публичные стримы
  Stream<Map<String, dynamic>> get messageStream =>
      _messageStreamController.stream;
  Stream<Map<String, dynamic>> get statusStream =>
      _statusStreamController.stream;
  Stream<bool> get connectionStream => _connectionStreamController.stream;
  
  bool get isConnected => _channel != null;
  
  // Установить токен
  void setToken(String token) {
    _token = token;
  }
  
  // Подключиться к WebSocket
  Future<void> connect(String chatId) async {
    try {
      final url = Uri.parse('$_baseUrl?token=$_token&chatId=$chatId');
      _channel = WebSocketChannel.connect(url);
      
      _logger.i('💡 WebSocket подключён: $chatId');
      _connectionStreamController.add(true);
      
      // Слушать входящие сообщения
      _channel!.stream.listen(
        (dynamic message) {
          _handleMessage(message);
        },
        onError: (error) {
          _logger.e('❌ WebSocket ошибка: $error');
          _connectionStreamController.add(false);
        },
        onDone: () {
          _logger.w('⚠️ WebSocket закрыт');
          _connectionStreamController.add(false);
        },
      );
    } catch (e) {
      _logger.e('❌ Ошибка подключения WebSocket: $e');
      _connectionStreamController.add(false);
    }
  }
  
  // Обработать входящее сообщение
  void _handleMessage(dynamic message) {
    try {
      final Map<String, dynamic> data = jsonDecode(message);
      final String type = data['type'] ?? '';
      
      _logger.i('💡 📥 WebSocket сообщение: $type');
      
      switch (type) {
        case 'message':
          _messageStreamController.add(data);
          break;
        case 'status':
          _statusStreamController.add(data);
          break;
        case 'typing':
          _statusStreamController.add(data);
          break;
        default:
          _logger.w('⚠️ Неизвестный тип сообщения: $type');
      }
    } catch (e) {
      _logger.e('❌ Ошибка обработки сообщения: $e');
    }
  }
  
  // Отправить сообщение
  void sendMessage(Map<String, dynamic> message) {
    try {
      if (!isConnected) {
        _logger.w('⚠️ WebSocket не подключён');
        return;
      }
      
      final String jsonMessage = jsonEncode(message);
      _channel!.sink.add(jsonMessage);
      _logger.i('💡 📤 WebSocket отправлено: ${message['type']}');
    } catch (e) {
      _logger.e('❌ Ошибка отправки: $e');
    }
  }
  
  // Отправить сообщение о печати
  void sendTyping(String chatId) {
    sendMessage({
      'type': 'typing',
      'chatId': chatId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  // Отправить подтверждение прочтения
  void sendReadReceipt(String messageId, String chatId) {
    sendMessage({
      'type': 'read',
      'messageId': messageId,
      'chatId': chatId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  // Отправить пинг для поддержки соединения
  void sendPing() {
    sendMessage({
      'type': 'ping',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  // Закрыть соединение
  Future<void> disconnect() async {
    try {
      if (_channel != null) {
        await _channel!.sink.close();
        _channel = null;
        _logger.i('💡 WebSocket отключён');
        _connectionStreamController.add(false);
      }
    } catch (e) {
      _logger.e('❌ Ошибка при закрытии WebSocket: $e');
    }
  }
  
  // Очистить ресурсы
  void dispose() {
    disconnect();
    _messageStreamController.close();
    _statusStreamController.close();
    _connectionStreamController.close();
  }
}

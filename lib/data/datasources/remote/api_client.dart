import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class ApiClient {
  static const String baseUrl = 'https://ravenapp.ru/api';
  
  late Dio _dio;
  String? _token;
  String? _currentUserId;
  final _logger = Logger();

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.i('📤 REQUEST: ${options.method} ${options.baseUrl}${options.path}');
          
          if (_token != null && _token!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $_token';
            _logger.i('✅ Token added: ${_token!.substring(0, 20)}...');
          } else {
            _logger.w('⚠️ No token in request!');
          }
          
          if (options.data != null) {
            _logger.i('📦 Body: ${options.data}');
          }
          
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.i('📥 RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
          _logger.i('📋 Data: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) {
          _logger.e('❌ ERROR: ${error.type} - ${error.message}');
          _logger.e('📋 Response: ${error.response?.data}');
          return handler.next(error);
        },
      ),
    );
  }

  void setToken(String token) {
    _token = token;
    _logger.i('🔑 Token set: ${token.substring(0, 30)}...');
  }

  void setCurrentUserId(String userId) {
    _currentUserId = userId;
  }

  String? get currentUserId => _currentUserId;

  void clearToken() {
    _token = null;
    _logger.i('🗑️ Token cleared');
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      _handleResponseStatus(response);
      return response;
    } on DioException catch (e) {
      _logger.e('❌ GET Error: $e');
      rethrow;
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      _handleResponseStatus(response);
      return response;
    } on DioException catch (e) {
      _logger.e('❌ POST Error: $e');
      rethrow;
    }
  }

  Future<Response> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      _handleResponseStatus(response);
      return response;
    } on DioException catch (e) {
      _logger.e('❌ PUT Error: $e');
      rethrow;
    }
  }

  Future<Response> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      _handleResponseStatus(response);
      return response;
    } on DioException catch (e) {
      _logger.e('❌ DELETE Error: $e');
      rethrow;
    }
  }

  void _handleResponseStatus(Response response) {
    _logger.i('Status: ${response.statusCode}');
    
    if (response.statusCode == 401) {
      _logger.e('⛔ 401 Unauthorized!');
      _logger.e('Response: ${response.data}');
      clearToken();
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: 'Unauthorized - Token invalid or expired',
      );
    }
    
    if (response.statusCode == null || response.statusCode! >= 400) {
      _logger.e('⛔ HTTP ${response.statusCode}: ${response.data}');
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: 'HTTP ${response.statusCode}',
      );
    }
  }

  Future<Response> login(String email, String password) async {
    try {
      _logger.i('📤 Attempting login with: $email');
      
      final response = await post(
        '/Auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      
      _logger.i('📥 Login response: ${response.data}');
      
      // Сохраняем userId и токены
      if (response.data is Map) {
        final userId = response.data['userId'];
        final token = response.data['token'];
        if (userId != null) {
          setCurrentUserId(userId.toString());
        }
        if (token != null) {
          setToken(token.toString());
        }
      }
      
      return response;
    } catch (e) {
      _logger.e('❌ Login error: $e');
      rethrow;
    }
  }

  Future<Response> getChats({int page = 1, int pageSize = 25}) async {
    try {
      _logger.i('📤 Fetching chats - Page: $page, Size: $pageSize');
      final response = await get(
        '/Chats',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );
      _logger.i('📥 Chats loaded: ${response.data}');
      return response;
    } on DioException catch (e) {
      _logger.e('❌ Get Chats Error: $e');
      rethrow;
    }
  }

  Future<Response> createGroupChat({
    required String name,
    String? description,
    List<String>? memberIds,
    bool isPublic = false,
  }) async {
    try {
      _logger.i('📤 Creating group chat: $name');
      
      final data = {
        'name': name,
        'description': description ?? '',
        'type': 1, // ChatType.Group = 1
        'memberIds': memberIds ?? [],
        'isPublic': isPublic,
      };
      
      _logger.i('📦 Request body: $data');
      
      final response = await post(
        '/Chats/group',
        data: data,
      );
      
      _logger.i('📥 Group chat created: ${response.data}');
      return response;
    } on DioException catch (e) {
      _logger.e('❌ Create Group Chat Error: ${e.type} - ${e.message}');
      _logger.e('Response: ${e.response?.data}');
      _logger.e('Status Code: ${e.response?.statusCode}');
      rethrow;
    }
  }

  Future<Response> createPersonalChat(String targetUserId) async {
    try {
      _logger.i('📤 Creating personal chat with user: $targetUserId');
      
      final response = await post('/Chats/personal/$targetUserId');
      
      _logger.i('📥 Personal chat created: ${response.data}');
      return response;
    } on DioException catch (e) {
      _logger.e('❌ Create Personal Chat Error: $e');
      rethrow;
    }
  }

  Future<Response> getChatById(String chatId) async {
    try {
      _logger.i('📤 Fetching chat: $chatId');
      final response = await get('/Chats/$chatId');
      _logger.i('📥 Chat loaded: ${response.data}');
      return response;
    } on DioException catch (e) {
      _logger.e('❌ Get Chat Error: $e');
      rethrow;
    }
  }

  Future<Response> getChatMembers(String chatId) async {
    try {
      _logger.i('📤 Fetching chat members: $chatId');
      final response = await get('/Chats/$chatId/members');
      _logger.i('📥 Chat members loaded: ${response.data}');
      return response;
    } on DioException catch (e) {
      _logger.e('❌ Get Chat Members Error: $e');
      rethrow;
    }
  }

  Future<Response> addChatMembers(String chatId, List<String> memberIds) async {
    try {
      _logger.i('📤 Adding members to chat $chatId: $memberIds');
      
      final response = await post(
        '/Chats/$chatId/members',
        data: memberIds,
      );
      
      _logger.i('📥 Members added: ${response.data}');
      return response;
    } on DioException catch (e) {
      _logger.e('❌ Add Chat Members Error: $e');
      rethrow;
    }
  }

  Future<Response> updateChat(
    String chatId, {
    String? name,
    String? description,
    bool? isPublic,
  }) async {
    try {
      _logger.i('📤 Updating chat: $chatId');
      
      final response = await put(
        '/Chats/$chatId',
        data: {
          'name': name,
          'description': description,
          'isPublic': isPublic,
        },
      );
      
      _logger.i('📥 Chat updated: ${response.data}');
      return response;
    } on DioException catch (e) {
      _logger.e('❌ Update Chat Error: $e');
      rethrow;
    }
  }

  Future<Response> deleteChat(String chatId) async {
    try {
      _logger.i('📤 Deleting chat: $chatId');
      final response = await delete('/Chats/$chatId');
      _logger.i('📥 Chat deleted');
      return response;
    } on DioException catch (e) {
      _logger.e('❌ Delete Chat Error: $e');
      rethrow;
    }
  }

  Future<Response> leaveChat(String chatId) async {
    try {
      _logger.i('📤 Leaving chat: $chatId');
      final response = await post('/Chats/$chatId/leave');
      _logger.i('📥 Left chat');
      return response;
    } on DioException catch (e) {
      _logger.e('❌ Leave Chat Error: $e');
      rethrow;
    }
  }

  Future<Response> searchUsers({
    required String searchTerm,
    int page = 1,
    int pageSize = 25,
  }) async {
    try {
      _logger.i('📤 Searching users: $searchTerm - Page: $page');
      
      final response = await get(
        '/Users/list/search/user',
        queryParameters: {
          'SearchTerm': searchTerm,
          'Page': page,
          'PageSize': pageSize,
        },
      );
      
      _logger.i('📥 Search results: ${response.data}');
      return response;
    } on DioException catch (e) {
      _logger.e('❌ Search Users Error: $e');
      rethrow;
    }
  }

  Future<Response> sendMessage({
    required String chatId,
    required String content,
    String? replyToMessageId,
    String? targetUserId,
  }) async {
    try {
      if (_token == null || _token!.isEmpty) {
        throw Exception('Not authenticated - no token');
      }

      _logger.i('📤 Sending message to chat: $chatId, targetUserId: $targetUserId');
      
      final formData = FormData.fromMap({
        'Content': content,
        if (chatId.isNotEmpty) 'ChatId': chatId,
        if (replyToMessageId != null) 'ReplyToMessageId': replyToMessageId,
      });
      
      final url = targetUserId != null 
          ? '/Messages/send?targetUserId=$targetUserId'
          : '/Messages/send';

      _logger.i('📤 POST $url');
      _logger.i('📦 FormData: Content=$content, ChatId=$chatId');

      final response = await _dio.post(
        url,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
      
      _handleResponseStatus(response);
      _logger.i('📥 Message sent: ${response.data}');
      return response;
    } on DioException catch (e) {
      _logger.e('❌ Send Message Error: ${e.message}');
      _logger.e('Response: ${e.response?.data}');
      _logger.e('Status: ${e.response?.statusCode}');
      rethrow;
    }
  }
}

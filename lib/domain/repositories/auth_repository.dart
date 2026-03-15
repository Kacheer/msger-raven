import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/auth_local_datasource.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/remote/api_client.dart';
import '../../data/models/auth_models.dart';

class AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final ApiClient _apiClient;

  AuthRepository(this._remoteDataSource, this._localDataSource, this._apiClient);

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? username,
  }) async {
    final request = RegisterRequest(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      username: username,
    );
    final response = await _remoteDataSource.register(request);
    
    if (response.token != null && response.refreshToken != null && response.userId != null) {
      await _localDataSource.saveTokens(
        response.token!,
        response.refreshToken!,
        response.userId!,
      );
      _apiClient.setToken(response.token!);
    }
    
    return response;
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final request = LoginRequest(email: email, password: password);
    final response = await _remoteDataSource.login(request);
    
    if (response.token != null && response.refreshToken != null && response.userId != null) {
      await _localDataSource.saveTokens(
        response.token!,
        response.refreshToken!,
        response.userId!,
      );
      _apiClient.setToken(response.token!);
    }
    
    return response;
  }

  Future<void> logout() async {
    try {
      final refreshToken = _localDataSource.getRefreshToken();
      if (refreshToken != null) {
        await _remoteDataSource.logout(refreshToken);
      }
    } catch (e) {
      // Игнорируем ошибки на логауте
    }
    _apiClient.clearToken();
    await _localDataSource.clearTokens();
  }

  bool isLoggedIn() => _localDataSource.isLoggedIn();
  String? getToken() => _localDataSource.getToken();
  String? getUserId() => _localDataSource.getUserId();
}

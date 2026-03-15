import 'package:dio/dio.dart';
import 'api_client.dart';
import '../../models/auth_models.dart';

class AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSource(this._apiClient);

  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _apiClient.post('Auth/register', data: request.toJson());
      if (response.data == null) {
        throw Exception('Empty response from register');
      }
      return AuthResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.post('Auth/login', data: request.toJson());
      if (response.data == null) {
        throw Exception('Empty response from login');
      }
      return AuthResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<void> logout(String refreshToken) async {
    try {
      await _apiClient.post('Auth/logout', data: {'refreshToken': refreshToken});
    } catch (e) {
      // Ignore logout errors
    }
  }
}

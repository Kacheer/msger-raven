import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/local/auth_local_datasource.dart';
import '../../data/datasources/remote/api_client.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../domain/repositories/auth_repository.dart';

final apiClientProvider = Provider((ref) => ApiClient());

final sharedPreferencesProvider = FutureProvider((ref) async {
  return await SharedPreferences.getInstance();
});

final authLocalDataSourceProvider = FutureProvider((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return AuthLocalDataSource(prefs);
});

final authRemoteDataSourceProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRemoteDataSource(apiClient);
});

final authRepositoryProvider = FutureProvider((ref) async {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final localDataSource = await ref.watch(authLocalDataSourceProvider.future);
  final apiClient = ref.watch(apiClientProvider);
  
  // Загрузи токен из SharedPreferences при инициализации
  final token = localDataSource.getToken();
  if (token != null && token.isNotEmpty) {
    apiClient.setToken(token);
  }
  
  return AuthRepository(remoteDataSource, localDataSource, apiClient);
});

final isLoggedInProvider = FutureProvider((ref) async {
  try {
    final authRepo = await ref.watch(authRepositoryProvider.future);
    final isLoggedIn = authRepo.isLoggedIn();
    return isLoggedIn;
  } catch (e) {
    return false;
  }
});

final currentUserIdProvider = FutureProvider((ref) async {
  try {
    final authRepo = await ref.watch(authRepositoryProvider.future);
    return authRepo.getUserId() ?? '';
  } catch (e) {
    return '';
  }
});

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;
  final ApiClient _apiClient;

  AuthNotifier(this._authRepository, this._apiClient) 
    : super(const AsyncValue.data(null));

  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? username,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authRepository.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        username: username,
      );
      final token = _authRepository.getToken();
      if (token != null) {
        _apiClient.setToken(token);
      }
    });
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authRepository.login(
        email: email,
        password: password,
      );
      final token = _authRepository.getToken();
      if (token != null) {
        _apiClient.setToken(token);
      }
    });
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _authRepository.logout(),
    );
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  final authRepoAsync = ref.watch(authRepositoryProvider);
  final apiClient = ref.watch(apiClientProvider);
  
  return authRepoAsync.when(
    data: (authRepo) => AuthNotifier(authRepo, apiClient),
    loading: () => AuthNotifier(
      AuthRepository(
        ref.watch(authRemoteDataSourceProvider),
        AuthLocalDataSource(null as dynamic),
        apiClient,
      ),
      apiClient,
    ),
    error: (error, stack) => AuthNotifier(
      AuthRepository(
        ref.watch(authRemoteDataSourceProvider),
        AuthLocalDataSource(null as dynamic),
        apiClient,
      ),
      apiClient,
    ),
  );
});

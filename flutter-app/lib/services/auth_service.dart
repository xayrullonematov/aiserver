import 'package:dio/dio.dart';
import 'package:ai_server_copilot/core/auth_exception.dart';
import 'package:ai_server_copilot/models/user.dart';
import 'package:ai_server_copilot/services/api_service.dart';
import 'package:ai_server_copilot/services/storage_service.dart';

class AuthService {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthService(this._apiService, this._storageService);

  String _errorMessage(Object error, {String fallback = 'Authentication request failed'}) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['detail'] is String) {
        return data['detail'] as String;
      }
      if (error.message != null && error.message!.isNotEmpty) {
        return error.message!;
      }
    }
    return fallback;
  }

  Future<User?> login(String email, String password) async {
    try {
      final response = await _apiService.dio.post(
        'auth/login',
        data: {
          'email': email,
          'password': password,
        },
        options: Options(extra: {'skipAuth': true}),
      );

      await _storageService.saveTokens(
        accessToken: response.data['access_token'] as String,
        refreshToken: response.data['refresh_token'] as String,
      );
      return await me();
    } catch (e) {
      await _storageService.deleteTokens();
      throw AuthException(_errorMessage(e, fallback: 'Login failed'));
    }
  }

  Future<User?> register(String email, String password) async {
    try {
      final response = await _apiService.dio.post(
        'auth/register',
        data: {
          'email': email,
          'password': password,
        },
        options: Options(extra: {'skipAuth': true}),
      );

      await _storageService.saveTokens(
        accessToken: response.data['access_token'] as String,
        refreshToken: response.data['refresh_token'] as String,
      );
      return await me();
    } catch (e) {
      await _storageService.deleteTokens();
      throw AuthException(_errorMessage(e, fallback: 'Registration failed'));
    }
  }

  Future<User?> loadCurrentUser() async {
    try {
      return await me();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        await _storageService.deleteTokens();
        return null;
      }
      throw AuthException(_errorMessage(e, fallback: 'Unable to load current user'));
    } catch (e) {
      throw AuthException(_errorMessage(e, fallback: 'Unable to load current user'));
    }
  }

  Future<User?> me() async {
    final response = await _apiService.dio.get('auth/me');
    return User.fromJson(response.data);
  }

  Future<void> logout() async {
    final refreshToken = await _storageService.getRefreshToken();
    try {
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _apiService.dio.post(
          'auth/logout',
          data: {'refresh_token': refreshToken},
          options: Options(extra: {'skipAuth': true}),
        );
      }
    } finally {
      await _storageService.deleteTokens();
    }
  }

  Future<String?> getAccessToken() async {
    try {
      return await _storageService.getAccessToken();
    } catch (_) {
      return null;
    }
  }
}

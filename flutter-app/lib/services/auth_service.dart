import 'package:dio/dio.dart';
import 'package:ai_server_copilot/models/user.dart';
import 'package:ai_server_copilot/services/api_service.dart';
import 'package:ai_server_copilot/services/storage_service.dart';

class AuthService {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthService(this._apiService, this._storageService);

  Future<User?> login(String email, String password) async {
    try {
      final response = await _apiService.dio.post('auth/login', data: {
        'email': email,
        'password': password,
      });

      final token = response.data['access_token'];
      await _storageService.saveToken(token);

      return await me();
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> register(String email, String password) async {
    try {
      await _apiService.dio.post('auth/register', data: {
        'email': email,
        'password': password,
      });
      return login(email, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> me() async {
    try {
      final response = await _apiService.dio.get('auth/me');
      return User.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    await _storageService.deleteToken();
  }
}

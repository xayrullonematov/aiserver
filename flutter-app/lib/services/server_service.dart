import 'package:ai_server_copilot/models/server.dart';
import 'package:ai_server_copilot/services/api_service.dart';

class ServerService {
  final ApiService _apiService;

  ServerService(this._apiService);

  Future<List<ServerProfile>> getServers() async {
    try {
      final response = await _apiService.dio.get('/servers');
      final List<dynamic> data = response.data;
      return data.map((json) => ServerProfile.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<ServerProfile> addServer({
    required String displayName,
    required String host,
    required int port,
    required String username,
    required String authType,
    required String passwordOrKey,
    required String projectPath,
  }) async {
    try {
      final response = await _apiService.dio.post('/servers', data: {
        'display_name': displayName,
        'host': host,
        'port': port,
        'username': username,
        'auth_type': authType,
        'credentials': passwordOrKey,
        'project_path': projectPath,
      });
      return ServerProfile.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<ServerProfile> getServer(String id) async {
    final response = await _apiService.dio.get('/servers/$id');
    return ServerProfile.fromJson(response.data);
  }

  Future<void> deleteServer(String id) async {
    await _apiService.dio.delete('/servers/$id');
  }

  Future<bool> testConnection(String id) async {
    try {
      final response = await _apiService.dio.post('/servers/$id/test');
      return response.data['status'] == 'success';
    } catch (e) {
      return false;
    }
  }
}

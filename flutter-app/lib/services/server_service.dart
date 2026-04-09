import 'package:ai_server_copilot/services/api_service.dart';
import 'package:ai_server_copilot/models/server.dart';

class ServerService {
  final ApiService _apiService;

  ServerService(this._apiService);

  Future<List<ServerProfile>> getServers() async {
    final response = await _apiService.dio.get('servers');
    return (response.data as List)
        .map((e) => ServerProfile.fromJson(e))
        .toList();
  }

  Future<void> addServer({
    required String displayName,
    required String host,
    required int port,
    required String username,
    required String authType,
    required String passwordOrKey,
    required String projectPath,
  }) async {
    await _apiService.dio.post('servers', data: {
      'display_name': displayName,
      'host': host,
      'port': port,
      'username': username,
      'auth_type': authType,
      'encrypted_credentials': passwordOrKey,
      'project_path': projectPath,
    });
  }

  Future<void> deleteServer(String id) async {
    await _apiService.dio.delete('servers/$id');
  }

  Future<Map<String, dynamic>> getMetrics(String serverId) async {
    final response = await _apiService.dio.get('servers/$serverId/metrics');
    return response.data;
  }
}

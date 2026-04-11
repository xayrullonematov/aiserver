import 'package:dio/dio.dart';
import 'package:ai_server_copilot/services/api_service.dart';
import 'package:ai_server_copilot/models/server.dart';

class ServerConnectionResult {
  final bool isConnected;
  final String message;

  const ServerConnectionResult({
    required this.isConnected,
    required this.message,
  });

  factory ServerConnectionResult.fromApiResponse(
    Object? responseData, {
    String fallbackMessage = 'Connection test failed',
  }) {
    if (responseData is Map) {
      final data = Map<String, dynamic>.from(responseData);
      final status = data['status']?.toString().toLowerCase();
      final message = data['message']?.toString() ??
          data['detail']?.toString() ??
          fallbackMessage;

      return ServerConnectionResult(
        isConnected: status == 'success' || status == 'connected',
        message: message,
      );
    }

    return ServerConnectionResult(
      isConnected: false,
      message: fallbackMessage,
    );
  }
}

class ServerSaveResult {
  final ServerProfile server;
  final ServerConnectionResult connection;

  const ServerSaveResult({required this.server, required this.connection});
}

class ServerService {
  final ApiService _apiService;

  ServerService(this._apiService);

  Future<List<ServerProfile>> getServers() async {
    final response = await _apiService.dio.get('servers/');
    return (response.data as List)
        .map((e) => ServerProfile.fromJson(e))
        .toList();
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
    final response = await _apiService.dio.post(
      'servers/',
      data: {
        'display_name': displayName,
        'host': host,
        'port': port,
        'username': username,
        'auth_type': authType,
        // Backend expects 'credentials' — it encrypts this field server-side.
        // The old code sent 'encrypted_credentials' which is wrong.
        'credentials': passwordOrKey,
        'project_path': projectPath,
      },
    );
    return ServerProfile.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ServerConnectionResult> testServer(String serverId) async {
    try {
      final response = await _apiService.dio.post('servers/$serverId/test');
      return ServerConnectionResult.fromApiResponse(
        response.data,
        fallbackMessage: 'Connection test failed',
      );
    } on DioException catch (e) {
      return ServerConnectionResult.fromApiResponse(
        e.response?.data,
        fallbackMessage: e.message ?? 'Connection test failed',
      );
    } catch (e) {
      return ServerConnectionResult(isConnected: false, message: e.toString());
    }
  }

  Future<void> deleteServer(String id) async {
    await _apiService.dio.delete('servers/$id');
  }

  Future<Map<String, dynamic>> getMetrics(String serverId) async {
    final response = await _apiService.dio.get('servers/$serverId/metrics');
    return response.data;
  }
}

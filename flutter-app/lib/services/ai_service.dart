import 'package:ai_server_copilot/services/api_service.dart';

class AIService {
  final ApiService _apiService;

  AIService(this._apiService);

  Future<List<String>> getProviders() async {
    final response = await _apiService.dio.get('/ai/providers/');
    return List<String>.from(response.data);
  }

  Future<String> packageContext(String serverId) async {
    final response = await _apiService.dio.post('/ai/context/$serverId/');
    return response.data['context'];
  }

  Future<void> chat({
    required String provider,
    required String apiKey,
    required List<Map<String, String>> messages,
  }) async {
    // Note: The actual chat streaming is often handled via WebSocket or a direct POST with streaming response.
    // For this implementation, we'll assume the /ai/chat endpoint returns a stream or we're using the WebSocket via WSService.
    await _apiService.dio.post('/ai/chat/', data: {
      'provider': provider,
      'api_key': apiKey,
      'messages': messages,
    });
  }
}

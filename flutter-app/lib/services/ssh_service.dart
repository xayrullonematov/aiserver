import 'package:ai_server_copilot/services/api_service.dart';

class SSHService {
  final ApiService _apiService;

  SSHService(this._apiService);

  Future<void> connect(String serverId) async {
    await _apiService.dio.post('/ssh/$serverId/connect/');
  }

  Future<void> disconnect(String serverId) async {
    await _apiService.dio.post('/ssh/$serverId/disconnect/');
  }

  Future<void> execute(String serverId, String command, {bool approved = false}) async {
    await _apiService.dio.post('/ssh/$serverId/execute/', data: {
      'command': command,
      'approved': approved,
    });
  }

  Future<List<dynamic>> listFiles(String serverId, String path) async {
    final response = await _apiService.dio.get(
      '/ssh/$serverId/files',
      queryParameters: {'path': path},
    );
    return response.data;
  }

  Future<String> readFile(String serverId, String path) async {
    final response = await _apiService.dio.get(
      '/ssh/$serverId/file',
      queryParameters: {'path': path},
    );
    return response.data['content'];
  }

  Future<void> writeFile(String serverId, String path, String content) async {
    await _apiService.dio.put(
      '/ssh/$serverId/file',
      data: {
        'path': path,
        'content': content,
      },
    );
  }

  Future<Map<String, dynamic>> getMetrics(String serverId) async {
    // We'll execute a command to get CPU and RAM usage
    // For Linux: top -bn1 | grep "Cpu(s)" and free -m
    final response = await _apiService.dio.post('/ssh/$serverId/execute/', data: {
      'command': "top -bn1 | grep 'Cpu(s)' | awk '{print \$2}'; free -m | grep Mem | awk '{print \$3/\$2 * 100.0}'",
      'approved': true,
    });
    
    final output = response.data['output'] as String;
    final lines = output.trim().split('\n');
    
    return {
      'cpu': double.tryParse(lines.isNotEmpty ? lines[0] : '0') ?? 0.0,
      'ram': double.tryParse(lines.length > 1 ? lines[1] : '0') ?? 0.0,
    };
  }

  Future<List<dynamic>> getExecutionLogs(String serverId) async {
    final response = await _apiService.dio.get('/servers/$serverId/logs/');
    return response.data;
  }
}

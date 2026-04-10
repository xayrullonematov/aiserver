import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:ai_server_copilot/core/config.dart';

class WSService {
  WebSocketChannel? _terminalChannel;
  WebSocketChannel? _aiChannel;

  void connectTerminal(String serverId, String token) {
    final uri = Uri.parse(AppConfig.wsUrl).replace(
      path: '${Uri.parse(AppConfig.wsUrl).path}/$serverId/terminal',
      queryParameters: {'token': token},
    );
    _terminalChannel = WebSocketChannel.connect(
      uri,
    );
  }

  void connectAI(String serverId, String token) {
    final uri = Uri.parse(AppConfig.wsUrl).replace(
      path: '${Uri.parse(AppConfig.wsUrl).path}/$serverId/ai',
      queryParameters: {'token': token},
    );
    _aiChannel = WebSocketChannel.connect(
      uri,
    );
  }

  Stream? get terminalStream => _terminalChannel?.stream;
  Stream? get aiStream => _aiChannel?.stream;

  void sendTerminal(String message) => _terminalChannel?.sink.add(message);
  void sendAI(String message) => _aiChannel?.sink.add(message);

  void disconnect() {
    _terminalChannel?.sink.close();
    _aiChannel?.sink.close();
  }
}

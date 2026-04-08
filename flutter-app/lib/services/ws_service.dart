import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:ai_server_copilot/core/config.dart';

class WSService {
  WebSocketChannel? _terminalChannel;
  WebSocketChannel? _aiChannel;

  void connectTerminal(String serverId, String token) {
    _terminalChannel = WebSocketChannel.connect(
      Uri.parse('${AppConfig.wsUrl}/$serverId/terminal?token=$token'),
    );
  }

  void connectAI(String serverId, String token) {
    _aiChannel = WebSocketChannel.connect(
      Uri.parse('${AppConfig.wsUrl}/$serverId/ai?token=$token'),
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

import 'dart:async';
import 'package:ai_server_copilot/providers/auth_provider.dart';
import 'package:ai_server_copilot/services/storage_service.dart';
import 'package:ai_server_copilot/services/ws_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'terminal_provider.g.dart';

@Riverpod(keepAlive: true)
WSService wsService(WsServiceRef ref) {
  return WSService();
}

@riverpod
class TerminalNotifier extends _$TerminalNotifier {
  StreamSubscription? _subscription;

  @override
  List<String> build(String serverId) {
    ref.onDispose(() {
      _subscription?.cancel();
      ref.read(wsServiceProvider).disconnect();
    });
    return [];
  }

  Future<void> connect() async {
    final ws = ref.read(wsServiceProvider);
    final storage = ref.read(storageServiceProvider);
    final token = await storage.getAccessToken();

    if (token != null) {
      ws.connectTerminal(serverId, token);
      _subscription = ws.terminalStream?.listen((data) {
        state = [...state, data.toString()];
      });
    }
  }

  void sendCommand(String command) {
    ref.read(wsServiceProvider).sendTerminal(command);
  }
}

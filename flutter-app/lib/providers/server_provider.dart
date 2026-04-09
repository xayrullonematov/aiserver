import 'dart:async';
import 'package:ai_server_copilot/models/server.dart';
import 'package:ai_server_copilot/providers/auth_provider.dart';
import 'package:ai_server_copilot/services/api_service.dart';
import 'package:ai_server_copilot/services/server_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'server_provider.g.dart';

@Riverpod(keepAlive: true)
ServerService serverService(ServerServiceRef ref) {
  final api = ref.watch(apiServiceProvider);
  return ServerService(api);
}

@riverpod
class Servers extends _$Servers {
  @override
  FutureOr<List<ServerProfile>> build() async {
    final service = ref.watch(serverServiceProvider);
    return await service.getServers();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(serverServiceProvider);
      return await service.getServers();
    });
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
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(serverServiceProvider);
      await service.addServer(
        displayName: displayName,
        host: host,
        port: port,
        username: username,
        authType: authType,
        passwordOrKey: passwordOrKey,
        projectPath: projectPath,
      );
      return await service.getServers();
    });
  }

  Future<void> deleteServer(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(serverServiceProvider);
      await service.deleteServer(id);
      return await service.getServers();
    });
  }
}

@riverpod
Stream<Map<String, double>> serverMetrics(ServerMetricsRef ref, String serverId) async* {
  final service = ref.watch(serverServiceProvider); // ✅ Fixed: sshServiceProvider → serverServiceProvider

  while (true) {
    try {
      final metrics = await service.getMetrics(serverId);
      yield {
        'cpu': (metrics['cpu'] as num).toDouble(),
        'ram': (metrics['ram'] as num).toDouble(),
      };
    } catch (e) {
      yield {'cpu': 0.0, 'ram': 0.0};
    }
    await Future.delayed(const Duration(seconds: 5));
  }
}

import 'dart:async';
import 'package:ai_server_copilot/models/server.dart';
import 'package:ai_server_copilot/providers/auth_provider.dart';
import 'package:ai_server_copilot/providers/server_provider.dart';
import 'package:ai_server_copilot/services/api_service.dart';
import 'package:ai_server_copilot/services/ssh_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'file_explorer_provider.g.dart';

ServerProfile? _findServer(List<ServerProfile>? servers, String serverId) {
  if (servers == null) return null;

  for (final server in servers) {
    if (server.id == serverId) {
      return server;
    }
  }

  return null;
}

String _normalizeExplorerPath(String path) {
  if (path.isEmpty || path == '.') {
    return '/';
  }

  if (path.length > 1 && path.endsWith('/')) {
    return path.substring(0, path.length - 1);
  }

  return path;
}

String _resolveExplorerRoot(List<ServerProfile>? servers, String serverId) {
  final server = _findServer(servers, serverId);
  return _normalizeExplorerPath(server?.projectPath ?? '/');
}

@Riverpod(keepAlive: true)
SSHService sshService(SshServiceRef ref) {
  final api = ref.watch(apiServiceProvider);
  return SSHService(api);
}

@riverpod
class FileExplorerNotifier extends _$FileExplorerNotifier {
  @override
  FutureOr<List<dynamic>> build(String serverId, String path) async {
    final service = ref.watch(sshServiceProvider);
    return await service.listFiles(serverId, path);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(sshServiceProvider);
      return await service.listFiles(serverId, path);
    });
  }
}

@riverpod
String explorerRootPath(ExplorerRootPathRef ref, String serverId) {
  final servers = ref.read(serversProvider).valueOrNull;
  return _resolveExplorerRoot(servers, serverId);
}

@riverpod
class CurrentPath extends _$CurrentPath {
  @override
  String build(String serverId) {
    return ref.read(explorerRootPathProvider(serverId));
  }

  void navigateTo(String newPath) => state = _normalizeExplorerPath(newPath);

  void goUp() {
    final rootPath = ref.read(explorerRootPathProvider(serverId));
    final normalizedState = _normalizeExplorerPath(state);
    final normalizedRoot = _normalizeExplorerPath(rootPath);

    if (normalizedState == normalizedRoot || normalizedState == '/') {
      state = normalizedRoot;
      return;
    }

    final lastSlash = normalizedState.lastIndexOf('/');
    if (lastSlash <= 0) {
      state = normalizedRoot;
      return;
    }

    final parentPath = normalizedState.substring(0, lastSlash);
    state =
        parentPath.length < normalizedRoot.length
            ? normalizedRoot
            : _normalizeExplorerPath(parentPath);
  }
}

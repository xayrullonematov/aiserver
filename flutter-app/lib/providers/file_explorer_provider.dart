import 'package:ai_server_copilot/providers/auth_provider.dart';
import 'package:ai_server_copilot/services/ssh_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'file_explorer_provider.g.dart';

@Riverpod(keepAlive: true)
SSHService sshService(SSHServiceRef ref) {
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
class CurrentPath extends _$CurrentPath {
  @override
  String build(String serverId) => '.';

  void navigateTo(String newPath) => state = newPath;
  
  void goUp() {
    if (state == '.') return;
    final segments = state.split('/');
    if (segments.length <= 1) {
      state = '.';
    } else {
      state = segments.sublist(0, segments.length - 1).join('/');
    }
  }
}

import 'package:ai_server_copilot/models/user.dart';
import 'package:ai_server_copilot/services/api_service.dart';
import 'package:ai_server_copilot/services/auth_service.dart';
import 'package:ai_server_copilot/services/storage_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
StorageService storageService(StorageServiceRef ref) {
  return StorageService();
}

@Riverpod(keepAlive: true)
ApiService apiService(ApiServiceRef ref) {
  final storage = ref.watch(storageServiceProvider);
  return ApiService(storage);
}

@Riverpod(keepAlive: true)
AuthService authService(AuthServiceRef ref) {
  final api = ref.watch(apiServiceProvider);
  final storage = ref.watch(storageServiceProvider);
  return AuthService(api, storage);
}

@riverpod
class Auth extends _$Auth {
  @override
  FutureOr<User?> build() async {
    final service = ref.watch(authServiceProvider);
    return await service.loadCurrentUser();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(authServiceProvider);
      return await service.login(email, password);
    });
  }

  Future<void> register(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(authServiceProvider);
      return await service.register(email, password);
    });
  }

  Future<void> logout() async {
    final service = ref.read(authServiceProvider);
    await service.logout();
    state = const AsyncValue.data(null);
  }
}

import 'package:dio/dio.dart';
import 'package:ai_server_copilot/core/config.dart';
import 'package:ai_server_copilot/services/storage_service.dart';

class ApiService {
  late Dio _dio;
  final StorageService _storageService;

  ApiService(this._storageService) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            // Handle token expiration - could trigger logout or refresh
          }
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}

import 'package:dio/dio.dart';
import 'package:ai_server_copilot/core/config.dart';
import 'package:ai_server_copilot/services/storage_service.dart';

class ApiService {
  late Dio _dio;
  late Dio _refreshDio;
  final StorageService _storageService;
  Future<String?>? _refreshFuture;

  ApiService(this._storageService) {
    final options = BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    );
    _dio = Dio(options);
    _refreshDio = Dio(options);

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (options.extra['skipAuth'] == true) {
            return handler.next(options);
          }

          final token = await _storageService.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (!_shouldAttemptRefresh(e.requestOptions, e.response?.statusCode)) {
            return handler.next(e);
          }

          final newAccessToken = await _refreshAccessToken();
          if (newAccessToken == null) {
            return handler.next(e);
          }

          final requestOptions = e.requestOptions;
          requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
          requestOptions.extra['retried'] = true;

          try {
            final response = await _dio.fetch(requestOptions);
            return handler.resolve(response);
          } on DioException catch (retryError) {
            return handler.next(retryError);
          }
        },
      ),
    );
  }

  bool _shouldAttemptRefresh(RequestOptions options, int? statusCode) {
    if (statusCode != 401) {
      return false;
    }
    if (options.extra['skipAuth'] == true || options.extra['retried'] == true) {
      return false;
    }

    final path = options.path.startsWith('/') ? options.path.substring(1) : options.path;
    return !path.startsWith('auth/login') &&
        !path.startsWith('auth/register') &&
        !path.startsWith('auth/refresh') &&
        !path.startsWith('auth/logout');
  }

  Future<String?> _refreshAccessToken() async {
    if (_refreshFuture != null) {
      return _refreshFuture;
    }

    _refreshFuture = _performRefresh();
    try {
      return await _refreshFuture;
    } finally {
      _refreshFuture = null;
    }
  }

  Future<String?> _performRefresh() async {
    final refreshToken = await _storageService.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _storageService.deleteTokens();
      return null;
    }

    try {
      final response = await _refreshDio.post(
        'auth/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(extra: {'skipAuth': true}),
      );

      final accessToken = response.data['access_token'] as String?;
      final newRefreshToken = response.data['refresh_token'] as String?;
      if (accessToken == null || newRefreshToken == null) {
        await _storageService.deleteTokens();
        return null;
      }

      await _storageService.saveTokens(
        accessToken: accessToken,
        refreshToken: newRefreshToken,
      );
      return accessToken;
    } on DioException {
      await _storageService.deleteTokens();
      return null;
    }
  }

  Dio get dio => _dio;
}

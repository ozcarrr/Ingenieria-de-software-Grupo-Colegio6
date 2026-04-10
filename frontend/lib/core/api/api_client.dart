import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static const _baseUrl = 'http://localhost:5001/api';
  static const _tokenKey = 'auth_token';

  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      contentType: 'application/json',
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: _tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        // Surface API errors cleanly — UI layer handles them
        return handler.next(error);
      },
    ));
  }

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<void> clearToken() => _storage.delete(key: _tokenKey);

  Future<String?> getToken() => _storage.read(key: _tokenKey);

  // ── Auth ────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
    String? institution,
    String role = 'student',
  }) async {
    final response = await _dio.post('/auth/register', data: {
      'username': username,
      'email': email,
      'password': password,
      'fullName': fullName,
      'institution': institution,
      'role': role,
    });
    return response.data as Map<String, dynamic>;
  }

  // ── Feed ────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getFeed({int page = 1, int pageSize = 20}) async {
    final response = await _dio.get('/posts/feed', queryParameters: {
      'page': page,
      'pageSize': pageSize,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<int> createPost({
    required String content,
    String postType = 'Regular',
    String? imageUrl,
    String? eventDate,
  }) async {
    final response = await _dio.post('/posts', data: {
      'content': content,
      'postType': postType,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (eventDate != null) 'eventDate': eventDate,
    });
    return response.data as int;
  }

  // ── Storage ─────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> uploadFile(String filePath, String contentType) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: filePath.split('/').last),
    });
    final response = await _dio.post(
      '/storage/upload',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return response.data as Map<String, dynamic>;
  }

  // ── Reports ─────────────────────────────────────────────────────────────────

  Future<List<int>> downloadReport({int? month, int? year}) async {
    final response = await _dio.get<List<int>>(
      '/reports/me',
      queryParameters: {
        if (month != null) 'month': month,
        if (year != null) 'year': year,
      },
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data!;
  }
}

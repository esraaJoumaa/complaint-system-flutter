import 'package:dio/dio.dart';

import '../models/user_model.dart';
import '../core/constants/api_constants.dart';
import 'base_client.dart';
import '../core/storage/token_storage.dart';
import 'dio_client.dart';

class AuthService {
  AuthService({Dio? dio}) : _dio = dio ?? DioClient.instance.dio;
  final Dio _dio;

  // ──────────────────────────────────────────────
  Future<UserModel> login(String username, String password) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiConstants.login,
        data: {'username': username, 'password': password},
      );
      final user = _parseUserFromResponse(response.data);
      if ((user.token ?? '').trim().isNotEmpty) {
        await TokenStorage.save(user.token!);
      }
      return user;
    } on DioException catch (e) {
      throw Exception(BaseClient.handleError(e));
    }
  }

  // ──────────────────────────────────────────────
  Future<UserModel> me() async {
    try {
      final response = await _dio.get<dynamic>(ApiConstants.me);
      return _parseUserFromResponse(response.data);
    } on DioException catch (e) {
      throw Exception(BaseClient.handleError(e));
    }
  }

  // ──────────────────────────────────────────────
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String birthdate,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiConstants.register,
        data: <String, dynamic>{
          'name': name,
          'email': email,
          'phone': phone,
          'birthdate': birthdate,
          'password': password,
          'password_confirmation': password,
        },
      );
      final data = response.data;
      if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        if (map['success'] == false) {
          throw Exception(map['message']?.toString() ?? 'خطأ في التسجيل');
        }
        final dynamic userField = map['data'];
        final Map<String, dynamic> userMap = (userField is Map)
            ? Map<String, dynamic>.from(userField)
            : map;
        return UserModel.fromJson(userMap);
      }
      throw Exception('استجابة غير متوقعة من السيرفر');
    } on DioException catch (e) {
      throw Exception(BaseClient.handleError(e));
    }
  }

  // ──────────────────────────────────────────────
  Future<UserModel> verifyEmail(String email, String code) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiConstants.verifyEmail,
        data: {'email': email, 'code': code.trim()},
      );

      final responseData = response.data;
      if (responseData is Map) {
        final root = Map<String, dynamic>.from(responseData);

        if (root['success'] == false) {
          throw Exception(
            root['message']?.toString() ??
                'رمز التحقق غير صحيح أو منتهي الصلاحية',
          );
        }

        final dynamic dataField = root['data'];
        if (dataField is Map) {
          final container = Map<String, dynamic>.from(dataField);

          final String? token = container['token']?.toString();

          final dynamic userField = container['user'];
          if (userField is Map) {
            final Map<String, dynamic> userMap = Map<String, dynamic>.from(
              userField,
            );

            if (token != null && token.isNotEmpty) {
              userMap['token'] = token;
            }

            final user = UserModel.fromJson(userMap);
            if ((user.token ?? '').trim().isNotEmpty) {
              await TokenStorage.save(user.token!);
            }
            return user;
          }
        }
      }
      throw Exception('استجابة غير متوقعة من السيرفر');
    } on DioException catch (e) {
      throw Exception(BaseClient.handleError(e));
    }
  }

  // ──────────────────────────────────────────────
  static UserModel _parseUserFromResponse(dynamic responseData) {
    if (responseData == null) throw Exception('استجابة فارغة من السيرفر');
    if (responseData is! Map) throw Exception('تنسيق استجابة غير صالح');

    final root = Map<String, dynamic>.from(responseData);
    final dynamic dataField = root['data'];
    final Map<String, dynamic> container = (dataField is Map)
        ? Map<String, dynamic>.from(dataField)
        : root;

    final String? token =
        (container['token'] ??
                container['access_token'] ??
                root['token'] ??
                root['access_token'])
            ?.toString();

    final dynamic userField = container['user'] ?? container['user_data'];
    final Map<String, dynamic> userMap = (userField is Map)
        ? Map<String, dynamic>.from(userField)
        : Map<String, dynamic>.from(container);

    if (token != null && token.isNotEmpty) userMap['token'] = token;

    // role object
    if (userMap['role'] == null) {
      if (container['role'] is Map)
        userMap['role'] = container['role'];
      else if (root['role'] is Map)
        userMap['role'] = root['role'];
    }

    return UserModel.fromJson(userMap);
  }
}

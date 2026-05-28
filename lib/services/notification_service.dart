import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import 'base_client.dart';
import 'dio_client.dart';

class NotificationModel {
  final int id;
  final int userId;
  final String title;
  final String body;
  final bool isRead;
  final DateTime? createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.isRead,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? json['message']?.toString() ?? '',
      isRead: json['is_read'] == true || json['is_read'] == 1,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();
  final Dio _dio = DioClient.instance.dio;

  Future<List<NotificationModel>> fetchLatest() async {
    try {
      final response = await _dio.get(ApiConstants.notificationsLatest);
      final data = response.data;
      List<dynamic> raw = [];
      if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        if (map['data'] is List) raw = map['data'] as List;
      } else if (data is List) {
        raw = data;
      }
      return raw
          .whereType<Map>()
          .map((e) => NotificationModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw BaseClient.handleError(e);
    }
  }

  Future<int> fetchUnreadCount() async {
    try {
      final response = await _dio.get(ApiConstants.unreadNotificationsCount);
      final data = response.data;
      if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        final inner = map['data'];
        if (inner is Map) {
          return int.tryParse(inner['unread_count']?.toString() ?? '0') ?? 0;
        }
      }
      return 0;
    } on DioException catch (_) {
      return 0;
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _dio.put(ApiConstants.markNotificationRead(id));
    } on DioException catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await _dio.put(ApiConstants.markAllNotificationsRead);
    } on DioException catch (_) {}
  }
}

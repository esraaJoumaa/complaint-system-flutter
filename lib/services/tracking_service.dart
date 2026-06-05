import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../models/complaint_model.dart';
import 'base_client.dart';
import 'dio_client.dart';

class TrackingService {
  TrackingService({Dio? dio}) : _dio = dio ?? DioClient.instance.dio;

  final Dio _dio;

  Future<ComplaintModel> getComplaintById(int id) async {
    try {
      final response = await _dio.get<dynamic>(ApiConstants.complaintById(id));
      final data = response.data;
      if (data is! Map) throw const FormatException('Expected object');

      final map = Map<String, dynamic>.from(data as Map);

      final dynamic payload = map['data'];
      if (payload is! Map) throw const FormatException('Expected data object');
      final payloadMap = Map<String, dynamic>.from(payload as Map);

      final dynamic nested = payloadMap['complaint'];
      final Map<String, dynamic> complaintMap = (nested is Map)
          ? Map<String, dynamic>.from(nested as Map)
          : payloadMap;

      if (!complaintMap.containsKey('user_score') ||
          complaintMap['user_score'] == null) {
        final scoreFromPayload =
            payloadMap['user_score'] ??
            payloadMap['score'] ??
            map['user_score'];
        if (scoreFromPayload != null) {
          complaintMap['user_score'] = scoreFromPayload;
        }
      }

      final dynamic newScore =
          payloadMap['user_new_score'] ?? map['user_new_score'];
      if (newScore != null && complaintMap['user_score'] == null) {
        complaintMap['user_score'] = newScore;
      }

      return ComplaintModel.fromJson(complaintMap);
    } on DioException catch (e) {
      throw Exception(BaseClient.handleError(e));
    } on FormatException {
      throw Exception('تعذر قراءة بيانات الشكوى');
    }
  }
}

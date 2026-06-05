
import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../models/rating_model.dart';
import 'base_client.dart';
import 'dio_client.dart';

class RatingService {
  RatingService({Dio? dio}) : _dio = dio ?? DioClient.instance.dio;
  final Dio _dio;

  // ───────────────────────────────────────────────────────────────
  Future<RatingResponse> rateAuthority({
    required String complainId,
    required int responseSpeedScore,
    String? comment,
  }) async {
    try {
      final int id = int.parse(complainId);
      final response = await _dio.post<dynamic>(
        ApiConstants.rateComplaint(id),
        data: {
          'response_speed_score': responseSpeedScore,
          if (comment != null && comment.trim().isNotEmpty)
            'comment': comment.trim(),
        },
      );
      return RatingResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(BaseClient.handleError(e));
    }
  }


  // ───────────────────────────────────────────────────────────────
  Future<RejectComplaintResponse> rejectComplaint({
    required String complainId,
    required String rejectionReason,
  }) async {
    try {
      final int id = int.parse(complainId);
      final response = await _dio.post<dynamic>(
        ApiConstants.rejectComplaint(id),
        data: {
          'rejection_reason': rejectionReason.trim(),
        },
      );
      return RejectComplaintResponse.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(BaseClient.handleError(e));
    }
  }
}

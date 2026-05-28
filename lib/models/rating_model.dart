class RatingModel {
  final int id;
  final String complainId;
  final int userId;
  final int authorityId;
  final int responseSpeedScore;
  final String? comment;
  final String createdAt;
  final String updatedAt;

  RatingModel({
    required this.id,
    required this.complainId,
    required this.userId,
    required this.authorityId,
    required this.responseSpeedScore,
    this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      id: json['id'],
      complainId: json['complain_id'].toString(),
      userId: json['user_id'],
      authorityId: json['authority_id'],
      responseSpeedScore: json['response_speed_score'],
      comment: json['comment'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'complain_id': complainId,
    'user_id': userId,
    'authority_id': authorityId,
    'response_speed_score': responseSpeedScore,
    'comment': comment,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class AuthorityRatingSummary {
  final int id;
  final String name;
  final double averageRating;
  final int totalRatings;

  AuthorityRatingSummary({
    required this.id,
    required this.name,
    required this.averageRating,
    required this.totalRatings,
  });

  factory AuthorityRatingSummary.fromJson(Map<String, dynamic> json) {
    return AuthorityRatingSummary(
      id: json['id'],
      name: json['name'],
      averageRating: (json['average_rating'] as num).toDouble(),
      totalRatings: json['total_ratings'],
    );
  }
}

class RatingResponse {
  final bool success;
  final String message;
  final RatingModel rating;
  final AuthorityRatingSummary authority;

  RatingResponse({
    required this.success,
    required this.message,
    required this.rating,
    required this.authority,
  });

  factory RatingResponse.fromJson(Map<String, dynamic> json) {
    return RatingResponse(
      success: json['success'],
      message: json['message'],
      rating: RatingModel.fromJson(json['data']['rating']),
      authority: AuthorityRatingSummary.fromJson(json['data']['authority']),
    );
  }
}

class RejectComplaintResponse {
  final bool success;
  final String status;
  final String message;

  RejectComplaintResponse({
    required this.success,
    required this.status,
    required this.message,
  });

  bool get isUserBanned => status == 'banned';

  factory RejectComplaintResponse.fromJson(Map<String, dynamic> json) {
    return RejectComplaintResponse(
      success: json['success'],
      status: json['status'] ?? '',
      message: json['message'],
    );
  }
}

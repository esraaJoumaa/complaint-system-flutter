class MessageModel {
  final int? id;
  final String message;
  final String? fileUrl;
  final String? fileType;
  final bool isRead;
  final DateTime? sentAt;
  final String? senderType;
  final String? senderName;
  final int? senderId;

  const MessageModel({
    this.id,
    required this.message,
    this.fileUrl,
    this.fileType,
    this.isRead = false,
    this.sentAt,
    this.senderType,
    this.senderName,
    this.senderId,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    String? senderName;
    int? senderId;
    if (json['sender'] is Map) {
      final sender = Map<String, dynamic>.from(json['sender'] as Map);
      senderName = sender['name']?.toString();
      senderId = sender['id'] is int
          ? sender['id'] as int
          : int.tryParse(sender['id']?.toString() ?? '');
    }

    final String? rawSenderType =
        json['senderType']?.toString() ?? json['sender_type']?.toString();

    return MessageModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? ''),
      message: json['message']?.toString() ?? '',
      fileUrl: json['file_url']?.toString(),
      fileType: json['file_type']?.toString(),
      isRead: json['is_read'] == true || json['is_read'] == 1,
      sentAt: json['sent_at'] != null
          ? DateTime.tryParse(json['sent_at'].toString())
          : null,
      senderType: rawSenderType?.toLowerCase().trim(),
      senderName: senderName,
      senderId: senderId,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'message': message,
    'file_url': fileUrl,
    'file_type': fileType,
    'is_read': isRead ? 1 : 0,
    'sent_at': sentAt?.toIso8601String(),
    'senderType': senderType,
    'sender_name': senderName,
    'sender_id': senderId,
  };

  bool get isFromOfficial {
    final t = senderType?.toLowerCase() ?? '';
    return t == 'manager' ||
        t == 'dept_manager' ||
        t == 'employee' ||
        t == 'admin' ||
        t == 'official';
  }

  bool get isFromCitizen {
    final t = senderType?.toLowerCase() ?? '';
    return t == 'citizen' || t == 'user';
  }
}

class NotificationModel {
  final int id;
  final String notificationType;
  final String title;
  final String message;
  final bool isRead;
  final int? relatedUserId;
  final String? relatedUserName;
  final int? relatedPostId;
  final int? relatedCourseId;
  final int? relatedExamId;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.notificationType,
    required this.title,
    required this.message,
    required this.isRead,
    this.relatedUserId,
    this.relatedUserName,
    this.relatedPostId,
    this.relatedCourseId,
    this.relatedExamId,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      notificationType: json['notification_type'],
      title: json['title'],
      message: json['message'],
      isRead: json['is_read'],
      relatedUserId: json['related_user'],
      relatedUserName: json['related_user_name'],
      relatedPostId: json['related_post_id'],
      relatedCourseId: json['related_course_id'],
      relatedExamId: json['related_exam_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'notification_type': notificationType,
      'title': title,
      'message': message,
      'is_read': isRead,
      'related_user': relatedUserId,
      'related_user_name': relatedUserName,
      'related_post_id': relatedPostId,
      'related_course_id': relatedCourseId,
      'related_exam_id': relatedExamId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

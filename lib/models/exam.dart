import 'package:json_annotation/json_annotation.dart';

part 'exam.g.dart';

@JsonSerializable()
class Exam {
  final int id;
  final String title;
  final String category;
  final String level;
  final String lastDate;
  final String link;
  final String description;
  final bool isActive;
  final String createdAt;

  Exam({
    required this.id,
    required this.title,
    required this.category,
    required this.level,
    required this.lastDate,
    required this.link,
    required this.description,
    required this.isActive,
    required this.createdAt,
  });

  factory Exam.fromJson(Map<String, dynamic> json) => _$ExamFromJson(json);

  Map<String, dynamic> toJson() => _$ExamToJson(this);

  Exam copyWith({
    int? id,
    String? title,
    String? category,
    String? level,
    String? lastDate,
    String? link,
    String? description,
    bool? isActive,
    String? createdAt,
  }) {
    return Exam(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      level: level ?? this.level,
      lastDate: lastDate ?? this.lastDate,
      link: link ?? this.link,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Exam _$ExamFromJson(Map<String, dynamic> json) => Exam(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  category: json['category'] as String,
  level: json['level'] as String,
  lastDate: json['lastDate'] as String,
  link: json['link'] as String,
  description: json['description'] as String,
  isActive: json['isActive'] as bool,
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$ExamToJson(Exam instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'category': instance.category,
  'level': instance.level,
  'lastDate': instance.lastDate,
  'link': instance.link,
  'description': instance.description,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt,
};

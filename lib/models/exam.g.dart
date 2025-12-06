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
  lastDate: json['last_date'] as String,
  link: json['link'] as String,
  description: json['description'] as String,
  isActive: json['is_active'] as bool,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$ExamToJson(Exam instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'category': instance.category,
  'level': instance.level,
  'last_date': instance.lastDate,
  'link': instance.link,
  'description': instance.description,
  'is_active': instance.isActive,
  'created_at': instance.createdAt,
};

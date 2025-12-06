// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentProfile _$StudentProfileFromJson(Map<String, dynamic> json) =>
    StudentProfile(
      id: (json['id'] as num).toInt(),
      currentLevel: json['current_level'] as String,
      stream: json['stream'] as String,
      interests: (json['interests'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      careerGoals: json['career_goals'] as String,
      phone: json['phone'] as String,
      dateOfBirth: json['date_of_birth'] as String,
    );

Map<String, dynamic> _$StudentProfileToJson(StudentProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'current_level': instance.currentLevel,
      'stream': instance.stream,
      'interests': instance.interests,
      'career_goals': instance.careerGoals,
      'phone': instance.phone,
      'date_of_birth': instance.dateOfBirth,
    };

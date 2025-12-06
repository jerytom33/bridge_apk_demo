// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resume_analysis.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResumeAnalysis _$ResumeAnalysisFromJson(Map<String, dynamic> json) =>
    ResumeAnalysis(
      id: (json['id'] as num).toInt(),
      user: (json['user'] as num).toInt(),
      pdfFile: json['pdf_file'] as String,
      geminiResponse: ResumeGeminiResponse.fromJson(
        json['gemini_response'] as Map<String, dynamic>,
      ),
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$ResumeAnalysisToJson(ResumeAnalysis instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user': instance.user,
      'pdf_file': instance.pdfFile,
      'gemini_response': instance.geminiResponse,
      'created_at': instance.createdAt,
    };

ResumeGeminiResponse _$ResumeGeminiResponseFromJson(
  Map<String, dynamic> json,
) => ResumeGeminiResponse(
  suitableCareerPaths:
      (json['suitable_career_paths'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
  skillGaps:
      (json['skill_gaps'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
  recommendedCourses:
      (json['recommended_courses'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
  suggestedNextSteps:
      (json['suggested_next_steps'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
  overallSummary: json['overall_summary'] as String,
);

Map<String, dynamic> _$ResumeGeminiResponseToJson(
  ResumeGeminiResponse instance,
) => <String, dynamic>{
  'suitable_career_paths': instance.suitableCareerPaths,
  'skill_gaps': instance.skillGaps,
  'recommended_courses': instance.recommendedCourses,
  'suggested_next_steps': instance.suggestedNextSteps,
  'overall_summary': instance.overallSummary,
};

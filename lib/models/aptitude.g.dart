// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aptitude.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AptitudeQuestion _$AptitudeQuestionFromJson(
  Map<String, dynamic> json,
) => AptitudeQuestion(
  id: (json['id'] as num).toInt(),
  question: json['question_text'] as String,
  options: [
    json['option_a'] as String,
    json['option_b'] as String,
    json['option_c'] as String,
    json['option_d'] as String,
  ],
  correctOption:
      0, // This will need to be set separately as it's not in the API response
);

Map<String, dynamic> _$AptitudeQuestionToJson(AptitudeQuestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'question_text': instance.question,
      'option_a': instance.options.length > 0 ? instance.options[0] : '',
      'option_b': instance.options.length > 1 ? instance.options[1] : '',
      'option_c': instance.options.length > 2 ? instance.options[2] : '',
      'option_d': instance.options.length > 3 ? instance.options[3] : '',
      'correctOption': instance.correctOption,
    };

AptitudeResult _$AptitudeResultFromJson(Map<String, dynamic> json) =>
    AptitudeResult(
      id: (json['id'] as num?)?.toInt() ?? 0,
      user: (json['user'] as num?)?.toInt() ?? 0,
      score: (json['score'] as num?)?.toInt() ?? 0,
      answers:
          (json['answers'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value as String),
          ) ??
          {},
      geminiAnalysis: AptitudeGeminiResponse.fromJson(
        json['gemini_analysis'] as Map<String, dynamic>,
      ),
      attemptedAt: json['attempted_at'] as String,
    );

Map<String, dynamic> _$AptitudeResultToJson(AptitudeResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user': instance.user,
      'score': instance.score,
      'answers': instance.answers,
      'gemini_analysis': instance.geminiAnalysis.toJson(),
      'attempted_at': instance.attemptedAt,
    };

AptitudeGeminiResponse _$AptitudeGeminiResponseFromJson(
  Map<String, dynamic> json,
) => AptitudeGeminiResponse(
  strengths:
      (json['strengths'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
  weaknesses:
      (json['weaknesses'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
  suggestedCareers:
      (json['suggested_careers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
  improvementTips:
      (json['improvement_tips'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
);

Map<String, dynamic> _$AptitudeGeminiResponseToJson(
  AptitudeGeminiResponse instance,
) => <String, dynamic>{
  'strengths': instance.strengths,
  'weaknesses': instance.weaknesses,
  'suggested_careers': instance.suggestedCareers,
  'improvement_tips': instance.improvementTips,
};

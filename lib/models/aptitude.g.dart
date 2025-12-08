// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aptitude.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AptitudeQuestion _$AptitudeQuestionFromJson(Map<String, dynamic> json) =>
    AptitudeQuestion(
      id: (json['id'] as num).toInt(),
      question: json['question'] as String,
      options: (json['options'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      correctOption: (json['correctOption'] as num).toInt(),
    );

Map<String, dynamic> _$AptitudeQuestionToJson(AptitudeQuestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'question': instance.question,
      'options': instance.options,
      'correctOption': instance.correctOption,
    };

AptitudeResult _$AptitudeResultFromJson(Map<String, dynamic> json) =>
    AptitudeResult(
      id: (json['id'] as num).toInt(),
      user: (json['user'] as num).toInt(),
      score: (json['score'] as num).toInt(),
      answers: Map<String, String>.from(json['answers'] as Map),
      geminiAnalysis: AptitudeGeminiResponse.fromJson(
        json['geminiAnalysis'] as Map<String, dynamic>,
      ),
      attemptedAt: json['attemptedAt'] as String,
    );

Map<String, dynamic> _$AptitudeResultToJson(AptitudeResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user': instance.user,
      'score': instance.score,
      'answers': instance.answers,
      'geminiAnalysis': instance.geminiAnalysis,
      'attemptedAt': instance.attemptedAt,
    };

AptitudeGeminiResponse _$AptitudeGeminiResponseFromJson(
  Map<String, dynamic> json,
) => AptitudeGeminiResponse(
  strengths: (json['strengths'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  weaknesses: (json['weaknesses'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  suggestedCareers: (json['suggestedCareers'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  improvementTips: (json['improvementTips'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$AptitudeGeminiResponseToJson(
  AptitudeGeminiResponse instance,
) => <String, dynamic>{
  'strengths': instance.strengths,
  'weaknesses': instance.weaknesses,
  'suggestedCareers': instance.suggestedCareers,
  'improvementTips': instance.improvementTips,
};

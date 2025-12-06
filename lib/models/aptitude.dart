import 'package:json_annotation/json_annotation.dart';

part 'aptitude.g.dart';

@JsonSerializable()
class AptitudeQuestion {
  final int id;
  final String question;
  final List<String> options;
  final int correctOption;

  AptitudeQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOption,
  });

  factory AptitudeQuestion.fromJson(Map<String, dynamic> json) =>
      _$AptitudeQuestionFromJson(json);

  Map<String, dynamic> toJson() => _$AptitudeQuestionToJson(this);
}

@JsonSerializable()
class AptitudeResult {
  final int id;
  final int user;
  final int score;
  final Map<String, String> answers;
  final AptitudeGeminiResponse geminiAnalysis;
  final String attemptedAt;

  AptitudeResult({
    required this.id,
    required this.user,
    required this.score,
    required this.answers,
    required this.geminiAnalysis,
    required this.attemptedAt,
  });

  factory AptitudeResult.fromJson(Map<String, dynamic> json) =>
      _$AptitudeResultFromJson(json);

  Map<String, dynamic> toJson() => _$AptitudeResultToJson(this);
}

@JsonSerializable()
class AptitudeGeminiResponse {
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> suggestedCareers;
  final List<String> improvementTips;

  AptitudeGeminiResponse({
    required this.strengths,
    required this.weaknesses,
    required this.suggestedCareers,
    required this.improvementTips,
  });

  factory AptitudeGeminiResponse.fromJson(Map<String, dynamic> json) =>
      _$AptitudeGeminiResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AptitudeGeminiResponseToJson(this);
}

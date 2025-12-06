import 'package:json_annotation/json_annotation.dart';

part 'resume_analysis.g.dart';

@JsonSerializable()
class ResumeAnalysis {
  final int id;
  final int user;
  final String pdfFile;
  final ResumeGeminiResponse geminiResponse;
  final String createdAt;

  ResumeAnalysis({
    required this.id,
    required this.user,
    required this.pdfFile,
    required this.geminiResponse,
    required this.createdAt,
  });

  factory ResumeAnalysis.fromJson(Map<String, dynamic> json) =>
      _$ResumeAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$ResumeAnalysisToJson(this);
}

@JsonSerializable()
class ResumeGeminiResponse {
  final List<String> suitableCareerPaths;
  final List<String> skillGaps;
  final List<String> recommendedCourses;
  final List<String> suggestedNextSteps;
  final String overallSummary;

  ResumeGeminiResponse({
    required this.suitableCareerPaths,
    required this.skillGaps,
    required this.recommendedCourses,
    required this.suggestedNextSteps,
    required this.overallSummary,
  });

  factory ResumeGeminiResponse.fromJson(Map<String, dynamic> json) =>
      _$ResumeGeminiResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ResumeGeminiResponseToJson(this);
}

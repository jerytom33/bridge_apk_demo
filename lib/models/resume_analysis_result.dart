class ResumeAnalysisResult {
  final int id;
  final int user;
  final String pdfFile;
  final DateTime createdAt;
  final GeminiResponse geminiResponse;
  final String candidateName;
  final String candidateEmail;
  final String candidatePhone;
  final String candidateLevel;
  final String predictedField;
  final int resumeScore;
  final List<String> detectedSkills;
  final List<String> recommendedSkills;
  final List<RecommendedCourse> recommendedCourses;
  final List<String> scoreBreakdown;

  ResumeAnalysisResult({
    required this.id,
    required this.user,
    required this.pdfFile,
    required this.createdAt,
    required this.geminiResponse,
    required this.candidateName,
    required this.candidateEmail,
    required this.candidatePhone,
    required this.candidateLevel,
    required this.predictedField,
    required this.resumeScore,
    required this.detectedSkills,
    required this.recommendedSkills,
    required this.recommendedCourses,
    required this.scoreBreakdown,
  });

  factory ResumeAnalysisResult.fromJson(Map<String, dynamic> json) {
    return ResumeAnalysisResult(
      id: json['id'] as int,
      user: json['user'] as int,
      pdfFile: json['pdf_file'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      geminiResponse: GeminiResponse.fromJson(
        json['gemini_response'] as Map<String, dynamic>,
      ),
      candidateName: json['candidate_name'] as String? ?? '',
      candidateEmail: json['candidate_email'] as String? ?? '',
      candidatePhone: json['candidate_phone'] as String? ?? '',
      candidateLevel: json['candidate_level'] as String? ?? '',
      predictedField: json['predicted_field'] as String? ?? '',
      resumeScore: json['resume_score'] as int? ?? 0,
      detectedSkills: List<String>.from(json['detected_skills'] ?? []),
      recommendedSkills: List<String>.from(json['recommended_skills'] ?? []),
      recommendedCourses:
          (json['recommended_courses'] as List<dynamic>?)
              ?.map(
                (e) => RecommendedCourse.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      scoreBreakdown: List<String>.from(json['score_breakdown'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'pdf_file': pdfFile,
      'created_at': createdAt.toIso8601String(),
      'gemini_response': geminiResponse.toJson(),
      'candidate_name': candidateName,
      'candidate_email': candidateEmail,
      'candidate_phone': candidatePhone,
      'candidate_level': candidateLevel,
      'predicted_field': predictedField,
      'resume_score': resumeScore,
      'detected_skills': detectedSkills,
      'recommended_skills': recommendedSkills,
      'recommended_courses': recommendedCourses.map((e) => e.toJson()).toList(),
      'score_breakdown': scoreBreakdown,
    };
  }
}

class GeminiResponse {
  final List<String> suitableCareerPaths;
  final List<String> skillGaps;
  final List<String> recommendedCourses;
  final List<String> suggestedNextSteps;
  final String overallSummary;

  GeminiResponse({
    required this.suitableCareerPaths,
    required this.skillGaps,
    required this.recommendedCourses,
    required this.suggestedNextSteps,
    required this.overallSummary,
  });

  factory GeminiResponse.fromJson(Map<String, dynamic> json) {
    return GeminiResponse(
      suitableCareerPaths: List<String>.from(
        json['suitable_career_paths'] ?? [],
      ),
      skillGaps: List<String>.from(json['skill_gaps'] ?? []),
      recommendedCourses: List<String>.from(json['recommended_courses'] ?? []),
      suggestedNextSteps: List<String>.from(json['suggested_next_steps'] ?? []),
      overallSummary: json['overall_summary'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'suitable_career_paths': suitableCareerPaths,
      'skill_gaps': skillGaps,
      'recommended_courses': recommendedCourses,
      'suggested_next_steps': suggestedNextSteps,
      'overall_summary': overallSummary,
    };
  }
}

class RecommendedCourse {
  final String name;
  final String link;

  RecommendedCourse({required this.name, required this.link});

  factory RecommendedCourse.fromJson(Map<String, dynamic> json) {
    return RecommendedCourse(
      name: json['name'] as String,
      link: json['link'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'link': link};
  }
}

// History item model
class ResumeHistoryItem {
  final int id;
  final String candidateName;
  final String candidateLevel;
  final String predictedField;
  final int resumeScore;
  final DateTime createdAt;

  ResumeHistoryItem({
    required this.id,
    required this.candidateName,
    required this.candidateLevel,
    required this.predictedField,
    required this.resumeScore,
    required this.createdAt,
  });

  factory ResumeHistoryItem.fromJson(Map<String, dynamic> json) {
    return ResumeHistoryItem(
      id: json['id'] as int,
      candidateName: json['candidate_name'] as String? ?? '',
      candidateLevel: json['candidate_level'] as String? ?? '',
      predictedField: json['predicted_field'] as String? ?? '',
      resumeScore: json['resume_score'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

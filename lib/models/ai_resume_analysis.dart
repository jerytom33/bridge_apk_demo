class AiResumeAnalysis {
  final String status;
  final String filename;
  final AnalysisData data;

  AiResumeAnalysis({
    required this.status,
    required this.filename,
    required this.data,
  });

  factory AiResumeAnalysis.fromJson(Map<String, dynamic> json) {
    return AiResumeAnalysis(
      status: json['status'] as String,
      filename: json['filename'] as String,
      data: AnalysisData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'filename': filename, 'data': data.toJson()};
  }
}

class AnalysisData {
  final BasicDetails basicDetails;
  final String candidateLevel;
  final String predictedField;
  final List<String> recommendedSkills;
  final List<RecommendedCourse> recommendedCourses;
  final int resumeScore;
  final List<String> scoreBreakdown;

  AnalysisData({
    required this.basicDetails,
    required this.candidateLevel,
    required this.predictedField,
    required this.recommendedSkills,
    required this.recommendedCourses,
    required this.resumeScore,
    required this.scoreBreakdown,
  });

  factory AnalysisData.fromJson(Map<String, dynamic> json) {
    return AnalysisData(
      basicDetails: BasicDetails.fromJson(
        json['basic_details'] as Map<String, dynamic>,
      ),
      candidateLevel: json['candidate_level'] as String,
      predictedField: json['predicted_field'] as String,
      recommendedSkills: (json['recommended_skills'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      recommendedCourses: (json['recommended_courses'] as List<dynamic>)
          .map((e) => RecommendedCourse.fromJson(e as Map<String, dynamic>))
          .toList(),
      resumeScore: json['resume_score'] as int,
      scoreBreakdown: (json['score_breakdown'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'basic_details': basicDetails.toJson(),
      'candidate_level': candidateLevel,
      'predicted_field': predictedField,
      'recommended_skills': recommendedSkills,
      'recommended_courses': recommendedCourses.map((e) => e.toJson()).toList(),
      'resume_score': resumeScore,
      'score_breakdown': scoreBreakdown,
    };
  }
}

class BasicDetails {
  final String? name;
  final String? email;
  final String? mobileNumber;
  final List<String>? skills;
  final List<String>? education;
  final List<String>? experience;
  final int? noOfPages;
  final double? totalExperience;

  BasicDetails({
    this.name,
    this.email,
    this.mobileNumber,
    this.skills,
    this.education,
    this.experience,
    this.noOfPages,
    this.totalExperience,
  });

  factory BasicDetails.fromJson(Map<String, dynamic> json) {
    return BasicDetails(
      name: json['name'] as String?,
      email: json['email'] as String?,
      mobileNumber: json['mobile_number'] as String?,
      skills: json['skills'] != null
          ? (json['skills'] as List<dynamic>).map((e) => e as String).toList()
          : null,
      education: json['education'] != null
          ? (json['education'] as List<dynamic>)
                .map((e) => e as String)
                .toList()
          : null,
      experience: json['experience'] != null
          ? (json['experience'] as List<dynamic>)
                .map((e) => e as String)
                .toList()
          : null,
      noOfPages: json['no_of_pages'] as int?,
      totalExperience: json['total_experience'] != null
          ? (json['total_experience'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'mobile_number': mobileNumber,
      'skills': skills,
      'education': education,
      'experience': experience,
      'no_of_pages': noOfPages,
      'total_experience': totalExperience,
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

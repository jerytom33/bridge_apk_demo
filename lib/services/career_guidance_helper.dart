/// Provides fallback career guidance when Gemini AI is unavailable
class CareerGuidanceHelper {
  /// Generate career paths based on predicted field
  static List<String> getCareerPaths(String predictedField) {
    final field = predictedField.toLowerCase();

    if (field.contains('web')) {
      return [
        'Frontend Developer',
        'Backend Developer',
        'Full Stack Developer',
        'UI/UX Designer',
        'Web Application Developer',
      ];
    } else if (field.contains('data')) {
      return [
        'Data Analyst',
        'Data Scientist',
        'Machine Learning Engineer',
        'Business Intelligence Analyst',
        'Data Engineer',
      ];
    } else if (field.contains('android')) {
      return [
        'Android Developer',
        'Mobile Application Developer',
        'Android UI/UX Designer',
        'Mobile DevOps Engineer',
        'Flutter Developer',
      ];
    } else if (field.contains('ios')) {
      return [
        'iOS Developer',
        'Mobile Application Developer',
        'iOS UI/UX Designer',
        'Swift Developer',
        'Flutter Developer',
      ];
    } else if (field.contains('ui') || field.contains('ux')) {
      return [
        'UI/UX Designer',
        'Product Designer',
        'Interaction Designer',
        'Visual Designer',
        'User Researcher',
      ];
    } else {
      // Generic tech career paths
      return [
        'Software Developer',
        'IT Consultant',
        'Systems Analyst',
        'Technical Support Engineer',
        'Quality Assurance Engineer',
      ];
    }
  }

  /// Generate skill gaps based on detected vs recommended skills
  static List<String> getSkillGaps(
    List<String> detectedSkills,
    List<String> recommendedSkills,
    String predictedField,
  ) {
    final gaps = <String>[];

    // Add recommended skills that aren't detected
    for (final skill in recommendedSkills) {
      if (!detectedSkills.any((s) => s.toLowerCase() == skill.toLowerCase())) {
        gaps.add(skill);
      }
    }

    // Add field-specific essentials if missing
    final field = predictedField.toLowerCase();
    final essentialSkills = _getEssentialSkills(field);

    for (final essential in essentialSkills) {
      if (!detectedSkills.any(
            (s) => s.toLowerCase().contains(essential.toLowerCase()),
          ) &&
          !gaps.any((g) => g.toLowerCase().contains(essential.toLowerCase()))) {
        gaps.add(essential);
      }
    }

    return gaps.take(6).toList(); // Limit to top 6 gaps
  }

  static List<String> _getEssentialSkills(String field) {
    if (field.contains('web')) {
      return ['Git', 'REST APIs', 'Database', 'Testing'];
    } else if (field.contains('data')) {
      return ['Python', 'SQL', 'Statistics', 'Data Visualization'];
    } else if (field.contains('android')) {
      return ['Kotlin', 'Android SDK', 'Git', 'REST APIs'];
    } else if (field.contains('ios')) {
      return ['Swift', 'iOS SDK', 'Git', 'REST APIs'];
    } else {
      return ['Git', 'Problem Solving', 'Communication'];
    }
  }

  /// Generate suggested next steps based on candidate level and field
  static List<String> getNextSteps(
    String candidateLevel,
    String predictedField,
    List<String> skillGaps,
  ) {
    final steps = <String>[];
    final level = candidateLevel.toLowerCase();

    // Level-specific advice
    if (level.contains('fresher')) {
      steps.addAll([
        'Build a strong portfolio with 3-5 projects showcasing your skills',
        'Contribute to open-source projects on GitHub to gain experience',
        'Apply for internships to get hands-on industry experience',
      ]);
    } else if (level.contains('intermediate')) {
      steps.addAll([
        'Work on advanced projects that demonstrate leadership abilities',
        'Earn industry-recognized certifications in your field',
        'Network with professionals through LinkedIn and tech meetups',
      ]);
    } else {
      steps.addAll([
        'Lead technical projects and mentor junior developers',
        'Stay updated with latest technologies and industry trends',
        'Consider speaking at conferences or writing technical blogs',
      ]);
    }

    // Add skill gap recommendations
    if (skillGaps.isNotEmpty) {
      final topGaps = skillGaps.take(2).join(' and ');
      steps.add(
        'Focus on learning $topGaps through online courses or bootcamps',
      );
    }

    // Field-specific advice
    final field = predictedField.toLowerCase();
    if (field.contains('web')) {
      steps.add(
        'Stay updated with modern frameworks like React, Vue, or Angular',
      );
    } else if (field.contains('data')) {
      steps.add('Practice with real datasets on Kaggle or similar platforms');
    } else if (field.contains('mobile')) {
      steps.add('Build and publish apps on Play Store or App Store');
    }

    return steps.take(5).toList(); // Limit to top 5 steps
  }

  /// Generate overall summary
  static String getSummary(
    String candidateLevel,
    String predictedField,
    int resumeScore,
    List<String> detectedSkills,
  ) {
    final level = candidateLevel.toLowerCase();
    final field = predictedField;

    String levelDesc;
    if (level.contains('fresher')) {
      levelDesc = 'an entry-level professional';
    } else if (level.contains('intermediate')) {
      levelDesc = 'a mid-level professional';
    } else {
      levelDesc = 'an experienced professional';
    }

    String scoreDesc;
    if (resumeScore >= 80) {
      scoreDesc = 'Your resume is excellent and well-structured';
    } else if (resumeScore >= 60) {
      scoreDesc = 'Your resume is good but has room for improvement';
    } else {
      scoreDesc = 'Your resume needs significant enhancement';
    }

    return '$scoreDesc. You appear to be $levelDesc in $field with ${detectedSkills.length} identified skills. '
        'Focus on building practical experience, expanding your skill set, and keeping your resume updated with recent achievements.';
  }
}

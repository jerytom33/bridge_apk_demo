import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main_wrapper.dart';

class FallbackAptitudeResultScreen extends StatelessWidget {
  final int score;
  final int total;
  final Map<String, dynamic> categoryBreakdown;
  final String educationLevel;
  final int? timeTaken;
  final Map<String, String>? answers;
  final List<Map<String, dynamic>>? questions;
  final Map<String, dynamic>? aiAnalysis;

  const FallbackAptitudeResultScreen({
    super.key,
    required this.score,
    int? totalQuestions,
    required this.categoryBreakdown,
    this.educationLevel = '10th',
    this.timeTaken,
    this.answers,
    this.questions,
    this.aiAnalysis,
  }) : total = totalQuestions ?? 10;

  @override
  Widget build(BuildContext context) {
    // 1. Calculate Percentage Logic
    final int calculatedPercentage = score > total
        ? score
        : (score / total * 100).round();

    // Determine recommended stream
    String recommendedStream = _getRecommendedStream();
    Color streamColor = _getStreamColor(recommendedStream);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Test Results (Offline)',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Aptitude Test Results',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Education Level: $educationLevel Passed',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Overall Score Circle
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: CircularProgressIndicator(
                      value: calculatedPercentage / 100,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        calculatedPercentage >= 70
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$calculatedPercentage%',
                        style: GoogleFonts.poppins(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '$calculatedPercentage/100',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Section-wise Scores
            Text(
              'Section-wise Performance',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),

            // Dynamic Sections from Backend
            ...categoryBreakdown.entries.map((entry) {
              final title = entry.key;
              final data = entry.value as Map<String, dynamic>;
              final correct = (data['correct'] as num?)?.toInt() ?? 0;
              final totalQs = (data['total'] as num?)?.toInt() ?? 1;

              return Column(
                children: [
                  _buildSectionScore(
                    title,
                    correct,
                    totalQs,
                    _getCategoryColor(title),
                    _getCategoryIcon(title),
                  ),
                  const SizedBox(height: 15),
                ],
              );
            }),

            const SizedBox(height: 20),

            // Recommended Stream Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: streamColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: streamColor.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _getStreamIcon(recommendedStream),
                    size: 48,
                    color: streamColor,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Recommended Stream',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    recommendedStream,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: streamColor,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    aiAnalysis != null && aiAnalysis!['summary'] != null
                        ? aiAnalysis!['summary'].toString()
                        : _getStreamDescription(recommendedStream),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Suggested Careers Section
            Text(
              'Suggested Career Paths',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 15),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _getCareerSuggestions(recommendedStream).map((career) {
                return Chip(
                  label: Text(
                    career,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6C63FF),
                    ),
                  ),
                  backgroundColor: const Color(
                    0xFF6C63FF,
                  ).withValues(alpha: 0.1),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              }).toList(),
            ),

            if (aiAnalysis != null) ...[
              const SizedBox(height: 30),
              Text(
                'Assessment Analysis',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.indigo.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.analytics_outlined,
                          color: Colors.indigo,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Performance Insights',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (aiAnalysis!['strong_areas'] != null) ...[
                      Text(
                        'Strengths:',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                      ...(aiAnalysis!['strong_areas'] as List).map(
                        (e) => Text(
                          '• $e',
                          style: GoogleFonts.poppins(fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (aiAnalysis!['weak_areas'] != null) ...[
                      Text(
                        'Areas to Improve:',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                      ...(aiAnalysis!['weak_areas'] as List).map(
                        (e) => Text(
                          '• $e',
                          style: GoogleFonts.poppins(fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (aiAnalysis!['improvement_tips'] != null) ...[
                      Text(
                        'Tips:',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                      ...(aiAnalysis!['improvement_tips'] as List).map(
                        (e) => Text(
                          '• $e',
                          style: GoogleFonts.poppins(fontSize: 13),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 30),

            // Action Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainWrapper(),
                    ),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Back to Home',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionScore(
    String section,
    int score,
    int total,
    Color color,
    IconData icon,
  ) {
    final percentage = total > 0 ? (score / total * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$score out of $total questions',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$percentage%',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              SizedBox(
                width: 60,
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String title) {
    final t = title.toLowerCase();
    if (t.contains('science')) return const Color(0xFF6C63FF);
    if (t.contains('commerce')) return const Color(0xFF00BFA5);
    if (t.contains('humanities')) return const Color(0xFFFF6F00);
    return Colors.blue;
  }

  IconData _getCategoryIcon(String title) {
    final t = title.toLowerCase();
    if (t.contains('science')) return Icons.science;
    if (t.contains('commerce')) return Icons.business_center;
    if (t.contains('humanities')) return Icons.auto_stories;
    return Icons.star;
  }

  String _getRecommendedStream() {
    int scienceScore = 0;
    int commerceScore = 0;
    int humanitiesScore = 0;

    // Use percentage score to determine strongest
    categoryBreakdown.forEach((key, value) {
      final k = key.toLowerCase();
      final data = value as Map<String, dynamic>;
      final correct = (data['correct'] as num?)?.toInt() ?? 0;
      final total = (data['total'] as num?)?.toInt() ?? 1;
      final percentage = (correct / total * 100).toInt();

      if (k.contains('science')) scienceScore = percentage;
      if (k.contains('commerce')) commerceScore = percentage;
      if (k.contains('humanities')) humanitiesScore = percentage;
    });

    if (scienceScore >= commerceScore && scienceScore >= humanitiesScore) {
      return 'Science Stream';
    } else if (commerceScore >= scienceScore &&
        commerceScore >= humanitiesScore) {
      return 'Commerce Stream';
    } else {
      return 'Humanities Stream';
    }
  }

  Color _getStreamColor(String stream) {
    switch (stream) {
      case 'Science Stream':
        return const Color(0xFF6C63FF);
      case 'Commerce Stream':
        return const Color(0xFF00BFA5);
      case 'Humanities Stream':
        return const Color(0xFFFF6F00);
      default:
        return Colors.grey;
    }
  }

  IconData _getStreamIcon(String stream) {
    switch (stream) {
      case 'Science Stream':
        return Icons.science;
      case 'Commerce Stream':
        return Icons.business_center;
      case 'Humanities Stream':
        return Icons.auto_stories;
      default:
        return Icons.school;
    }
  }

  String _getStreamDescription(String stream) {
    if (educationLevel == '10th') {
      // For 10th grade students
      switch (stream) {
        case 'Science Stream':
          return 'You have strong logical deduction and analytical skills. You likely enjoy figuring out how things work. Consider careers in Engineering, Medicine, Research, or Technology.';
        case 'Commerce Stream':
          return 'You have good practical math skills, understand value/money, and have a logical approach to management. Consider careers in Business, Finance, Accounting, or Economics.';
        case 'Humanities Stream':
          return 'You excel in language, understanding abstract concepts, social dynamics, and critical thinking. Consider careers in Law, Psychology, Journalism, or Social Work.';
        default:
          return '';
      }
    } else {
      // For 12th grade students - more specific career clusters
      switch (stream) {
        case 'Science Stream':
          return 'Strong STEM aptitude! You excel in technical thinking and problem-solving. Recommended fields: Engineering, Medicine, IT, AI, Data Science, Research, Biotechnology.';
        case 'Commerce Stream':
          return 'Excellent business acumen! You have strategic thinking and financial aptitude. Recommended fields: B.Com, BBA, CA, CS, Economics, MBA, Finance, Marketing.';
        case 'Humanities Stream':
          return 'Outstanding creative and social intelligence! You have strong communication and empathy. Recommended fields: Law, Arts, Psychology, Media, Design, Journalism, Public Relations.';
        default:
          return '';
      }
    }
  }

  List<String> _getCareerSuggestions(String stream) {
    if (aiAnalysis != null && aiAnalysis!['suggested_careers'] != null) {
      return (aiAnalysis!['suggested_careers'] as List).cast<String>();
    }
    // Fallback if not in analysis
    if (educationLevel == '10th') {
      switch (stream) {
        case 'Science Stream':
          return [
            'Engineering',
            'Medicine',
            'Computer Science',
            'Biotechnology',
            'Architecture',
            'Pilot / Aviation',
            'Research Scientist',
          ];
        case 'Commerce Stream':
          return [
            'Chartered Accountancy (CA)',
            'Investment Banking',
            'Business Management (BBA/MBA)',
            'Economics',
            'Digital Marketing',
            'Company Secretary (CS)',
            'Entrepreneurship',
          ];
        case 'Humanities Stream':
          return [
            'Law / Legal Services',
            'Psychology',
            'Journalism & Mass Media',
            'Civil Services (IAS/IPS)',
            'Product Design',
            'Social Work',
            'Teaching / Academia',
          ];
        default:
          return [];
      }
    } else {
      switch (stream) {
        case 'Science Stream':
          return [
            'Software Engineering',
            'Data Science & AI',
            'Medical Professional',
            'Robotics',
            'Astrophysics',
            'Cybersecurity',
            'Pharmacology',
          ];
        case 'Commerce Stream':
          return [
            'Financial Analyst',
            'Corporate Law',
            'Stock Market Trading',
            'Human Resource Mgmt',
            'Supply Chain Mgmt',
            'Banking Professional',
            'Actuarial Science',
          ];
        case 'Humanities Stream':
          return [
            'International Relations',
            'Clinical Psychology',
            'Content Strategy',
            'Graphic Design',
            'Public Policy',
            'Anthropology',
            'Film Making',
          ];
        default:
          return [];
      }
    }
  }
}

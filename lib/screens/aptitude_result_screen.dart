import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';

class AptitudeResultScreen extends StatelessWidget {
  final int score;
  final int total;
  final int scienceScore;
  final int commerceScore;
  final int humanitiesScore;
  final String educationLevel;
  final int? timeTaken;
  final Map<String, String>? answers;
  final List<Map<String, dynamic>>? questions;
  final Map<String, dynamic>? aiAnalysis;

  const AptitudeResultScreen({
    super.key,
    required this.score,
    int? totalQuestions, // Accept either total or totalQuestions
    this.scienceScore = 0,
    this.commerceScore = 0,
    this.humanitiesScore = 0,
    this.educationLevel = '10th',
    this.timeTaken,
    this.answers,
    this.questions,
    this.aiAnalysis,
  }) : total = totalQuestions ?? 15;

  @override
  Widget build(BuildContext context) {
    final percentage = (score / total * 100).round();

    // Determine recommended stream based on highest section score
    String recommendedStream = _getRecommendedStream();
    Color streamColor = _getStreamColor(recommendedStream);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Test Results',
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
                      value: percentage / 100,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        percentage >= 70 ? Colors.green : Colors.orange,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$percentage%',
                        style: GoogleFonts.poppins(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '$score/$total',
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

            _buildSectionScore(
              educationLevel == '10th' ? 'Science' : 'STEM & Technical',
              scienceScore,
              5,
              const Color(0xFF6C63FF),
              Icons.science,
            ),
            const SizedBox(height: 15),

            _buildSectionScore(
              educationLevel == '10th' ? 'Commerce' : 'Business & Finance',
              commerceScore,
              5,
              const Color(0xFF00BFA5),
              Icons.business,
            ),
            const SizedBox(height: 15),

            _buildSectionScore(
              educationLevel == '10th' ? 'Humanities' : 'Creative & Social',
              humanitiesScore,
              5,
              const Color(0xFFFF6F00),
              Icons.menu_book,
            ),
            const SizedBox(height: 30),

            // Recommendation Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: streamColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: streamColor.withOpacity(0.3),
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
                    _getStreamDescription(recommendedStream),
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

            // Action Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
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
    final percentage = (score / total * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
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

  String _getRecommendedStream() {
    if (scienceScore > commerceScore && scienceScore > humanitiesScore) {
      return 'Science Stream';
    } else if (commerceScore > scienceScore &&
        commerceScore > humanitiesScore) {
      return 'Commerce Stream';
    } else if (humanitiesScore > scienceScore &&
        humanitiesScore > commerceScore) {
      return 'Humanities Stream';
    } else {
      // If there's a tie, default to Science
      return 'Science Stream';
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
}

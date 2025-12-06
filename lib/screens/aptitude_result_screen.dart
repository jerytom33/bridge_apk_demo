import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';

class AptitudeResultScreen extends StatelessWidget {
  final int score;
  final int total;

  const AptitudeResultScreen({
    super.key,
    required this.score,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (score / total * 100).round();
    String grade;
    Color gradeColor;

    if (percentage >= 90) {
      grade = 'A+';
      gradeColor = Colors.green;
    } else if (percentage >= 80) {
      grade = 'A';
      gradeColor = Colors.green;
    } else if (percentage >= 70) {
      grade = 'B';
      gradeColor = Colors.lightGreen;
    } else if (percentage >= 60) {
      grade = 'C';
      gradeColor = Colors.orange;
    } else {
      grade = 'D';
      gradeColor = Colors.red;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Test Results',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
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
            const SizedBox(height: 30),
            // Score Circle
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: percentage / 100,
                      strokeWidth: 15,
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
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        grade,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: gradeColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // AI Analysis Section
            _buildAnalysisSection(),
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

  Widget _buildAnalysisSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: const Color(0xFF6C63FF), size: 24),
                const SizedBox(width: 10),
                Text(
                  'AI Analysis',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6C63FF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              'Based on your performance, here\'s what our AI analysis suggests:',
              style: GoogleFonts.poppins(
                fontSize: 16,
                height: 1.5,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 15),
            _buildAnalysisPoint(
              icon: Icons.check_circle,
              color: Colors.green,
              text: 'Strong analytical and problem-solving skills',
            ),
            const SizedBox(height: 10),
            _buildAnalysisPoint(
              icon: Icons.trending_up,
              color: Colors.blue,
              text: 'Good mathematical aptitude',
            ),
            const SizedBox(height: 10),
            _buildAnalysisPoint(
              icon: Icons.lightbulb,
              color: Colors.orange,
              text: 'Could improve in verbal reasoning section',
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Recommended Careers: Data Analyst, Software Engineer, Financial Analyst',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6C63FF),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisPoint({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }
}

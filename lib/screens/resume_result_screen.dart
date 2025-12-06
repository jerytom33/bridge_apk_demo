import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResumeResultScreen extends StatelessWidget {
  const ResumeResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AI Analysis',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resume Analysis',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'AI-powered insights to boost your career',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 30),
            // Strengths Section
            _buildAnalysisSection(
              title: 'Strengths',
              icon: Icons.check_circle,
              color: Colors.green,
              content:
                  '• Strong technical skills in programming languages\n• Excellent problem-solving abilities\n• Leadership experience from university projects',
            ),
            const SizedBox(height: 20),
            // Weaknesses Section
            _buildAnalysisSection(
              title: 'Areas for Improvement',
              icon: Icons.warning,
              color: Colors.orange,
              content:
                  '• Limited industry experience\n• Could improve soft skills communication\n• Needs more exposure to team collaboration tools',
            ),
            const SizedBox(height: 20),
            // Recommendations Section
            _buildAnalysisSection(
              title: 'Recommendations',
              icon: Icons.lightbulb,
              color: const Color(0xFF6C63FF),
              content:
                  '• Apply for internships to gain practical experience\n• Take online courses in communication skills\n• Join professional networking groups\n• Consider certifications in emerging technologies',
            ),
            const SizedBox(height: 20),
            // Skills Section
            _buildSkillsSection(),
            const SizedBox(height: 20),
            // Career Path Section
            _buildCareerPathSection(),
            const SizedBox(height: 30),
            // Action Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
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

  Widget _buildAnalysisSection({
    required String title,
    required IconData icon,
    required Color color,
    required String content,
  }) {
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
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              content,
              style: GoogleFonts.poppins(
                fontSize: 16,
                height: 1.5,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsSection() {
    final skills = [
      'JavaScript',
      'Python',
      'React',
      'Node.js',
      'SQL',
      'Communication',
      'Leadership',
      'Problem Solving'
    ];

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
                Icon(Icons.star, color: Colors.amber[700], size: 24),
                const SizedBox(width: 10),
                Text(
                  'Key Skills Identified',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: skills.map((skill) {
                return Chip(
                  label: Text(skill),
                  backgroundColor: Colors.grey[200],
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCareerPathSection() {
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
                Icon(Icons.directions,
                    color: const Color(0xFF6C63FF), size: 24),
                const SizedBox(width: 10),
                Text(
                  'Recommended Career Path',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6C63FF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Based on your resume, we recommend pursuing a career as a Software Engineer. '
                'Focus on building a strong portfolio, gaining internship experience, and '
                'developing both technical and soft skills.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

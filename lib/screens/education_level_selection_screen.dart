import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'aptitude_test_screen.dart';

class EducationLevelSelectionScreen extends StatelessWidget {
  const EducationLevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Education Level',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Text(
              'Choose Your Education Level',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Select your current education status to take a personalized AI-powered aptitude test',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 40),

            // 10th Passed Option
            _buildEducationCard(
              context,
              title: '10th Passed',
              subtitle: 'SSLC / Secondary School Completed',
              icon: Icons.school,
              color: const Color(0xFF6C63FF),
              level: '10th',
            ),
            const SizedBox(height: 16),

            // 12th Passed Option
            _buildEducationCard(
              context,
              title: '12th Passed',
              subtitle: 'Higher Secondary / Pre-University Completed',
              icon: Icons.school_outlined,
              color: const Color(0xFF00BFA5),
              level: '12th',
            ),
            const SizedBox(height: 16),

            // Diploma Option
            _buildEducationCard(
              context,
              title: 'Diploma / Polytechnic',
              subtitle: 'Diploma / Vocational Training Completed',
              icon: Icons.workspace_premium,
              color: const Color(0xFFFF6B6B),
              level: 'Diploma',
            ),
            const SizedBox(height: 16),

            // Bachelor's Degree Option
            _buildEducationCard(
              context,
              title: "Bachelor's",
              subtitle: 'Undergraduate Degree Completed',
              icon: Icons.school_rounded,
              color: const Color(0xFFFFA726),
              level: 'Bachelor',
            ),
            const SizedBox(height: 16),

            // Master's Degree Option
            _buildEducationCard(
              context,
              title: "Master's",
              subtitle: 'Post-Graduate Degree Completed',
              icon: Icons.military_tech,
              color: const Color(0xFF9C27B0),
              level: 'Master',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String level,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AptitudeTestScreen(educationLevel: level),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}

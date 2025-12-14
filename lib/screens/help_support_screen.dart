import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Help & Support',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Message
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.help_outline,
                    size: 60,
                    color: Color(0xFF6C63FF),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'How can we help you?',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Find answers to common questions below',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // FAQ Section
            _buildSectionHeader('Frequently Asked Questions'),
            const SizedBox(height: 16),

            // Getting Started
            _buildFAQCategory('Getting Started'),
            _buildFAQItem(
              'How do I complete my profile?',
              'Navigate to the Profile tab, tap the Edit button, fill in your details including name, email, phone, education level, and interests, then tap Update Profile.',
            ),
            _buildFAQItem(
              'How do I take an aptitude test?',
              '1. Go to the Aptitude Test section from the home screen\n2. Select your education level (10th, 12th, Diploma, Bachelor\'s, or Master\'s)\n3. Wait for AI-generated questions to load (may take up to 60 seconds)\n4. Answer all 10 questions\n5. Submit the test to see your results and AI analysis',
            ),
            _buildFAQItem(
              'How do I upload my resume?',
              'Go to the Resume section, tap Upload Resume, select your PDF file from your device, and wait for AI analysis to complete.',
            ),

            const SizedBox(height: 16),

            // Features
            _buildFAQCategory('Features'),
            _buildFAQItem(
              'How does resume analysis work?',
              'Our AI analyzes your resume to extract skills, experience, and education. It provides career recommendations, identifies skill gaps, and suggests next steps for your career growth.',
            ),
            _buildFAQItem(
              'What are career recommendations?',
              'Based on your education, interests, and aptitude test results, we provide personalized career path suggestions that match your profile and goals.',
            ),
            _buildFAQItem(
              'How do I save courses or exams?',
              'Browse courses or exams, tap the bookmark icon on any item to save it. Access your saved items from the respective sections.',
            ),
            _buildFAQItem(
              'What do the education levels mean?',
              '- 10th: Secondary school level\n- 12th: Higher secondary level\n- Diploma: Polytechnic/vocational training\n- Bachelor\'s: Undergraduate degree\n- Master\'s: Post-graduate degree',
            ),

            const SizedBox(height: 16),

            // Account & Settings
            _buildFAQCategory('Account & Settings'),
            _buildFAQItem(
              'How do I change my password?',
              'Currently, password changes are not available in-app. Please contact support to reset your password.',
            ),
            _buildFAQItem(
              'How do I enable/disable notifications?',
              'Go to Profile > Settings > Notifications to manage your notification preferences.',
            ),
            _buildFAQItem(
              'How do I delete my account?',
              'To delete your account and all associated data, please contact our support team at support@bridgeapp.com.',
            ),

            const SizedBox(height: 16),

            // Troubleshooting
            _buildFAQCategory('Troubleshooting'),
            _buildFAQItem(
              'Questions are taking too long to load',
              'AI question generation can take 30-60 seconds. Ensure you have a stable internet connection and be patient during this time.',
            ),
            _buildFAQItem(
              'I\'m getting login errors',
              'Ensure you\'re using the correct email and password. If you\'ve forgotten your password, contact support for a reset.',
            ),
            _buildFAQItem(
              'The app crashes or freezes',
              'Try closing and reopening the app. If the problem persists, clear the app cache or reinstall the app.',
            ),

            const SizedBox(height: 32),

            // Contact Support Section
            _buildSectionHeader('Contact Support'),
            const SizedBox(height: 16),

            _buildContactCard(
              Icons.email,
              'Email Support',
              'support@bridgeapp.com',
              'Response time: 24-48 hours',
            ),
            const SizedBox(height: 12),
            _buildContactCard(
              Icons.bug_report,
              'Report a Bug',
              'bugs@bridgeapp.com',
              'Include screenshots and error messages',
            ),
            const SizedBox(height: 12),
            _buildContactCard(
              Icons.feedback,
              'Send Feedback',
              'Use the feedback option in Profile settings',
              'Help us improve the app',
            ),

            const SizedBox(height: 32),

            // App Information
            _buildSectionHeader('App Information'),
            const SizedBox(height: 16),
            _buildInfoRow('App Name', 'Bridge'),
            _buildInfoRow('Version', '1.0.0'),
            _buildInfoRow('Build', '2025.12'),
            _buildInfoRow('Platform', 'Flutter'),

            const SizedBox(height: 32),

            // Footer
            Center(
              child: Text(
                '© 2024 Bridge - Career Guidance Platform',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF6C63FF),
      ),
    );
  }

  Widget _buildFAQCategory(String category) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Text(
        category,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          question,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        iconColor: const Color(0xFF6C63FF),
        collapsedIconColor: Colors.grey[600],
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              answer,
              style: GoogleFonts.poppins(
                fontSize: 13,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(
    IconData icon,
    String title,
    String contact,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6C63FF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  contact,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF6C63FF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Last Updated
            Center(
              child: Text(
                'Last Updated: December 2025',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Introduction
            _buildSection(
              'Introduction',
              'Bridge is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.',
            ),

            _buildSection(
              '1. Information We Collect',
              'We collect information that you provide directly to us, including:',
            ),
            _buildBulletPoint(
              'Personal information: Name, email address, phone number',
            ),
            _buildBulletPoint(
              'Educational information: Education level, stream, interests, career goals',
            ),
            _buildBulletPoint('Profile data: Date of birth, address, city'),
            _buildBulletPoint(
              'Resume data: If you choose to upload your resume',
            ),
            _buildBulletPoint(
              'Usage data: App interactions, features used, preferences',
            ),
            _buildBulletPoint(
              'Device information: Device type, operating system, unique device identifiers',
            ),

            const SizedBox(height: 16),

            _buildSection(
              '2. How We Use Your Information',
              'We use the information we collect to:',
            ),
            _buildBulletPoint(
              'Provide personalized career guidance and educational recommendations',
            ),
            _buildBulletPoint(
              'Customize aptitude tests based on your education level',
            ),
            _buildBulletPoint(
              'Analyze your resume and provide career insights',
            ),
            _buildBulletPoint(
              'Send you notifications about courses, exams, and opportunities',
            ),
            _buildBulletPoint('Improve our services and develop new features'),
            _buildBulletPoint('Communicate with you about updates and support'),
            _buildBulletPoint(
              'Monitor and analyze usage patterns to enhance user experience',
            ),

            const SizedBox(height: 16),

            _buildSection(
              '3. Data Sharing and Disclosure',
              'We do not sell your personal information. We may share your information only in these situations:',
            ),
            _buildBulletPoint(
              'Service Providers: Third-party services that help us operate the app (hosting, analytics, AI services)',
            ),
            _buildBulletPoint(
              'Legal Requirements: When required by law or to protect rights and safety',
            ),
            _buildBulletPoint(
              'Business Transfers: In connection with mergers or acquisitions',
            ),
            _buildBulletPoint(
              'With Your Consent: When you explicitly agree to share information',
            ),

            const SizedBox(height: 16),

            _buildSection(
              '4. Data Security',
              'We implement appropriate technical and organizational measures to protect your data:',
            ),
            _buildBulletPoint('Encryption in transit (HTTPS/TLS) and at rest'),
            _buildBulletPoint(
              'Secure backend infrastructure with regular security audits',
            ),
            _buildBulletPoint('Access controls and authentication mechanisms'),
            _buildBulletPoint('Regular security assessments and updates'),

            const SizedBox(height: 16),

            _buildSection(
              '5. Your Rights and Choices',
              'You have the following rights regarding your personal information:',
            ),
            _buildBulletPoint('Access: Request a copy of your personal data'),
            _buildBulletPoint(
              'Correction: Update or correct inaccurate information',
            ),
            _buildBulletPoint(
              'Deletion: Request deletion of your account and data',
            ),
            _buildBulletPoint(
              'Opt-out: Unsubscribe from marketing communications',
            ),
            _buildBulletPoint(
              'Data Portability: Request your data in a portable format',
            ),

            const SizedBox(height: 16),

            _buildSection(
              '6. Data Retention',
              'We retain your information for as long as your account is active or as needed to provide services. You may request deletion of your account at any time through the app settings.',
            ),

            _buildSection(
              '7. Third-Party Services',
              'Our app may contain links to third-party websites or services. We are not responsible for the privacy practices of these third parties. Please review their privacy policies before providing any information.',
            ),

            _buildSection(
              '8. Children\'s Privacy',
              'Our service is intended for users aged 13 and above. We do not knowingly collect information from children under 13. If you believe we have collected such information, please contact us immediately.',
            ),

            _buildSection(
              '9. Changes to This Policy',
              'We may update this Privacy Policy from time to time. We will notify you of significant changes through the app or via email. Continued use of the app after changes constitutes acceptance of the updated policy.',
            ),

            _buildSection(
              '10. Contact Us',
              'If you have questions or concerns about this Privacy Policy or our data practices, please contact us at:',
            ),
            _buildContactInfo('Email', 'privacy@bridgeapp.com'),
            _buildContactInfo('Support', 'support@bridgeapp.com'),

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

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6C63FF),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 14,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF6C63FF),
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF6C63FF),
            ),
          ),
        ],
      ),
    );
  }
}

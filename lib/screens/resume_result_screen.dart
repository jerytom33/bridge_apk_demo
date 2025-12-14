import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/resume_analysis_result.dart';

class ResumeResultScreen extends StatelessWidget {
  final ResumeAnalysisResult analysis;

  const ResumeResultScreen({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Resume Analysis',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              analysis.candidateName.isNotEmpty
                  ? analysis.candidateName
                  : 'Resume Analysis',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Analyzed on ${_formatDate(analysis.createdAt)}',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),

            // Resume Score
            _buildResumeScoreCard(),
            const SizedBox(height: 20),

            // Contact
            if (analysis.candidateEmail.isNotEmpty ||
                analysis.candidatePhone.isNotEmpty) ...[
              _buildContactCard(),
              const SizedBox(height: 20),
            ],

            // Profile Badges
            _buildProfileBadges(),
            const SizedBox(height: 20),

            // Gemini Summary
            _buildGeminiSummaryCard(),

            // Score Breakdown
            if (analysis.scoreBreakdown.isNotEmpty) ...[
              _buildScoreBreakdownCard(),
              const SizedBox(height: 20),
            ],

            // Skills
            if (analysis.detectedSkills.isNotEmpty) ...[
              _buildSkillsCard(
                'Detected Skills',
                analysis.detectedSkills,
                Colors.blue,
              ),
              const SizedBox(height: 20),
            ],

            if (analysis.recommendedSkills.isNotEmpty) ...[
              _buildSkillsCard(
                'Recommended Skills',
                analysis.recommendedSkills,
                Colors.orange,
              ),
              const SizedBox(height: 20),
            ],

            // Courses
            if (analysis.recommendedCourses.isNotEmpty) ...[
              _buildCoursesCard(context),
              const SizedBox(height: 30),
            ],

            // Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Upload Another Resume',
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

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  Widget _buildResumeScoreCard() {
    final score = analysis.resumeScore;
    final percentage = score / 100;
    final scoreColor = score >= 80
        ? Colors.green
        : score >= 60
        ? Colors.orange
        : Colors.red;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Resume Score',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            CircularPercentIndicator(
              radius: 80.0,
              lineWidth: 15.0,
              percent: percentage,
              center: Text(
                '$score%',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: scoreColor,
                ),
              ),
              progressColor: scoreColor,
              backgroundColor: Colors.grey[200]!,
              circularStrokeCap: CircularStrokeCap.round,
            ),
            const SizedBox(height: 15),
            Text(
              score >= 80
                  ? 'Excellent!'
                  : score >= 60
                  ? 'Good - Can Improve'
                  : 'Needs Improvement',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: const Color(0xFF6C63FF), size: 24),
                const SizedBox(width: 10),
                Text(
                  'Contact Details',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6C63FF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            if (analysis.candidateEmail.isNotEmpty)
              _buildInfoRow(Icons.email, analysis.candidateEmail),
            if (analysis.candidateEmail.isNotEmpty &&
                analysis.candidatePhone.isNotEmpty)
              const SizedBox(height: 10),
            if (analysis.candidatePhone.isNotEmpty)
              _buildInfoRow(Icons.phone, analysis.candidatePhone),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileBadges() {
    return Row(
      children: [
        Expanded(
          child: _buildBadge(
            Icons.military_tech,
            'Level',
            analysis.candidateLevel.isNotEmpty
                ? analysis.candidateLevel
                : 'N/A',
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildBadge(
            Icons.trending_up,
            'Field',
            analysis.predictedField.isNotEmpty
                ? analysis.predictedField
                : 'N/A',
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(
    IconData icon,
    String label,
    String value,
    MaterialColor color,
  ) {
    return Card(
      elevation: 2,
      color: color[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color[700], size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeminiSummaryCard() {
    final summary = analysis.geminiResponse.overallSummary;
    if (summary.isEmpty ||
        summary.toLowerCase().contains('error') ||
        summary.toLowerCase().contains('unavailable') ||
        summary.toLowerCase().contains('failed')) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const SizedBox(height: 20),
        Card(
          elevation: 2,
          color: Colors.indigo[50],
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
                    Icon(
                      Icons.auto_awesome,
                      color: Colors.indigo[700],
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'AI Analysis Summary',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  summary,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    height: 1.6,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildScoreBreakdownCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.checklist, color: Colors.green[700], size: 24),
                const SizedBox(width: 10),
                Text(
                  'Score Breakdown',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            ...analysis.scoreBreakdown.map((item) {
              final isPositive = item.startsWith('[+]');
              final cleanedItem = item
                  .replaceFirst('[+] ', '')
                  .replaceFirst('[-] ', '');
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isPositive ? Icons.check_circle : Icons.cancel,
                      color: isPositive ? Colors.green : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        cleanedItem,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsCard(
    String title,
    List<String> skills,
    MaterialColor color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: color[700], size: 24),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: skills
                  .map(
                    (skill) => Chip(
                      label: Text(skill),
                      backgroundColor: color[50],
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        color: color[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursesCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.school, color: const Color(0xFF6C63FF), size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Recommended Courses',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6C63FF),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            ...analysis.recommendedCourses
                .map(
                  (course) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: InkWell(
                      onTap: () => _launchUrl(course.link, context),
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C63FF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF6C63FF).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                course.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF6C63FF),
                                ),
                              ),
                            ),
                            Icon(
                              Icons.open_in_new,
                              color: const Color(0xFF6C63FF),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url, BuildContext context) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open link: $url'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

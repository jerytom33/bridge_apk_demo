import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'resume_upload_screen.dart';
import 'aptitude_test_screen.dart';
import 'exams_screen.dart';
import 'courses_screen.dart';
import 'feed_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bridge It',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome!',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Discover your perfect career path',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 30),
            // Grid of 5 big cards
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  // Resume Card
                  _buildFeatureCard(
                    context,
                    title: 'Resume',
                    icon: Icons.description_outlined,
                    color: const Color(0xFF6C63FF),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ResumeUploadScreen(),
                        ),
                      );
                    },
                  ),
                  // Aptitude Card
                  _buildFeatureCard(
                    context,
                    title: 'Aptitude',
                    icon: Icons.quiz_outlined,
                    color: const Color(0xFFFF6B6B),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AptitudeTestScreen(),
                        ),
                      );
                    },
                  ),
                  // Exams Card
                  _buildFeatureCard(
                    context,
                    title: 'Exams',
                    icon: Icons.calendar_month_outlined,
                    color: const Color(0xFF4ECDC4),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ExamsScreen(),
                        ),
                      );
                    },
                  ),
                  // Courses Card
                  _buildFeatureCard(
                    context,
                    title: 'Courses',
                    icon: Icons.school_outlined,
                    color: const Color(0xFFFFD166),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CoursesScreen(),
                        ),
                      );
                    },
                  ),
                  // Feed Card
                  _buildFeatureCard(
                    context,
                    title: 'Feed',
                    icon: Icons.feed_outlined,
                    color: const Color(0xFF118AB2),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FeedScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                size: 40,
                color: color,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

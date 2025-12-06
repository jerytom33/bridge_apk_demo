import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../courses_screen.dart';
import '../exams_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _dashboardData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.getStudentDashboard();
      if (response['success'] == true) {
        setState(() {
          _dashboardData = response['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response['error'];
          _isLoading = false;
        });
        if (response['error'].toString().contains('Unauthorized')) {
          // Handle unauthorized - maybe redirect to login
        }
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $_error'),
              ElevatedButton(
                onPressed: _loadDashboard,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final profile = _dashboardData?['profile'];
    final featuredCourses = _dashboardData?['featured_courses'] as List? ?? [];
    final upcomingExams = _dashboardData?['upcoming_exams'] as List? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboard,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Summary
            if (profile != null) ...[
              Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(profile['first_name'] ?? 'Student'),
                  subtitle: Text(
                    '${profile['stream'] ?? ''} - ${profile['current_level'] ?? ''}',
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Quick Actions (Saved Items)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _QuickActionButton(
                  icon: Icons.bookmark,
                  label: 'Saved Courses',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const CoursesScreen(showSaved: true),
                      ),
                    );
                  },
                ),
                _QuickActionButton(
                  icon: Icons.event,
                  label: 'Saved Exams',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const ExamsScreen(showSaved: true),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Featured Courses
            _SectionHeader(
              title: 'Featured Courses',
              onSeeAll: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CoursesScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            if (featuredCourses.isEmpty)
              const Text('No featured courses available.')
            else
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: featuredCourses.length,
                  itemBuilder: (context, index) {
                    final course = featuredCourses[index];
                    return Container(
                      width: 160,
                      margin: const EdgeInsets.only(right: 16),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: Icon(Icons.book, size: 40),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                course['title'] ?? 'Course',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(course['instructor_name'] ?? ''),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 24),

            // Upcoming Exams
            _SectionHeader(
              title: 'Upcoming Exams',
              onSeeAll: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ExamsScreen()),
                );
              },
            ),
            const SizedBox(height: 8),
            if (upcomingExams.isEmpty)
              const Text('No upcoming exams.')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: upcomingExams.length,
                itemBuilder: (context, index) {
                  final exam = upcomingExams[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.event_note),
                      title: Text(exam['title'] ?? 'Exam'),
                      subtitle: Text(exam['date'] ?? ''),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;

  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton(onPressed: onSeeAll, child: const Text('See All')),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(radius: 24, child: Icon(icon)),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }
}

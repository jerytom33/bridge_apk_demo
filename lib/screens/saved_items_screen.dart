import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/career_model.dart';
import '../models/course_model.dart';
import '../services/api_service.dart';

class SavedItemsScreen extends StatefulWidget {
  const SavedItemsScreen({super.key});

  @override
  _SavedItemsScreenState createState() => _SavedItemsScreenState();
}

class _SavedItemsScreenState extends State<SavedItemsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Career> _savedCareers = [];
  List<Course> _savedCourses = [];
  List<Map<String, dynamic>> _savedJobs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSavedItems();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedItems() async {
    final prefs = await SharedPreferences.getInstance();

    // Load saved careers (saved IDs stored locally). TODO: Implement career fetching when API endpoint is available
    final careers = <Career>[];

    // Load saved courses
    final courseResult = await ApiService.getSavedCourses();
    final courses = <Course>[];
    if (courseResult['success']) {
      courses.addAll(
        (courseResult['data']['data'] as List)
            .map((course) => Course.fromJson(course['course']))
            .toList(),
      );
    }

    // Load saved jobs (mock data)
    final savedJobIds = prefs.getStringList('saved_jobs') ?? [];
    final jobs = [
      {
        'id': '1',
        'title': 'Senior Frontend Developer',
        'company': 'Tech Corp',
        'location': 'San Francisco, CA',
        'type': 'Full-time',
        'salary': '\$120k - \$160k',
      },
      {
        'id': '2',
        'title': 'Data Scientist',
        'company': 'AI Solutions',
        'location': 'Remote',
        'type': 'Full-time',
        'salary': '\$100k - \$140k',
      },
      {
        'id': '3',
        'title': 'UX Designer',
        'company': 'Design Studio',
        'location': 'New York, NY',
        'type': 'Contract',
        'salary': '\$80k - \$100k',
      },
    ].where((job) => savedJobIds.contains(job['id'])).toList();

    setState(() {
      _savedCareers = careers;
      _savedCourses = courses;
      _savedJobs = jobs;
      _isLoading = false;
    });
  }

  Future<void> _removeCareer(Career career) async {
    setState(() {
      _savedCareers.remove(career);
    });

    final prefs = await SharedPreferences.getInstance();
    final savedCareers = prefs.getStringList('saved_careers') ?? [];
    savedCareers.remove(career.id.toString());
    await prefs.setStringList('saved_careers', savedCareers);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Career removed from saved'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _removeCourse(Course course) async {
    setState(() {
      _savedCourses.remove(course);
    });

    final prefs = await SharedPreferences.getInstance();
    final savedCourses = prefs.getStringList('saved_courses') ?? [];
    savedCourses.remove(course.id.toString());
    await prefs.setStringList('saved_courses', savedCourses);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Course removed from saved'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _removeJob(Map<String, dynamic> job) async {
    setState(() {
      _savedJobs.remove(job);
    });

    final prefs = await SharedPreferences.getInstance();
    final savedJobs = prefs.getStringList('saved_jobs') ?? [];
    savedJobs.remove(job['id']);
    await prefs.setStringList('saved_jobs', savedJobs);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Job removed from saved'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Items'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Careers'),
            Tab(text: 'Courses'),
            Tab(text: 'Jobs'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCareersTab(),
                _buildCoursesTab(),
                _buildJobsTab(),
              ],
            ),
    );
  }

  Widget _buildCareersTab() {
    if (_savedCareers.isEmpty) {
      return _buildEmptyState(
        icon: Icons.work_off,
        title: 'No saved careers',
        subtitle: 'Start exploring and save careers that interest you',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _savedCareers.length,
      itemBuilder: (context, index) {
        final career = _savedCareers[index];
        return SavedCareerCard(
          career: career,
          onRemove: () => _removeCareer(career),
        );
      },
    );
  }

  Widget _buildCoursesTab() {
    if (_savedCourses.isEmpty) {
      return _buildEmptyState(
        icon: Icons.school,
        title: 'No saved courses',
        subtitle: 'Find and save courses to enhance your skills',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _savedCourses.length,
      itemBuilder: (context, index) {
        final course = _savedCourses[index];
        return SavedCourseCard(
          course: course,
          onRemove: () => _removeCourse(course),
        );
      },
    );
  }

  Widget _buildJobsTab() {
    if (_savedJobs.isEmpty) {
      return _buildEmptyState(
        icon: Icons.business_center,
        title: 'No saved jobs',
        subtitle: 'Save job opportunities to apply later',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _savedJobs.length,
      itemBuilder: (context, index) {
        final job = _savedJobs[index];
        return SavedJobCard(job: job, onRemove: () => _removeJob(job));
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.explore),
            label: const Text('Explore'),
          ),
        ],
      ),
    );
  }
}

class SavedCareerCard extends StatelessWidget {
  final Career career;
  final VoidCallback onRemove;

  const SavedCareerCard({
    super.key,
    required this.career,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        career.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        career.description,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.bookmark),
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _InfoChip(
                  icon: Icons.attach_money,
                  label: career.salary,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.trending_up,
                  label: career.growth,
                  color: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: career.skills.take(3).map((skill) {
                return Chip(
                  label: Text(skill, style: const TextStyle(fontSize: 12)),
                  backgroundColor: Colors.blue.withValues(alpha: 0.1),
                  labelStyle: const TextStyle(color: Colors.blue),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class SavedCourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onRemove;

  const SavedCourseCard({
    super.key,
    required this.course,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        course.description,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.bookmark),
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getLevelColor(
                      course.careerPath,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    course.careerPath,
                    style: TextStyle(
                      fontSize: 12,
                      color: _getLevelColor(course.careerPath),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule, size: 14, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        course.duration,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'Beginner':
        return Colors.green;
      case 'Intermediate':
        return Colors.orange;
      case 'Advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class SavedJobCard extends StatelessWidget {
  final Map<String, dynamic> job;
  final VoidCallback onRemove;

  const SavedJobCard({super.key, required this.job, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job['title'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job['company'],
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            job['location'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.bookmark),
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    job['type'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    job['salary'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Applying for ${job['title']}...')),
                  );
                },
                child: const Text('Apply Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

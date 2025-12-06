import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/course_model.dart';
import '../services/api_service.dart';

class CourseSuggestionsScreen extends StatefulWidget {
  const CourseSuggestionsScreen({super.key});

  @override
  _CourseSuggestionsScreenState createState() =>
      _CourseSuggestionsScreenState();
}

class _CourseSuggestionsScreenState extends State<CourseSuggestionsScreen> {
  List<Course> _courses = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedLevel = 'All';

  final List<String> _levels = ['All', 'Beginner', 'Intermediate', 'Advanced'];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    try {
      final result = await ApiService.getCourses();
      if (result['success']) {
        final courses = (result['data']['data'] as List)
            .map((course) => Course.fromJson(course))
            .toList();
        setState(() {
          _courses = courses;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Course> get _filteredCourses {
    List<Course> filtered = _courses;

    // Filter by level (using careerPath instead of level)
    if (_selectedLevel != 'All') {
      filtered = filtered
          .where((course) => course.careerPath == _selectedLevel)
          .toList();
    }

    // Filter by search query (using title instead of name)
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (course) =>
                course.title.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                course.description.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    return filtered;
  }

  Future<void> _toggleSaveCourse(Course course) async {
    setState(() {
      course.toggleSaved();
    });

    // Save to local storage
    final prefs = await SharedPreferences.getInstance();
    final savedCourses = prefs.getStringList('saved_courses') ?? [];

    if (course.isSaved) {
      savedCourses.add(course.id.toString());
    } else {
      savedCourses.remove(course.id.toString());
    }

    await prefs.setStringList('saved_courses', savedCourses);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          course.isSaved ? 'Course saved!' : 'Course removed from saved',
        ),
        backgroundColor: course.isSaved ? Colors.green : Colors.orange,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Suggestions'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search courses...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),

                // Level Filter
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _levels.length,
                    itemBuilder: (context, index) {
                      final level = _levels[index];
                      final isSelected = level == _selectedLevel;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(level),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedLevel = level;
                            });
                          },
                          backgroundColor: Colors.grey[200],
                          selectedColor: Colors.blue.withValues(alpha: 0.2),
                          checkmarkColor: Colors.blue,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Results
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredCourses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.school, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty && _selectedLevel == 'All'
                              ? 'No courses available'
                              : 'No courses found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredCourses.length,
                    itemBuilder: (context, index) {
                      final course = _filteredCourses[index];
                      return CourseCard(
                        course: course,
                        onSave: () => _toggleSaveCourse(course),
                        levelColor: _getLevelColor(course.careerPath),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onSave;
  final Color levelColor;

  const CourseCard({
    super.key,
    required this.course,
    required this.onSave,
    required this.levelColor,
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
                  onPressed: onSave,
                  icon: Icon(
                    course.isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: course.isSaved ? Colors.blue : Colors.grey,
                  ),
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
                    color: levelColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    course.careerPath,
                    style: TextStyle(
                      fontSize: 12,
                      color: levelColor,
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
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Enrolling in ${course.title}...'),
                      action: SnackBarAction(
                        label: 'Learn More',
                        onPressed: () {
                          // Show course details
                        },
                      ),
                    ),
                  );
                },
                child: const Text('Enroll Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

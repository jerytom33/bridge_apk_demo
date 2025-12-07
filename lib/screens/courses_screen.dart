import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/course_model.dart';
import '../services/api_service.dart';

class CoursesScreen extends StatefulWidget {
  final bool showSaved;
  const CoursesScreen({super.key, this.showSaved = false});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  List<Course> _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() => _isLoading = true);
    try {
      final result = widget.showSaved
          ? await ApiService.getSavedCourses()
          : await ApiService.getCourses();

      if (result['success']) {
        final responseData = result['data'];
        print('Courses API Response: $responseData'); // Debug log

        List<dynamic> listCallback = [];
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data')) {
            listCallback = responseData['data'] as List;
          } else if (responseData.containsKey('results')) {
            listCallback = responseData['results'] as List;
          } else if (responseData.containsKey('courses')) {
            listCallback = responseData['courses'] as List;
          }
        } else if (responseData is List) {
          listCallback = responseData;
        }

        final courses = listCallback
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['error'] ?? 'Failed to load')),
          );
        }
      }
    } catch (e) {
      print('Error parsing courses: $e'); // Debug log
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshCourses() async {
    await _loadCourses();
  }

  Future<void> _toggleSave(int courseId) async {
    final courseIndex = _courses.indexWhere((c) => c.id == courseId);
    if (courseIndex == -1) return;

    final course = _courses[courseIndex];
    // Optimistic update
    setState(() {
      final updatedCourse = course.copyWith(isSaved: !course.isSaved);
      _courses[courseIndex] = updatedCourse;
    });

    try {
      final newState = !_courses[courseIndex]
          .isSaved; // This logic is tricky with the setState above.
      // Let's rely on the original state:
      // If original 'course.isSaved' was true, we want to unsave (target state false).
      // If original 'course.isSaved' was false, we want to save (target state true).

      final apiResult = !course.isSaved
          ? await ApiService.saveCourse(courseId)
          : await ApiService.unsaveCourse(courseId);

      if (!apiResult['success']) {
        // Revert on failure
        if (mounted) {
          setState(() {
            _courses[courseIndex] = course; // Revert to original
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(apiResult['error'] ?? 'Action failed')),
          );
        }
      } else {
        // If showing saved items and we unsaved one, remove it from list
        if (widget.showSaved && course.isSaved) {
          setState(() {
            _courses.removeAt(courseIndex);
          });
        }
      }
    } catch (e) {
      // Revert
      if (mounted) {
        setState(() {
          _courses[courseIndex] = course;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.showSaved ? 'Saved Courses' : 'Trending Courses',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshCourses,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Explore Courses',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Discover trending courses in your field',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),
              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search courses...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Courses List
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: SpinKitFadingCircle(
                          color: Color(0xFF6C63FF),
                          size: 40.0,
                        ),
                      )
                    : ListView.separated(
                        itemCount: _courses.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final course = _courses[index];
                          return Card(
                            // Inherits CardTheme
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                // Navigate to details
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            course.title,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            course.isSaved
                                                ? Icons.bookmark
                                                : Icons.bookmark_border,
                                            color: Theme.of(
                                              context,
                                            ).primaryColor,
                                          ),
                                          onPressed: () =>
                                              _toggleSave(course.id),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'by ${course.provider}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: Colors.grey[700]),
                                    ),
                                    const SizedBox(height: 16),
                                    // Rating and Stats
                                    Row(
                                      children: [
                                        _buildTag(
                                          context,
                                          icon: Icons.star,
                                          label: course.rating.toString(),
                                          color: Colors.amber,
                                          bgColor: Colors.amber[100]!,
                                        ),
                                        const SizedBox(width: 12),
                                        _buildTag(
                                          context,
                                          icon: Icons.people,
                                          label: 'N/A',
                                          color: Colors.grey,
                                          bgColor: Colors.grey[200]!,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    // Level and Category Tags
                                    Row(
                                      children: [
                                        _buildTag(
                                          context,
                                          label: course.careerPath,
                                          color: Theme.of(context).primaryColor,
                                          bgColor: Theme.of(
                                            context,
                                          ).primaryColor.withOpacity(0.1),
                                        ),
                                        const SizedBox(width: 10),
                                        _buildTag(
                                          context,
                                          label: course.duration,
                                          color: Colors.grey[800]!,
                                          bgColor: Colors.grey[200]!,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(
    BuildContext context, {
    IconData? icon,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

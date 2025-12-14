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
        // print('Courses API Response: $responseData'); // Debug log

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
        _checkDeepLink(); // Check if we need to open a specific course
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
      // print('Error loading courses: $e'); // Debug log
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
      // This logic is tricky with the setState above.
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

  int? _highlightedCourseId;
  bool _initialDeepLinkHandled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialDeepLinkHandled) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic> && args.containsKey('courseId')) {
        try {
          _highlightedCourseId = int.parse(args['courseId'].toString());
          // print('🔗 Deep link received for Course ID: $_highlightedCourseId');
        } catch (e) {
          // print('❌ Error parsing courseId from arguments: $e');
        }
      }
      _initialDeepLinkHandled = true;
    }
  }

  void _checkDeepLink() {
    if (_highlightedCourseId != null && !_isLoading) {
      try {
        final course = _courses.firstWhere((c) => c.id == _highlightedCourseId);
        // Slight delay to ensure UI is ready
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _showCourseDetails(course);
            // Reset to prevent re-opening on simple setStates
            setState(() {
              _highlightedCourseId = null;
            });
          }
        });
      } catch (e) {
        // print(
        //   'Could not find course with ID $_highlightedCourseId to highlight',
        // );
      }
    }
  }

  void _showCourseDetails(Course course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        course.title,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        course.isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: Theme.of(context).primaryColor,
                        size: 30,
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Close sheet to update list
                        _toggleSave(course.id);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'by ${course.provider}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _buildTag(
                      context,
                      icon: Icons.star,
                      label: '${course.rating} Rating',
                      color: Colors.amber[800]!,
                      bgColor: Colors.amber[100]!,
                    ),
                    const SizedBox(width: 12),
                    _buildTag(
                      context,
                      icon: Icons.access_time,
                      label: course.duration,
                      color: Colors.blue[800]!,
                      bgColor: Colors.blue[100]!,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'About this course',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  course.description.isNotEmpty
                      ? course.description
                      : 'No description available for this course.',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.grey[700],
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Enrollment feature coming soon!'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Enroll Now',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
                          // print('Highlighting course: ${course.title}');
                          return Card(
                            // Inherits CardTheme
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => _showCourseDetails(course),
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
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: [
                                        _buildTag(
                                          context,
                                          label: course.careerPath,
                                          color: Theme.of(context).primaryColor,
                                          bgColor: Theme.of(
                                            context,
                                          ).primaryColor.withValues(alpha: 0.1),
                                        ),
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

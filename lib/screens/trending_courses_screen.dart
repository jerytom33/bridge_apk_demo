import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../services/api_service.dart';

class TrendingCoursesScreen extends StatefulWidget {
  const TrendingCoursesScreen({super.key});

  @override
  State<TrendingCoursesScreen> createState() => _TrendingCoursesScreenState();
}

class _TrendingCoursesScreenState extends State<TrendingCoursesScreen> {
  List<Course> _allCourses = [];
  List<Course> _filteredCourses = [];
  String? _selectedCategory;
  String? _selectedLevel;
  String? _selectedType;
  bool _isLoading = true;

  final List<String> _categories = [
    'All',
    'Technology',
    'Business',
    'Arts',
    'Science',
    'Engineering',
    'Medicine',
    'Law',
    'Finance',
    'Education',
  ];

  final List<String> _levels = ['All', 'Beginner', 'Intermediate', 'Advanced'];
  final List<String> _types = ['All', 'Online', 'Offline'];

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
          _allCourses = courses;
          _filteredCourses = courses;
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

  void _filterCourses() {
    setState(() {
      _filteredCourses = _allCourses.where((course) {
        bool categoryMatch =
            _selectedCategory == null ||
            _selectedCategory == 'All' ||
            course.careerPath == _selectedCategory;
        bool levelMatch =
            _selectedLevel == null ||
            _selectedLevel == 'All' ||
            course.careerPath == _selectedLevel;
        bool typeMatch = _selectedType == null || _selectedType == 'All';
        return categoryMatch && levelMatch && typeMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trending Courses'), centerTitle: true),
      body: Column(
        children: [
          // Filters
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter Courses',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                // Category Filter
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _categories.map((category) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: _selectedCategory == category,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = selected ? category : null;
                            });
                            _filterCourses();
                          },
                          selectedColor: Colors.blue.withValues(alpha: 0.2),
                          checkmarkColor: Colors.blue,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                // Level and Type Filters
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedLevel,
                        hint: const Text('Level'),
                        items: _levels.map((level) {
                          return DropdownMenuItem(
                            value: level,
                            child: Text(level),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedLevel = value;
                          });
                          _filterCourses();
                        },
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedType,
                        hint: const Text('Type'),
                        items: _types.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value;
                          });
                          _filterCourses();
                        },
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          // Courses List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredCourses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No courses found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your filters',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredCourses.length,
                    itemBuilder: (context, index) {
                      final course = _filteredCourses[index];
                      return _CourseCard(course: course);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final Course course;

  const _CourseCard({required this.course});

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    course.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
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
              ],
            ),
            const SizedBox(height: 8),
            Text(
              course.description,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  course.provider,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.people, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('N/A', style: const TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Rating
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      course.rating.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Duration
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(course.duration, style: const TextStyle(fontSize: 14)),
                  ],
                ),
                const Spacer(),
                // Type
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getTypeColor('Online').withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 12,
                      color: _getTypeColor('Online'),
                      fontWeight: FontWeight.w600,
                    ),
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
                    SnackBar(content: Text('Enrolling in ${course.title}...')),
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

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Online':
        return Colors.blue;
      case 'Offline':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

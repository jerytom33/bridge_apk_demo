import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/exam_model.dart';
import '../services/api_service.dart';

class ExamsScreen extends StatefulWidget {
  final bool showSaved;
  const ExamsScreen({super.key, this.showSaved = false});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  List<Exam> _exams = [];
  String _selectedLevel = 'All';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  Future<void> _loadExams() async {
    setState(() => _isLoading = true);
    try {
      final result = widget.showSaved
          ? await ApiService.getSavedExams()
          : await ApiService.getExams(
              level: _selectedLevel == 'All' ? null : _selectedLevel,
            );

      if (result['success']) {
        final responseData = result['data'];
        print('Exams API Response: $responseData'); // Debug log

        List<dynamic> listCallback = [];
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data')) {
            listCallback = responseData['data'] as List;
          } else if (responseData.containsKey('results')) {
            listCallback = responseData['results'] as List;
          } else if (responseData.containsKey('exams')) {
            listCallback = responseData['exams'] as List;
          }
        } else if (responseData is List) {
          listCallback = responseData;
        }

        final exams = listCallback.map((exam) => Exam.fromJson(exam)).toList();

        setState(() {
          _exams = exams;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['error'] ?? 'Failed to load exams')),
          );
        }
      }
    } catch (e) {
      print('Error parsing exams: $e'); // Debug log
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshExams() async {
    await _loadExams();
  }

  Future<void> _toggleSave(int examId) async {
    final index = _exams.indexWhere((e) => e.id == examId);
    if (index == -1) return;

    final exam = _exams[index];
    // Optimistic update
    setState(() {
      _exams[index] = exam.copyWith(isSaved: !exam.isSaved);
    });

    try {
      final newState = !exam.isSaved;
      final apiResult = newState
          ? await ApiService.saveExam(examId)
          : await ApiService.unsaveExam(examId);

      if (!apiResult['success']) {
        // Revert
        if (mounted) {
          setState(() {
            _exams[index] = exam;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(apiResult['error'] ?? 'Action failed')),
          );
        }
      } else {
        // If showing saved items and we unsaved one, remove it from list
        if (widget.showSaved && !newState) {
          setState(() {
            _exams.removeAt(index);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _exams[index] = exam;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.showSaved ? 'Saved Exams' : 'Upcoming Exams',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshExams,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!widget.showSaved) ...[
                Text(
                  'Find Your Exams',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Stay updated with exam schedules',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),
                // Filter Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedLevel,
                  decoration: InputDecoration(
                    labelText: 'Filter by Level',
                    prefixIcon: Icon(
                      Icons.filter_list,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All Levels')),
                    DropdownMenuItem(
                      value: 'Undergraduate',
                      child: Text('Undergraduate'),
                    ),
                    DropdownMenuItem(
                      value: 'Postgraduate',
                      child: Text('Postgraduate'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedLevel = value;
                      });
                      _loadExams(); // Reload with new filter
                    }
                  },
                ),
                const SizedBox(height: 20),
              ],

              // Exams List
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: SpinKitFadingCircle(
                          color: Color(0xFF6C63FF),
                          size: 40.0,
                        ),
                      )
                    : _exams.isEmpty
                    ? const Center(child: Text("No exams found"))
                    : ListView.separated(
                        itemCount: _exams.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final exam = _exams[index];
                          return Card(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {},
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Theme.of(
                                              context,
                                            ).primaryColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.calendar_today,
                                            color: Theme.of(
                                              context,
                                            ).primaryColor,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            exam.name,
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
                                            exam.isSaved
                                                ? Icons.bookmark
                                                : Icons.bookmark_border,
                                            color: Theme.of(
                                              context,
                                            ).primaryColor,
                                          ),
                                          onPressed: () => _toggleSave(exam.id),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      exam.description,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Colors.grey[700],
                                            height: 1.5,
                                          ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        _buildTag(
                                          context,
                                          icon: Icons.school,
                                          label: exam.educationLevel,
                                          color: Colors.grey[700]!,
                                          bgColor: Colors.grey[200]!,
                                        ),
                                        const SizedBox(width: 12),
                                        _buildTag(
                                          context,
                                          icon: Icons.book,
                                          label: exam.subject,
                                          color: Colors.grey[700]!,
                                          bgColor: Colors.grey[200]!,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: Colors.grey[300]!,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: 16,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Date: ${exam.date}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey[800],
                                                ),
                                          ),
                                        ],
                                      ),
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

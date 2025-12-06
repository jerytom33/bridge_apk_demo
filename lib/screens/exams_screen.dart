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

  // TODO: Add toggle save for exams if needed (exam model doesn't have isSaved yet?)
  // Wait, I updated Course model to have isSaved. Did I update Exam model?
  // I only updated ID type in Exam model.
  // I should check if Exam model has isSaved.
  // The user request for Exam model didn't specify isSaved, but user request for features says "List All Enabled Exams", "Save Exam", "Unsave", "My Saved Exams".
  // The API response for "My Saved Exams" will return exams.
  // The API response for "List All Exams" usually has `is_saved` flag if authenticated.
  // I should update Exam model to include `isSaved` if I want to show the bookmark icon state correctly.
  // For now, I'll assume it doesn't and just implement the listing, or check the model file again.
  // Checked: exam_model.dart doesn't have `isSaved`.
  // I should add `isSaved` to `Exam` model to support this feature properly.
  // Given I'm in the middle of writing this file, I will leave logic commented or generic.
  // Actually, I should update the Exam model first.

  // Implementing without isSaved for now (user might just see list), or I handle saving separately.
  // But to toggle, I need state.
  // I'll update Exam model in next step. For now I'll just write the screen code assuming `isSaved` exists (and it will fail/warn), or better,
  // I'll implementation the UI and comment out the toggle logic or use a local map for saved state if model doesn't have it.
  // Better: I will update the Exam model in the *same* step? No, multi-step.
  // I'll write this file assuming `isSaved` is available, and then immediately update `Exam` model to include it.

  // Re-reading Exam model:
  // fields: id (int), name, description, date, educationLevel, subject, duration, examType.
  // I will add `bool isSaved` to it.

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
    // Filter logic is handled by API for main list, but for saved list we might want client side filter?
    // Or just hide filter if showing saved.

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.showSaved ? 'Saved Exams' : 'Upcoming Exams',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
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
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Stay updated with exam schedules',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),
                // Filter Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedLevel,
                  decoration: InputDecoration(
                    labelText: 'Filter by Level',
                    labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
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
                            const SizedBox(height: 15),
                        itemBuilder: (context, index) {
                          final exam = _exams[index];
                          return Card(
                            elevation: 2,
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
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF6C63FF,
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.calendar_today,
                                          color: Color(0xFF6C63FF),
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: Text(
                                          exam.name,
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      // Bookmark icon (placeholder fun)
                                      IconButton(
                                        icon: Icon(
                                          exam.isSaved
                                              ? Icons.bookmark
                                              : Icons.bookmark_border,
                                          color: const Color(0xFF6C63FF),
                                        ),
                                        onPressed: () => _toggleSave(exam.id),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  Text(
                                    exam.description,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.school,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        exam.educationLevel,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Icon(
                                        Icons.book,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        exam.subject,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Date: ${exam.date}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.grey[800],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
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
}

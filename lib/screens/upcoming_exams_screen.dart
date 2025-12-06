import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exam_model.dart';

class UpcomingExamsScreen extends StatefulWidget {
  const UpcomingExamsScreen({super.key});

  @override
  _UpcomingExamsScreenState createState() => _UpcomingExamsScreenState();
}

class _UpcomingExamsScreenState extends State<UpcomingExamsScreen> {
  List<Exam> _allExams = [];
  List<Exam> _filteredExams = [];
  String? _userEducationLevel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserDataAndExams();
  }

  Future<void> _loadUserDataAndExams() async {
    // Load user education level from shared preferences
    final prefs = await SharedPreferences.getInstance();
    final userEducationLevel = prefs.getString('user_education_level');

    setState(() {
      _userEducationLevel = userEducationLevel;
    });

    // Mock exam data
    final exams = [
      Exam(
        id: 1,
        name: 'JEE Main 2024',
        description: 'Joint Entrance Examination for engineering colleges',
        date: '2024-04-15',
        educationLevel: '12th',
        subject: 'PCM',
        duration: '3 hours',
        examType: 'Online',
      ),
      Exam(
        id: 2,
        name: 'NEET 2024',
        description:
            'National Eligibility cum Entrance Test for medical colleges',
        date: '2024-05-05',
        educationLevel: '12th',
        subject: 'PCB',
        duration: '3 hours',
        examType: 'Offline',
      ),
      Exam(
        id: 3,
        name: 'CAT 2024',
        description: 'Common Admission Test for MBA programs',
        date: '2024-11-24',
        educationLevel: 'UG',
        subject: 'Quantitative, Verbal, DI & LR',
        duration: '2 hours',
        examType: 'Online',
      ),
      Exam(
        id: 4,
        name: 'GATE 2025',
        description: 'Graduate Aptitude Test in Engineering',
        date: '2025-02-01',
        educationLevel: 'UG',
        subject: 'Engineering Mathematics',
        duration: '3 hours',
        examType: 'Online',
      ),
      Exam(
        id: 5,
        name: 'UPSC Prelims 2024',
        description:
            'Union Public Service Commission Civil Services Preliminary Exam',
        date: '2024-06-16',
        educationLevel: 'UG',
        subject: 'General Studies, CSAT',
        duration: '2 hours',
        examType: 'Offline',
      ),
      Exam(
        id: 6,
        name: 'SSC CGL 2024',
        description: 'Staff Selection Commission Combined Graduate Level Exam',
        date: '2024-07-10',
        educationLevel: 'UG',
        subject: 'Quantitative Aptitude, English, Reasoning, GK',
        duration: '2 hours',
        examType: 'Online',
      ),
      Exam(
        id: 7,
        name: 'CBSE Class 10 Board Exam 2024',
        description:
            'Central Board of Secondary Education Class 10 examination',
        date: '2024-03-01',
        educationLevel: '10th',
        subject: 'Mathematics',
        duration: '3 hours',
        examType: 'Offline',
      ),
      Exam(
        id: 8,
        name: 'ICSE Class 12 Board Exam 2024',
        description:
            'Indian Certificate of Secondary Education Class 12 examination',
        date: '2024-02-15',
        educationLevel: '12th',
        subject: 'Physics',
        duration: '3 hours',
        examType: 'Offline',
      ),
    ];

    setState(() {
      _allExams = exams;
      _filteredExams = userEducationLevel != null
          ? exams
                .where((exam) => exam.educationLevel == userEducationLevel)
                .toList()
          : exams;
      _isLoading = false;
    });
  }

  void _filterExamsByEducationLevel(String? educationLevel) {
    setState(() {
      _userEducationLevel = educationLevel;
      _filteredExams = educationLevel != null
          ? _allExams
                .where((exam) => exam.educationLevel == educationLevel)
                .toList()
          : _allExams;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upcoming Exams'), centerTitle: true),
      body: Column(
        children: [
          // Education Level Filter
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter by Education Level',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _userEducationLevel == null,
                      onSelected: (selected) {
                        _filterExamsByEducationLevel(null);
                      },
                      selectedColor: Colors.blue.withValues(alpha: 0.2),
                      checkmarkColor: Colors.blue,
                    ),
                    FilterChip(
                      label: const Text('10th'),
                      selected: _userEducationLevel == '10th',
                      onSelected: (selected) {
                        _filterExamsByEducationLevel(selected ? '10th' : null);
                      },
                      selectedColor: Colors.blue.withValues(alpha: 0.2),
                      checkmarkColor: Colors.blue,
                    ),
                    FilterChip(
                      label: const Text('12th'),
                      selected: _userEducationLevel == '12th',
                      onSelected: (selected) {
                        _filterExamsByEducationLevel(selected ? '12th' : null);
                      },
                      selectedColor: Colors.blue.withValues(alpha: 0.2),
                      checkmarkColor: Colors.blue,
                    ),
                    FilterChip(
                      label: const Text('UG'),
                      selected: _userEducationLevel == 'UG',
                      onSelected: (selected) {
                        _filterExamsByEducationLevel(selected ? 'UG' : null);
                      },
                      selectedColor: Colors.blue.withValues(alpha: 0.2),
                      checkmarkColor: Colors.blue,
                    ),
                    FilterChip(
                      label: const Text('PG'),
                      selected: _userEducationLevel == 'PG',
                      onSelected: (selected) {
                        _filterExamsByEducationLevel(selected ? 'PG' : null);
                      },
                      selectedColor: Colors.blue.withValues(alpha: 0.2),
                      checkmarkColor: Colors.blue,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          // Exams List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredExams.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No upcoming exams found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _userEducationLevel != null
                              ? 'No exams available for $_userEducationLevel level'
                              : 'No exams available',
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
                    itemCount: _filteredExams.length,
                    itemBuilder: (context, index) {
                      final exam = _filteredExams[index];
                      return _ExamCard(exam: exam);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  final Exam exam;

  const _ExamCard({required this.exam});

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
                    exam.name,
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
                    color: _getEducationLevelColor(
                      exam.educationLevel,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    exam.educationLevel,
                    style: TextStyle(
                      fontSize: 12,
                      color: _getEducationLevelColor(exam.educationLevel),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              exam.description,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  exam.date,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  exam.duration,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
                    color: _getExamTypeColor(
                      exam.examType,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    exam.examType,
                    style: TextStyle(
                      fontSize: 12,
                      color: _getExamTypeColor(exam.examType),
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
                    exam.subject,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Setting reminder for ${exam.name}...'),
                    ),
                  );
                },
                child: const Text('Set Reminder'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getEducationLevelColor(String level) {
    switch (level) {
      case '10th':
        return Colors.green;
      case '12th':
        return Colors.blue;
      case 'UG':
        return Colors.orange;
      case 'PG':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getExamTypeColor(String type) {
    switch (type) {
      case 'Online':
        return Colors.green;
      case 'Offline':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

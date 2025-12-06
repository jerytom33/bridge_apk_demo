import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

class ExamsScreen extends StatefulWidget {
  const ExamsScreen({super.key});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  final List<Map<String, dynamic>> _exams = [
    {
      'id': 1,
      'name': 'JEE Main',
      'date': '2023-07-15',
      'description': 'Joint Entrance Examination for engineering aspirants',
      'level': 'Undergraduate',
      'subject': 'PCM',
    },
    {
      'id': 2,
      'name': 'NEET',
      'date': '2023-08-06',
      'description':
          'National Eligibility cum Entrance Test for medical aspirants',
      'level': 'Undergraduate',
      'subject': 'PCB',
    },
    {
      'id': 3,
      'name': 'CAT',
      'date': '2023-11-26',
      'description': 'Common Admission Test for MBA programs',
      'level': 'Postgraduate',
      'subject': 'Quantitative, Verbal, DI, LR',
    },
    {
      'id': 4,
      'name': 'GATE',
      'date': '2024-02-03',
      'description': 'Graduate Aptitude Test in Engineering',
      'level': 'Postgraduate',
      'subject': 'Engineering',
    },
    {
      'id': 5,
      'name': 'CLAT',
      'date': '2024-01-14',
      'description': 'Common Law Admission Test',
      'level': 'Undergraduate',
      'subject': 'Law',
    },
  ];

  String _selectedLevel = 'All';
  bool _isLoading = false;

  List<Map<String, dynamic>> get _filteredExams {
    if (_selectedLevel == 'All') {
      return _exams;
    }
    return _exams.where((exam) => exam['level'] == _selectedLevel).toList();
  }

  Future<void> _refreshExams() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Upcoming Exams',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshExams,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                      value: 'Undergraduate', child: Text('Undergraduate')),
                  DropdownMenuItem(
                      value: 'Postgraduate', child: Text('Postgraduate')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedLevel = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              // Exams List
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: SpinKitFadingCircle(
                          color: Color(0xFF6C63FF),
                          size: 40.0,
                        ),
                      )
                    : ListView.separated(
                        itemCount: _filteredExams.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 15),
                        itemBuilder: (context, index) {
                          final exam = _filteredExams[index];
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
                                          color: const Color(0xFF6C63FF)
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
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
                                          exam['name'],
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  Text(
                                    exam['description'],
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
                                        exam['level'],
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
                                        exam['subject'],
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
                                      'Date: ${exam['date']}',
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

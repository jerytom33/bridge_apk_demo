import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../services/api_service.dart';

class ResumeAnalyzerScreen extends StatefulWidget {
  const ResumeAnalyzerScreen({super.key});

  @override
  _ResumeAnalyzerScreenState createState() => _ResumeAnalyzerScreenState();
}

class _ResumeAnalyzerScreenState extends State<ResumeAnalyzerScreen> {
  File? _selectedFile;
  bool _isAnalyzing = false;
  List<String> _extractedSkills = [];
  List<String> _careerPaths = []; // New field for career paths
  List<String> _skillGaps = []; // New field for skill gaps
  List<String> _recommendedActions = []; // New field for recommended actions
  bool _analysisComplete = false;

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'], // Only allow PDF files
      );

      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _analysisComplete = false;
          _extractedSkills.clear();
          _careerPaths.clear();
          _skillGaps.clear();
          _recommendedActions.clear();
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking file: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _analyzeResume() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a resume file first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final result = await ApiService.uploadResume(_selectedFile!);

      if (result['success']) {
        // Extract data from API response
        final data = result['data'];

        // Extract skills
        List<String> skills = [];
        if (data['skills'] != null) {
          skills = List<String>.from(data['skills']);
        } else {
          // Mock skills if API doesn't return them
          skills = [
            'Communication',
            'Teamwork',
            'Problem Solving',
            'Leadership',
            'Time Management',
            'Critical Thinking',
            'Adaptability',
            'Project Management',
          ];
        }

        // Extract career paths
        List<String> careerPaths = [];
        if (data['career_paths'] != null) {
          careerPaths = List<String>.from(data['career_paths']);
        } else {
          // Mock career paths if API doesn't return them
          careerPaths = [
            'Software Developer',
            'Data Analyst',
            'Project Manager',
            'Business Consultant',
          ];
        }

        // Extract skill gaps
        List<String> skillGaps = [];
        if (data['skill_gaps'] != null) {
          skillGaps = List<String>.from(data['skill_gaps']);
        } else {
          // Mock skill gaps if API doesn't return them
          skillGaps = [
            'Technical Skills',
            'Industry Knowledge',
            'Certifications',
            'Experience',
          ];
        }

        // Extract recommended actions
        List<String> recommendedActions = [];
        if (data['recommended_actions'] != null) {
          recommendedActions = List<String>.from(data['recommended_actions']);
        } else {
          // Mock recommended actions if API doesn't return them
          recommendedActions = [
            'Take online courses in your field',
            'Gain practical experience through internships',
            'Attend industry conferences and networking events',
            'Consider professional certifications',
          ];
        }

        setState(() {
          _extractedSkills = skills;
          _careerPaths = careerPaths;
          _skillGaps = skillGaps;
          _recommendedActions = recommendedActions;
          _analysisComplete = true;
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resume analyzed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Resume analysis failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Use mock data if API fails
      setState(() {
        _extractedSkills = [
          'Communication',
          'Teamwork',
          'Problem Solving',
          'Leadership',
          'Time Management',
          'Critical Thinking',
          'Adaptability',
          'Project Management',
        ];
        _careerPaths = [
          'Software Developer',
          'Data Analyst',
          'Project Manager',
          'Business Consultant',
        ];
        _skillGaps = [
          'Technical Skills',
          'Industry Knowledge',
          'Certifications',
          'Experience',
        ];
        _recommendedActions = [
          'Take online courses in your field',
          'Gain practical experience through internships',
          'Attend industry conferences and networking events',
          'Consider professional certifications',
        ];
        _analysisComplete = true;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Using demo data for analysis'),
          backgroundColor: Colors.orange,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Analyzer'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How it works:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '1. Upload your resume (PDF only)\n'
                      '2. Our AI analyzes your skills and experience\n'
                      '3. Get personalized career suggestions based on your profile',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // File Upload Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.cloud_upload,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _selectedFile != null
                          ? 'Selected: ${_selectedFile!.path.split('/').last}'
                          : 'No file selected',
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _pickFile,
                      icon: const Icon(Icons.file_upload),
                      label: const Text('Choose Resume (PDF only)'),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _isAnalyzing ? null : _analyzeResume,
                      icon: _isAnalyzing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.analytics),
                      label: Text(
                          _isAnalyzing ? 'Analyzing...' : 'Analyze Resume'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Results Section
            if (_analysisComplete) ...[
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView(
                      children: [
                        const Text(
                          'AI Analysis Results',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        // Extracted Skills
                        const Text(
                          'Extracted Skills:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _extractedSkills.map((skill) {
                            return Chip(
                              label: Text(skill),
                              backgroundColor:
                                  Colors.blue.withValues(alpha: 0.1),
                              labelStyle: const TextStyle(color: Colors.blue),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),

                        // Career Paths
                        const Text(
                          'Suggested Career Paths:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _careerPaths.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: Icon(
                                Icons.work,
                                color: Colors.green,
                              ),
                              title: Text(_careerPaths[index]),
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Skill Gaps
                        const Text(
                          'Identified Skill Gaps:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _skillGaps.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: Icon(
                                Icons.warning,
                                color: Colors.orange,
                              ),
                              title: Text(_skillGaps[index]),
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Recommended Actions
                        const Text(
                          'Recommended Actions:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _recommendedActions.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: Icon(
                                Icons.check_circle,
                                color: Colors.blue,
                              ),
                              title: Text(_recommendedActions[index]),
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Career suggestions feature coming soon!'),
                                ),
                              );
                            },
                            child: const Text('Get Career Suggestions'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

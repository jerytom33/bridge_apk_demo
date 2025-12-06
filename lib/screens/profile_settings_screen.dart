import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/theme_provider.dart';
import '../models/exam_model.dart';
import '../models/course_model.dart';
import 'login_screen.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  _ProfileSettingsScreenState createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _feedbackController = TextEditingController();

  bool _isLoading = false;
  bool _isEditing = false;
  String _userName = '';
  String _userEmail = '';
  String _userEducationLevel = '';
  String _userStream = '';
  List<String> _userInterests = [];
  String _userCareerGoals = '';

  // Mock data for profile history
  List<Map<String, dynamic>> _resumeAnalyses = [];
  List<Map<String, dynamic>> _aptitudeResults = [];
  List<Exam> _savedExams = [];
  List<Course> _savedCourses = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadProfileHistory();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'Student';
      _userEmail = prefs.getString('user_email') ?? 'student@example.com';
      _userEducationLevel =
          prefs.getString('user_education_level') ?? 'Not specified';
      _userStream = prefs.getString('user_stream') ?? 'Not specified';
      _userCareerGoals =
          prefs.getString('user_career_goals') ?? 'Not specified';

      // Load interests
      final interestsString = prefs.getString('user_interests');
      if (interestsString != null) {
        _userInterests = interestsString.split(',');
      }

      _nameController.text = _userName;
      _emailController.text = _userEmail;
      _phoneController.text = prefs.getString('user_phone') ?? '';
    });
  }

  Future<void> _loadProfileHistory() async {
    // Mock resume analyses data
    final resumeAnalyses = [
      {
        'id': '1',
        'date': '2024-01-10',
        'skills': ['Communication', 'Teamwork', 'Problem Solving'],
        'careerPaths': ['Software Developer', 'Data Analyst'],
        'skillGaps': ['Technical Skills', 'Certifications'],
      },
      {
        'id': '2',
        'date': '2023-11-15',
        'skills': ['Leadership', 'Time Management', 'Critical Thinking'],
        'careerPaths': ['Project Manager', 'Business Consultant'],
        'skillGaps': ['Industry Knowledge', 'Experience'],
      },
    ];

    // Mock aptitude results data
    final aptitudeResults = [
      {
        'id': '1',
        'date': '2024-01-05',
        'score': '85%',
        'strengths': ['Quantitative Aptitude', 'Logical Reasoning'],
        'weaknesses': ['Verbal Ability'],
        'suggestedCareers': ['Data Scientist', 'Financial Analyst'],
      },
      {
        'id': '2',
        'date': '2023-12-20',
        'score': '78%',
        'strengths': ['Verbal Ability', 'Critical Thinking'],
        'weaknesses': ['Quantitative Aptitude'],
        'suggestedCareers': ['Content Writer', 'Marketing Specialist'],
      },
    ];

    // Mock saved exams data
    final savedExams = [
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
    ];

    // Mock saved courses data
    final savedCourses = [
      Course(
        id: 1,
        title: 'Python for Data Science',
        provider: 'Coursera',
        careerPath: 'Data Science',
        duration: '8 weeks',
        price: 'Free',
        rating: 4.8,
        link: 'https://coursera.org/learn/python-data-science',
        description:
            'Learn Python programming and data analysis libraries like Pandas and NumPy',
        isCertified: true,
        isActive: true,
        createdAt: '2023-01-01T00:00:00Z',
      ),
      Course(
        id: 2,
        title: 'Digital Marketing Masterclass',
        provider: 'Udemy',
        careerPath: 'Marketing',
        duration: '6 weeks',
        price: '\$49.99',
        rating: 4.6,
        link: 'https://udemy.com/course/digital-marketing',
        description:
            'Master SEO, social media marketing, and Google Ads for business growth',
        isCertified: true,
        isActive: true,
        createdAt: '2023-01-01T00:00:00Z',
      ),
    ];

    setState(() {
      _resumeAnalyses = resumeAnalyses;
      _aptitudeResults = aptitudeResults;
      _savedExams = savedExams;
      _savedCourses = savedCourses;
    });
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final profileData = {
        'current_level': _userEducationLevel,
        'stream': _userStream,
        'interests': _userInterests,
        'career_goals': _userCareerGoals,
        'phone': _phoneController.text.trim(),
      };

      final result = await ApiService.updateStudentProfile(profileData);

      if (result['success']) {
        setState(() {
          _userName = _nameController.text.trim();
          _userEmail = _emailController.text.trim();
          _isEditing = false;
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Profile update failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submitFeedback() async {
    if (_feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your feedback'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Mock API call for feedback
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for your feedback!'),
          backgroundColor: Colors.green,
        ),
      );

      _feedbackController.clear();
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting feedback: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _logout() async {
    try {
      await ApiService.logout();

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during logout: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: TextField(
          controller: _feedbackController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Share your thoughts, suggestions, or report issues...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _submitFeedback,
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Profile'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Profile Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Profile Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _isEditing = !_isEditing;
                                  });
                                },
                                icon: Icon(
                                  _isEditing ? Icons.close : Icons.edit,
                                ),
                                label: Text(_isEditing ? 'Cancel' : 'Edit'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Name Field
                                TextFormField(
                                  controller: _nameController,
                                  enabled: _isEditing,
                                  decoration: const InputDecoration(
                                    labelText: 'Full Name',
                                    prefixIcon: Icon(Icons.person),
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your name';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Email Field
                                TextFormField(
                                  controller: _emailController,
                                  enabled: _isEditing,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: Icon(Icons.email),
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    if (!RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                    ).hasMatch(value)) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Phone Field
                                TextFormField(
                                  controller: _phoneController,
                                  enabled: _isEditing,
                                  keyboardType: TextInputType.phone,
                                  decoration: const InputDecoration(
                                    labelText: 'Phone Number',
                                    prefixIcon: Icon(Icons.phone),
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      if (!RegExp(
                                        r'^[0-9]{10}$',
                                      ).hasMatch(value)) {
                                        return 'Please enter a valid 10-digit phone number';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Education Level
                                if (!_isEditing)
                                  ListTile(
                                    title: const Text('Education Level'),
                                    subtitle: Text(_userEducationLevel),
                                    leading: const Icon(Icons.school),
                                  ),

                                // Stream
                                if (!_isEditing)
                                  ListTile(
                                    title: const Text('Stream'),
                                    subtitle: Text(_userStream),
                                    leading: const Icon(Icons.book),
                                  ),

                                // Interests
                                if (!_isEditing)
                                  ListTile(
                                    title: const Text('Interests'),
                                    subtitle: Text(_userInterests.join(', ')),
                                    leading: const Icon(Icons.interests),
                                  ),

                                // Career Goals
                                if (!_isEditing)
                                  ListTile(
                                    title: const Text('Career Goals'),
                                    subtitle: Text(_userCareerGoals),
                                    leading: const Icon(Icons.flag),
                                  ),

                                // Update Button
                                if (_isEditing) ...[
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _isLoading
                                          ? null
                                          : _updateProfile,
                                      child: _isLoading
                                          ? const CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            )
                                          : const Text('Update Profile'),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Settings Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Settings',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Dark Mode Toggle
                          Consumer<ThemeProvider>(
                            builder: (context, themeProvider, child) {
                              return SwitchListTile(
                                title: const Text('Dark Mode'),
                                subtitle: const Text('Toggle dark/light theme'),
                                value: themeProvider.isDarkMode,
                                onChanged: (value) {
                                  themeProvider.toggleTheme();
                                },
                                secondary: Icon(
                                  themeProvider.isDarkMode
                                      ? Icons.dark_mode
                                      : Icons.light_mode,
                                ),
                              );
                            },
                          ),

                          const Divider(),

                          // Notifications
                          ListTile(
                            title: const Text('Notifications'),
                            subtitle: const Text(
                              'Manage notification preferences',
                            ),
                            leading: const Icon(Icons.notifications),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Notification settings coming soon!',
                                  ),
                                ),
                              );
                            },
                          ),

                          // Privacy
                          ListTile(
                            title: const Text('Privacy'),
                            subtitle: const Text(
                              'Privacy and security settings',
                            ),
                            leading: const Icon(Icons.privacy_tip),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Privacy settings coming soon!',
                                  ),
                                ),
                              );
                            },
                          ),

                          // Help & Support
                          ListTile(
                            title: const Text('Help & Support'),
                            subtitle: const Text(
                              'Get help and contact support',
                            ),
                            leading: const Icon(Icons.help),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Help & support coming soon!'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Actions Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Actions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Send Feedback
                          ListTile(
                            title: const Text('Send Feedback'),
                            subtitle: const Text('Help us improve the app'),
                            leading: const Icon(Icons.feedback),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: _showFeedbackDialog,
                          ),

                          const Divider(),

                          // Logout
                          ListTile(
                            title: const Text('Logout'),
                            subtitle: const Text('Sign out of your account'),
                            leading: const Icon(
                              Icons.logout,
                              color: Colors.red,
                            ),
                            onTap: _logout,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // App Info
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Bridge App',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Version 1.0.0',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '© 2024 Bridge - Career Guidance Platform',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),

            // History Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resume Analyses
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Resume Analyses',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_resumeAnalyses.isEmpty)
                            const Center(child: Text('No resume analyses yet'))
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _resumeAnalyses.length,
                              itemBuilder: (context, index) {
                                final analysis = _resumeAnalyses[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              analysis['date'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const Icon(Icons.description),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Extracted Skills:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Wrap(
                                          spacing: 4,
                                          children: (analysis['skills'] as List)
                                              .map(
                                                (skill) => Chip(
                                                  label: Text(skill),
                                                  backgroundColor: Colors.blue
                                                      .withValues(alpha: 0.1),
                                                  labelStyle: const TextStyle(
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Suggested Career Paths:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Wrap(
                                          spacing: 4,
                                          children:
                                              (analysis['careerPaths'] as List)
                                                  .map(
                                                    (path) => Chip(
                                                      label: Text(path),
                                                      backgroundColor: Colors
                                                          .green
                                                          .withValues(
                                                            alpha: 0.1,
                                                          ),
                                                      labelStyle:
                                                          const TextStyle(
                                                            color: Colors.green,
                                                          ),
                                                    ),
                                                  )
                                                  .toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Aptitude Results
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Aptitude Test Results',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_aptitudeResults.isEmpty)
                            const Center(
                              child: Text('No aptitude test results yet'),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _aptitudeResults.length,
                              itemBuilder: (context, index) {
                                final result = _aptitudeResults[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              result['date'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const Icon(Icons.psychology),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Text(
                                              'Score: ',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(result['score']),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Strengths:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Wrap(
                                          spacing: 4,
                                          children:
                                              (result['strengths'] as List)
                                                  .map(
                                                    (strength) => Chip(
                                                      label: Text(strength),
                                                      backgroundColor: Colors
                                                          .green
                                                          .withValues(
                                                            alpha: 0.1,
                                                          ),
                                                      labelStyle:
                                                          const TextStyle(
                                                            color: Colors.green,
                                                          ),
                                                    ),
                                                  )
                                                  .toList(),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Suggested Careers:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Wrap(
                                          spacing: 4,
                                          children:
                                              (result['suggestedCareers']
                                                      as List)
                                                  .map(
                                                    (career) => Chip(
                                                      label: Text(career),
                                                      backgroundColor: Colors
                                                          .purple
                                                          .withValues(
                                                            alpha: 0.1,
                                                          ),
                                                      labelStyle:
                                                          const TextStyle(
                                                            color:
                                                                Colors.purple,
                                                          ),
                                                    ),
                                                  )
                                                  .toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Saved Exams
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Saved Exams',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_savedExams.isEmpty)
                            const Center(child: Text('No saved exams'))
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _savedExams.length,
                              itemBuilder: (context, index) {
                                final exam = _savedExams[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          exam.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          exam.description,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today,
                                              size: 16,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              exam.date,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Icon(
                                              Icons.access_time,
                                              size: 16,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              exam.duration,
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
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Saved Courses
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Saved Courses',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_savedCourses.isEmpty)
                            const Center(child: Text('No saved courses'))
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _savedCourses.length,
                              itemBuilder: (context, index) {
                                final course = _savedCourses[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          course.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          course.description,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.person,
                                              size: 16,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              course.provider,
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                            const Spacer(),
                                            const Icon(
                                              Icons.star,
                                              size: 16,
                                              color: Colors.orange,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              course.rating.toString(),
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

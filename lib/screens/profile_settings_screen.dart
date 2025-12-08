import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../services/api_service.dart';
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
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();
  final _placeController = TextEditingController();
  final _feedbackController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
  String? _profileImageUrl;

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
    _dobController.dispose();
    _addressController.dispose();
    _placeController.dispose();
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
      _dobController.text = prefs.getString('user_dob') ?? '';
      _addressController.text = prefs.getString('user_address') ?? '';
      _placeController.text = prefs.getString('user_place') ?? '';
      _profileImageUrl = prefs.getString('user_profile_image');
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
        'dob': _dobController.text.trim(),
        'address': _addressController.text.trim(),
        'place': _placeController.text.trim(),
      };

      final result = await ApiService.updateStudentProfile(profileData);

      if (result['success']) {
        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', _nameController.text.trim());
        await prefs.setString('user_email', _emailController.text.trim());
        await prefs.setString('user_phone', _phoneController.text.trim());
        await prefs.setString('user_dob', _dobController.text.trim());
        await prefs.setString('user_address', _addressController.text.trim());
        await prefs.setString('user_place', _placeController.text.trim());

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

  Future<void> _pickProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });

        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_profile_image', image.path);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(
        const Duration(days: 6570),
      ), // 18 years ago
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
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
                  // Profile Picture at Top (Standard UX)
                  Center(
                    child: GestureDetector(
                      onTap: _pickProfileImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : (_profileImageUrl != null &&
                                          _profileImageUrl!.isNotEmpty
                                      ? FileImage(File(_profileImageUrl!))
                                      : null),
                            child:
                                (_profileImage == null &&
                                    (_profileImageUrl == null ||
                                        _profileImageUrl!.isEmpty))
                                ? const Icon(Icons.person, size: 60)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

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

                                // Date of Birth Field
                                TextFormField(
                                  controller: _dobController,
                                  enabled: _isEditing,
                                  readOnly: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Date of Birth',
                                    prefixIcon: Icon(Icons.calendar_today),
                                    border: OutlineInputBorder(),
                                    hintText: 'Select your date of birth',
                                  ),
                                  onTap: _isEditing ? _pickDate : null,
                                ),
                                const SizedBox(height: 16),

                                // Place/City Field
                                TextFormField(
                                  controller: _placeController,
                                  enabled: _isEditing,
                                  decoration: const InputDecoration(
                                    labelText: 'City/Place',
                                    prefixIcon: Icon(Icons.location_city),
                                    border: OutlineInputBorder(),
                                    hintText: 'Enter your city',
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Address Field
                                TextFormField(
                                  controller: _addressController,
                                  enabled: _isEditing,
                                  maxLines: 3,
                                  decoration: const InputDecoration(
                                    labelText: 'Address',
                                    prefixIcon: Icon(Icons.home),
                                    border: OutlineInputBorder(),
                                    hintText: 'Enter your full address',
                                    alignLabelWithHint: true,
                                  ),
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

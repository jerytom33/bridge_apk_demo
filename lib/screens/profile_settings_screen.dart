import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

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

  bool _isLoading = false;
  bool _isEditing = false;
  String _userName = '';
  String _userEmail = '';
  String _userEducationLevel = '';
  String _userStream = '';
  List<String> _userInterests = [];
  String _userCareerGoals = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh user data when screen is displayed
    _loadUserData();
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
    setState(() => _isLoading = true);

    try {
      // Fetch full student profile from backend
      final profileResult = await ApiService.fetchStudentProfile();

      if (profileResult['success']) {
        final data = profileResult['data'];
        print('📥 Student Profile data loaded: $data');

        // Check if data has top-level fields or nested user object
        // The /student/profile/ endpoint typically returns the student profile fields
        // and optionally a nested 'user' object or ID.
        // We might also need to fetch basic auth info if 'user' is just an ID.

        Map<String, dynamic> userData = {};
        Map<String, dynamic> profileData = {};

        if (data.containsKey('user') && data['user'] is Map) {
          userData = data['user'];
          profileData = data; // content is mixed or sibling
        } else {
          // Fallback/Alternative: fetch basic user info separately if needed
          // but let's assume 'data' contains the fields we need directly or nested
          profileData = data;
          // If user details are not in profileData, we might rely on what we already have or fetch auth/me
          final authResult = await ApiService.fetchProfile();
          if (authResult['success']) {
            userData = authResult['data']['user'] ?? authResult['data'];
          }
        }

        // Merge to get complete picture
        // Prioritize profileData for student fields, userData for name/email

        setState(() {
          _userName = userData['name'] ?? profileData['name'] ?? _userName;
          _userEmail = userData['email'] ?? profileData['email'] ?? _userEmail;

          _userEducationLevel =
              profileData['current_level'] ?? _userEducationLevel;
          _userStream = profileData['stream'] ?? _userStream;
          _userCareerGoals = profileData['career_goals'] ?? _userCareerGoals;

          // Load interests
          var interestsData = profileData['interests'];
          if (interestsData != null) {
            if (interestsData is List) {
              _userInterests = List<String>.from(interestsData);
            } else if (interestsData is String) {
              // Handle string representation if any
              if (interestsData.startsWith('[') &&
                  interestsData.endsWith(']')) {
                // It's a stringified list, strip brackets and quotes
                // This is a rough parser, ideally backend sends JSON array
                String clean = interestsData.substring(
                  1,
                  interestsData.length - 1,
                );
                _userInterests = clean
                    .split(',')
                    .map(
                      (e) => e.trim().replaceAll("'", "").replaceAll('"', ""),
                    )
                    .toList();
              } else {
                _userInterests = interestsData.split(',');
              }
            }
          }

          // Load form controllers
          _nameController.text = _userName;
          _emailController.text = _userEmail;
          _phoneController.text = profileData['phone'] ?? _phoneController.text;
          _dobController.text = profileData['dob'] ?? _dobController.text;
          _addressController.text =
              profileData['address'] ?? _addressController.text;
          _placeController.text = profileData['place'] ?? _placeController.text;
        });

        // Save fresh data to SharedPreferences for offline access
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', _userName);
        await prefs.setString('user_email', _userEmail);
        await prefs.setString('user_education_level', _userEducationLevel);
        await prefs.setString('user_stream', _userStream);
        await prefs.setString('user_career_goals', _userCareerGoals);
        await prefs.setString('user_interests', _userInterests.join(','));
        // Also save other fields if needed for cache
        await prefs.setString('user_phone', _phoneController.text);
        await prefs.setString('user_dob', _dobController.text);
        await prefs.setString('user_address', _addressController.text);
        await prefs.setString('user_place', _placeController.text);

        print('✅ Profile data loaded and cached');
      } else {
        // Backend failed, fallback to SharedPreferences
        print('⚠️ Backend fetch failed: ${profileResult['error']}');
        await _loadFromSharedPreferences();
      }
    } catch (e) {
      print('❌ Error fetching profile: $e');
      // Network error, fallback to SharedPreferences
      await _loadFromSharedPreferences();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadFromSharedPreferences() async {
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
        'name': _nameController.text.trim(), // Add name
        'email': _emailController.text.trim(), // Add email
        'current_level': _userEducationLevel,
        'stream': _userStream,
        'interests': _userInterests,
        'career_goals': _userCareerGoals,
        'phone': _phoneController.text.trim(),
        'dob': _dobController.text.trim(),
        'address': _addressController.text.trim(),
        'place': _placeController.text.trim(),
      };

      print('📤 Updating profile with data: $profileData');

      final result = await ApiService.updateStudentProfile(profileData);

      if (result['success']) {
        // Save to SharedPreferences for offline access
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', _nameController.text.trim());
        await prefs.setString('user_email', _emailController.text.trim());
        await prefs.setString('user_phone', _phoneController.text.trim());
        await prefs.setString('user_dob', _dobController.text.trim());
        await prefs.setString('user_address', _addressController.text.trim());
        await prefs.setString('user_place', _placeController.text.trim());
        await prefs.setString('user_education_level', _userEducationLevel);
        await prefs.setString('user_stream', _userStream);
        await prefs.setString('user_career_goals', _userCareerGoals);
        await prefs.setString('user_interests', _userInterests.join(','));

        setState(() {
          _userName = _nameController.text.trim();
          _userEmail = _emailController.text.trim();
          _isEditing = false;
        });

        print('✅ Profile updated successfully in database and cache');

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Reload data to ensure UI is in sync with backend
        await _loadUserData();
      } else {
        print('❌ Profile update failed: ${result['error']}');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Profile update failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('❌ Error updating profile: $e');
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
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: SingleChildScrollView(
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
                          icon: Icon(_isEditing ? Icons.close : Icons.edit),
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
                                if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
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
                                onPressed: _isLoading ? null : _updateProfile,
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
                      subtitle: const Text('Manage notification preferences'),
                      leading: const Icon(Icons.notifications),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Notification settings coming soon!'),
                          ),
                        );
                      },
                    ),

                    // Privacy
                    ListTile(
                      title: const Text('Privacy'),
                      subtitle: const Text('Privacy and security settings'),
                      leading: const Icon(Icons.privacy_tip),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Privacy settings coming soon!'),
                          ),
                        );
                      },
                    ),

                    // Help & Support
                    ListTile(
                      title: const Text('Help & Support'),
                      subtitle: const Text('Get help and contact support'),
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
                      leading: const Icon(Icons.logout, color: Colors.red),
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
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '© 2024 Bridge - Career Guidance Platform',
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

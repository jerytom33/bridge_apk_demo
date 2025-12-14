import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'profile_settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = '';
  String _userEmail = '';
  String? _profileImageUrl;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload data every time the screen is displayed
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedImagePath = prefs.getString('user_profile_image');

    setState(() {
      _userName = prefs.getString('user_name') ?? 'Student';
      _userEmail = prefs.getString('user_email') ?? 'student@example.com';

      // Clear previous cached image
      _profileImage = null;

      // Check if saved image file exists
      if (savedImagePath != null && savedImagePath.isNotEmpty) {
        final imageFile = File(savedImagePath);
        if (imageFile.existsSync()) {
          _profileImageUrl = savedImagePath;
        } else {
          // File doesn't exist, clear from preferences
          _profileImageUrl = null;
          prefs.remove('user_profile_image');
        }
      } else {
        _profileImageUrl = null;
      }
    });

    // Debug print to verify data
    // print('Profile loaded: $_userName, $_userEmail, Image: $_profileImageUrl');
  }

  Future<void> _pickProfileImage() async {
    try {
      // Show options: Camera or Gallery
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Update Profile Picture'),
          content: const Text('Choose an option'),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.pop(context, ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Camera'),
            ),
            TextButton.icon(
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Gallery'),
            ),
          ],
        ),
      );

      if (source == null) return;

      final XFile? image = await _picker.pickImage(
        source: source,
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
        _profileImageUrl = image.path;

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
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _logout() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Clear all user state first
      setState(() {
        _userName = '';
        _userEmail = '';
        _profileImage = null;
        _profileImageUrl = null;
      });

      // Delete profile image file if it exists
      final prefs = await SharedPreferences.getInstance();
      final savedImagePath = prefs.getString('user_profile_image');
      if (savedImagePath != null && savedImagePath.isNotEmpty) {
        try {
          final imageFile = File(savedImagePath);
          if (imageFile.existsSync()) {
            await imageFile.delete();
            // print('🗑️ Deleted profile image: $savedImagePath');
          }
        } catch (e) {
          // print('⚠️ Error deleting image file: $e');
        }
      }

      // Call API logout
      await ApiService.logout();

      // Double-check: Explicitly clear all user-related preferences
      await prefs.remove('user_name');
      await prefs.remove('user_email');
      await prefs.remove('user_profile_image');
      await prefs.remove('user_phone');
      await prefs.remove('user_dob');
      await prefs.remove('user_address');
      await prefs.remove('user_place');

      // print('✅ All user data cleared from SharedPreferences');

      if (!mounted) return;

      // Navigate to login screen and clear navigation stack
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Background Wave
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(60),
                  bottomRight: Radius.circular(60),
                ),
              ),
            ),

            // Profile Avatar (overlapping)
            Transform.translate(
              offset: const Offset(0, -80),
              child: Column(
                children: [
                  // Avatar with Edit Button
                  GestureDetector(
                    onTap: _pickProfileImage,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: const Color(0xFF93C5FD),
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
                                ? const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Color(0xFF60A5FA),
                                  )
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black26, blurRadius: 4),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Color(0xFF60A5FA),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // User Info
                  Text(
                    _userName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _userEmail,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),

                  // Menu Options Card 1
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _buildMenuItem(
                            icon: Icons.account_box_outlined,
                            title: 'Edit profile information',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ProfileSettingsScreen(),
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1),
                          _buildMenuItem(
                            icon: Icons.notifications_outlined,
                            title: 'Notifications',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Notifications settings coming soon!',
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

                  // Menu Options Card 2
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _buildMenuItem(
                            icon: Icons.help_outline,
                            title: 'Help & Support',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Help & Support coming soon!'),
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1),
                          _buildMenuItem(
                            icon: Icons.lock_outline,
                            title: 'Privacy policy',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Privacy policy coming soon!'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Logout Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.red),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Icon(icon, color: Colors.black87, size: 24),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}

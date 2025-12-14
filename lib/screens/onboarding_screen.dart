import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import 'main_wrapper.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _educationLevelController = TextEditingController();
  final _streamController = TextEditingController();
  final _careerGoalsController = TextEditingController();

  final List<String> _selectedInterests = [];
  bool _isLoading = false;

  // Predefined interests options
  final List<String> _interestsOptions = [
    'Technology',
    'Business',
    'Arts',
    'Science',
    'Engineering',
    'Medicine',
    'Law',
    'Education',
    'Finance',
    'Marketing',
    'Design',
    'Writing',
  ];

  @override
  void dispose() {
    _educationLevelController.dispose();
    _streamController.dispose();
    _careerGoalsController.dispose();
    super.dispose();
  }

  Future<void> _setupProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final profileProvider = Provider.of<ProfileProvider>(
        context,
        listen: false,
      );
      final result = await profileProvider.setupProfile({
        'education_level': _educationLevelController.text,
        'stream': _streamController.text,
        'interests': _selectedInterests,
        'career_goals': _careerGoalsController.text,
      });

      if (result['success'] && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile setup completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainWrapper()),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Profile setup failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        _selectedInterests.add(interest);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Profile Setup',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF6C63FF),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                'Tell us about yourself',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'This helps us provide personalized career recommendations',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Education Level
                    _buildDropdownField(
                      controller: _educationLevelController,
                      label: 'Education Level',
                      icon: Icons.school_outlined,
                      items: ['10th', '12th', 'Undergraduate', 'Postgraduate'],
                      hint: 'Select your education level',
                    ),
                    const SizedBox(height: 20),

                    // Stream/Subject
                    _buildTextField(
                      controller: _streamController,
                      label: 'Stream/Subject',
                      icon: Icons.book_outlined,
                      hintText: 'e.g., Science, Commerce, Arts, etc.',
                    ),
                    const SizedBox(height: 20),

                    // Interests
                    _buildInterestsSelector(),
                    const SizedBox(height: 20),

                    // Career Goals
                    _buildTextField(
                      controller: _careerGoalsController,
                      label: 'Career Goals',
                      icon: Icons.flag_outlined,
                      maxLines: 3,
                      hintText: 'What are your career aspirations?',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Continue Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _setupProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SpinKitFadingCircle(
                          color: Colors.white,
                          size: 24.0,
                        )
                      : Text(
                          'Continue',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[100],
            prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF6C63FF),
                width: 1.5,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required List<String> items,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: controller.text.isEmpty ? null : controller.text,
          isExpanded: true, // Fix overflow by expanding to fill width
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[100],
            prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ), // Reduce padding
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF6C63FF),
                width: 1.5,
              ),
            ),
          ),
          items: items.map((String item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                controller.text = value;
              });
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildInterestsSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Interests',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _interestsOptions.map((interest) {
            final isSelected = _selectedInterests.contains(interest);
            return FilterChip(
              label: Text(interest),
              selected: isSelected,
              onSelected: (selected) => _toggleInterest(interest),
              selectedColor: const Color(0xFF6C63FF),
              backgroundColor: Colors.grey[100],
              labelStyle: GoogleFonts.poppins(
                color: isSelected ? Colors.white : Colors.black87,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFF6C63FF)
                      : Colors.grey[300]!,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/aptitude_ai_service.dart';
import 'aptitude_result_screen.dart';
import 'login_screen.dart';

class AptitudeTestScreen extends StatefulWidget {
  final String educationLevel;

  const AptitudeTestScreen({super.key, required this.educationLevel});

  @override
  State<AptitudeTestScreen> createState() => _AptitudeTestScreenState();
}

class _AptitudeTestScreenState extends State<AptitudeTestScreen> {
  final AptitudeAiService _apiService = AptitudeAiService();

  List<Map<String, dynamic>> _questions = [];
  int _currentQuestionIndex = 0;
  final Map<int, int> _answers = {};

  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _loadQuestions();
  }

  /// Convert education level API value to user-friendly display name
  String _getLevelDisplayName(String level) {
    const levelNames = {
      '10th': '10th Standard',
      '12th': '12th Standard',
      'Diploma': 'Diploma',
      'Bachelor': "Bachelor's Degree",
      'Master': "Master's Degree",
    };
    return levelNames[level] ?? level;
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('Loading questions for level: ${widget.educationLevel}');
      final questions = await _apiService.getPersonalizedQuestions(
        educationLevel: widget.educationLevel,
        questionCount: 10,
      );

      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading questions: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  void _selectAnswer(int optionIndex) {
    setState(() {
      _answers[_currentQuestionIndex] = optionIndex;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  Future<void> _submitTest() async {
    // Check if all questions are answered
    if (_answers.length < _questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please answer all questions before submitting',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Convert _answers (Map<int, int>) to Map<String, String> for API
      final Map<String, String> apiAnswers = _answers.map(
        (key, value) =>
            MapEntry(key.toString(), _apiService.indexToLetter(value)),
      );

      final result = await _apiService.analyzeResults(
        questions: _questions,
        answers: apiAnswers,
      );

      // print('=== DEBUG APTITUDE RESULT ===');
      // print(result);
      // print('=============================');

      final timeTaken = DateTime.now().difference(_startTime).inSeconds;

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AptitudeResultScreen(
            score: (result['score'] as num?)?.toInt() ?? 0,
            totalQuestions: _questions.length,
            timeTaken: timeTaken,
            categoryBreakdown: Map<String, dynamic>.from(
              result['category_breakdown'] ?? {},
            ),
            answers: apiAnswers, // Pass the converted answers
            questions: _questions,
            aiAnalysis: result['ai_analysis'],
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to submit test: ${e.toString().replaceAll('Exception: ', '')}',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    if (_errorMessage != null) {
      return _buildErrorScreen();
    }

    if (_questions.isEmpty) {
      return _buildEmptyScreen();
    }

    return _buildTestScreen();
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Loading ${_getLevelDisplayName(widget.educationLevel)} Test',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SpinKitFadingCircle(color: Color(0xFF6C63FF), size: 60.0),
            const SizedBox(height: 24),
            Text(
              'Generating ${_getLevelDisplayName(widget.educationLevel)} questions...',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              'This may take a few moments',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Error',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
              const SizedBox(height: 24),
              Text(
                'Failed to Load Questions',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage ?? 'Unknown error occurred',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _loadQuestions,
                icon: const Icon(Icons.refresh),
                label: Text('Retry', style: GoogleFonts.poppins(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              if (_errorMessage != null &&
                  (_errorMessage!.contains('Authentication failed') ||
                      _errorMessage!.contains('Not authenticated'))) ...[
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () {
                    // Navigate to Login Screen and clear stack
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.login),
                  label: Text(
                    'Login Again',
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF6C63FF),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'No Questions Available',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'No questions found',
              style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestScreen() {
    final currentQuestion = _questions[_currentQuestionIndex];
    final selectedAnswerIndex = _answers[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${_getLevelDisplayName(widget.educationLevel)} - Aptitude Test',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                '${_currentQuestionIndex + 1}/${_questions.length}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _questions.length,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Question number badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.help_outline,
                          size: 18,
                          color: Color(0xFF6C63FF),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Question ${_currentQuestionIndex + 1}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6C63FF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Question text
                  Text(
                    currentQuestion['question'] ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Options
                  ...List.generate(
                    (currentQuestion['options'] as List).length,
                    (index) => _buildOptionCard(
                      index,
                      currentQuestion['options'][index],
                      selectedAnswerIndex == index,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentQuestionIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousQuestion,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFF6C63FF)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Previous',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6C63FF),
                        ),
                      ),
                    ),
                  ),
                if (_currentQuestionIndex > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isSubmitting
                        ? null
                        : (_currentQuestionIndex < _questions.length - 1
                              ? _nextQuestion
                              : _submitTest),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _currentQuestionIndex < _questions.length - 1
                                ? 'Next'
                                : 'Submit Test',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(int index, String optionText, bool isSelected) {
    final optionLabels = ['A', 'B', 'C', 'D', 'E', 'F'];

    return GestureDetector(
      onTap: () => _selectAnswer(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6C63FF).withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6C63FF)
                : Colors.grey.withValues(alpha: 0.1),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF6C63FF) : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  optionLabels[index],
                  style: GoogleFonts.poppins(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                optionText,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF6C63FF),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

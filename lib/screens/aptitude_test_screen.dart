import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'aptitude_result_screen.dart';

class AptitudeTestScreen extends StatefulWidget {
  const AptitudeTestScreen({super.key});

  @override
  State<AptitudeTestScreen> createState() => _AptitudeTestScreenState();
}

class _AptitudeTestScreenState extends State<AptitudeTestScreen> {
  // Sample questions for demonstration
  final List<Map<String, dynamic>> _questions = List.generate(25, (index) {
    return {
      'id': index + 1,
      'question': 'Sample Question ${index + 1}: What is 2 + ${index + 1}?',
      'options': [
        'Option A: ${index + 3}',
        'Option B: ${index + 4}',
        'Option C: ${index + 5}',
        'Option D: ${index + 6}',
      ],
      'correctOption': 0, // Index of correct answer
    };
  });

  int _currentQuestionIndex = 0;
  List<int?> _answers = List.filled(25, null);
  bool _isSubmitting = false;
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
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
    setState(() {
      _isSubmitting = true;
    });

    try {
      // Calculate score
      int score = 0;
      for (int i = 0; i < _questions.length; i++) {
        if (_answers[i] == _questions[i]['correctOption']) {
          score++;
        }
      }

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AptitudeResultScreen(score: score, total: _questions.length),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Submission failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestionIndex];
    final elapsedTime = DateTime.now().difference(_startTime);
    final remainingTime = Duration(minutes: 30) - elapsedTime;
    final isLastQuestion = _currentQuestionIndex == _questions.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Aptitude Test',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${remainingTime.inMinutes}:${(remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color:
                    remainingTime.inMinutes < 5 ? Colors.red : Colors.black87,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress Indicator
            Row(
              children: [
                Text(
                  'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: LinearProgressIndicator(
                    value: (_currentQuestionIndex + 1) / _questions.length,
                    backgroundColor: Colors.grey[300],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // Question
            Text(
              question['question'],
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 30),
            // Options
            Expanded(
              child: ListView.separated(
                itemCount: question['options'].length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 15),
                itemBuilder: (context, index) {
                  final isSelected = _answers[_currentQuestionIndex] == index;
                  return GestureDetector(
                    onTap: () => _selectAnswer(index),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF6C63FF).withOpacity(0.1)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF6C63FF)
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF6C63FF)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF6C63FF)
                                    : Colors.grey[400]!,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check,
                                    size: 20, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              question['options'][index],
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.black87,
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
            const SizedBox(height: 20),
            // Navigation Buttons
            Row(
              children: [
                // Previous Button
                if (_currentQuestionIndex > 0)
                  SizedBox(
                    width: 120,
                    height: 45,
                    child: OutlinedButton(
                      onPressed: _previousQuestion,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF6C63FF)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Previous',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: const Color(0xFF6C63FF),
                        ),
                      ),
                    ),
                  ),
                const Spacer(),
                // Next/Submit Button
                SizedBox(
                  width: 120,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: _isSubmitting
                        ? null
                        : (isLastQuestion ? _submitTest : _nextQuestion),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SpinKitFadingCircle(
                            color: Colors.white,
                            size: 20.0,
                          )
                        : Text(
                            isLastQuestion ? 'Submit' : 'Next',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

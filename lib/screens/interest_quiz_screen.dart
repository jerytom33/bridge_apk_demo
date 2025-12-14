import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'career_suggestions_screen.dart';

class QuizQuestion {
  final String question;
  final List<String> options;
  final int
  correctAnswer; // For demo purposes, we'll use this as the "ideal" answer

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });
}

class InterestQuizScreen extends StatefulWidget {
  const InterestQuizScreen({super.key});

  @override
  State<InterestQuizScreen> createState() => _InterestQuizScreenState();
}

class _InterestQuizScreenState extends State<InterestQuizScreen> {
  final List<QuizQuestion> _questions = [
    QuizQuestion(
      question: 'What type of work environment do you prefer?',
      options: [
        'Quiet and focused',
        'Collaborative and team-based',
        'Fast-paced and dynamic',
        'Flexible and remote',
      ],
      correctAnswer: 1,
    ),
    QuizQuestion(
      question: 'Which activity interests you the most?',
      options: [
        'Solving complex problems',
        'Creating and designing things',
        'Working with people',
        'Organizing and planning',
      ],
      correctAnswer: 0,
    ),
    QuizQuestion(
      question: 'How do you prefer to learn new things?',
      options: [
        'Through hands-on experience',
        'By reading and researching',
        'Through discussions with others',
        'By taking structured courses',
      ],
      correctAnswer: 0,
    ),
    QuizQuestion(
      question: 'What motivates you at work?',
      options: [
        'Financial rewards',
        'Making a positive impact',
        'Personal growth and learning',
        'Work-life balance',
      ],
      correctAnswer: 1,
    ),
    QuizQuestion(
      question: 'Which skill would you like to develop?',
      options: [
        'Technical programming skills',
        'Leadership and management',
        'Creative design abilities',
        'Analytical thinking',
      ],
      correctAnswer: 0,
    ),
    QuizQuestion(
      question: 'What type of projects excite you?',
      options: [
        'Building innovative products',
        'Improving existing systems',
        'Helping others directly',
        'Research and discovery',
      ],
      correctAnswer: 0,
    ),
    QuizQuestion(
      question: 'How do you handle challenges?',
      options: [
        'Break them down into smaller steps',
        'Seek help from others',
        'Research best practices',
        'Trust my intuition',
      ],
      correctAnswer: 0,
    ),
    QuizQuestion(
      question: 'What work schedule do you prefer?',
      options: [
        'Regular 9-5 schedule',
        'Flexible hours',
        'Project-based deadlines',
        'Varied schedule with travel',
      ],
      correctAnswer: 1,
    ),
  ];

  int _currentQuestionIndex = 0;
  int? _selectedAnswer;
  final List<int> _answers = [];
  bool _isLoading = false;

  void _nextQuestion() {
    if (_selectedAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an answer'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _answers.add(_selectedAnswer!);
      _selectedAnswer = null;

      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        _submitQuiz();
      }
    });
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _selectedAnswer = _answers.isNotEmpty ? _answers.last : null;
        if (_answers.isNotEmpty) {
          _answers.removeLast();
        }
      });
    }
  }

  Future<void> _submitQuiz() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApiService.submitAptitudeTest(
        _answers.asMap().map(
          (key, value) => MapEntry(key.toString(), value.toString()),
        ),
      );

      if (result['success']) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quiz completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to career suggestions
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const CareerSuggestionsScreen(),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Quiz submission failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Even if API fails, still navigate to career suggestions with mock data
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Using demo results for career suggestions'),
          backgroundColor: Colors.orange,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const CareerSuggestionsScreen(),
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

  double get _progress {
    return (_currentQuestionIndex + 1) / _questions.length;
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(title: const Text('Interest Quiz'), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Progress Bar
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${(_progress * 100).toInt()}%',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: _progress,
                            backgroundColor: Colors.grey[300],
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Question
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        currentQuestion.question,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Options
                  Expanded(
                    child: ListView.builder(
                      itemCount: currentQuestion.options.length,
                      itemBuilder: (context, index) {
                        final isSelected = _selectedAnswer == index;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedAnswer = index;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.blue.withValues(alpha: 0.1)
                                    : null,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.blue
                                      : Colors.grey[300]!,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_unchecked,
                                    color: isSelected
                                        ? Colors.blue
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      currentQuestion.options[index],
                                      style: TextStyle(
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Navigation Buttons
                  Row(
                    children: [
                      if (_currentQuestionIndex > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _previousQuestion,
                            child: const Text('Previous'),
                          ),
                        ),
                      if (_currentQuestionIndex > 0) const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _nextQuestion,
                          child: Text(
                            _currentQuestionIndex == _questions.length - 1
                                ? 'Submit'
                                : 'Next',
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

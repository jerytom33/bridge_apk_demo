import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'aptitude_result_screen.dart';

class AptitudeTestScreen extends StatefulWidget {
  final String educationLevel; // '10th' or '12th'

  const AptitudeTestScreen({super.key, required this.educationLevel});

  @override
  State<AptitudeTestScreen> createState() => _AptitudeTestScreenState();
}

class _AptitudeTestScreenState extends State<AptitudeTestScreen> {
  late List<Map<String, dynamic>> _questions;
  int _currentQuestionIndex = 0;
  late List<int?> _answers;
  bool _isSubmitting = false;
  late DateTime _startTime;

  // Questions for 10th Passed Students
  final List<Map<String, dynamic>> _questions10th = [
    // Section A: Analytical & Logical Reasoning (Science Indicator)
    {
      'id': 1,
      'section': 'Science',
      'question':
          'Look at this series: 2, 1, (1/2), (1/4), ... What number should come next?',
      'options': ['(1/3)', '(1/8)', '(2/8)', '(1/16)'],
      'correctOption': 1, // (1/8)
    },
    {
      'id': 2,
      'section': 'Science',
      'question':
          'You have two beakers of water. One is at 100°C and the other is at 0°C. You mix them in a perfect vacuum. What is the most logical outcome?',
      'options': [
        'The water evaporates immediately.',
        'The mixture eventually reaches an equilibrium temperature (around 50°C).',
        'The hot water stays on top, and cold water stays at the bottom.',
        'The water freezes immediately.',
      ],
      'correctOption': 1,
    },
    {
      'id': 3,
      'section': 'Science',
      'question':
          'If "Gear A" turns clockwise and is connected to "Gear B", and "Gear B" is connected to "Gear C", which way does "Gear C" turn?',
      'options': [
        'Clockwise',
        'Anti-clockwise',
        'It does not move',
        'Back and forth',
      ],
      'correctOption': 0, // Clockwise
    },
    {
      'id': 4,
      'section': 'Science',
      'question':
          'Which of the following statements is a hypothesis (a scientific guess)?',
      'options': [
        'The plant is green.',
        'Plants grow faster if given fertilizer because of the nutrients.',
        'I like plants.',
        'There are 5 plants in the garden.',
      ],
      'correctOption': 1,
    },
    {
      'id': 5,
      'section': 'Science',
      'question':
          'Logic Puzzle: Some doctors are singers. All singers are dancers. Therefore:',
      'options': [
        'All doctors are dancers.',
        'Some doctors are dancers.',
        'No doctors are dancers.',
        'All dancers are doctors.',
      ],
      'correctOption': 1,
    },
    // Section B: Commercial & Data Aptitude (Commerce Indicator)
    {
      'id': 6,
      'section': 'Commerce',
      'question':
          'You buy a phone for ₹10,000 and sell it for ₹12,000. What is your profit percentage?',
      'options': ['10%', '15%', '20%', '25%'],
      'correctOption': 2, // 20%
    },
    {
      'id': 7,
      'section': 'Commerce',
      'question':
          'Imagine you are the manager of a school festival. You have a budget of ₹5,000. The decoration costs ₹2,000 and food costs ₹3,500. What is the best logical decision?',
      'options': [
        'Buy everything and borrow money.',
        'Cancel the food entirely.',
        'Reduce the decoration budget to buy food, or find a cheaper food vendor to fit the ₹5,000 limit.',
        'Ask the Principal for more money immediately.',
      ],
      'correctOption': 2,
    },
    {
      'id': 8,
      'section': 'Commerce',
      'question':
          'Which of the following represents an "Asset" (something that puts money in your pocket/has value)?',
      'options': [
        'A loan you took from a bank.',
        'The monthly electricity bill.',
        'A piece of land you own.',
        'Interest you have to pay.',
      ],
      'correctOption': 2,
    },
    {
      'id': 9,
      'section': 'Commerce',
      'question':
          'Looking at a graph, if the line is going steadily upwards from left to right, what does it usually indicate?',
      'options': [
        'Decrease in value.',
        'No change.',
        'Increase or Growth.',
        'Random fluctuation.',
      ],
      'correctOption': 2,
    },
    {
      'id': 10,
      'section': 'Commerce',
      'question':
          'If 10 workers can build a wall in 4 days, how many days will it take for 20 workers to build the same wall (assuming they work at the same speed)?',
      'options': ['8 days', '2 days', '4 days', '5 days'],
      'correctOption': 1, // 2 days
    },
    // Section C: Verbal, Social & Creative Aptitude (Humanities Indicator)
    {
      'id': 11,
      'section': 'Humanities',
      'question':
          'Read the statement: "The pen is mightier than the sword." What does this imply?',
      'options': [
        'Pens are sharper than swords.',
        'Writing and ideas have more influence on people than violence/force.',
        'Authors make good soldiers.',
        'Swords are useless in war.',
      ],
      'correctOption': 1,
    },
    {
      'id': 12,
      'section': 'Humanities',
      'question':
          'You see a news report about a conflict between two countries. What is the most "Humanities" approach to understanding it?',
      'options': [
        'Calculating the cost of the weapons used.',
        'Analyzing the chemical composition of the explosives.',
        'Ignoring it because it\'s far away.',
        'Researching the history, culture, and political reasons behind the conflict.',
      ],
      'correctOption': 3,
    },
    {
      'id': 13,
      'section': 'Humanities',
      'question': 'Which word implies the opposite of "Optimistic" (hopeful)?',
      'options': ['Realistic', 'Pessimistic', 'Energetic', 'Artistic'],
      'correctOption': 1,
    },
    {
      'id': 14,
      'section': 'Humanities',
      'question':
          'If you were asked to solve a problem regarding "Student Stress," which solution focuses on Psychology/Sociology?',
      'options': [
        'Measuring the student\'s blood pressure.',
        'Creating a machine to do homework for them.',
        'Analyzing their study environment and talking to them about their mental health.',
        'Calculating the average hours they sleep.',
      ],
      'correctOption': 2,
    },
    {
      'id': 15,
      'section': 'Humanities',
      'question':
          'Complete the analogy: History is to Time, as Geography is to _______?',
      'options': ['Space/Place', 'Money', 'People', 'Plants'],
      'correctOption': 0,
    },
  ];

  // Questions for 12th Passed Students
  final List<Map<String, dynamic>> _questions12th = [
    // Section A: STEM & Technical Aptitude
    {
      'id': 1,
      'section': 'STEM',
      'question':
          'A train travels 120 km in 2 hours. If its speed increases by 50%, how long will it take to travel 180 km?',
      'options': ['2 hours', '2.5 hours', '3 hours', '1.5 hours'],
      'correctOption': 0, // 2 hours
    },
    {
      'id': 2,
      'section': 'STEM',
      'question':
          'Which mathematical operation is mainly used to model unpredictable systems like weather patterns or the stock market?',
      'options': [
        'Simple Algebra',
        'Calculus (Differentiation & Integration)',
        'Geometry',
        'Basic Arithmetic',
      ],
      'correctOption': 1,
    },
    {
      'id': 3,
      'section': 'STEM',
      'question':
          'You are given a large dataset of patient symptoms and test results. Your goal is to find a causal relationship between two variables. Which field are you most likely working in?',
      'options': [
        'Literature',
        'Data Science / Scientific Research',
        'Hotel Management',
        'Journalism',
      ],
      'correctOption': 1,
    },
    {
      'id': 4,
      'section': 'STEM',
      'question':
          'Two resistors of 10 Ω each are connected in parallel. What is the total equivalent resistance?',
      'options': ['20 Ω', '10 Ω', '5 Ω', '0 Ω'],
      'correctOption': 2, // 5 Ω
    },
    {
      'id': 5,
      'section': 'STEM',
      'question':
          'What is the primary purpose of writing an algorithm in computer science?',
      'options': [
        'To write fictional stories',
        'To give a clear step-by-step solution to a problem',
        'To memorize data',
        'To debate technology philosophy',
      ],
      'correctOption': 1,
    },
    // Section B: Business, Finance & Management Aptitude
    {
      'id': 6,
      'section': 'Business',
      'question':
          'A company wants to launch a new product. What is the most important strategic question in the beginning?',
      'options': [
        'What colour should the packaging be?',
        'Who is the target customer and what problem does this product solve?',
        'How many workers are needed?',
        'Which competitor started first?',
      ],
      'correctOption': 1,
    },
    {
      'id': 7,
      'section': 'Business',
      'question':
          'If the RBI increases the Repo Rate, what is the most likely impact?',
      'options': [
        'Increase in money supply',
        'Reduction in borrowing & control of inflation',
        'Immediate stock market boom',
        'Freezing of banks',
      ],
      'correctOption': 1,
    },
    {
      'id': 8,
      'section': 'Business',
      'question':
          'Which financial document shows a company\'s assets, liabilities, and shareholder equity?',
      'options': [
        'Income Statement',
        'Cash Flow Statement',
        'Balance Sheet',
        'Memorandum',
      ],
      'correctOption': 2,
    },
    {
      'id': 9,
      'section': 'Business',
      'question': 'Opportunity Cost means:',
      'options': [
        'Total production cost',
        'The benefit lost by choosing one option over another',
        'Profit made on a sale',
        'Business tax',
      ],
      'correctOption': 1,
    },
    {
      'id': 10,
      'section': 'Business',
      'question':
          'A crucial team member is delaying a project. What is the best managerial response?',
      'options': [
        'Fire them immediately',
        'Do the work without telling them',
        'Find the reason, redistribute work, and support them',
        'Cancel the project',
      ],
      'correctOption': 2,
    },
    // Section C: Creative, Social & Communicative Aptitude
    {
      'id': 11,
      'section': 'Creative',
      'question':
          'Which career relies most on understanding human behaviour and non-verbal cues?',
      'options': [
        'Mechanical Engineering',
        'Actuarial Science',
        'Psychology / Counselling',
        'Drilling Technician',
      ],
      'correctOption': 2,
    },
    {
      'id': 12,
      'section': 'Creative',
      'question':
          'While studying the Partition of India, which question is most Humanities-focused?',
      'options': [
        'Population data',
        'Cultural, emotional & social impact',
        'Land area size',
        'Price changes',
      ],
      'correctOption': 1,
    },
    {
      'id': 13,
      'section': 'Creative',
      'question':
          'A key skill for careers in Law, Media & Public Relations is:',
      'options': [
        'Memorising formulas',
        'Communication, persuasion & critical reading',
        'Solving differential equations',
        'Mechanical hand skills',
      ],
      'correctOption': 1,
    },
    {
      'id': 14,
      'section': 'Creative',
      'question': 'An architect or designer balances which two major factors?',
      'options': [
        'Profit & stock',
        'Function and Aesthetics',
        'Speed & mass production',
        'Chemical reactions & physics',
      ],
      'correctOption': 1,
    },
    {
      'id': 15,
      'section': 'Creative',
      'question': 'If a novel uses satire, its main purpose is to:',
      'options': [
        'Praise society',
        'Entertain with random jokes',
        'Criticise society using humour and irony',
        'Provide exact historical records',
      ],
      'correctOption': 2,
    },
  ];

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();

    // Select questions based on education level
    _questions = widget.educationLevel == '10th'
        ? _questions10th
        : _questions12th;
    _answers = List.filled(_questions.length, null);
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
      // Calculate overall score
      int totalScore = 0;
      int section1Score = 0; // Science/STEM
      int section2Score = 0; // Commerce/Business
      int section3Score = 0; // Humanities/Creative

      for (int i = 0; i < _questions.length; i++) {
        if (_answers[i] == _questions[i]['correctOption']) {
          totalScore++;

          // Calculate section-wise scores
          String section = _questions[i]['section'];

          // For 10th: Science, Commerce, Humanities
          // For 12th: STEM, Business, Creative
          if (section == 'Science' || section == 'STEM') {
            section1Score++;
          } else if (section == 'Commerce' || section == 'Business') {
            section2Score++;
          } else if (section == 'Humanities' || section == 'Creative') {
            section3Score++;
          }
        }
      }

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AptitudeResultScreen(
              score: totalScore,
              total: _questions.length,
              scienceScore: section1Score,
              commerceScore: section2Score,
              humanitiesScore: section3Score,
              educationLevel: widget.educationLevel,
            ),
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
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Aptitude Test',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Center(
          child: Text(
            'Questions for ${widget.educationLevel} level are not available yet.',
            style: GoogleFonts.poppins(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final question = _questions[_currentQuestionIndex];
    final elapsedTime = DateTime.now().difference(_startTime);
    final remainingTime = const Duration(minutes: 20) - elapsedTime;
    final isLastQuestion = _currentQuestionIndex == _questions.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Aptitude Test - ${widget.educationLevel} Passed',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${remainingTime.inMinutes}:${(remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: remainingTime.inMinutes < 5
                    ? Colors.red
                    : Colors.black87,
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
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF6C63FF),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Section Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getSectionColor(question['section']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Section: ${question['section']}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _getSectionColor(question['section']),
                ),
              ),
            ),
            const SizedBox(height: 20),
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
                                ? const Icon(
                                    Icons.check,
                                    size: 20,
                                    color: Colors.white,
                                  )
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

  Color _getSectionColor(String section) {
    switch (section) {
      case 'Science':
        return const Color(0xFF6C63FF);
      case 'Commerce':
        return const Color(0xFF00BFA5);
      case 'Humanities':
        return const Color(0xFFFF6F00);
      default:
        return Colors.grey;
    }
  }
}

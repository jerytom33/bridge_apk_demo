import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoadmapStep {
  final String id;
  final String title;
  final String description;
  final List<String> subtasks;
  bool isCompleted;

  RoadmapStep({
    required this.id,
    required this.title,
    required this.description,
    required this.subtasks,
    this.isCompleted = false,
  });

  double get progress {
    if (subtasks.isEmpty) return isCompleted ? 1.0 : 0.0;
    final completedSubtasks =
        subtasks.where((subtask) => subtask.startsWith('✓')).length;
    return completedSubtasks / subtasks.length;
  }
}

class LearningRoadmapScreen extends StatefulWidget {
  const LearningRoadmapScreen({super.key});

  @override
  _LearningRoadmapScreenState createState() => _LearningRoadmapScreenState();
}

class _LearningRoadmapScreenState extends State<LearningRoadmapScreen> {
  List<RoadmapStep> _roadmapSteps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRoadmap();
  }

  Future<void> _loadRoadmap() async {
    // Mock roadmap data
    final steps = [
      RoadmapStep(
        id: '1',
        title: 'Self-Assessment',
        description: 'Understand your strengths, interests, and career goals',
        subtasks: [
          'Complete interest quiz',
          'Identify your skills',
          'Define career objectives',
        ],
      ),
      RoadmapStep(
        id: '2',
        title: 'Skill Development',
        description: 'Build essential skills for your chosen career path',
        subtasks: [
          'Take fundamental courses',
          'Practice with projects',
          'Build a portfolio',
        ],
      ),
      RoadmapStep(
        id: '3',
        title: 'Resume Building',
        description:
            'Create a professional resume that highlights your abilities',
        subtasks: [
          'Draft your resume',
          'Get feedback from mentors',
          'Finalize and optimize',
        ],
      ),
      RoadmapStep(
        id: '4',
        title: 'Networking',
        description: 'Connect with professionals in your field of interest',
        subtasks: [
          'Join professional communities',
          'Attend industry events',
          'Build online presence',
        ],
      ),
      RoadmapStep(
        id: '5',
        title: 'Job Search',
        description: 'Find and apply for suitable opportunities',
        subtasks: [
          'Research companies',
          'Prepare for interviews',
          'Submit applications',
        ],
      ),
      RoadmapStep(
        id: '6',
        title: 'Interview Preparation',
        description: 'Get ready for technical and behavioral interviews',
        subtasks: [
          'Practice common questions',
          'Prepare your examples',
          'Mock interviews',
        ],
      ),
      RoadmapStep(
        id: '7',
        title: 'Continuous Learning',
        description: 'Keep updating your skills and knowledge',
        subtasks: [
          'Follow industry trends',
          'Take advanced courses',
          'Seek mentorship',
        ],
      ),
    ];

    // Load saved progress
    final prefs = await SharedPreferences.getInstance();
    final savedProgress = prefs.getStringList('roadmap_progress') ?? [];

    for (int i = 0; i < steps.length && i < savedProgress.length; i++) {
      steps[i].isCompleted = savedProgress[i] == 'true';
    }

    setState(() {
      _roadmapSteps = steps;
      _isLoading = false;
    });
  }

  Future<void> _toggleStepCompletion(RoadmapStep step) async {
    setState(() {
      step.isCompleted = !step.isCompleted;
    });

    // Save progress
    final prefs = await SharedPreferences.getInstance();
    final savedProgress =
        _roadmapSteps.map((s) => s.isCompleted.toString()).toList();
    await prefs.setStringList('roadmap_progress', savedProgress);

    // Update overall progress in home screen
    final completedSteps = _roadmapSteps.where((s) => s.isCompleted).length;
    final overallProgress = completedSteps / _roadmapSteps.length;
    await prefs.setDouble('roadmap_progress', overallProgress);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            step.isCompleted ? 'Step completed!' : 'Step marked as incomplete'),
        backgroundColor: step.isCompleted ? Colors.green : Colors.orange,
      ),
    );
  }

  double get _overallProgress {
    if (_roadmapSteps.isEmpty) return 0.0;
    final completedSteps =
        _roadmapSteps.where((step) => step.isCompleted).length;
    return completedSteps / _roadmapSteps.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Roadmap'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRoadmap,
            tooltip: 'Reset Progress',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                // Overall Progress
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Overall Progress',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CircularPercentIndicator(
                        radius: 60.0,
                        lineWidth: 10.0,
                        percent: _overallProgress,
                        center: Text(
                          '${(_overallProgress * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        progressColor: Colors.blue,
                        backgroundColor: Colors.grey[300] ?? Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_roadmapSteps.where((s) => s.isCompleted).length} of ${_roadmapSteps.length} steps completed',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // Roadmap Steps
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _roadmapSteps.length,
                    itemBuilder: (context, index) {
                      final step = _roadmapSteps[index];
                      return RoadmapStepCard(
                        step: step,
                        stepNumber: index + 1,
                        onToggle: () => _toggleStepCompletion(step),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class RoadmapStepCard extends StatelessWidget {
  final RoadmapStep step;
  final int stepNumber;
  final VoidCallback onToggle;

  const RoadmapStepCard({
    super.key,
    required this.step,
    required this.stepNumber,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: step.isCompleted ? 2 : 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Step Number
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: step.isCompleted ? Colors.green : Colors.blue,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: step.isCompleted
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 18,
                          )
                        : Text(
                            stepNumber.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),

                // Title and Checkbox
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          step.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: step.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: step.isCompleted ? Colors.grey : null,
                          ),
                        ),
                      ),
                      Checkbox(
                        value: step.isCompleted,
                        onChanged: (value) => onToggle(),
                        activeColor: Colors.green,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              step.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),

            // Subtasks
            if (step.subtasks.isNotEmpty) ...[
              const Text(
                'Key Activities:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...step.subtasks.map((subtask) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(
                          step.isCompleted
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          size: 16,
                          color: step.isCompleted ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            subtask,
                            style: TextStyle(
                              fontSize: 13,
                              color: step.isCompleted ? Colors.grey : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],

            // Progress Bar
            if (!step.isCompleted && step.subtasks.isNotEmpty) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: step.progress,
                backgroundColor: Colors.grey[300] ?? Colors.grey,
                valueColor: AlwaysStoppedAnimation<Color>(
                  step.progress == 1.0 ? Colors.green : Colors.blue,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

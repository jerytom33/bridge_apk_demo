import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/career_model.dart';
import 'course_suggestions_screen.dart';

class CareerSuggestionsScreen extends StatefulWidget {
  const CareerSuggestionsScreen({super.key});

  @override
  _CareerSuggestionsScreenState createState() =>
      _CareerSuggestionsScreenState();
}

class _CareerSuggestionsScreenState extends State<CareerSuggestionsScreen> {
  List<Career> _careers = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCareers();
  }

  Future<void> _loadCareers() async {
    try {
      // TODO: Implement career fetching when API endpoint is available
      // For now, we'll use mock data or local storage
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Career> get _filteredCareers {
    if (_searchQuery.isEmpty) {
      return _careers;
    }
    return _careers
        .where(
          (career) =>
              career.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              career.description.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ),
        )
        .toList();
  }

  Future<void> _toggleSaveCareer(Career career) async {
    setState(() {
      career.toggleSaved();
    });

    // Save to local storage
    final prefs = await SharedPreferences.getInstance();
    final savedCareers = prefs.getStringList('saved_careers') ?? [];

    if (career.isSaved) {
      savedCareers.add(career.id.toString());
    } else {
      savedCareers.remove(career.id.toString());
    }

    await prefs.setStringList('saved_careers', savedCareers);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          career.isSaved ? 'Career saved!' : 'Career removed from saved',
        ),
        backgroundColor: career.isSaved ? Colors.green : Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Career Suggestions'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.school),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CourseSuggestionsScreen(),
                ),
              );
            },
            tooltip: 'View Courses',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search careers...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Results
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredCareers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.work_off, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No careers available'
                              : 'No careers found for "$_searchQuery"',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredCareers.length,
                    itemBuilder: (context, index) {
                      final career = _filteredCareers[index];
                      return CareerCard(
                        career: career,
                        onSave: () => _toggleSaveCareer(career),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class CareerCard extends StatelessWidget {
  final Career career;
  final VoidCallback onSave;

  const CareerCard({super.key, required this.career, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        career.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        career.description,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onSave,
                  icon: Icon(
                    career.isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: career.isSaved ? Colors.blue : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _InfoChip(
                  icon: Icons.attach_money,
                  label: career.salary,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.trending_up,
                  label: career.growth,
                  color: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Key Skills:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: career.skills.map((skill) {
                return Chip(
                  label: Text(skill, style: const TextStyle(fontSize: 12)),
                  backgroundColor: Colors.blue.withValues(alpha: 0.1),
                  labelStyle: const TextStyle(color: Colors.blue),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Learning more about ${career.title}...'),
                      action: SnackBarAction(
                        label: 'View Roadmap',
                        onPressed: () {
                          // Navigate to learning roadmap
                        },
                      ),
                    ),
                  );
                },
                child: const Text('Learn More'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

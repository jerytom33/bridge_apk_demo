import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ExploreItem {
  final String id;
  final String title;
  final String description;
  final String category;
  final String tag;
  final IconData icon;

  ExploreItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.tag,
    required this.icon,
  });
}

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ExploreItem> _exploreItems = [];
  List<ExploreItem> _filteredItems = [];
  bool _isLoading = false;
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Careers',
    'Courses',
    'Jobs',
    'Skills',
  ];

  @override
  void initState() {
    super.initState();
    _loadExploreItems();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterItems();
  }

  Future<void> _loadExploreItems() async {
    // Mock explore data
    final items = [
      ExploreItem(
        id: '1',
        title: 'Software Engineering',
        description:
            'Design, develop and maintain software systems and applications',
        category: 'Careers',
        tag: 'Technology',
        icon: Icons.computer,
      ),
      ExploreItem(
        id: '2',
        title: 'Data Science Bootcamp',
        description:
            'Intensive course covering data analysis, machine learning, and AI',
        category: 'Courses',
        tag: 'Popular',
        icon: Icons.analytics,
      ),
      ExploreItem(
        id: '3',
        title: 'Frontend Developer',
        description:
            'Create user interfaces and web applications using modern frameworks',
        category: 'Jobs',
        tag: 'Remote',
        icon: Icons.web,
      ),
      ExploreItem(
        id: '4',
        title: 'Python Programming',
        description:
            'Learn Python from basics to advanced concepts and applications',
        category: 'Skills',
        tag: 'In-Demand',
        icon: Icons.code,
      ),
      ExploreItem(
        id: '5',
        title: 'Product Management',
        description: 'Lead product development and strategy in tech companies',
        category: 'Careers',
        tag: 'Leadership',
        icon: Icons.lightbulb,
      ),
      ExploreItem(
        id: '6',
        title: 'UI/UX Design Course',
        description:
            'Master user interface and user experience design principles',
        category: 'Courses',
        tag: 'Creative',
        icon: Icons.palette,
      ),
      ExploreItem(
        id: '7',
        title: 'Mobile App Developer',
        description: 'Build native and cross-platform mobile applications',
        category: 'Jobs',
        tag: 'Flexible',
        icon: Icons.smartphone,
      ),
      ExploreItem(
        id: '8',
        title: 'Communication Skills',
        description:
            'Develop effective verbal and written communication abilities',
        category: 'Skills',
        tag: 'Soft Skills',
        icon: Icons.chat,
      ),
      ExploreItem(
        id: '9',
        title: 'Digital Marketing',
        description:
            'Plan and execute digital marketing campaigns and strategies',
        category: 'Careers',
        tag: 'Marketing',
        icon: Icons.trending_up,
      ),
      ExploreItem(
        id: '10',
        title: 'Machine Learning Fundamentals',
        description:
            'Introduction to ML algorithms, neural networks, and deep learning',
        category: 'Courses',
        tag: 'Advanced',
        icon: Icons.psychology,
      ),
    ];

    setState(() {
      _exploreItems = items;
      _filteredItems = items;
    });
  }

  void _filterItems() {
    setState(() {
      _filteredItems = _exploreItems.where((item) {
        final matchesSearch =
            item.title.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            ) ||
            item.description.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            );
        final matchesCategory =
            _selectedCategory == 'All' || item.category == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  Future<void> _performSearch() async {
    if (_searchController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Call API for search (mock implementation)
      // TODO: Implement explore search when API endpoint is available
      // For now, we'll use local filtering
      _filterItems();
    } catch (e) {
      // Use local filtering if API fails
      _filterItems();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Careers':
        return Colors.blue;
      case 'Courses':
        return Colors.green;
      case 'Jobs':
        return Colors.orange;
      case 'Skills':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _onItemTapped(ExploreItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.description),
            const SizedBox(height: 16),
            Row(
              children: [
                Chip(
                  label: Text(item.category),
                  backgroundColor: _getCategoryColor(
                    item.category,
                  ).withValues(alpha: 0.1),
                  labelStyle: TextStyle(
                    color: _getCategoryColor(item.category),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Chip(label: Text(item.tag), backgroundColor: Colors.grey[200]),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Learning more about ${item.title}...')),
              );
            },
            child: const Text('Learn More'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explore'), centerTitle: true),
      body: Column(
        children: [
          // Search Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search careers, courses, jobs...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.search),
                      onPressed: _performSearch,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
                const SizedBox(height: 12),

                // Category Filter
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = category == _selectedCategory;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                            _filterItems();
                          },
                          backgroundColor: Colors.grey[200],
                          selectedColor: Colors.blue.withValues(alpha: 0.2),
                          checkmarkColor: Colors.blue,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Trending Section
          if (_searchController.text.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Icon(Icons.trending_up, color: Colors.orange),
                  const SizedBox(width: 8),
                  const Text(
                    'Trending Now',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Results
          Expanded(
            child: _filteredItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isEmpty
                              ? 'Start exploring to find opportunities'
                              : 'No results found for "${_searchController.text}"',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      return ExploreCard(
                        item: item,
                        onTap: () => _onItemTapped(item),
                        categoryColor: _getCategoryColor(item.category),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class ExploreCard extends StatelessWidget {
  final ExploreItem item;
  final VoidCallback onTap;
  final Color categoryColor;

  const ExploreCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.categoryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: categoryColor, size: 24),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Chip(
                          label: Text(
                            item.category,
                            style: const TextStyle(fontSize: 11),
                          ),
                          backgroundColor: categoryColor.withValues(alpha: 0.1),
                          labelStyle: TextStyle(
                            color: categoryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(
                            item.tag,
                            style: const TextStyle(fontSize: 11),
                          ),
                          backgroundColor: Colors.grey[200],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}

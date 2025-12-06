# Quick Start: Student Dashboard Implementation

## Summary of Changes

### ✅ What Was Done
1. **Added `getStudentDashboard()` method** to `ApiService`
   - Calls: `GET /api/student/dashboard/`
   - Authentication: Bearer token
   - Timeout: 10 seconds
   - Full error handling

2. **URL Configuration**
   - Android: `http://10.0.2.2:8000/api`
   - Testing: `http://127.0.0.1:8000/api`

### 📍 Code Location
File: `lib/services/api_service.dart`
- Lines 709-758: New `getStudentDashboard()` method

## Implementation Examples

### Example 1: Basic Dashboard Call
```dart
import 'package:bridge_app/services/api_service.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;
  Map<String, dynamic>? dashboardData;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      final response = await ApiService.getStudentDashboard();
      
      if (response['success']) {
        setState(() {
          dashboardData = response['data'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response['error'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load dashboard: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(child: Text('Error: $errorMessage'));
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Profile Section
          _buildProfileSection(dashboardData!['profile']),
          
          // Featured Courses
          _buildSectionHeader('Featured Courses'),
          _buildCoursesList(dashboardData!['featured_courses']),
          
          // Upcoming Exams
          _buildSectionHeader('Upcoming Exams'),
          _buildExamsList(dashboardData!['upcoming_exams']),
          
          // Saved Items
          _buildSectionHeader('Saved Courses'),
          _buildCoursesList(dashboardData!['saved_courses']),
        ],
      ),
    );
  }

  Widget _buildProfileSection(Map<String, dynamic> profile) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: profile['avatar'] != null
                    ? NetworkImage(profile['avatar'])
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                profile['name'] ?? 'Student',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(profile['email'] ?? ''),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCoursesList(List<dynamic> courses) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(course['title'] ?? 'Course'),
            subtitle: Text(course['instructor'] ?? 'Unknown'),
            trailing: const Icon(Icons.arrow_forward),
          ),
        );
      },
    );
  }

  Widget _buildExamsList(List<dynamic> exams) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: exams.length,
      itemBuilder: (context, index) {
        final exam = exams[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(exam['title'] ?? 'Exam'),
            subtitle: Text('${exam['date']} at ${exam['time']}'),
            trailing: const Icon(Icons.calendar_today),
          ),
        );
      },
    );
  }
}
```

### Example 2: With Provider Pattern (Recommended)
```dart
import 'package:provider/provider.dart';

class DashboardProvider extends ChangeNotifier {
  Map<String, dynamic>? _dashboard;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get dashboard => _dashboard;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await ApiService.getStudentDashboard();
    
    if (response['success']) {
      _dashboard = response['data'];
    } else {
      _error = response['error'];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshDashboard() async {
    await fetchDashboard();
  }
}

// Usage in HomeScreen
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(child: Text('Error: ${provider.error}'));
        }

        final dashboard = provider.dashboard;
        // Build UI with dashboard data
        return SingleChildScrollView(
          child: Column(
            children: [
              // Profile, courses, exams...
            ],
          ),
        );
      },
    );
  }
}
```

### Example 3: With Pull-to-Refresh
```dart
class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    final provider = context.read<DashboardProvider>();
    await provider.fetchDashboard();
  }

  void _onRefresh() async {
    await _loadDashboard();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: _refreshController,
      onRefresh: _onRefresh,
      child: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.dashboard == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.dashboard == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.error}'),
                  ElevatedButton(
                    onPressed: _loadDashboard,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Build UI with dashboard data
          return SingleChildScrollView(
            child: Column(children: []),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}
```

## Testing Steps

### 1. Test in Console
```bash
# Start Django backend
cd your_django_project
python manage.py runserver 0.0.0.0:8000

# In another terminal, test the endpoint
curl -X GET http://127.0.0.1:8000/api/student/dashboard/ \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### 2. Test in App
1. Launch the app: `flutter run`
2. Register or login
3. Navigate to home screen
4. Check logcat for: `STUDENT_DASHBOARD → 200`
5. Verify data displays correctly

### 3. Check Logs
```
I/flutter: STUDENT_DASHBOARD → 200
I/flutter: Dashboard Response: {
  "profile": {...},
  "featured_courses": [...],
  ...
}
```

## Response Data Structure

```dart
// The response['data'] contains:
{
  'profile': {
    'id': int,
    'name': String,
    'email': String,
    'avatar': String?,
    // ... other profile fields
  },
  'featured_courses': [
    {
      'id': int,
      'title': String,
      'description': String,
      'instructor': String,
      // ... other course fields
    },
    // ... more courses
  ],
  'upcoming_exams': [
    {
      'id': int,
      'title': String,
      'date': String,
      'time': String,
      // ... other exam fields
    },
    // ... more exams
  ],
  'saved_courses': [...],
  'saved_exams': [...]
}
```

## Performance Tips

1. **Cache the data locally** after first fetch
2. **Show skeleton loaders** while fetching
3. **Implement pull-to-refresh** for manual updates
4. **Use pagination** for long lists
5. **Lazy load images** with cached_network_image

## Status

✅ **API Integration Complete**
- Method added to ApiService
- Full error handling implemented
- Ready for UI integration

📝 **Next: Integrate with HomeScreen UI**

---

For questions or debugging, check:
- Logcat output for error messages
- Django server logs for request details
- STUDENT_DASHBOARD_INTEGRATION.md for full documentation

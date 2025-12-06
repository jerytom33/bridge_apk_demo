# Student Dashboard API Integration

## Overview
The Flutter app now integrates with the new **Student Dashboard Gateway** endpoint from your Django backend. This endpoint provides a unified, optimized response for the mobile app's home screen.

## Endpoint Details

**URL:** `GET /api/student/dashboard/`  
**Authentication:** Required (Bearer Token)  
**Base URL:** `http://10.0.2.2:8000/api` (Android) or `http://127.0.0.1:8000/api` (Testing)

## Response Format
```json
{
    "profile": {
        "id": 1,
        "name": "Student Name",
        "email": "student@example.com",
        "avatar": "url/to/avatar",
        ...
    },
    "featured_courses": [
        {
            "id": 1,
            "title": "Course Title",
            "description": "...",
            "instructor": "...",
            ...
        }
    ],
    "upcoming_exams": [
        {
            "id": 1,
            "title": "Exam Title",
            "date": "2025-12-15",
            "time": "10:00",
            ...
        }
    ],
    "saved_courses": [...],
    "saved_exams": [...]
}
```

## Implementation in Flutter

### 1. Call the Endpoint
```dart
import 'package:bridge_app/services/api_service.dart';

// In your HomeScreen or any screen after authentication
final response = await ApiService.getStudentDashboard();

if (response['success']) {
    final data = response['data'];
    
    // Extract data from response
    final profile = data['profile'];
    final featuredCourses = data['featured_courses'];
    final upcomingExams = data['upcoming_exams'];
    final savedCourses = data['saved_courses'];
    final savedExams = data['saved_exams'];
    
    // Update UI with this data
} else {
    print('Error: ${response['error']}');
}
```

### 2. Integration Points
This endpoint is perfect for:
- **Home Screen:** Display welcome message, profile, featured content
- **Dashboard:** Show upcoming exams, saved items
- **Feed Screen:** Display latest courses and recommendations

### 3. Error Handling
The endpoint handles:
- **401 Unauthorized:** Token expired (auto-clears auth data)
- **Timeout:** 10-second timeout for poor connections
- **Network Errors:** Returns proper error messages

## API Service Methods

### getStudentDashboard()
```dart
static Future<Map<String, dynamic>> getStudentDashboard()
```

**Returns:**
- `{'success': true, 'data': {...}}` - Dashboard data
- `{'success': false, 'error': 'Error message'}` - Error response

**Example Usage:**
```dart
final response = await ApiService.getStudentDashboard();

if (response['success']) {
    final dashboard = response['data'];
    setState(() {
        profile = dashboard['profile'];
        courses = dashboard['featured_courses'];
        exams = dashboard['upcoming_exams'];
    });
}
```

## Benefits of This Architecture

1. **Reduced Latency:** Single request instead of 5+ API calls
2. **Optimized Data:** Backend handles filtering and pagination
3. **Bandwidth Efficient:** Only relevant data is sent
4. **Future-Proof:** Easy to add new dashboard sections
5. **Mobile-Focused:** Designed specifically for app needs

## Testing the Integration

### Test with cURL
```bash
# First, get a token
curl -X POST http://127.0.0.1:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password"}'

# Then call dashboard endpoint with the token
curl -X GET http://127.0.0.1:8000/api/student/dashboard/ \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### Test in the App
1. Register/Login on the app
2. Navigate to Home Screen
3. Dashboard data loads automatically
4. Check console logs for `STUDENT_DASHBOARD → 200` success message

## Debugging

Enable debug logging to see API responses:
```dart
// Check console output for these logs:
// STUDENT_DASHBOARD → 200
// Dashboard Response: {...response data...}

// Errors will show:
// Student Dashboard Error: {error details}
```

## File Changes

- **lib/services/api_service.dart**: Added `getStudentDashboard()` method
  - Location: Lines 709-758
  - Full error handling with timeout support
  - Bearer token authentication

## Next Steps

1. **Implement HomeScreen Integration:** 
   - Call `ApiService.getStudentDashboard()` on screen load
   - Display profile, featured courses, upcoming exams
   - Add loading and error states

2. **Update Feed Screen:**
   - Use featured_courses and featured_exams from dashboard
   - Implement infinite scroll for additional content

3. **Add Caching:**
   - Cache dashboard data locally
   - Refresh on pull-to-refresh
   - Invalidate cache on logout

4. **Optimize Loading:**
   - Show skeleton loaders while fetching
   - Progressive data loading for each section
   - Implement retry logic for failed requests

## Support

- **Backend Port:** http://127.0.0.1:8000/
- **API Documentation:** `/api/` (if available on Django)
- **Console Logs:** Check logcat for request/response details

---

**Status:** ✅ Ready to implement in UI screens

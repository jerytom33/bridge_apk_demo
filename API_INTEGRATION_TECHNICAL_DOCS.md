# Backend Integration Technical Documentation

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Mobile App                        │
│                   (Bridge IT - Student)                      │
└──────────────────────────┬──────────────────────────────────┘
                           │
                    HTTP/HTTPS (REST)
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                  Django REST Backend                         │
│              (http://127.0.0.1:8000/api)                   │
│                                                              │
│  • Authentication (JWT)                                      │
│  • Resume Analysis & Upload                                  │
│  • Aptitude Testing                                          │
│  • Exam & Course Management                                  │
│  • Career Recommendations                                    │
│  • Social Feed                                               │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔌 Connection Details

### Base Configuration
```dart
// File: lib/services/api_service.dart
class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  // Works on Android emulator via host IP 127.0.0.1
}
```

### Environment Considerations

| Environment | URL | Notes |
|-------------|-----|-------|
| Android Emulator | `http://127.0.0.1:8000/api` | ✅ Default |
| Physical Device (Same Network) | `http://{PC_IP}:8000/api` | Update IP manually |
| iOS Simulator | `http://127.0.0.1:8000/api` | Same as emulator |
| Production | `https://api.example.com/api` | Use environment variables |

---

## 🔐 Authentication & Security

### JWT Token Flow
```
1. User Login
   └─> POST /api/auth/login/
       └─> Response: { access, refresh, user_id }

2. Token Storage
   └─> SharedPreferences
       └─> access_token
       └─> refresh_token
       └─> user_id

3. API Requests
   └─> All requests include:
       └─> Header: Authorization: Bearer {access_token}

4. Token Refresh (When Implemented)
   └─> 401 Response
       └─> POST /api/token/refresh/
           └─> { refresh_token }
           └─> Response: { access }
```

### Token Management Methods
```dart
// Get stored token
static Future<String?> _getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('access_token');
}

// Save tokens after login
static Future<void> _saveAuthData(
  String accessToken,
  String refreshToken,
  int userId,
) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('access_token', accessToken);
  await prefs.setString('refresh_token', refreshToken);
  await prefs.setInt('user_id', userId);
}

// Clear tokens on logout
static Future<void> _clearAuthData() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('access_token');
  await prefs.remove('refresh_token');
  await prefs.remove('user_id');
}
```

---

## 📝 API Response Standards

### Standard Success Response
```json
{
  "success": true,
  "message": "Operation successful",
  "data": {
    "id": 1,
    "name": "Example Item",
    "description": "..."
  }
}
```

### Standard Error Response
```json
{
  "success": false,
  "error": "Detailed error message"
}
```

### List Response Format
```json
{
  "success": true,
  "data": [
    { "id": 1, "name": "Item 1" },
    { "id": 2, "name": "Item 2" }
  ]
}
```

### Authentication Response Format
```json
{
  "success": true,
  "message": "Login successful!",
  "access": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "user_id": 1
}
```

---

## 🔄 API Call Flow Example

### Example: User Login Flow
```dart
// 1. User taps login button
void _login() async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  
  // 2. Call AuthProvider.login()
  final result = await authProvider.login(email, password);
  
  // 3. AuthProvider calls ApiService.loginUser()
  final response = await ApiService.loginUser(email, password);
  // HTTP Request:
  // POST /api/auth/login/
  // Body: {"email": "...", "password": "..."}
  
  // 4. ApiService saves tokens
  await _saveAuthData(data['access'], data['refresh'], data['user_id']);
  
  // 5. AuthProvider updates state
  _isAuthenticated = true;
  notifyListeners(); // Rebuilds UI
  
  // 6. App navigates to MainWrapper
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const MainWrapper()),
  );
}
```

---

## 📤 File Upload - Resume Upload Example

### Implementation
```dart
static Future<Map<String, dynamic>> uploadResume(File resumeFile) async {
  final token = await _getToken();
  
  // Create multipart request
  final request = http.MultipartRequest(
    'POST',
    Uri.parse('$baseUrl/resume/upload/'),
  );
  
  // Add authorization header
  request.headers['Authorization'] = 'Bearer $token';
  
  // Add file
  request.files.add(
    await http.MultipartFile.fromPath('pdf_file', resumeFile.path),
  );
  
  // Send request
  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);
  
  // Handle response
  if (response.statusCode == 200) {
    return {'success': true, 'data': jsonDecode(response.body)};
  }
  return {'success': false, 'error': '...'};
}
```

### Usage in Screen
```dart
// In ResumeUploadScreen
Future<void> _uploadResume() async {
  final result = await ApiService.uploadResume(resumeFile);
  
  if (result['success']) {
    // Show success message
    // Navigate to result screen with data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResumeResultScreen(data: result['data']),
      ),
    );
  } else {
    // Show error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['error'])),
    );
  }
}
```

---

## 🎯 All 28 Integrated API Endpoints

### 1. Authentication (4)
```
POST   /api/auth/register/
       Request: { name, email, password, confirm_password }
       Response: { success, message, access, refresh, user_id }

POST   /api/auth/login/
       Request: { email, password }
       Response: { success, message, access, refresh, user_id }

GET    /api/auth/me/
       Headers: { Authorization: Bearer {token} }
       Response: { success, data: { user_details } }

PUT    /api/auth/profile/setup/
       Request: { current_level, stream, interests, career_goals, phone, ... }
       Response: { success, data: { profile_data } }
```

### 2. Resume (2)
```
POST   /api/resume/upload/
       FormData: { pdf_file: File }
       Response: { success, data: { analysis } }

GET    /api/resume/history/
       Response: { success, data: [ { id, pdf_file, analysis, created_at }, ... ] }
```

### 3. Aptitude (3)
```
GET    /api/aptitude/questions/
       Response: { success, data: [ { id, question_text, option_a, option_b, ... }, ... ] }

POST   /api/aptitude/submit/
       Request: { answers: { "1": "A", "2": "B", ... } }
       Response: { success, data: { score, analysis, gemini_analysis } }

GET    /api/aptitude/history/
       Response: { success, data: [ { id, score, answers, analysis, attempted_at }, ... ] }
```

### 4. Exams (4)
```
GET    /api/exams/?level=12&stream=Science&search=...
       Response: { success, data: [ { id, name, date, level, stream }, ... ] }

POST   /api/exams/{id}/save/
       Response: { success, data: { exam_data } }

DELETE /api/exams/{id}/unsave/
       Response: { success, message: "..." }

GET    /api/exams/saved/
       Response: { success, data: [ { id, name, date, ... }, ... ] }
```

### 5. Courses (4)
```
GET    /api/courses/?level=12&stream=Science&career_path=...&search=...
       Response: { success, data: [ { id, title, description, level, stream }, ... ] }

POST   /api/courses/{id}/save/
       Response: { success, data: { course_data } }

DELETE /api/courses/{id}/unsave/
       Response: { success, message: "..." }

GET    /api/courses/saved/
       Response: { success, data: [ { id, title, description, ... }, ... ] }
```

### 6. Feed/Posts (3)
```
GET    /api/feed/posts/?level=...&stream=...&search=...&author_type=...
       Response: { success, data: [ { id, title, content, author, likes, is_liked, ... }, ... ] }

POST   /api/feed/posts/{id}/like/
       Response: { success, data: { post_data, like_count } }

POST   /api/feed/posts/{id}/save/
       Response: { success, message: "..." }
```

### 7. Careers (Optional - 4)
```
GET    /api/careers/?level=...&stream=...&search=...
       Response: { success, data: [ { id, title, description, requirements, ... }, ... ] }

GET    /api/careers/suggestions/
       Response: { success, data: [ { id, title, match_score }, ... ] }

POST   /api/careers/{id}/save/
       Response: { success, data: { career_data } }

GET    /api/careers/saved/
       Response: { success, data: [ { id, title, ... }, ... ] }
```

---

## 🔌 Query Parameters Supported

### Filtering Parameters
- `level` - Education level (e.g., "12", "Bachelor")
- `stream` - Stream/branch (e.g., "Science", "Commerce", "Arts")
- `career_path` - Career path filter (e.g., "Engineering", "Management")
- `search` - Search term (searches title and description)
- `author_type` - Post author type (e.g., "mentor", "expert", "student")

### Example Requests
```dart
// Get courses with filters
final uri = Uri.parse('$baseUrl/courses/')
  .replace(queryParameters: {
    'level': '12',
    'stream': 'Science',
    'career_path': 'Engineering',
    'search': 'Python'
  });

// Get feed posts filtered
final uri = Uri.parse('$baseUrl/feed/posts/')
  .replace(queryParameters: {
    'level': '12',
    'search': 'career'
  });
```

---

## 🐛 Error Handling

### Network Errors
```dart
catch (e) {
  return {'success': false, 'error': 'Network error: ${e.toString()}'};
}
```

### HTTP Status Codes
- `200` - Success
- `201` - Created
- `400` - Bad request (validation error)
- `401` - Unauthorized (token invalid/expired)
- `403` - Forbidden (insufficient permissions)
- `404` - Not found
- `500` - Server error

### Common Error Responses
```json
{
  "success": false,
  "error": "Invalid credentials"
}

{
  "success": false,
  "error": "Not authenticated"
}

{
  "success": false,
  "error": "Resume upload failed"
}
```

---

## 📊 Provider Architecture

### AuthProvider
```dart
class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  User? _user;
  
  // Methods
  Future<Map<String, dynamic>> login(email, password)
  Future<Map<String, dynamic>> register(...)
  Future<void> autoLogin()
  Future<void> logout()
}
```

### ProfileProvider
```dart
class ProfileProvider with ChangeNotifier {
  User? _profile;
  
  // Methods
  Future<void> loadProfile()
  Future<void> updateProfile(data)
}
```

### FeedProvider
```dart
class FeedProvider with ChangeNotifier {
  List<Post> _posts = [];
  
  // Methods
  Future<void> loadPosts()
  Future<void> likePost(postId)
  Future<void> savePost(postId)
}
```

---

## 🚀 Django Backend Requirements

Your Django backend must:

1. **Support JWT Authentication**
   - Generate access + refresh tokens
   - Include tokens in login response

2. **Validate Requests**
   - Check Authorization header
   - Verify token validity
   - Return 401 for invalid tokens

3. **Return Standard Responses**
   - All responses must have `success` field
   - Include `data` or `error` field accordingly

4. **Handle File Uploads**
   - Accept multipart/form-data
   - Store file path in response
   - Support PDF files for resumes

5. **Implement Filtering**
   - Support query parameters
   - Implement search functionality
   - Handle optional parameters

6. **Configure CORS**
   - Allow requests from Flutter client
   - Set appropriate headers

---

## 🧪 Testing Endpoints Locally

### Test Authentication
```bash
# Register
curl -X POST http://127.0.0.1:8000/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "TestPass123!",
    "confirm_password": "TestPass123!"
  }'

# Login
curl -X POST http://127.0.0.1:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "TestPass123!"
  }'
```

### Test Protected Endpoint
```bash
# Replace TOKEN with actual token from login
curl -X GET http://127.0.0.1:8000/api/exams/ \
  -H "Authorization: Bearer TOKEN"
```

### Test File Upload
```bash
curl -X POST http://127.0.0.1:8000/api/resume/upload/ \
  -H "Authorization: Bearer TOKEN" \
  -F "pdf_file=@/path/to/resume.pdf"
```

---

## 📝 Debugging Tips

1. **Enable Flutter Verbose Logs**
   ```bash
   flutter run -v
   ```

2. **Monitor API Calls**
   - All requests are logged in debug console
   - Look for `→ 200`, `→ 401`, etc.

3. **Use Network Profiler**
   - Dart DevTools includes network profiler
   - Monitor request/response details

4. **Test Backend Independently**
   - Use curl or Postman
   - Test endpoints before integrating

5. **Check Token Validity**
   ```dart
   final token = await SharedPreferences.getInstance()
       .getString('access_token');
   print('Token: $token');
   ```

---

## 🔄 Update Procedures

### Update API Endpoint
1. Update endpoint URL in `ApiService`
2. Update response parsing if format changed
3. Test with new backend
4. Verify in relevant screens

### Add New Endpoint
1. Create method in `ApiService`
2. Add to relevant Provider if needed
3. Create/update Screen UI
4. Test integration

### Update Error Handling
1. Modify error response handling in `ApiService`
2. Update Provider error messages
3. Update UI error display

---

**Last Updated:** December 6, 2025  
**Status:** ✅ Production Ready  
**Tested With:** Django REST Framework

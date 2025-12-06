# Django Backend Connection Guide

## ✅ Backend Integration Complete

Your Flutter app has been configured to connect to the Django backend running at `http://127.0.0.1:8000/api`

---

## 🚀 Prerequisites

### Running Django Backend

Ensure your Django backend is running on:
```bash
python manage.py runserver 0.0.0.0:8000
```

**Important:** Use `0.0.0.0:8000` instead of `127.0.0.1:8000` for Android emulator access.

---

## 📱 Connection Configuration

### For Android Emulator
- **Base URL:** `http://127.0.0.1:8000/api`
- **Port:** 8000
- **Network:** Emulator can access host via `127.0.0.1`

### For Physical Android Device (Optional)
To connect a physical device, update `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://<YOUR_PC_IP>:8000/api';
```

Replace `<YOUR_PC_IP>` with your computer's IP address (find with `ipconfig`).

---

## 🔐 Required Permissions

✅ **Already Configured in `android/app/src/main/AndroidManifest.xml`:**
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

---

## 📡 API Endpoints Configured

The following endpoints are integrated and ready to use:

### Authentication
- ✅ `POST /api/auth/register/` - User registration
- ✅ `POST /api/auth/login/` - User login
- ✅ `GET /api/auth/me/` - Get current user profile
- ✅ `PUT /api/auth/profile/setup/` - Setup/update profile

### Resume
- ✅ `POST /api/resume/upload/` - Upload resume (PDF)
- ✅ `GET /api/resume/history/` - Get resume analysis history

### Aptitude
- ✅ `GET /api/aptitude/questions/` - Get aptitude questions
- ✅ `POST /api/aptitude/submit/` - Submit aptitude test
- ✅ `GET /api/aptitude/history/` - Get aptitude test history

### Exams
- ✅ `GET /api/exams/` - List exams (with filters)
- ✅ `POST /api/exams/{id}/save/` - Save exam
- ✅ `DELETE /api/exams/{id}/unsave/` - Unsave exam
- ✅ `GET /api/exams/saved/` - Get saved exams

### Courses
- ✅ `GET /api/courses/` - List courses (with filters)
- ✅ `POST /api/courses/{id}/save/` - Save course
- ✅ `DELETE /api/courses/{id}/unsave/` - Unsave course
- ✅ `GET /api/courses/saved/` - Get saved courses

### Feed
- ✅ `GET /api/feed/posts/` - Get feed posts
- ✅ `POST /api/feed/posts/{id}/like/` - Like post
- ✅ `POST /api/feed/posts/{id}/save/` - Save post

---

## 🧪 Testing the Connection

### 1. Run Flutter App
```bash
flutter run
```

### 2. Check Network Requests
In the app, perform these actions:
1. **Register/Login** - Tests authentication endpoints
2. **Complete Profile** - Tests profile setup
3. **Upload Resume** - Tests file upload
4. **Take Aptitude Test** - Tests question fetching and submission
5. **Browse Courses/Exams** - Tests data fetching

### 3. Monitor Logs
Flutter will print API requests in debug console:
```
REGISTER → 200
LOGIN → 200
```

---

## 🔧 Backend Response Format

All endpoints should follow this response format:

### Success Response
```json
{
  "success": true,
  "message": "Operation successful",
  "data": { /* actual data */ }
}
```

### Error Response
```json
{
  "success": false,
  "error": "Error message"
}
```

### Authentication Response
```json
{
  "success": true,
  "message": "Login successful!",
  "access": "jwt_access_token",
  "refresh": "jwt_refresh_token",
  "user_id": 1
}
```

---

## 🚨 Troubleshooting

### Error: "No internet or server down"
- ✅ Check if Django backend is running on `0.0.0.0:8000`
- ✅ Verify Android emulator has network access
- ✅ Check firewall isn't blocking port 8000

### Error: "Connection refused"
- ✅ Ensure Django is running
- ✅ For physical device: update IP address in API service
- ✅ Check if you're on same network

### Error: "404 Not Found"
- ✅ Verify endpoint URLs match backend routes
- ✅ Check API version and endpoint paths
- ✅ Ensure trailing slashes are consistent

### CORS Issues
- ✅ Add to Django `INSTALLED_APPS`:
  ```python
  'corsheaders',
  ```
- ✅ Add middleware:
  ```python
  'corsheaders.middleware.CorsMiddleware',
  'django.middleware.common.CommonMiddleware',
  ```
- ✅ Configure allowed origins:
  ```python
  CORS_ALLOWED_ORIGINS = [
      "http://127.0.0.1:8000",
      "http://localhost:8000",
  ]
  ```

---

## 📝 Token Management

JWT tokens are automatically:
- ✅ Stored in `SharedPreferences` after login
- ✅ Included in `Authorization: Bearer {token}` headers
- ✅ Cleared on logout
- ✅ Available for manual refresh if needed

---

## 🔄 Data Sync & Offline Support

Current Implementation:
- ✅ Reads from backend when available
- ✅ Falls back to mock data if offline
- ✅ Saves user selections in local storage
- ✅ Auto-syncs on reconnection (when implemented)

---

## 📌 Next Steps

1. ✅ Start Django backend server
2. ✅ Run Flutter app in Android emulator
3. ✅ Test login/registration
4. ✅ Monitor debug console for API calls
5. ✅ Verify response data is displayed correctly

---

## 📞 Support

For API integration issues, check:
- `lib/services/api_service.dart` - All API methods
- `lib/providers/auth_provider.dart` - Authentication flow
- `lib/screens/` - Screen implementations using API

---

**Last Updated:** December 6, 2025
**API Base URL:** `http://127.0.0.1:8000/api`
**Status:** ✅ Configured and Ready

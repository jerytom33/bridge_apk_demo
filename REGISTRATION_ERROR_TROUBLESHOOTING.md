# Registration Error Troubleshooting Guide

**Date:** December 6, 2025  
**Issue:** "No internet or server down" error when creating account

---

## 🔍 What Was Fixed

### 1. **API Service Error Handling** ✅
- Added timeout handling (10 seconds)
- Better JSON parsing for error responses
- Specific error messages instead of generic ones
- Support for multiple error response formats

### 2. **Signup Screen Error Display** ✅
- Changed generic error message to show actual error details
- Now displays the real backend error message
- Better debugging information

### 3. **Login Screen Error Handling** ✅
- Added timeout exception handling
- Better error messages with HTTP status codes
- Handles malformed JSON responses

---

## 🧪 How to Debug Registration Issues

### Step 1: Check Django Backend is Running

```bash
# Start Django backend
python manage.py runserver 0.0.0.0:8000

# You should see output like:
# Starting development server at http://0.0.0.0:8000/
```

### Step 2: Test Backend Endpoint Manually

```bash
# Test registration endpoint with curl
curl -X POST http://127.0.0.1:8000/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "TestPass123!",
    "confirm_password": "TestPass123!"
  }'

# Expected response:
# {"success": true, "access": "...", "refresh": "...", "user_id": 1}
```

### Step 3: Check App Logs for Details

Run Flutter with verbose logging:

```bash
flutter run -v
```

Look for these logs:

```
REGISTER → 200              # Success (HTTP 200)
REGISTER → 201              # Success (HTTP 201)
REGISTER → 400              # Bad request (check data format)
REGISTER → 500              # Server error (check Django logs)
Response body: {...}        # Actual backend response
```

### Step 4: Review Backend Response Format

Your Django backend MUST return this format:

```json
{
  "success": true,
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "user_id": 1
}
```

**Or for errors:**

```json
{
  "success": false,
  "error": "User with this email already exists"
}
```

---

## 🔧 Common Registration Issues & Solutions

### Issue 1: "Request timeout"

**Cause:** Backend is slow or not responding  
**Solution:**
```bash
# Check if Django is running
python manage.py runserver 0.0.0.0:8000

# Check if port 8000 is open
netstat -an | grep 8000
```

### Issue 2: "Network error: ..."

**Cause:** Connection cannot be established  
**Solution:**
- Verify Django is running on `0.0.0.0:8000` (not `127.0.0.1:8000`)
- Check firewall isn't blocking port 8000
- For physical device: Use correct IP address

### Issue 3: "Invalid credentials (Status: 400)"

**Cause:** 
- Email already exists
- Password doesn't meet requirements
- Missing required fields
- Passwords don't match

**Solution:**
- Check backend for validation rules
- Use strong password (mix of uppercase, lowercase, numbers, symbols)
- Verify email is unique
- Ensure passwords match

### Issue 4: "Invalid credentials (Status: 500)"

**Cause:** Backend error  
**Solution:**
- Check Django console for error traceback
- Check database is accessible
- Review database migrations have been run

### Issue 5: Can't parse error response

**Cause:** Backend returned non-JSON response  
**Solution:**
- Check backend isn't returning HTML error page
- Verify endpoint URL is correct
- Check Django is not redirecting requests

---

## ✅ Verification Checklist for Registration

- [ ] Django backend running on `0.0.0.0:8000`
- [ ] Can test endpoint with curl successfully
- [ ] Response has `success`, `access`, `refresh`, `user_id` fields
- [ ] Error responses have `error` field
- [ ] No firewall blocking port 8000
- [ ] Flutter app shows detailed error, not generic message
- [ ] Console shows `REGISTER → 200` or `REGISTER → 201`
- [ ] User can proceed to profile setup after registration

---

## 📊 Expected Flow

```
1. User enters credentials
   ↓
2. App validates input
   ↓
3. App sends POST /api/auth/register/
   ↓
4. Django backend validates
   ↓
5. Backend returns response:
   - If success: {"success": true, "access": "...", ...}
   - If error: {"success": false, "error": "..."}
   ↓
6. App shows:
   - Success: Navigate to profile setup
   - Error: Show actual error message from backend
```

---

## 🐛 Enable Detailed Logging

To see all network details, add this to the beginning of `lib/main.dart`:

```dart
void main() {
  // Enable debug logging
  HttpOverrides.global = MyHttpOverrides();
  
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BridgeApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
```

Then watch Flutter console:
```bash
flutter run -v > app_logs.txt 2>&1
```

---

## 📞 Backend Configuration Checklist

Ensure your Django backend has:

```python
# settings.py

# 1. CORS Enabled
INSTALLED_APPS = [
    'corsheaders',
    'rest_framework',
    # ...
]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.common.CommonMiddleware',
    # ...
]

CORS_ALLOWED_ORIGINS = [
    "http://127.0.0.1:8000",
    "http://localhost:8000",
]

# 2. JWT Configured
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ),
}

# 3. API URLs
urlpatterns = [
    path('api/auth/register/', RegisterView.as_view(), name='register'),
    path('api/auth/login/', LoginView.as_view(), name='login'),
    # ...
]
```

---

## 🆘 Still Having Issues?

### 1. Verify with curl first

```bash
curl -v -X POST http://127.0.0.1:8000/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{"name":"Test","email":"test@test.com","password":"Pass123!","confirm_password":"Pass123!"}'
```

Examine:
- HTTP status code
- Response headers
- Response body

### 2. Check Android Emulator Network

```bash
# From emulator shell
adb shell ping 127.0.0.1
adb shell curl -v http://127.0.0.1:8000/api/auth/register/ \
  -d '{"name":"Test","email":"test@test.com",...}'
```

### 3. Monitor Django Logs

```bash
# In Django terminal, enable SQL logging
python manage.py runserver 0.0.0.0:8000 --settings=yourproject.settings_debug

# Watch for:
# [POST /api/auth/register/]
# Check password validation
# Check email uniqueness
# Check database queries
```

### 4. Add Debugging to Backend

```python
# In your Django view
@api_view(['POST'])
def register(request):
    print(f"Register request: {request.data}")
    try:
        # ... registration logic
        print("Registration successful")
        return Response({'success': True, ...})
    except Exception as e:
        print(f"Registration error: {e}")
        return Response({'success': False, 'error': str(e)})
```

---

## 📋 Files Modified in This Fix

1. **lib/services/api_service.dart**
   - Added timeout handling
   - Improved error parsing
   - Better error messages

2. **lib/screens/signup_screen.dart**
   - Changed error display to show actual message
   - Removed generic "no internet" error

3. **lib/screens/register_screen.dart**
   - Already had proper error handling
   - No changes needed

---

## ✨ Expected Behavior After Fix

### Success Flow
1. User enters credentials and taps Register
2. App shows loading spinner
3. Backend validates and creates account
4. App shows "Account created successfully!" message
5. App navigates to profile setup screen

### Error Flow
1. User enters credentials and taps Register
2. App shows loading spinner
3. Backend returns error (e.g., "Email already exists")
4. App shows actual error message from backend
5. User can try again with different credentials

---

## 🎯 Key Changes Made

| Change | Impact | Status |
|--------|--------|--------|
| Timeout handling | Prevents hanging requests | ✅ Fixed |
| Error parsing | Shows real error messages | ✅ Fixed |
| Signup screen | No more generic errors | ✅ Fixed |
| Login screen | Better error messages | ✅ Fixed |
| Console logging | Easier debugging | ✅ Improved |

---

**Configuration Complete!**  
Your registration error handling is now much better with detailed error messages.

If you still see errors, use the debugging steps above to identify the exact issue on your backend.

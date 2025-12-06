# Quick Reference - Backend Integration

## 🔌 Connection Quick Start

```
Backend URL: http://127.0.0.1:8000/api
Emulator:    ✅ Works (127.0.0.1)
Device:      🔧 Update IP manually
Status:      ✅ CONNECTED
```

## 🚀 Start Backend

```bash
# Windows/Mac/Linux
python manage.py runserver 0.0.0.0:8000

# Important: Use 0.0.0.0, not 127.0.0.1
```

## 🏃 Run Flutter App

```bash
flutter run
```

## 📱 Test Connection

1. **Open app** → Login/Register screen appears
2. **Try login** → Check console for `LOGIN → 200`
3. **Check response** → Should see user data loaded

## 🔍 Key Files

| File | Purpose |
|------|---------|
| `lib/services/api_service.dart` | All API calls (701 lines) |
| `lib/providers/auth_provider.dart` | Authentication logic |
| `lib/screens/login_screen.dart` | Login UI |
| `BACKEND_SETUP_GUIDE.md` | Detailed setup |
| `API_INTEGRATION_TECHNICAL_DOCS.md` | Technical details |
| `INTEGRATION_STATUS.md` | Full status report |

## 📡 API Endpoints (28 Total)

| Category | Count | Status |
|----------|-------|--------|
| Authentication | 4 | ✅ Ready |
| Resume | 2 | ✅ Ready |
| Aptitude | 3 | ✅ Ready |
| Exams | 4 | ✅ Ready |
| Courses | 4 | ✅ Ready |
| Feed | 3 | ✅ Ready |
| Careers | 4 | ⏳ Optional |

## 🔐 Required Endpoints

### Minimum for App to Work
```
POST   /api/auth/register/      - Register users
POST   /api/auth/login/         - Login users
GET    /api/auth/me/            - Get user profile
PUT    /api/auth/profile/setup/ - Setup profile
```

### All Other Endpoints
See `BACKEND_SETUP_GUIDE.md` for complete list.

## 🔑 Response Format Must Be

```json
{
  "success": true/false,
  "message": "...",
  "data": {...} | "error": "..."
}
```

## ⚡ Common Commands

### Test Connection
```bash
# PowerShell
./test_backend_connection.ps1

# Bash
bash test_backend_connection.sh
```

### Rebuild App
```bash
flutter clean
flutter pub get
flutter run
```

### View Logs
```bash
flutter run -v  # Verbose mode
```

## 🎯 Troubleshooting

| Error | Fix |
|-------|-----|
| Connection refused | Backend not running |
| 404 Not Found | Endpoint doesn't exist |
| 401 Unauthorized | Token missing/invalid |
| CORS error | Configure Django CORS |
| No internet error | Firewall blocking 8000 |

## 📲 Physical Device Setup

1. Find PC IP: `ipconfig` (Windows)
2. Update `lib/services/api_service.dart`:
   ```dart
   static const String baseUrl = 'http://192.168.x.x:8000/api';
   ```
3. Rebuild: `flutter run`

## 🧪 Quick API Test

```bash
# Register
curl -X POST http://127.0.0.1:8000/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{"name":"Test","email":"test@test.com","password":"pass123","confirm_password":"pass123"}'

# Login (get token)
curl -X POST http://127.0.0.1:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"pass123"}'

# Use token to get exams
curl -X GET http://127.0.0.1:8000/api/exams/ \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## 📋 Django Settings Required

```python
# settings.py

# CORS Configuration
INSTALLED_APPS = [
    'corsheaders',
    # ... other apps
]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.common.CommonMiddleware',
    # ... other middleware
]

CORS_ALLOWED_ORIGINS = [
    "http://127.0.0.1:8000",
    "http://localhost:8000",
]

# JWT Configuration
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ),
}
```

## ✅ Verification Checklist

- [ ] Django running on `0.0.0.0:8000`
- [ ] Flutter app starts without errors
- [ ] Login request shows `200` status
- [ ] No CORS errors
- [ ] Response format includes `success` field
- [ ] Tokens stored after login
- [ ] Can fetch protected endpoints
- [ ] Resume upload works
- [ ] File permissions correct

## 🆘 Still Having Issues?

1. Check `BACKEND_SETUP_GUIDE.md` - Full setup instructions
2. Review `API_INTEGRATION_TECHNICAL_DOCS.md` - Detailed docs
3. Verify `INTEGRATION_STATUS.md` - Status report
4. Test endpoints with `curl` first
5. Check Django logs for errors
6. Verify CORS is configured

## 📞 Support Resources

- **Flutter Docs:** https://flutter.dev/docs
- **Django REST:** https://www.django-rest-framework.org/
- **JWT:** https://github.com/encode/django-rest-framework-simplejwt
- **CORS:** https://github.com/adamchainz/django-cors-headers

---

**Configuration:** ✅ Complete  
**Status:** ✅ Ready to Use  
**Last Updated:** December 6, 2025

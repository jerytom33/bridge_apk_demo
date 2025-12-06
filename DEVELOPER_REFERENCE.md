# Student Dashboard API - Developer Reference Card

## 🎯 One-Liner
Unified API endpoint that returns profile, featured courses, upcoming exams, and saved items in a single request.

## 📍 Endpoint
```
GET http://127.0.0.1:8000/api/student/dashboard/
Authorization: Bearer YOUR_ACCESS_TOKEN
```

## 💾 Flutter Usage
```dart
final response = await ApiService.getStudentDashboard();

if (response['success']) {
    final dashboard = response['data'];
    // Use: dashboard['profile']
    // Use: dashboard['featured_courses']
    // Use: dashboard['upcoming_exams']
    // Use: dashboard['saved_courses']
    // Use: dashboard['saved_exams']
} else {
    print('Error: ${response['error']}');
}
```

## 📦 Response Format
```dart
Map<String, dynamic> {
    'success': true,
    'data': {
        'profile': { /* user profile */ },
        'featured_courses': [ /* courses list */ ],
        'upcoming_exams': [ /* exams list */ ],
        'saved_courses': [ /* saved courses */ ],
        'saved_exams': [ /* saved exams */ ]
    }
}
```

## 🔑 Key Features
| Feature | Details |
|---------|---------|
| **Auth** | Bearer token required |
| **Timeout** | 10 seconds |
| **Error 401** | Token expired, auto clear auth |
| **Caching** | Implement locally in app |
| **Refresh** | Call method again |

## ⚡ Common Implementations

### State Management
```dart
class DashboardProvider extends ChangeNotifier {
    Future<void> load() async {
        final res = await ApiService.getStudentDashboard();
        _data = res['success'] ? res['data'] : null;
        notifyListeners();
    }
}
```

### Widget Integration
```dart
FutureBuilder(
    future: ApiService.getStudentDashboard(),
    builder: (context, snapshot) {
        if (!snapshot.hasData) return LoadingWidget();
        if (snapshot.hasError) return ErrorWidget();
        return DisplayWidget(snapshot.data['data']);
    },
)
```

### With Loading
```dart
Future<void> _load() async {
    setState(() => loading = true);
    final res = await ApiService.getStudentDashboard();
    setState(() {
        if (res['success']) data = res['data'];
        else error = res['error'];
        loading = false;
    });
}
```

## 🧪 Test Commands
```bash
# Get token
curl -X POST http://127.0.0.1:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"email":"user@test.com","password":"pass"}'

# Call dashboard
curl -X GET http://127.0.0.1:8000/api/student/dashboard/ \
  -H "Authorization: Bearer TOKEN"
```

## 🔍 Debug Logs
Look for in logcat:
```
STUDENT_DASHBOARD → 200          # Success
STUDENT_DASHBOARD → 401          # Token expired
Student Dashboard Timeout        # Timeout
Student Dashboard Error:         # Other error
```

## 📂 Code Location
- **Method:** `lib/services/api_service.dart` (line 719)
- **Returns:** `Future<Map<String, dynamic>>`
- **Requires:** Active authentication token

## ⚠️ Error Scenarios
```
No Token
→ 'Unauthorized: No token found'

Token Expired  
→ 'Unauthorized: Token expired' (clears auth)

Network Timeout
→ 'Request timeout. Check your connection.'

Server Error
→ 'Failed to fetch dashboard (Status: 500)'
```

## 🚀 Integration Checklist
- [ ] Backend running at http://127.0.0.1:8000/
- [ ] User logged in with valid token
- [ ] Call ApiService.getStudentDashboard()
- [ ] Handle success and error cases
- [ ] Display data in UI
- [ ] Test on device with 10.0.2.2 URL

## 📊 Expected Response Time
- Cold: 300-500ms
- Warm: 100-200ms
- Network latency: +100-300ms

## 💡 Pro Tips
1. **Cache locally** after first fetch
2. **Show loading state** while fetching
3. **Implement refresh** for manual updates
4. **Handle timeouts** gracefully
5. **Log responses** for debugging

## 🎓 Documentation
- `STUDENT_DASHBOARD_INTEGRATION.md` - Full docs
- `QUICK_START_DASHBOARD.md` - Examples
- This file - Quick reference

## 🆘 Quick Troubleshoot
| Problem | Solution |
|---------|----------|
| 401 Error | Re-login for new token |
| Connection refused | Check 10.0.2.2 URL |
| Timeout | Check network/backend |
| Empty data | Verify backend data |

---

**Everything is ready!** Just integrate the response data into your UI screens.

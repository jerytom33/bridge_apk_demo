# Onboarding 500 Error - Backend Fix Required

## 🐛 Current Issue

The onboarding screen is correctly calling the backend, but getting a **500 Server Error**:

```
📦 Profile setup data: {education_level: Undergraduate, stream: Science, interests: [Technology, Business, Science, Finance], career_goals: to be a techy}
🔧 Profile setup endpoint: https://bridgeit-backend.onrender.com/api/student/profile/
📡 Profile setup response status: 500
❌ Profile setup returned HTML error page
```

**Root Cause:** Backend is crashing when processing the request, likely due to field name mismatch.

## 🔍 The Problem

**Flutter sends:** `education_level`  
**Backend expects:** `current_level`

When the serializer receives `education_level`, it doesn't recognize it and crashes with 500 error.

## ✅ Backend Fix Required

### Option 1: Update Serializer to Accept Both Field Names (RECOMMENDED)

**File:** `users/serializers.py` or `student_gateway/serializers.py`

```python
from rest_framework import serializers
from .models import Student

class StudentProfileUpdateSerializer(serializers.ModelSerializer):
    # Add alias: education_level → current_level
    education_level = serializers.CharField(
        source='current_level',
        required=False,
        allow_blank=True,
        max_length=50
    )
    
    class Meta:
        model = Student
        fields = [
            'id',
            'name',
            'email',
            'phone',
            'gender',
            'dob',
            'state',
            'district',
            'place',
            'address',
            'current_level',
            'education_level',  # Alias for current_level
            'stream',
            'career_goals',
            'interests',
        ]
        read_only_fields = ['id']
        extra_kwargs = {
            'current_level': {'required': False, 'allow_blank': True},
            'stream': {'required': False, 'allow_blank': True},
            'career_goals': {'required': False, 'allow_blank': True},
            'interests': {'required': False},
        }
```

**This allows:**
- Onboarding to send `education_level` ✅
- Profile Settings to send `current_level` ✅
- Both map to the same database field

### Option 2: Update View to Handle Field Mapping

**File:** `student_gateway/views.py`

```python
@api_view(['GET', 'PATCH'])
@permission_classes([IsAuthenticated])
def student_profile(request):
    """
    GET: Retrieve current user's profile
    PATCH: Update current user's profile
    """
    user = request.user
    
    if request.method == 'PATCH':
        # Map education_level to current_level if present
        data = request.data.copy()
        if 'education_level' in data and 'current_level' not in data:
            data['current_level'] = data.pop('education_level')
        
        serializer = StudentProfileUpdateSerializer(
            user, 
            data=data, 
            partial=True,
            context={'request': request}
        )
        
        if serializer.is_valid():
            serializer.save()
            return Response({
                'success': True,
                'message': 'Profile updated successfully',
                'user': serializer.data
            }, status=status.HTTP_200_OK)
        else:
            return Response({
                'success': False,
                'error': serializer.errors
            }, status=status.HTTP_400_BAD_REQUEST)
```

## 🧪 Testing After Backend Fix

### 1. Deploy Backend Changes

```bash
# After making changes
python manage.py migrate  # If needed
python manage.py runserver  # Test locally

# Then deploy
git add .
git commit -m "Add education_level alias for onboarding"
git push origin main
```

### 2. Wait for Render Deployment (2-3 minutes)

### 3. Test Onboarding in Flutter

**Expected Success Output:**
```
🛠️ Setting up profile: {education_level: Undergraduate, ...}
🔧 Profile setup endpoint: https://bridgeit-backend.onrender.com/api/student/profile/
📦 Profile setup data: {education_level: Undergraduate, ...}
📡 Profile setup response status: 200
📄 Profile setup response body: {"success": true, "message": "Profile updated successfully", "user": {...}}
✅ Profile setup successful
✅ Setup success – reloading...
```

## 📊 Complete Request/Response Flow

### Request (Flutter → Backend)

```http
PATCH /api/student/profile/
Authorization: Bearer eyJ0e...
Content-Type: application/json

{
  "education_level": "Undergraduate",
  "stream": "Science",
  "interests": ["Technology", "Business", "Science", "Finance"],
  "career_goals": "to be a techy"
}
```

### Response (Backend → Flutter)

**Success (200):**
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "user": {
    "id": 33,
    "name": "John Doe",
    "email": "john@example.com",
    "current_level": "Undergraduate",
    "stream": "Science",
    "interests": ["Technology", "Business", "Science", "Finance"],
    "career_goals": "to be a techy"
  }
}
```

**Error (500) - Current Issue:**
```html
<!doctype html>
<html lang="en">
<head>
  <title>Server Error (500)</title>
</head>
<body>
  <h1>Server Error (500)</h1>
</body>
</html>
```

## 🚨 Debug: Check Render Logs

To see the exact error:

1. Go to **Render Dashboard**
2. Select your **backend service**
3. Click **Logs** tab
4. Look for error when onboarding is submitted

**Common errors you might see:**

**Error 1: Unknown field**
```
django.core.exceptions.FieldError: Unknown field(s) (education_level) specified for Student
```
**Fix:** Add `education_level` alias in serializer

**Error 2: Validation error**
```
KeyError: 'current_level'
```
**Fix:** Make field optional in model or serializer

**Error 3: Database constraint**
```
IntegrityError: NOT NULL constraint failed: users_student.current_level
```
**Fix:** Ensure field allows null or provide default

## ✅ Quick Summary

**What's Working:**
- ✅ Flutter app correctly sends data
- ✅ Correct endpoint (`/api/student/profile/`)
- ✅ Correct method (`PATCH`)
- ✅ Proper authentication
- ✅ Debug logging enabled

**What's Broken:**
- ❌ Backend doesn't recognize `education_level` field
- ❌ Backend crashes with 500 error
- ❌ No proper error message returned

**Backend Fix Needed:**
1. Add `education_level` as serializer alias for `current_level`
2. OR map field in view before serialization
3. Deploy to Render
4. Test onboarding flow

## 🎯 Action Required

**Choose one fix and apply:**

✅ **Recommended:** Add serializer alias (cleaner, more maintainable)  
⚠️ **Alternative:** Map field in view (quick fix, but less elegant)

After applying the fix and deploying, the onboarding flow will work perfectly! 🚀

---

**Share the Render error logs** to get a more specific fix if needed!

# Profile Setup (Onboarding) - Backend Integration

## 🎯 Issue Fixed

The onboarding screen's profile setup was calling a non-existent endpoint.

**Before (WRONG):**
```
PUT /api/auth/profile/setup/
```

**After (CORRECT):**
```
PATCH /api/student/profile/
```

## ✅ Flutter Fix Applied

Updated `ApiService.setupProfile()` to:
- Use `PATCH` instead of `PUT`
- Call `/api/student/profile/` (same as profile settings)
- Added comprehensive debug logging
- Handle HTML error responses

## 📊 What Flutter Sends (Onboarding)

**Endpoint:** `PATCH /api/student/profile/`

**Request Body:**
```json
{
  "education_level": "Undergraduate",
  "stream": "Science",
  "interests": ["Technology", "Business", "Science", "Finance"],
  "career_goals": "to be a techy"
}
```

**Headers:**
```
Content-Type: application/json
Authorization: Bearer <access_token>
```

## 🔧 Backend Status

**Good News!** The backend endpoint already exists:
- ✅ `PATCH /api/student/profile/` is implemented
- ✅ Handles partial updates (all fields optional)
- ✅ Validates and saves data to database

**The backend doesn't need any changes!** The same endpoint used for Profile Settings also handles onboarding profile setup.

## 🧪 Testing After Hot Reload

**Hot reload** your Flutter app (`r`) and try the onboarding flow:

1. **Register a new account**
2. **Onboarding screen** appears
3. **Fill the form:**
   - Education Level: Select from dropdown
   - Stream/Subject: Enter text
   - Interests: Select multiple chips
   - Career Goals: Enter text

4. **Tap "Continue"**

5. **Check Terminal Output:**

**Expected Success:**
```
🛠️ Setting up profile: {education_level: Undergraduate, ...}
🔧 Profile setup endpoint: https://bridgeit-backend.onrender.com/api/student/profile/
📦 Profile setup data: {education_level: Undergraduate, ...}
📡 Profile setup response status: 200
📄 Profile setup response body: {"success": true, ...}
✅ Profile setup successful
✅ Setup success – reloading...
🔍 Loading profile...
✅ Profile loaded: Undergraduate
```

**If Endpoint Doesn't Exist (404):**
```
🔧 Profile setup endpoint: https://bridgeit-backend.onrender.com/api/student/profile/
📡 Profile setup response status: 404
📄 Profile setup response body: <!doctype html>...
❌ Profile setup returned HTML error page
```

**If Network Error:**
```
❌ Profile setup exception: TimeoutException after 0:00:30.000000
```

## 🎯 Complete Onboarding Flow

```
User Registers
    ↓
Registration Success (201)
    ↓
Onboarding Screen Appears
    ↓
User Fills Form:
  - Education Level
  - Stream
  - Interests (multiple)
  - Career Goals
    ↓
Tap "Continue"
    ↓
PATCH /api/student/profile/
    ↓
Backend Saves Data
    ↓
Flutter Reloads Profile
    ↓
Navigate to Home Screen
```

## 📝 Field Mapping

| Onboarding Field | Backend Field | Type |
|-----------------|---------------|------|
| Education Level | `education_level` OR `current_level` | String |
| Stream/Subject | `stream` | String |
| Interests | `interests` | Array |
| Career Goals | `career_goals` | Text |

**Note:** The onboarding sends `education_level` but the backend may use `current_level`. Ensure the serializer maps this correctly.

## 🔧 Backend Serializer Adjustment (If Needed)

If you see this error:
```
❌ Profile setup failed: Unknown field 'education_level'
```

**Update the serializer:**

```python
# users/serializers.py
class StudentProfileUpdateSerializer(serializers.ModelSerializer):
    # Add alias for education_level
    education_level = serializers.CharField(
        source='current_level',
        required=False,
        allow_blank=True
    )
    
    class Meta:
        model = Student
        fields = [
            'name', 'email', 'phone', 'dob',
            'current_level', 'education_level',  # Both fields
            'stream', 'career_goals', 'interests',
            # ... other fields
        ]
```

This allows both `education_level` and `current_level` to work.

## ✅ Summary

**Flutter Changes:**
- ✅ Updated endpoint: `/auth/profile/setup/` → `/student/profile/`
- ✅ Changed method: `PUT` → `PATCH`
- ✅ Added debug logging
- ✅ Added HTML error detection
- ✅ Added timeout handling

**Backend:**
- ✅ No changes needed (endpoint already exists!)
- ⚠️ May need serializer alias for `education_level` → `current_level`

**Test:**
1. Hot reload Flutter app (`r`)
2. Register new account
3. Complete onboarding
4. Check terminal for debug logs
5. Verify data saved (check Profile Settings)

Everything should work now! 🚀

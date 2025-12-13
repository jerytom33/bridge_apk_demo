# Profile Completion Screen - Backend Integration

## 📋 Overview

The Profile Completion Screen collects comprehensive user information after registration. This document ensures the backend properly handles all these fields.

## 🎯 Current Status

✅ **Flutter App Updated:**
- Now uses `PATCH /api/student/profile/` endpoint (same as Profile Settings)
- Sends all fields to backend
- Caches data to SharedPreferences
- Includesdebug logging

## 📊 Fields Collected

The profile completion screen collects:

| Field | Type | Required | Backend Field | Notes |
|-------|------|----------|---------------|-------|
| Phone | String | Yes | `phone` | 10 digits validation |
| Gender | String | Yes | `gender` | Male/Female/Other |
| Date of Birth | Date | Yes | `dob` | YYYY-MM-DD format |
| State | String | Yes | `state` | User's state |
| District | String | Yes | `district` | User's district |
| Place/City | String | Yes | `place` | User's city |
| Education Level | String | Yes | `current_level` | 10th/12th/UG/PG |
| Stream/Subject | String | Yes | `stream` | e.g., Science, Arts |
| Interests | Array | Yes | `interests` | Multiple selection |
| Career Goals | Text | Yes | `career_goals` | Text description |

## 🔧 Backend Requirements

### 1. Ensure Model Has All Fields

**File:** `users/models.py` (or wherever Student model is)

```python
from django.db import models
from django.contrib.auth.models import AbstractUser

class Student(AbstractUser):
    # Basic Info
    name = models.CharField(max_length=255, null=True, blank=True)
    phone = models.CharField(max_length=15, null=True, blank=True)
    gender = models.CharField(max_length=10, null=True, blank=True)  # ✅ ADD THIS
    dob = models.DateField(null=True, blank=True)
    
    # Location
    state = models.CharField(max_length=100, null=True, blank=True)  # ✅ ADD THIS
    district = models.CharField(max_length=100, null=True, blank=True)  # ✅ ADD THIS
    place = models.CharField(max_length=100, null=True, blank=True)
    address = models.TextField(null=True, blank=True)
    
    # Education
    current_level = models.CharField(max_length=50, null=True, blank=True)
    stream = models.CharField(max_length=100, null=True, blank=True)
    career_goals = models.TextField(null=True, blank=True)
    interests = models.JSONField(default=list, null=True, blank=True)
    
    def __str__(self):
        return self.email or self.username
```

**If Adding New Fields, Run:**
```bash
python manage.py makemigrations
python manage.py migrate
```

### 2. Update Serializer

**File:** `users/serializers.py` (or `student_gateway/serializers.py`)

```python
from rest_framework import serializers
from .models import Student

class StudentProfileUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Student
        fields = [
            'id',
            'name',
            'email',
            'phone',
            'gender',           # ✅ ADD THIS
            'dob',
            'state',            # ✅ ADD THIS
            'district',         # ✅ ADD THIS
            'place',
            'address',
            'current_level',
            'stream',
            'career_goals',
            'interests',
        ]
        read_only_fields = ['id']
    
    def validate_phone(self, value):
        """Validate phone number"""
        if value and not value.isdigit():
            raise serializers.ValidationError("Phone must contain only digits")
        if value and len(value) != 10:
            raise serializers.ValidationError("Phone must be 10 digits")
        return value
    
    def validate_gender(self, value):
        """Validate gender"""
        valid_genders = ['Male', 'Female', 'Other']
        if value and value not in valid_genders:
            raise serializers.ValidationError(f"Gender must be one of: {', '.join(valid_genders)}")
        return value
```

### 3. View Already Exists!

Your existing `StudentProfileView` at `PATCH /api/student/profile/` already handles this!

The view supports **partial updates**, so it will accept any combination of fields.

## 📱 Flutter → Backend Data Flow

### Profile Completion Sends:

```json
{
  "phone": "1234567890",
  "gender": "Male",
  "dob": "2000-01-15",
  "state": "Kerala",
  "district": "Kannur",
  "place": "Thalassery",
  "current_level": "12th",
  "stream": "Science",
  "interests": ["Technology", "Engineering"],
  "career_goals": "Become a software engineer"
}
```

### Backend Responds:

**Success (200):**
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "1234567890",
    "gender": "Male",
    "dob": "2000-01-15",
    "state": "Kerala",
    "district": "Kannur",
    "place": "Thalassery",
    "current_level": "12th",
    "stream": "Science",
    "interests": ["Technology", "Engineering"],
    "career_goals": "Become a software engineer",
    "address": null
  }
}
```

**Error (400):**
```json
{
  "success": false,
  "error": {
    "phone": ["Phone must be 10 digits"],
    "gender": ["Gender must be one of: Male, Female, Other"]
  }
}
```

## 🧪 Testing Profile Completion

### Test Complete Profile Flow:

1. **Register** a new account
2. **Profile Completion Screen** appears
3. Fill all fields:
   - Phone: 9876543210
   - Gender: Male
   - DOB: 2000-01-15
   - Education: 12th
   - Stream: Science
   - Interests: Technology, Engineering
   - Career Goals: Software Engineer
   - State/District/Place
4. **Tap "Complete Profile"**
5. **Check terminal:**

```
📤 Submitting profile completion: {phone: 9876543210, gender: Male, ...}
🔧 Updating profile at: https://bridgeit-backend.onrender.com/api/student/profile/
📡 Response status: 200
📄 Response body: {"success": true, ...}
✅ Profile completion successful
```

6. **Navigate to Home**
7. **Logout and Login**
8. **Check Profile Settings** - all data should be there!

## ⚙️ Backend Deployment Checklist

### If You Added New Fields (gender, state, district):

```bash
# 1. Add fields to model
# Edit users/models.py

# 2. Create migration
python manage.py makemigrations

# 3. Apply migration locally
python manage.py migrate

# 4. Test locally
python manage.py runserver

# 5. Commit and push
git add .
git commit -m "Add gender, state, district fields to Student model"
git push origin main

# 6. Render auto-deploys
# Check Render dashboard for deployment status

# 7. Verify migrations ran on Render
# Check Render logs for "Running migrations"
```

### Migration File Example:

```python
# users/migrations/0003_add_location_fields.py
from django.db import migrations, models

class Migration(migrations.Migration):
    dependencies = [
        ('users', '0002_studentprofile_address_studentprofile_place'),
    ]

    operations = [
        migrations.AddField(
            model_name='student',
            name='gender',
            field=models.CharField(blank=True, max_length=10, null=True),
        ),
        migrations.AddField(
            model_name='student',
            name='state',
            field=models.CharField(blank=True, max_length=100, null=True),
        ),
        migrations.AddField(
            model_name='student',
            name='district',
            field=models.CharField(blank=True, max_length=100, null=True),
        ),
    ]
```

## 🔄 Data Synchronization

### Profile Completion → Profile Settings:

Both screens now use the **same endpoint** (`PATCH /api/student/profile/`), ensuring:

✅ **Consistent Data:** All fields available in both screens  
✅ **No Duplication:** Single source of truth  
✅ **Easy Maintenance:** Update one endpoint, both screens work  

### Flow Diagram:

```
Registration
    ↓
Profile Completion Screen
    ↓
Collects: phone, gender, dob, location, education, interests
    ↓
PATCH /api/student/profile/
    ↓
Backend saves all fields
    ↓
Home Screen
    ↓
Later: Profile Settings Screen
    ↓
GET /api/student/profile/ (loads all data)
    ↓
User can update any field
    ↓
PATCH /api/student/profile/ (same endpoint!)
```

## 📝 Summary

### ✅ Flutter Changes Made:

1. Profile completion now uses `updateStudentProfile()` 
2. Sends all fields: phone, gender, dob, state, district, place, education
3. Caches to SharedPreferences
4. Debug logging added

### ✅ Backend Requirements:

1. **Add fields to model** (gender, state, district) if missing
2. **Run migrations** to update database
3. **Update serializer** to include new fields
4. **Existing view works** - no changes needed!
5. **Deploy to Render**

### 🧪 Test After Backend Deployment:

1. Register new account
2. Complete profile with all fields
3. Verify success message
4. Logout and login
5. Check Profile Settings - data should persist!

---

## 🚀 Quick Action Items

**If gender, state, district fields don't exist in your model:**

```bash
# 1. Add to users/models.py:
gender = models.CharField(max_length=10, null=True, blank=True)
state = models.CharField(max_length=100, null=True, blank=True)
district = models.CharField(max_length=100, null=True, blank=True)

# 2. Run:
python manage.py makemigrations
python manage.py migrate

# 3. Push to Render:
git add .
git commit -m "Add gender, state, district fields"
git push origin main
```

**If fields already exist:**

✅ No backend changes needed! The app will work immediately after hot reload.

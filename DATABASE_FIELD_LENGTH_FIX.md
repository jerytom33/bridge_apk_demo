# Database Field Length Error - Backend Fix

## 🐛 Error Found!

```
Profile setup failed: value too long for type character varying(10)
```

**Root Cause:** The database field `current_level` is defined as `VARCHAR(10)` (max 10 characters), but the value "Undergraduate" has 13 characters!

## 📊 The Data

**Flutter sends:**
```
education_level: "Undergraduate"  // 13 characters ❌
```

**Database allows:**
```
current_level VARCHAR(10)  // Only 10 characters!
```

## ✅ Backend Fix Required

### Fix 1: Increase Database Field Length (RECOMMENDED)

**File:** `users/models.py`

```python
class StudentProfile(models.Model):
    # ... other fields
    
    # BEFORE:
    # current_level = models.CharField(max_length=10, choices=LEVEL_CHOICES, blank=True)
    
    # AFTER: Increase to 50 characters
    current_level = models.CharField(max_length=50, choices=LEVEL_CHOICES, blank=True)
    
    # ... other fields
```

**Run migration:**
```bash
python manage.py makemigrations
python manage.py migrate
```

**Migration will be:**
```python
# users/migrations/000X_increase_current_level_length.py
from django.db import migrations, models

class Migration(migrations.Migration):
    dependencies = [
        ('users', '0003_studentprofile_district_studentprofile_gender_and_more'),
    ]

    operations = [
        migrations.AlterField(
            model_name='studentprofile',
            name='current_level',
            field=models.CharField(blank=True, max_length=50),
        ),
    ]
```

### Fix 2: Use Shorter Values in Flutter (ALTERNATIVE)

**File:** `lib/screens/onboarding_screen.dart`

Change the dropdown values to shorter ones:

```dart
// BEFORE:
items: ['10th', '12th', 'Undergraduate', 'Postgraduate'],

// AFTER: Use abbreviations
items: ['10th', '12th', 'UG', 'PG'],
```

**Pros:** Quick fix, no backend changes  
**Cons:** Less user-friendly abbreviations

## 🎯 Recommended Solution

**Use Fix 1** (Increase database field length) because:
- ✅ More user-friendly (full words instead of abbreviations)
- ✅ Future-proof (won't break with longer values)
- ✅ Proper database design
- ✅ Matches industry standards

## 📝 Complete Backend Fix Steps

### Step 1: Update Model

**File:** `users/models.py`

```python
class StudentProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    
    # Basic Info
    phone = models.CharField(max_length=15, blank=True)
    gender = models.CharField(max_length=10, blank=True)
    date_of_birth = models.DateField(null=True, blank=True)
    
    # Location
    state = models.CharField(max_length=100, blank=True)
    district = models.CharField(max_length=100, blank=True)
    place = models.CharField(max_length=100, blank=True)
    address = models.TextField(blank=True)
    
    # Education - INCREASE THIS
    current_level = models.CharField(max_length=50, blank=True)  # Changed from 10 to 50
    stream = models.CharField(max_length=100, blank=True)
    career_goals = models.TextField(blank=True)
    interests = models.JSONField(default=list, blank=True)
```

### Step 2: Add Serializer Alias (From Previous Fix)

**File:** `users/serializers.py`

```python
class StudentProfileUpdateSerializer(serializers.ModelSerializer):
    # Add alias: education_level → current_level
    education_level = serializers.CharField(
        source='current_level',
        required=False,
        allow_blank=True,
        max_length=50  # Match model field length
    )
    
    class Meta:
        model = StudentProfile
        fields = [
            'user_id',
            'phone',
            'gender',
            'date_of_birth',
            'state',
            'district',
            'place',
            'address',
            'current_level',
            'education_level',  # Alias
            'stream',
            'career_goals',
            'interests',
        ]
        extra_kwargs = {
            'current_level': {'max_length': 50},  # Match model
        }
```

### Step 3: Create & Run Migration

```bash
# Create migration
python manage.py makemigrations

# Output should show:
# Migrations for 'users':
#   users/migrations/000X_increase_current_level_length.py
#     - Alter field current_level on studentprofile

# Apply migration
python manage.py migrate

# Output should show:
# Running migrations:
#   Applying users.000X_increase_current_level_length... OK
```

### Step 4: Test Locally

```bash
python manage.py runserver
```

**Test with cURL:**
```bash
curl -X PATCH http://localhost:8000/api/student/profile/ \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "education_level": "Undergraduate",
    "stream": "Science",
    "interests": ["Technology"],
    "career_goals": "To be techy"
  }'
```

**Expected response:**
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "user": {
    "current_level": "Undergraduate",
    ...
  }
}
```

### Step 5: Deploy to Render

```bash
git add .
git commit -m "Increase current_level field length to 50 characters"
git push origin main
```

**Wait 2-3 minutes for deployment**

Render will:
1. Pull new code
2. Run `python manage.py migrate` automatically
3. Restart the server

### Step 6: Verify Deployment

Check Render logs for:
```
Running migrations:
  Applying users.000X_increase_current_level_length... OK
```

## 🧪 Test in Flutter App

After backend is deployed:

1. **Register new account**
2. **Onboarding screen** appears
3. **Select "Undergraduate"** from dropdown
4. Fill other fields
5. **Tap "Continue"**

**Expected terminal output:**
```
🛠️ Setting up profile: {education_level: Undergraduate, ...}
🔧 Profile setup endpoint: https://bridgeit-backend.onrender.com/api/student/profile/
📦 Profile setup data: {education_level: Undergraduate, ...}
📡 Profile setup response status: 200
📄 Profile setup response body: {"success": true, ...}
✅ Profile setup successful
```

## 📊 Field Length Requirements

| Field | Current | Required | Recommended |
|-------|---------|----------|-------------|
| current_level | 10 | 13 ("Undergraduate") | 50 |
| stream | 100 | 10-20 | 100 ✅ |
| phone | 15 | 10 | 15 ✅ |
| state | 100 | 20-30 | 100 ✅ |
| district | 100 | 20-30 | 100 ✅ |

## ✅ Summary

**Issue:** `current_level` field limited to 10 chars, but "Undergraduate" = 13 chars

**Fix:**
1. ✅ Update model: `max_length=10` → `max_length=50`
2. ✅ Run migrations
3. ✅ Add serializer alias (`education_level` → `current_level`)
4. ✅ Deploy to Render
5. ✅ Test onboarding

**After fix, onboarding will work perfectly!** 🚀

# Name Field "Student" Issue - Backend Fix

## 🐛 Issue

Profile Settings screen shows **"Student"** instead of the user's actual name that was entered during registration.

## 🔍 Root Cause

**Flutter correctly sends the name during registration:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123"
}
```

**But when fetching profile, backend returns:**
```json
{
  "name": null,  // ❌ Should be "John Doe"
  "email": "john@example.com"
}
```

**The backend is not saving or returning the `name` field properly.**

## ✅ Backend Fix Required

### Fix 1: Ensure Registration Saves Name

**File:** `users/views.py` or `auth/views.py`

```python
@api_view(['POST'])
def register(request):
    try:
        data = request.data
        
        # Create user
        user = User.objects.create_user(
            username=data.get('email'),
            email=data.get('email'),
            password=data.get('password'),
            # IMPORTANT: Save the name!
            first_name=data.get('name', ''),  # Option 1: Use first_name field
            # OR if you have custom name field:
            # name=data.get('name', ''),  # Option 2: Use custom name field
        )
        
        # ... rest of registration logic
```

### Fix 2: Ensure Profile Fetch Returns Name

**File:** `users/serializers.py`

```python
class UserProfileSerializer(serializers.ModelSerializer):
    # If using first_name field
    name = serializers.CharField(source='first_name', required=False)
    
    # OR if you have custom name field in model
    # name = serializers.CharField(required=False)
    
    class Meta:
        model = User
        fields = [
            'id',
            'name',          # Make sure this is included!
            'email',
            'username',
            # ... other fields
        ]
```

### Fix 3: Update User Model (if needed)

**If you want a dedicated `name` field:**

**File:** `users/models.py`

```python
from django.contrib.auth.models import AbstractUser

class User(AbstractUser):
    name = models.CharField(max_length=255, blank=True, null=True)
    # ... other custom fields
    
    def save(self, *args, **kwargs):
        # Auto-populate first_name if name is provided
        if self.name and not self.first_name:
            self.first_name = self.name
        super().save(*args, **kwargs)
```

**Run migration:**
```bash
python manage.py makemigrations
python manage.py migrate
```

## 🧪 Testing After Backend Fix

### 1. Test Registration

```bash
curl -X POST https://bridgeit-backend.onrender.com/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "Test@1234",
    "confirm_password": "Test@1234"
  }'
```

**Expected:**
```json
{
  "success": true,
  "access": "...",
  "user_id": 1
}
```

### 2. Test Profile Fetch

```bash
curl -X GET https://bridgeit-backend.onrender.com/api/student/profile/ \
  -H "Authorization: Bearer ACCESS_TOKEN"
```

**Expected (Should include name):**
```json
{
  "success": true,
  "user": {
    "id": 1,
    "name": "John Doe",  // ✅ Should be present!
    "email": "john@example.com"
  }
}
```

## 📊 Current vs Expected Flow

### Current (Broken) Flow:
```
Registration:
  Flutter sends: {name: "John Doe", email: ...}
      ↓
  Backend receives name but doesn't save it ❌
      ↓
  Database: name = null

Profile Fetch:
  Backend queries user
      ↓
  Database returns: name = null
      ↓
  Flutter receives: {name: null}
      ↓
  Displays fallback: "Student" ❌
```

### Expected (Fixed) Flow:
```
Registration:
  Flutter sends: {name: "John Doe", email: ...}
      ↓
  Backend saves name to database ✅
      ↓
  Database: name = "John Doe"

Profile Fetch:
  Backend queries user
      ↓
  Database returns: name = "John Doe"
      ↓
  Flutter receives: {name: "John Doe"}
      ↓
  Displays: "John Doe" ✅
```

## 🔧 Quick Diagnostic

**Check your Django shell:**

```bash
python manage.py shell
```

```python
from users.models import User

# Get last registered user
user = User.objects.last()

print(f"Username: {user.username}")
print(f"Email: {user.email}")
print(f"Name: {user.name if hasattr(user, 'name') else 'NO NAME FIELD'}")
print(f"First Name: {user.first_name}")

# If name is empty, manually set it
if not user.first_name:
    user.first_name = "John Doe"
    user.save()
    print("✅ Name updated!")
```

## ✅ Summary

**Problem:** Backend doesn't save/return name field

**Solution:** Update backend to:
1. ✅ Save `name` during registration
2. ✅ Return `name` in profile fetch
3. ✅ Add `name` field to User model (if needed)
4. ✅ Include `name` in serializer

**Action Required:**
1. Check registration view - ensure it saves `name`
2. Check serializer - ensure it includes `name`
3. Test with cURL
4. Deploy to Render

Once fixed, Profile Settings will show the actual user's name! 🚀

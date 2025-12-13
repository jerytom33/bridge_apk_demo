# Backend Implementation for Profile Update

## 🎯 Complete Backend Solution

The Flutter app is trying to call `PATCH /api/student/profile/` but it doesn't exist. Here's exactly what to add to your Django backend:

---

## Step 1: Update Student Model (if needed)

**File:** `student_gateway/models.py` or wherever your Student model is

Make sure the Student/User model has these fields:

```python
from django.db import models
from django.contrib.auth.models import AbstractUser

class Student(AbstractUser):
    # Basic fields
    name = models.CharField(max_length=255, null=True, blank=True)
    phone = models.CharField(max_length=15, null=True, blank=True)
    dob = models.DateField(null=True, blank=True)
    address = models.TextField(null=True, blank=True)
    place = models.CharField(max_length=100, null=True, blank=True)
    
    # Education fields
    current_level = models.CharField(max_length=50, null=True, blank=True)
    stream = models.CharField(max_length=100, null=True, blank=True)
    career_goals = models.TextField(null=True, blank=True)
    interests = models.JSONField(default=list, null=True, blank=True)
    
    # Other fields...
    
    def __str__(self):
        return self.email or self.username
```

**Run migrations after updating:**
```bash
python manage.py makemigrations
python manage.py migrate
```

---

## Step 2: Create/Update Serializer

**File:** `student_gateway/serializers.py`

```python
from rest_framework import serializers
from .models import Student

class StudentProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = Student
        fields = [
            'id',
            'name',
            'email',
            'phone',
            'dob',
            'address',
            'place',
            'current_level',
            'stream',
            'career_goals',
            'interests',
        ]
        read_only_fields = ['id']
    
    def validate_email(self, value):
        """Ensure email is unique (except for current user)"""
        user = self.context['request'].user
        if Student.objects.filter(email=value).exclude(id=user.id).exists():
            raise serializers.ValidationError("Email already in use")
        return value
    
    def validate_phone(self, value):
        """Validate phone number format"""
        if value and not value.isdigit():
            raise serializers.ValidationError("Phone number must contain only digits")
        if value and len(value) != 10:
            raise serializers.ValidationError("Phone number must be 10 digits")
        return value
```

---

## Step 3: Create View

**File:** `student_gateway/views.py`

```python
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from .serializers import StudentProfileSerializer

@api_view(['GET', 'PATCH'])
@permission_classes([IsAuthenticated])
def student_profile(request):
    """
    GET: Retrieve current user's profile
    PATCH: Update current user's profile
    """
    user = request.user
    
    if request.method == 'GET':
        # Return current profile
        serializer = StudentProfileSerializer(user)
        return Response({
            'success': True,
            'user': serializer.data
        })
    
    elif request.method == 'PATCH':
        # Update profile
        serializer = StudentProfileSerializer(
            user, 
            data=request.data, 
            partial=True,  # Allow partial updates
            context={'request': request}
        )
        
        if serializer.is_valid():
            # Save updated data
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

---

## Step 4: Add URL Route

**File:** `student_gateway/urls.py`

```python
from django.urls import path
from . import views

urlpatterns = [
    # ... your existing URLs
    
    # Profile endpoints
    path('profile/', views.student_profile, name='student_profile'),
    
    # ... other URLs
]
```

---

## Step 5: Update Main URLs (if needed)

**File:** `your_project/urls.py` (main project urls)

Make sure student_gateway URLs are included:

```python
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/student/', include('student_gateway.urls')),  # This line
    # ... other paths
]
```

---

## 🧪 Testing the Backend

### Using cURL:

```bash
# Get profile
curl -X GET https://bridgeit-backend.onrender.com/api/student/profile/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"

# Update profile
curl -X PATCH https://bridgeit-backend.onrender.com/api/student/profile/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "phone": "1234567890",
    "address": "123 Main St",
    "place": "New York",
    "current_level": "12th",
    "stream": "Science",
    "career_goals": "Software Engineer",
    "interests": ["coding", "music"]
  }'
```

### Expected Response (Success):

```json
{
  "success": true,
  "message": "Profile updated successfully",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "1234567890",
    "dob": "2000-01-01",
    "address": "123 Main St",
    "place": "New York",
    "current_level": "12th",
    "stream": "Science",
    "career_goals": "Software Engineer",
    "interests": ["coding", "music"]
  }
}
```

### Expected Response (Error):

```json
{
  "success": false,
  "error": {
    "phone": ["Phone number must be 10 digits"],
    "email": ["Email already in use"]
  }
}
```

---

## 📝 Complete File Structure

```
your_django_project/
├── student_gateway/
│   ├── models.py          # Student model with all fields
│   ├── serializers.py     # StudentProfileSerializer
│   ├── views.py           # student_profile view
│   └── urls.py            # URL routing
└── your_project/
    └── urls.py            # Include student_gateway.urls
```

---

## 🔄 Deployment Steps

### For Render.com:

1. **Commit and push** the changes:
```bash
git add .
git commit -m "Add student profile update endpoint"
git push origin main
```

2. **Render will auto-deploy** (wait 2-3 minutes)

3. **Verify deployment:**
   - Check Render dashboard for "Live" status
   - Check logs for any errors

### For Local Testing:

```bash
# Run migrations
python manage.py makemigrations
python manage.py migrate

# Start server
python manage.py runserver 0.0.0.0:8000
```

---

## ✅ Verification Checklist

After deploying:

- [ ] Backend deployed successfully
- [ ] Migrations applied
- [ ] Endpoint accessible: `GET /api/student/profile/`
- [ ] Endpoint accessible: `PATCH /api/student/profile/`
- [ ] Authentication working (Bearer token)
- [ ] Validation working (phone, email)
- [ ] Data saving to database
- [ ] Flutter app can update profile

---

## 🎯 Summary of What to Add

1. ✅ **Add fields to Student model** (if missing)
2. ✅ **Create StudentProfileSerializer** in `serializers.py`
3. ✅ **Create student_profile view** in `views.py`
4. ✅ **Add URL route** in `student_gateway/urls.py`
5. ✅ **Run migrations** (`makemigrations` + `migrate`)
6. ✅ **Deploy to Render** (git push)
7. ✅ **Test with Flutter app**

Once you add this code and deploy, the profile update will work! 🚀

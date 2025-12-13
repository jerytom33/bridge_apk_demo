# Registration 500 Error - Backend Debugging Guide

## 🐛 Issue

Registration fails with HTTP 500 Server Error:
```
I/flutter: REGISTER → 500
I/flutter: Response body: <!doctype html><html>...Server Error (500)</html>
```

## 📤 What Flutter Sends

**Endpoint:** `POST /api/auth/register/`

**Request Body:**
```json
{
  "name": "User Name",
  "email": "user@example.com",
  "password": "password123",
  "confirm_password": "password123"
}
```

**Headers:**
```
Content-Type: application/json
```

## 🔍 Backend Debugging Steps

### Step 1: Check Backend Logs

**On Render:**
1. Go to Render Dashboard
2. Select your backend service
3. Click "Logs" tab
4. Look for the error traceback when registration is attempted

**Locally:**
```bash
python manage.py runserver
# Watch terminal for error traceback
```

### Step 2: Common Causes of 500 Error

#### Cause 1: Missing Fields in User Model
```python
# Backend expects fields that don't exist
# Check users/models.py - User/Student model must have 'name' field
```

#### Cause 2: Database Constraints
```python
# Unique constraint violations
# Required fields missing
# Check model definitions
```

#### Cause 3: Signal Errors
```python
# If you have post_save signals for User creation
# They might be failing
# Check users/signals.py or apps.py
```

#### Cause 4: Serializer Issues
```python
# Serializer validation failing
# Check users/serializers.py
```

### Step 3: Test Registration Directly

**Using cURL:**
```bash
curl -X POST https://bridgeit-backend.onrender.com/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "Test@1234",
    "confirm_password": "Test@1234"
  }'
```

**Expected Success Response:**
```json
{
  "success": true,
  "message": "User registered successfully",
  "access": "eyJ0e...",
  "refresh": "eyJ0e...",
  "user_id": 1
}
```

## 🔧 Backend Fix Checklist

### Fix 1: Ensure User Model Has 'name' Field

**File:** `users/models.py`

```python
from django.contrib.auth.models import AbstractUser

class User(AbstractUser):
    # MUST have 'name' field or handle it in serializer
    name = models.CharField(max_length=255, blank=True, null=True)
    # ... other fields
```

**If you added 'name' field, run:**
```bash
python manage.py makemigrations
python manage.py migrate
```

### Fix 2: Check Registration View

**File:** `users/views.py` or `auth/views.py`

```python
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status

@api_view(['POST'])
def register(request):
    try:
        data = request.data
        
        # Validate required fields
        if not data.get('email') or not data.get('password'):
            return Response({
                'success': False,
                'error': 'Email and password are required'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Check password confirmation
        if data.get('password') != data.get('confirm_password'):
            return Response({
                'success': False,
                'error': 'Passwords do not match'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Create user
        user = User.objects.create_user(
            username=data.get('email'),  # or generate username
            email=data.get('email'),
            password=data.get('password'),
            name=data.get('name', ''),  # Handle optional name
        )
        
        # Generate tokens
        from rest_framework_simplejwt.tokens import RefreshToken
        refresh = RefreshToken.for_user(user)
        
        return Response({
            'success': True,
            'message': 'User registered successfully',
            'access': str(refresh.access_token),
            'refresh': str(refresh),
            'user_id': user.id
        }, status=status.HTTP_201_CREATED)
        
    except Exception as e:
        # Log the error
        import logging
        logger = logging.getLogger(__name__)
        logger.error(f"Registration error: {str(e)}")
        
        return Response({
            'success': False,
            'error': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
```

### Fix 3: Add Error Logging

**File:** `settings.py`

```python
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
        },
    },
    'loggers': {
        'django': {
            'handlers': ['console'],
            'level': 'DEBUG',
        },
    },
}
```

### Fix 4: Check for Unique Constraints

```python
# If email already exists
try:
    if User.objects.filter(email=data.get('email')).exists():
        return Response({
            'success': False,
            'error': 'Email already registered'
        }, status=status.HTTP_400_BAD_REQUEST)
except Exception as e:
    # Database error
    pass
```

## 📊 Testing After Fix

1. **Deploy fix to Render:**
```bash
git add .
git commit -m "Fix registration 500 error"
git push origin main
```

2. **Wait 2-3 minutes** for deployment

3. **Check Render logs** for any startup errors

4. **Test registration** in Flutter app

5. **Check terminal output:**
```
REGISTER → 201
Response body: {"success": true, ...}
```

## 🎯 Quick Debug Checklist

- [ ] Backend logs show the error traceback
- [ ] User model has 'name' field (or handle it)
- [ ] No unique constraint violations
- [ ] Registration view has try/catch
- [ ] Email validation working
- [ ] Password confirmation logic correct
- [ ] Token generation working
- [ ] No signal errors
- [ ] Migrations applied
- [ ] Backend deployed to Render

## 🚨 Temporary Workaround

If you need to test other features while fixing this:

**Use an already registered account** to login and skip registration.

## 📝 Expected Backend Response Structure

**Success (201):**
```json
{
  "success": true,
  "message": "User registered successfully",
  "access": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "user_id": 1
}
```

**Error (400/500):**
```json
{
  "success": false,
  "error": "Detailed error message"
}
```

## 🔄 Next Steps

1. **Check Render logs** to see the exact error
2. **Apply the appropriate fix** from above
3. **Test locally** before deploying
4. **Deploy to Render**
5. **Test in Flutter app**

Share the **backend error traceback** from Render logs for specific guidance!

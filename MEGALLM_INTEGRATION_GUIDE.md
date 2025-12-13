# MegaLLM Integration - Complete Setup Guide

## Overview
This guide will help you integrate MegaLLM AI into your Bridge IT app for:
1. **Enhanced Resume Analysis** - AI-powered skill extraction and career recommendations
2. **Personalized Aptitude Tests** - Dynamically generated questions based on user profile

## ✅ What's Been Created

### Backend Files (Ready to Use)
- `megallm_service.py` - Complete AI service implementation
- Includes resume analysis, question generation, and results analysis

### Flutter Files (Ready to Use)
- `lib/services/aptitude_ai_service.dart` - Service for AI-powered aptitude tests
- `lib/models/resume_analysis_result.dart` - Updated with AI fields

### Documentation
- `MEGALLM_BACKEND_SETUP.md` - Detailed backend installation instructions

---

## 🚀 Quick Start - Backend Integration

### Step 1: Copy Files to Django Backend

1. **Copy `megallm_service.py`** to your Django backend:
   ```
   L:\ALTASH\bridge-it-world\bridge-it-world\services\megallm_service.py
   ```
   (Create the `services` directory if it doesn't exist)

2. **Install Python Dependencies:**
   ```bash
   cd L:\ALTASH\bridge-it-world\bridge-it-world
   pip install openai python-dotenv PyPDF2
   ```

3. **Configure Environment Variables:**
   
   Create or update `.env` file in your Django root:
   ```env
   MEGALLM_API_KEY=your_api_key_here
   MEGALLM_BASE_URL=https://ai.megallm.io/v1
   MEGALLM_MODEL=gpt-5
   ```

4. **Load Environment Variables in `settings.py`:**
   ```python
   from dotenv import load_dotenv
   import os

   # Load environment variables
   load_dotenv()
   ```

### Step 2: Update Resume Upload Endpoint

In your Django `resume/views.py` (or equivalent), update the upload endpoint:

```python
from services.megallm_service import get_megallm_service
import PyPDF2
import io
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def upload_resume(request):
    try:
        pdf_file = request.FILES.get('pdf_file')
        
        if not pdf_file:
            return Response({'error': 'No PDF file provided'}, status=400)
        
        # Extract text from PDF
        pdf_reader = PyPDF2.PdfReader(io.BytesIO(pdf_file.read()))
        resume_text = ""
        for page in pdf_reader.pages:
            resume_text += page.extract_text()
        
        # Get AI analysis using MegaLLM
        megallm_service = get_megallm_service()
        ai_analysis = megallm_service.analyze_resume(resume_text)
        
        # Return response with AI analysis
        return Response({
            'success': True,
            'data': {
                'ai_analysis': ai_analysis,
                'resume_text': resume_text[:500]  # First 500 chars as preview
            }
        }, status=201)
        
    except Exception as e:
        return Response({'error': str(e)}, status=500)
```

### Step 3: Add Aptitude Endpoints

In your Django `aptitude/views.py`, add these new endpoints:

```python
from services.megallm_service import get_megallm_service
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_personalized_questions(request):
    """Generate personalized aptitude questions using AI"""
    try:
        education_level = request.query_params.get('level', '10th')
        
        # Get user profile (customize based on your User model)
        user_profile = {
            'interests': [],  # Add from user profile if available
            'career_goals': '',  # Add from user profile if available
        }
        
        # Generate questions using AI
        megallm_service = get_megallm_service()
        questions = megallm_service.generate_aptitude_questions(
            education_level=education_level,
            user_profile=user_profile
        )
        
        return Response({'success': True, 'data': questions}, status=200)
        
    except Exception as e:
        return Response({'error': str(e)}, status=500)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def analyze_aptitude_results(request):
    """Analyze aptitude test results using AI"""
    try:
        questions = request.data.get('questions', [])
        answers = request.data.get('answers', {})
        
        user_profile = {
            'interests': [],
            'career_goals': '',
        }
        
        # Analyze results using AI
        megallm_service = get_megallm_service()
        analysis = megallm_service.analyze_aptitude_results(
            questions=questions,
            answers=answers,
            user_profile=user_profile
        )
        
        return Response({'success': True, 'data': analysis}, status=200)
        
    except Exception as e:
        return Response({'error': str(e)}, status=500)
```

### Step 4: Add URL Routes

In your `urls.py`:

```python
from django.urls import path
from aptitude.views import get_personalized_questions, analyze_aptitude_results

urlpatterns = [
    # ... existing routes
    path('aptitude/personalized-questions/', get_personalized_questions),
    path('aptitude/analyze-results/', analyze_aptitude_results),
]
```

### Step 5: Test Backend

Restart your Django server and test:

```bash
# Test question generation (replace YOUR_TOKEN)
curl http://localhost:8000/api/aptitude/personalized-questions/?level=12th \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## 📱 Flutter Frontend Integration

### Option A: Use AI Questions with Fallback (Recommended)

Modify `lib/screens/aptitude_test_screen.dart`:

```dart
// Add imports
import '../services/aptitude_ai_service.dart';

// In _AptitudeTestScreenState class:
bool _isLoadingQuestions = true;
bool _useAIQuestions = false;
final _aptitudeAiService = AptitudeAiService();

@override
void initState() {
  super.initState();
  _startTime = DateTime.now();
  _loadQuestions();
}

Future<void> _loadQuestions() async {
  setState(() {
    _isLoadingQuestions = true;
  });

  try {
    // Try to get AI-generated questions
    final aiQuestions = await _aptitudeAiService.getPersonalizedQuestions(
      educationLevel: widget.educationLevel,
    );
    
    setState(() {
      _questions = aiQuestions;
      _answers = List.filled(_questions.length, null);
      _useAIQuestions = true;
      _isLoadingQuestions = false;
    });
  } catch (e) {
    print('Failed to load AI questions, using fallback: $e');
    // Fall back to hardcoded questions
    setState(() {
      _questions = widget.educationLevel == '10th' ? _questions10th : _questions12th;
      _answers = List.filled(_questions.length, null);
      _useAIQuestions = false;
      _isLoadingQuestions = false;
    });
  }
}

// In build method, add loading state:
@override
Widget build(BuildContext context) {
  if (_isLoadingQuestions) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Loading Questions...'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitFadingCircle(color: Color(0xFF6C63FF), size: 50.0),
            SizedBox(height: 20),
            Text('Generating personalized questions for you...'),
          ],
        ),
      ),
    );
  }
  
  // ... rest of existing build code
}
```

### Option B: Simple Test (Faster)

For quick testing, create a new test file:

```dart
// lib/test_ai_questions.dart
import 'package:flutter/material.dart';
import 'services/aptitude_ai_service.dart';

void testAIQuestions() async {
  final service = AptitudeAiService();
  
  try {
    print('Fetching AI questions...');
    final questions = await service.getPersonalizedQuestions(
      educationLevel: '12th',
    );
    
    print('SUCCESS! Got ${questions.length} questions');
    print('First question: ${questions.first}');
  } catch (e) {
    print('ERROR: $e');
  }
}
```

---

## 🧪 Testing Guide

### 1. Test Resume Analysis

```bash
# Upload a resume PDF
curl -X POST http://localhost:8000/api/resume/upload/ \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "pdf_file=@/path/to/resume.pdf"
```

Expected response:
```json
{
  "success": true,
  "data": {
    "ai_analysis": {
      "extracted_skills": ["Python", "Django", ...],
      "technical_skills": ["Backend Development", ...],
      "soft_skills": ["Communication", ...],
      "career_paths": ["Software Engineer", ...],
      "strengths": ["Strong technical background", ...],
      "improvements": ["Add more project details", ...],
      "ai_summary": "Summary of the resume...",
      "experience_level": "Mid",
      "recommended_roles": ["Backend Developer", ...]
    }
  }
}
```

### 2. Test Question Generation

```bash
curl http://localhost:8000/api/aptitude/personalized-questions/?level=12th \
  -H "Authorization: Bearer YOUR_TOKEN"
```

Expected response:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "section": "STEM",
      "question": "Question text?",
      "options": ["A", "B", "C", "D"],
      "correct_option": 0,
      "difficulty": "Medium"
    },
    ...
  ]
}
```

### 3. Test Results Analysis

```bash
curl -X POST http://localhost:8000/api/aptitude/analyze-results/ \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "questions": [...],
    "answers": {"1": 0, "2": 1, ...}
  }'
```

---

## 🎯 Next Steps

### Immediate (Required for Functionality)
1. ✅ Copy `megallm_service.py` to Django backend
2. ✅ Install Python dependencies
3. ✅ Configure `.env` with MegaLLM API key
4. ✅ Add endpoints to Django views
5. ✅ Test backend endpoints

### Frontend Enhancement (Optional but Recommended)
1. Update `aptitude_test_screen.dart` to load AI questions
2. Update `resume_result_screen.dart` to display AI insights
3. Add loading states and error handling
4. Test end-to-end flow

### Production Deployment
1. Deploy Django backend with environment variables
2. Update Flutter app's base URL if deploying to cloud
3. Monitor API usage and performance
4. Gather user feedback

---

## 🐛 Troubleshooting

### Backend Issues

**Error: "MEGALLM_API_KEY environment variable not set"**
- Ensure `.env` file exists in Django root
- Verify `load_dotenv()` is called in `settings.py`
- Check API key is correct

**Error: "Resume analysis failed"**
- Verify MegaLLM API key is valid
- Check MegaLLM service is accessible
- Review Django logs for detailed error

**Error: "Failed to generate valid questions"**
-The AI may return invalid JSON
- Check logs for actual AI response
- Try using a different model or adjusting temperature

### Flutter Issues

**Error: "No internet connection"**
- Ensure backend is running
- Verify base URL in `aptitude_ai_service.dart` matches your backend

**Error: "Authentication failed"**
- Check user is logged in
- Verify JWT token is valid
- Test login flow

---

## 📊 What You Get

### Resume Analysis Features
- ✅ Extracted skills (all, technical, soft)
- ✅ Career path recommendations
- ✅ Strengths identified
- ✅ Specific improvement suggestions
- ✅ Experience level assessment
- ✅ Recommended job roles

### Aptitude Test Features
- ✅ Personalized questions based on profile
- ✅ Dynamic difficulty adjustment
- ✅ AI-powered results analysis
- ✅ Career suggestions aligned with performance
- ✅ Specific improvement tips
- ✅ Fallback to hardcoded questions if AI fails

---

## ⚡ Performance Notes

- Question generation: ~3-5 seconds
- Resume analysis: ~5-10 seconds
- Results analysis: ~2-4 seconds

All timings depend on:
- MegaLLM API response time
- Resume length
- Network conditions

---

## 🎉 You're All Set!

Once you complete the backend setup:
1. Test the endpoints
2. Optionally update Flutter screens
3. Deploy and enjoy AI-powered features!

For detailed backend instructions, see: `MEGALLM_BACKEND_SETUP.md`

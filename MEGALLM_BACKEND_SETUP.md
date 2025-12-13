# MegaLLM Integration - Backend Files

This directory contains the files needed to integrate MegaLLM into your Django backend.

## Installation Steps

### 1. Install Required Dependencies

Add to your `requirements.txt`:
```
openai>=1.0.0
python-dotenv>=1.0.0
PyPDF2>=3.0.0
```

Then install:
```bash
pip install openai python-dotenv PyPDF2
```

### 2. Configure Environment Variables

Add to your `.env` file (create if it doesn't exist):
```
MEGALLM_API_KEY=your_api_key_here
MEGALLM_BASE_URL=https://ai.megallm.io/v1
MEGALLM_MODEL=gpt-5
```

### 3. Copy Service Files

Copy the following files to your Django backend:

- `megallm_service.py` → Place in a `services/` directory (create if doesn't exist)
- Or place it directly in your main app directory

### 4. Update Django Settings

In your `settings.py`, ensure you load environment variables:

```python
from dotenv import load_dotenv
import os

# Load environment variables
load_dotenv()

# You can access them like:
# MEGALLM_API_KEY = os.getenv('MEGALLM_API_KEY')
```

### 5. Update Resume API Endpoint

In your `resume/views.py` (or wherever your resume upload endpoint is):

```python
from services.megallm_service import get_megallm_service
import PyPDF2
import io

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
        
        # Save to database (your existing model)
        resume_analysis = ResumeAnalysis.objects.create(
            user=request.user,
            pdf_file=pdf_file,
            resume_text=resume_text,
            extracted_skills=ai_analysis.get('extracted_skills', []),
            technical_skills=ai_analysis.get('technical_skills', []),
            soft_skills=ai_analysis.get('soft_skills', []),
            career_paths=ai_analysis.get('career_paths', []),
            strengths=ai_analysis.get('strengths', []),
            improvements=ai_analysis.get('improvements', []),
            ai_summary=ai_analysis.get('ai_summary', ''),
            experience_level=ai_analysis.get('experience_level', ''),
            recommended_roles=ai_analysis.get('recommended_roles', [])
        )
        
        return Response({
            'success': True,
            'data': {
                'id': resume_analysis.id,
                'ai_analysis': ai_analysis,
                'created_at': resume_analysis.created_at
            }
        }, status=201)
        
    except Exception as e:
        return Response({
            'error': str(e)
        }, status=500)
```

### 6. Update Resume Model

Add these fields to your `ResumeAnalysis` model:

```python
from django.db import models
from django.contrib.auth.models import User

class ResumeAnalysis(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    pdf_file = models.FileField(upload_to='resumes/')
    resume_text = models.TextField()
    
    # AI Analysis Fields
    extracted_skills = models.JSONField(default=list)
    technical_skills = models.JSONField(default=list)
    soft_skills = models.JSONField(default=list)
    career_paths = models.JSONField(default=list)
    strengths = models.JSONField(default=list)
    improvements = models.JSONField(default=list)
    ai_summary = models.TextField(blank=True)
    experience_level = models.CharField(max_length=50, blank=True)
    recommended_roles = models.JSONField(default=list)
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-created_at']
```

Run migrations:
```bash
python manage.py makemigrations
python manage.py migrate
```

### 7. Add Aptitude Question Generation Endpoint

In your `aptitude/views.py`:

```python
from services.megallm_service import get_megallm_service

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_personalized_questions(request):
    try:
        education_level = request.query_params.get('level', '10th')
        
        # Get user profile
        user_profile = {
            'interests': request.user.profile.interests if hasattr(request.user, 'profile') else [],
            'career_goals': request.user.profile.career_goals if hasattr(request.user, 'profile') else '',
        }
        
        # Generate questions using AI
        megallm_service = get_megallm_service()
        questions = megallm_service.generate_aptitude_questions(
            education_level=education_level,
            user_profile=user_profile
        )
        
        return Response({
            'success': True,
            'data': questions
        }, status=200)
        
    except Exception as e:
        return Response({
            'error': str(e)
        }, status=500)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def analyze_aptitude_results(request):
    try:
        questions = request.data.get('questions', [])
        answers = request.data.get('answers', {})
        
        user_profile = {
            'interests': request.user.profile.interests if hasattr(request.user, 'profile') else [],
            'career_goals': request.user.profile.career_goals if hasattr(request.user, 'profile') else '',
        }
        
        # Analyze results using AI
        megallm_service = get_megallm_service()
        analysis = megallm_service.analyze_aptitude_results(
            questions=questions,
            answers=answers,
            user_profile=user_profile
        )
        
        return Response({
            'success': True,
            'data': analysis
        }, status=200)
        
    except Exception as e:
        return Response({
            'error': str(e)
        }, status=500)
```

### 8. Add URL Routes

In your `urls.py`:

```python
from django.urls import path
from .views import (
    upload_resume,
    get_personalized_questions,
    analyze_aptitude_results
)

urlpatterns = [
    # Resume
    path('resume/upload/', upload_resume, name='resume_upload'),
    
    # Aptitude
    path('aptitude/personalized-questions/', get_personalized_questions, name='personalized_questions'),
    path('aptitude/analyze-results/', analyze_aptitude_results, name='analyze_results'),
]
```

## Testing

Test the integration:

```bash
# Test resume upload (replace with your auth token)
curl -X POST http://localhost:8000/api/resume/upload/ \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "pdf_file=@/path/to/resume.pdf"

# Test question generation
curl http://localhost:8000/api/aptitude/personalized-questions/?level=12th \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## Troubleshooting

**Error: "MEGALLM_API_KEY environment variable not set"**
- Ensure `.env` file exists and contains the API key
- Make sure `python-dotenv` is installed
- Verify `load_dotenv()` is called in `settings.py`

**Error: "Resume analysis failed"**
- Check MegaLLM API key is valid
- Verify the base URL is correct
- Check logs for detailed error messages

**Error: "Failed to generate valid questions"**
- The AI response may not be in expected JSON format
- Check logs for the actual response
- Try reducing the number of questions or simplifying the prompt

## Next Steps

After backend integration is complete:
1. Update Flutter app to use new endpoints
2. Update Dart models to handle new AI fields
3. Update UI to display AI insights

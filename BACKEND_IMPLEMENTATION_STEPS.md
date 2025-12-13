# MegaLLM Backend Implementation Steps

Run these commands in your Django backend directory to complete the integration.

## Quick Setup (Automated)

```powershell
# Navigate to Django backend
cd L:\ALTASH\bridge-it-world\bridge-it-world

# Activate virtual environment (if not already activated)
& l:/ALTASH/bridge-it-world/bridge-it-world/venv_py312/Scripts/Activate.ps1

# Run setup script
& L:\ALTASH\bridge_apk_demo\setup_megallm_backend.ps1
```

---

## Manual Setup (If you prefer step-by-step)

### 1. Install Dependencies

```powershell
pip install openai python-dotenv PyPDF2 pdfplumber
```

### 2. Create Services Directory

```powershell
mkdir services
New-Item -ItemType File -Path services\__init__.py
```

### 3. Copy MegaLLM Service

```powershell
Copy-Item -Path "L:\ALTASH\bridge_apk_demo\megallm_service.py" -Destination "services\megallm_service.py"
```

### 4. Configure Environment Variables

Create `.env` file in Django root (or update existing):

```env
MEGALLM_API_KEY=your_api_key_here
MEGALLM_BASE_URL=https://ai.megallm.io/v1
MEGALLM_MODEL=gpt-5
```

### 5. Update Django Settings

In `settings.py`, add at the top:

```python
from dotenv import load_dotenv
load_dotenv()
```

### 6. Test MegaLLM Service

```powershell
python manage.py shell
```

Then in the Python shell:

```python
from services.megallm_service import get_megallm_service

# Test initialization
service = get_megallm_service()
print("✅ Service initialized!")

# Test resume analysis
result = service.analyze_resume("Software Engineer with Python and Django experience")
print(result['extracted_skills'])
```

---

## Adding Django Endpoints

### Option 1: Find and Update Existing Files

Look for these files in your Django backend:
- `resume/views.py` or `resume_app/views.py`
- `aptitude/views.py` or `aptitude_app/views.py`

### Option 2: Quick File Finder

```powershell
# Find resume-related files
Get-ChildItem -Recurse -Filter "*resume*" -File | Where-Object { $_.Extension -eq ".py" }

# Find aptitude-related files
Get-ChildItem -Recurse -Filter "*aptitude*" -File | Where-Object { $_.Extension -eq ".py" }
```

### Update Resume Upload View

Find your resume upload view and update it:

```python
from services.megallm_service import get_megallm_service
import PyPDF2
import io

# In your upload view function
def upload_resume(request):
    # ... existing code to handle file upload ...
    
    # Extract text from PDF
    pdf_reader = PyPDF2.PdfReader(io.BytesIO(pdf_file.read()))
    resume_text = ""
    for page in pdf_reader.pages:
        resume_text += page.extract_text()
    
    # Get AI analysis
    megallm_service = get_megallm_service()
    ai_analysis = megallm_service.analyze_resume(resume_text)
    
    # Return in response
    return JsonResponse({
        'success': True,
        'data': {
            'ai_analysis': ai_analysis,
            # ... other data ...
        }
    })
```

### Add Aptitude Endpoints

Create or update `aptitude/views.py`:

```python
from services.megallm_service import get_megallm_service
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_personalized_questions(request):
    try:
        education_level = request.GET.get('level', '10th')
        
        megallm_service = get_megallm_service()
        questions = megallm_service.generate_aptitude_questions(
            education_level=education_level,
            user_profile={}
        )
        
        return Response({'success': True, 'data': questions})
    except Exception as e:
        return Response({'error': str(e)}, status=500)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def analyze_aptitude_results(request):
    try:
        questions = request.data.get('questions', [])
        answers = request.data.get('answers', {})
        
        megallm_service = get_megallm_service()
        analysis = megallm_service.analyze_aptitude_results(
            questions=questions,
            answers=answers,
            user_profile={}
        )
        
        return Response({'success': True, 'data': analysis})
    except Exception as e:
        return Response({'error': str(e)}, status=500)
```

### Add URL Routes

In your `urls.py`:

```python
from aptitude.views import get_personalized_questions, analyze_aptitude_results

urlpatterns = [
    # ... existing patterns ...
    path('api/aptitude/personalized-questions/', get_personalized_questions),
    path('api/aptitude/analyze-results/', analyze_aptitude_results),
]
```

---

## Testing

### 1. Start Django Server

```powershell
python manage.py runserver 0.0.0.0:8000
```

### 2. Test Endpoints with cURL

```powershell
# Get personalized questions (replace YOUR_TOKEN)
curl http://localhost:8000/api/aptitude/personalized-questions/?level=12th `
  -H "Authorization: Bearer YOUR_TOKEN"
```

### 3. Test from Flutter App

Run your Flutter app and:
1. Navigate to Aptitude Test
2. Select education level
3. Questions should load from AI
4. Complete test and verify AI analysis

---

## Troubleshooting

**Error: "No module named 'services'"**
```powershell
# Make sure services/__init__.py exists
Test-Path services\__init__.py
```

**Error: "MEGALLM_API_KEY not set"**
```powershell
# Verify .env file exists and has the key
Get-Content .env | Select-String "MEGALLM"
```

**Error: "Cannot import get_megallm_service"**
```powershell
# Check if file was copied correctly
Test-Path services\megallm_service.py
```

---

## Quick Commands Reference

```powershell
# Navigate to backend
cd L:\ALTASH\bridge-it-world\bridge-it-world

# Activate venv
& venv_py312/Scripts/Activate.ps1

# Install deps
pip install openai python-dotenv PyPDF2

# Test service
python manage.py shell
>>> from services.megallm_service import get_megallm_service
>>> service = get_megallm_service()

# Run server
python manage.py runserver 0.0.0.0:8000
```

---

## Next Steps After Backend is Working

1. ✅ Test all endpoints with Postman or cURL
2. ✅ Verify AI responses are correct
3. ✅ Test from Flutter app
4. ✅ Monitor Django logs for errors
5. ✅ Deploy to production

For more details, see: `MEGALLM_INTEGRATION_GUIDE.md`

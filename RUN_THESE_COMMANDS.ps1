# ============================================
# MEGALLM BACKEND SETUP - RUN THESE COMMANDS
# ============================================
# Copy and paste these commands into your PowerShell terminal
# Current directory should be: L:\ALTASH\bridge-it-world\bridge-it-world
# Virtual environment should be activated

# ============================================
# STEP 1: Install Dependencies
# ============================================
Write-Host "Installing Python dependencies..." -ForegroundColor Cyan
pip install openai python-dotenv PyPDF2 pdfplumber

# ============================================
# STEP 2: Create Services Directory
# ============================================
Write-Host "`nCreating services directory..." -ForegroundColor Cyan
if (-not (Test-Path "services")) {
    New-Item -ItemType Directory -Path "services"
    New-Item -ItemType File -Path "services\__init__.py"
    Write-Host "Created services/ directory" -ForegroundColor Green
}

# ============================================
# STEP 3: Copy MegaLLM Service File
# ============================================
Write-Host "`nCopying MegaLLM service..." -ForegroundColor Cyan
Copy-Item -Path "L:\ALTASH\bridge_apk_demo\megallm_service.py" -Destination "services\megallm_service.py" -Force
Write-Host "Copied megallm_service.py" -ForegroundColor Green

# ============================================
# STEP 4: Update/Create .env File
# ============================================
Write-Host "`nConfiguring environment variables..." -ForegroundColor Cyan

$envConfig = @"

# MegaLLM API Configuration
MEGALLM_API_KEY=sk-mega-51c1ea28e101197977ad76e5d4446be7fdc5d0e2f45a92060e4d82a8d4c51839
MEGALLM_BASE_URL=https://ai.megallm.io/v1
MEGALLM_MODEL=gpt-5
"@

Add-Content -Path ".env" -Value $envConfig
Write-Host "Updated .env file" -ForegroundColor Green

# ============================================
# STEP 5: Test MegaLLM Service
# ============================================
Write-Host "`nTesting MegaLLM service..." -ForegroundColor Cyan

python -c @"
from services.megallm_service import get_megallm_service
print('✅ MegaLLM service loaded successfully!')
service = get_megallm_service()
print('✅ Service initialized with API key')
"@

Write-Host "`n✅ SETUP COMPLETE!" -ForegroundColor Green
Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "1. Update Django views (see BACKEND_IMPLEMENTATION_STEPS.md)" -ForegroundColor White
Write-Host "2. Test with: python manage.py runserver" -ForegroundColor White

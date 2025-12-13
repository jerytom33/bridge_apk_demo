# MegaLLM Backend Setup Script
# Run this from your Django backend directory: L:\ALTASH\bridge-it-world\bridge-it-world

Write-Host "🚀 Setting up MegaLLM Integration..." -ForegroundColor Cyan

# Check if virtual environment is activated
if ($env:VIRTUAL_ENV) {
    Write-Host "✅ Virtual environment detected: $env:VIRTUAL_ENV" -ForegroundColor Green
} else {
    Write-Host "⚠️  Warning: Virtual environment not detected. Activate it first!" -ForegroundColor Yellow
    Write-Host "Run: & l:/ALTASH/bridge-it-world/bridge-it-world/venv_py312/Scripts/Activate.ps1" -ForegroundColor Yellow
    exit 1
}

# Step 1: Install dependencies
Write-Host "`n📦 Installing Python dependencies..." -ForegroundColor Cyan
pip install openai python-dotenv PyPDF2 pdfplumber

# Step 2: Create services directory if it doesn't exist
Write-Host "`n📁 Creating services directory..." -ForegroundColor Cyan
if (-not (Test-Path "services")) {
    New-Item -ItemType Directory -Path "services"
    Write-Host "✅ Created services directory" -ForegroundColor Green
} else {
    Write-Host "✅ Services directory already exists" -ForegroundColor Green
}

# Create __init__.py in services
if (-not (Test-Path "services\__init__.py")) {
    New-Item -ItemType File -Path "services\__init__.py"
    Write-Host "✅ Created services/__init__.py" -ForegroundColor Green
}

# Step 3: Copy megallm_service.py
Write-Host "`n📝 Copying MegaLLM service..." -ForegroundColor Cyan
$sourcePath = "L:\ALTASH\bridge_apk_demo\megallm_service.py"
$destPath = "services\megallm_service.py"

if (Test-Path $sourcePath) {
    Copy-Item -Path $sourcePath -Destination $destPath -Force
    Write-Host "✅ Copied megallm_service.py to services/" -ForegroundColor Green
} else {
    Write-Host "❌ Error: Source file not found at $sourcePath" -ForegroundColor Red
    exit 1
}

# Step 4: Create/Update .env file
Write-Host "`n🔐 Configuring environment variables..." -ForegroundColor Cyan
$envContent = @"
# MegaLLM API Configuration
MEGALLM_API_KEY=sk-mega-51c1ea28e101197977ad76e5d4446be7fdc5d0e2f45a92060e4d82a8d4c51839
MEGALLM_BASE_URL=https://ai.megallm.io/v1
MEGALLM_MODEL=gpt-5
"@

if (Test-Path ".env") {
    # Append to existing .env
    Add-Content -Path ".env" -Value "`n$envContent"
    Write-Host "✅ Updated .env file with MegaLLM config" -ForegroundColor Green
} else {
    # Create new .env
    Set-Content -Path ".env" -Value $envContent
    Write-Host "✅ Created .env file with MegaLLM config" -ForegroundColor Green
}

# Step 5: Test the service
Write-Host "`n🧪 Testing MegaLLM service..." -ForegroundColor Cyan
$testScript = @"
from services.megallm_service import get_megallm_service
print('Testing MegaLLM service...')
try:
    service = get_megallm_service()
    print('✅ MegaLLM service initialized successfully!')
except Exception as e:
    print(f'❌ Error: {e}')
"@

$testScript | python

Write-Host "`n✅ Setup complete!" -ForegroundColor Green
Write-Host "`n📋 Next steps:" -ForegroundColor Cyan
Write-Host "1. Update your Django views to use MegaLLM service" -ForegroundColor White
Write-Host "2. Add the API endpoints (see MEGALLM_INTEGRATION_GUIDE.md)" -ForegroundColor White
Write-Host "3. Test with: python manage.py runserver" -ForegroundColor White

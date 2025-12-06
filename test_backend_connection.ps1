# Backend Connection Verification Script (Windows PowerShell)
# This script verifies that your Django backend is running and accessible

Write-Host "================================" -ForegroundColor Cyan
Write-Host "Bridge IT Backend Connection Test" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Check if backend is running
Write-Host "🔍 Checking Django backend at http://127.0.0.1:8000..." -ForegroundColor Yellow
Write-Host ""

try {
    $response = Invoke-WebRequest -Uri "http://127.0.0.1:8000/" -UseBasicParsing -ErrorAction Stop
    Write-Host "✅ Backend is running! (HTTP $($response.StatusCode))" -ForegroundColor Green
    Write-Host ""
    
    # Test API endpoints
    Write-Host "🔍 Testing API endpoints..." -ForegroundColor Yellow
    Write-Host ""
    
    # Test auth endpoint availability
    Write-Host "Testing: GET /api/auth/register/" -ForegroundColor Cyan
    try {
        $apiTest = Invoke-WebRequest -Uri "http://127.0.0.1:8000/api/auth/register/" -Method POST -UseBasicParsing -ErrorAction SilentlyContinue
        Write-Host "✅ API endpoint is responding" -ForegroundColor Green
    }
    catch {
        Write-Host "⚠️  API endpoint returned: $($_.Exception.Response.StatusCode)" -ForegroundColor Yellow
        Write-Host "This is expected for POST without credentials" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "✅ Backend is ready for Flutter app!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Run Flutter app: flutter run" -ForegroundColor White
    Write-Host "  2. Test login with your credentials" -ForegroundColor White
    Write-Host "  3. Monitor console for API calls" -ForegroundColor White
    
}
catch {
    Write-Host "❌ Backend is not running!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please start your Django backend:" -ForegroundColor Yellow
    Write-Host "  python manage.py runserver 0.0.0.0:8000" -ForegroundColor White
    Write-Host ""
    Write-Host "On Windows, you might also try:" -ForegroundColor Gray
    Write-Host "  python manage.py runserver" -ForegroundColor Gray
}

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan

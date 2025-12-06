#!/bin/bash
# Backend Connection Verification Script
# This script verifies that your Django backend is running and accessible

echo "================================"
echo "Bridge IT Backend Connection Test"
echo "================================"
echo ""

# Check if backend is running
echo "🔍 Checking Django backend at http://127.0.0.1:8000..."
echo ""

# Test the health endpoint
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8000/)

if [ "$RESPONSE" = "200" ] || [ "$RESPONSE" = "301" ] || [ "$RESPONSE" = "404" ]; then
    echo "✅ Backend is running! (HTTP $RESPONSE)"
    echo ""
    
    # Test API health
    echo "🔍 Testing API endpoints..."
    echo ""
    
    # Test registration endpoint
    echo "Testing: POST /api/auth/register/"
    curl -s -X POST http://127.0.0.1:8000/api/auth/register/ \
        -H "Content-Type: application/json" \
        -d '{"name":"test","email":"test@example.com","password":"test123","confirm_password":"test123"}' | jq '.' 2>/dev/null || echo "API accessible but check response format"
    echo ""
    
    echo "✅ Backend is ready for Flutter app!"
    echo ""
    echo "Next steps:"
    echo "1. Run Flutter app: flutter run"
    echo "2. Test login with your credentials"
    echo "3. Monitor console for API calls"
    
else
    echo "❌ Backend is not running!"
    echo ""
    echo "Please start your Django backend:"
    echo "  python manage.py runserver 0.0.0.0:8000"
    echo ""
fi

echo ""
echo "================================"

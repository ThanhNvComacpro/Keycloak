#!/bin/bash

# 🧪 Keycloak APIs Test Script
# Mở Postman với collection để test APIs

echo "🚀 Starting Keycloak API Testing..."
echo ""

# Check if Keycloak is running
if curl -s http://localhost:8080 > /dev/null; then
    echo "✅ Keycloak is running at http://localhost:8080"
else
    echo "❌ Keycloak is not running. Please start it first:"
    echo "   ./start-keycloak.sh"
    echo ""
    exit 1
fi

echo ""
echo "📋 API Test Instructions:"
echo "------------------------"
echo "1. Open Postman application"
echo "2. Import the collection: Keycloak_APIs.postman_collection.json"
echo "3. Set environment variables:"
echo "   - keycloak_url: http://localhost:8080"
echo "   - realm: master"
echo "   - client_id: admin-cli"
echo ""
echo "4. Test flow:"
echo "   a. Get Admin Token (để lấy admin access)"
echo "   b. Create User (tạo test user)"
echo "   c. Login with Email/Password (login với user đã tạo)"
echo "   d. Get User Info (lấy thông tin user)"
echo "   e. Test other APIs as needed"
echo ""

# Try to open Postman if available
if command -v postman &> /dev/null; then
    echo "🎯 Opening Postman..."
    postman &
elif [ -d "/Applications/Postman.app" ]; then
    echo "🎯 Opening Postman..."
    open -a "Postman"
else
    echo "💡 Please install Postman from: https://www.postman.com/downloads/"
fi

echo ""
echo "📚 Documentation:"
echo "- API Guide: KEYCLOAK_APIS.md"
echo "- Development Guide: DEVELOPMENT.md"
echo "- Admin Console: http://localhost:8080/admin"
echo ""
echo "Happy API Testing! 🎉"

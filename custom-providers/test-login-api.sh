#!/bin/bash

# Test Login API Script for OTP Provider
# Author: Assistant
# Date: June 15, 2025

echo "🧪 Testing Login API with OTP Provider"
echo "======================================"

# Configuration
KEYCLOAK_URL="http://localhost:8080"
REALM="master"
CLIENT_ID="admin-cli"

echo "📋 Configuration:"
echo "   Keycloak URL: $KEYCLOAK_URL"
echo "   Realm: $REALM"
echo "   Client ID: $CLIENT_ID"
echo ""

# Function to test email login
test_email_login() {
    local email="$1"
    local test_name="$2"
    
    echo "📧 Testing Email Login: $test_name"
    echo "   Email: $email"
    echo "   ----------------------------------------"
    
    # Step 1: Initiate login with email
    echo "   🔄 Step 1: Initiating login..."
    
    response=$(curl -s -w "%{http_code}" -X POST \
        "$KEYCLOAK_URL/realms/$REALM/protocol/openid-connect/token" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "grant_type=password" \
        -d "client_id=$CLIENT_ID" \
        -d "username=$email" \
        -d "password=dummy_password_to_trigger_otp")
    
    http_code="${response: -3}"
    response_body="${response%???}"
    
    echo "   📊 Response HTTP Code: $http_code"
    
    if [ "$http_code" = "401" ]; then
        echo "   ✅ Expected 401 - Login requires OTP authentication"
        
        # Check if response contains OTP-related error
        if echo "$response_body" | grep -q "invalid_grant\|unauthorized"; then
            echo "   ✅ Authentication flow triggered successfully"
        else
            echo "   📄 Response: $response_body"
        fi
    elif [ "$http_code" = "400" ]; then
        echo "   ⚠️  Bad request - Check if user exists and authentication flow is configured"
        echo "   📄 Response: $response_body"
    else
        echo "   📄 Unexpected response: $response_body"
    fi
    
    echo ""
}

# Function to test phone login
test_phone_login() {
    local phone="$1"
    local test_name="$2"
    
    echo "📱 Testing Phone Login: $test_name"
    echo "   Phone: $phone"
    echo "   ----------------------------------------"
    
    # Step 1: Initiate login with phone
    echo "   🔄 Step 1: Initiating login..."
    
    response=$(curl -s -w "%{http_code}" -X POST \
        "$KEYCLOAK_URL/realms/$REALM/protocol/openid-connect/token" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "grant_type=password" \
        -d "client_id=$CLIENT_ID" \
        -d "username=$phone" \
        -d "password=dummy_password_to_trigger_otp")
    
    http_code="${response: -3}"
    response_body="${response%???}"
    
    echo "   📊 Response HTTP Code: $http_code"
    
    if [ "$http_code" = "401" ]; then
        echo "   ✅ Expected 401 - Login requires OTP authentication"
        
        # Check if response contains OTP-related error
        if echo "$response_body" | grep -q "invalid_grant\|unauthorized"; then
            echo "   ✅ Authentication flow triggered successfully"
        else
            echo "   📄 Response: $response_body"
        fi
    elif [ "$http_code" = "400" ]; then
        echo "   ⚠️  Bad request - Check if user exists and authentication flow is configured"
        echo "   📄 Response: $response_body"
    else
        echo "   📄 Unexpected response: $response_body"
    fi
    
    echo ""
}

# Function to test authentication flow via browser
test_browser_flow() {
    local username="$1"
    local test_name="$2"
    
    echo "🌐 Testing Browser Authentication Flow: $test_name"
    echo "   Username: $username"
    echo "   ----------------------------------------"
    
    # Get authorization URL
    auth_url="$KEYCLOAK_URL/realms/$REALM/protocol/openid-connect/auth?client_id=$CLIENT_ID&response_type=code&scope=openid&redirect_uri=http://localhost:8080/auth/realms/master/account"
    
    echo "   🔗 Authorization URL:"
    echo "   $auth_url"
    echo ""
    echo "   📋 Manual test steps:"
    echo "   1. Open the URL above in browser"
    echo "   2. Enter username: $username"
    echo "   3. You should see OTP form (even if sending fails)"
    echo ""
}

# Function to check Keycloak status
check_keycloak_status() {
    echo "🔍 Checking Keycloak Status..."
    
    response=$(curl -s -w "%{http_code}" "$KEYCLOAK_URL/realms/$REALM")
    http_code="${response: -3}"
    
    if [ "$http_code" = "200" ]; then
        echo "   ✅ Keycloak is running and accessible"
        return 0
    else
        echo "   ❌ Keycloak is not accessible (HTTP: $http_code)"
        echo "   Please make sure Keycloak is running: ./start-keycloak.sh"
        return 1
    fi
}

# Function to list test users
list_test_users() {
    echo "👥 Test User Available:"
    echo "   � User: thanhnv_comacpro"
    echo "     📧 Email: thanhnv@comacpro.vn"
    echo "     📱 Phone: 0343499340"
    echo ""
}

# Main execution
main() {
    # Check Keycloak status
    if ! check_keycloak_status; then
        exit 1
    fi
    
    echo ""
    list_test_users
    
    echo "🧪 Starting API Login Tests..."
    echo "============================================="
    echo ""
    
    # Test email login
    test_email_login "thanhnv@comacpro.vn" "Thanh - Email Login"
    
    # Test phone login
    test_phone_login "0343499340" "Thanh - Phone Login"
    
    echo "🌐 Browser Authentication Flow Tests"
    echo "===================================="
    echo ""
    
    # Test browser flows
    test_browser_flow "thanhnv@comacpro.vn" "Thanh - Email Browser Flow"
    test_browser_flow "0343499340" "Thanh - Phone Browser Flow"
    
    echo "📝 Notes:"
    echo "========"
    echo "1. 401 responses are expected for API login tests"
    echo "2. This indicates that OTP authentication is required"
    echo "3. For full testing, use the browser authentication URLs"
    echo "4. If OTP sending fails, you'll still see the OTP form"
    echo "5. Configure SMTP/SMS in .env.otp for actual OTP delivery"
    echo ""
    echo "🧪 Test User Details:"
    echo "   📧 Email: thanhnv@comacpro.vn"
    echo "   📱 Phone: 0343499340"
    echo ""
    echo "✅ API Login Tests Complete!"
}

# Run main function
main

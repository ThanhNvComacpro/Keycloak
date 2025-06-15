#!/bin/bash

# Configure Authentication Flow for OTP Provider
# Author: Assistant
# Date: June 15, 2025

echo "🔧 Configuring Authentication Flow for OTP Provider"
echo "=================================================="

# Configuration
KEYCLOAK_URL="http://localhost:8080"
REALM="master"
ADMIN_USERNAME="admin"
ADMIN_PASSWORD="admin123"

echo "📋 Configuration:"
echo "   Keycloak URL: $KEYCLOAK_URL"
echo "   Realm: $REALM"
echo "   Admin User: $ADMIN_USERNAME"
echo ""

# Function to get admin token
get_admin_token() {
    echo "🔑 Getting admin token..."
    
    ADMIN_TOKEN=$(curl -s -X POST \
        "$KEYCLOAK_URL/realms/master/protocol/openid-connect/token" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "grant_type=password" \
        -d "client_id=admin-cli" \
        -d "username=$ADMIN_USERNAME" \
        -d "password=$ADMIN_PASSWORD" \
        | jq -r '.access_token')
    
    if [ "$ADMIN_TOKEN" = "null" ] || [ -z "$ADMIN_TOKEN" ]; then
        echo "❌ Failed to get admin token!"
        exit 1
    fi
    
    echo "✅ Admin token obtained successfully!"
}

# Function to create OTP authentication flow
create_otp_flow() {
    echo "📝 Creating OTP Authentication Flow..."
    
    # Create new authentication flow
    response=$(curl -s -w "%{http_code}" -X POST \
        "$KEYCLOAK_URL/admin/realms/$REALM/authentication/flows" \
        -H "Authorization: Bearer $ADMIN_TOKEN" \
        -H "Content-Type: application/json" \
        -d '{
            "alias": "OTP Login Flow",
            "description": "Custom OTP authentication flow for email/phone login",
            "providerId": "basic-flow",
            "topLevel": true,
            "builtIn": false
        }')
    
    http_code="${response: -3}"
    response_body="${response%???}"
    
    if [ "$http_code" = "201" ]; then
        echo "   ✅ OTP authentication flow created successfully!"
    else
        echo "   ❌ Failed to create OTP flow (HTTP: $http_code)"
        echo "   Response: $response_body"
        return 1
    fi
}

# Function to get flow ID
get_flow_id() {
    echo "🔍 Getting OTP flow ID..."
    
    FLOW_ID=$(curl -s -X GET \
        "$KEYCLOAK_URL/admin/realms/$REALM/authentication/flows" \
        -H "Authorization: Bearer $ADMIN_TOKEN" \
        | jq -r '.[] | select(.alias=="OTP Login Flow") | .id')
    
    if [ "$FLOW_ID" = "null" ] || [ -z "$FLOW_ID" ]; then
        echo "   ❌ Failed to get flow ID!"
        return 1
    fi
    
    echo "   ✅ Flow ID: $FLOW_ID"
}

# Function to add OTP authenticator to flow
add_otp_authenticator() {
    echo "🔌 Adding OTP authenticator to flow..."
    
    response=$(curl -s -w "%{http_code}" -X POST \
        "$KEYCLOAK_URL/admin/realms/$REALM/authentication/flows/OTP%20Login%20Flow/executions/execution" \
        -H "Authorization: Bearer $ADMIN_TOKEN" \
        -H "Content-Type: application/json" \
        -d '{
            "provider": "custom-otp-authenticator"
        }')
    
    http_code="${response: -3}"
    response_body="${response%???}"
    
    if [ "$http_code" = "201" ]; then
        echo "   ✅ OTP authenticator added successfully!"
    else
        echo "   ❌ Failed to add OTP authenticator (HTTP: $http_code)"
        echo "   Response: $response_body"
        return 1
    fi
}

# Function to set flow as browser flow
set_browser_flow() {
    echo "🌐 Setting OTP flow as browser authentication flow..."
    
    response=$(curl -s -w "%{http_code}" -X PUT \
        "$KEYCLOAK_URL/admin/realms/$REALM" \
        -H "Authorization: Bearer $ADMIN_TOKEN" \
        -H "Content-Type: application/json" \
        -d '{
            "browserFlow": "OTP Login Flow"
        }')
    
    http_code="${response: -3}"
    response_body="${response%???}"
    
    if [ "$http_code" = "204" ]; then
        echo "   ✅ OTP flow set as browser flow successfully!"
    else
        echo "   ❌ Failed to set browser flow (HTTP: $http_code)"
        echo "   Response: $response_body"
        return 1
    fi
}

# Function to list authentication flows
list_flows() {
    echo "📋 Current authentication flows:"
    
    curl -s -X GET \
        "$KEYCLOAK_URL/admin/realms/$REALM/authentication/flows" \
        -H "Authorization: Bearer $ADMIN_TOKEN" \
        | jq -r '.[] | "Flow: \(.alias) | ID: \(.id) | Built-in: \(.builtIn)"'
}

# Function to check current realm settings
check_realm_settings() {
    echo "🔍 Current realm authentication settings:"
    
    curl -s -X GET \
        "$KEYCLOAK_URL/admin/realms/$REALM" \
        -H "Authorization: Bearer $ADMIN_TOKEN" \
        | jq -r '{browserFlow, registrationFlow, directGrantFlow, resetCredentialsFlow, clientAuthenticationFlow, dockerAuthenticationFlow}'
}

# Main execution
main() {
    # Check if jq is installed
    if ! command -v jq &> /dev/null; then
        echo "❌ jq is required but not installed!"
        echo "Install with: brew install jq"
        exit 1
    fi
    
    # Get admin token
    get_admin_token
    
    echo ""
    echo "📊 Current state:"
    list_flows
    echo ""
    check_realm_settings
    
    echo ""
    echo "🚀 Creating and configuring OTP flow..."
    
    # Create flow and configure
    if create_otp_flow && get_flow_id && add_otp_authenticator && set_browser_flow; then
        echo ""
        echo "🎉 Authentication flow configured successfully!"
        echo ""
        echo "📊 Updated state:"
        list_flows
        echo ""
        check_realm_settings
        
        echo ""
        echo "✅ You can now test the OTP login flow!"
        echo "🔗 Test URL: http://localhost:8080/realms/$REALM/account"
        echo ""
        echo "📋 Test users:"
        echo "   📧 Email: test1@example.com, user@gmail.com"
        echo "   📱 Phone: 0901234567, +84987654321"
    else
        echo "❌ Failed to configure authentication flow!"
        exit 1
    fi
}

# Run main function
main

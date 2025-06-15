#!/bin/bash

# Create Specific Test Users for OTP Provider
# Author: Assistant
# Date: June 15, 2025

echo "🧪 Creating Specific Test Users for OTP Provider"
echo "=============================================="

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
        echo "Please check:"
        echo "1. Keycloak is running at $KEYCLOAK_URL"
        echo "2. Admin credentials are correct"
        exit 1
    fi
    
    echo "✅ Admin token obtained successfully!"
}

# Function to delete existing test users
delete_existing_users() {
    echo "🗑️ Deleting existing test users..."
    
    # Get list of users
    users=$(curl -s -X GET \
        "$KEYCLOAK_URL/admin/realms/$REALM/users?max=50" \
        -H "Authorization: Bearer $ADMIN_TOKEN")
    
    # Delete test users (not admin)
    echo "$users" | jq -r '.[] | select(.username != "admin") | .id' | while read user_id; do
        if [ ! -z "$user_id" ]; then
            curl -s -X DELETE \
                "$KEYCLOAK_URL/admin/realms/$REALM/users/$user_id" \
                -H "Authorization: Bearer $ADMIN_TOKEN"
            echo "   🗑️ Deleted user ID: $user_id"
        fi
    done
    
    echo "✅ Cleaned up existing test users!"
}

# Function to create user with both email and phone
create_combined_user() {
    local email="$1"
    local phone="$2"
    local username="$3"
    local first_name="$4"
    local last_name="$5"
    
    echo "👤 Creating user: $username"
    echo "   📧 Email: $email"
    echo "   📱 Phone: $phone"
    
    response=$(curl -s -w "%{http_code}" -X POST \
        "$KEYCLOAK_URL/admin/realms/$REALM/users" \
        -H "Authorization: Bearer $ADMIN_TOKEN" \
        -H "Content-Type: application/json" \
        -d "{
            \"username\": \"$username\",
            \"email\": \"$email\",
            \"firstName\": \"$first_name\",
            \"lastName\": \"$last_name\",
            \"enabled\": true,
            \"emailVerified\": true,
            \"attributes\": {
                \"phoneNumber\": [\"$phone\"],
                \"phoneVerified\": [\"true\"],
                \"loginType\": [\"both\"]
            }
        }")
    
    http_code="${response: -3}"
    response_body="${response%???}"
    
    if [ "$http_code" = "201" ]; then
        echo "   ✅ User created successfully!"
        
        # Get user ID and update attributes separately
        user_id=$(curl -s -X GET \
            "$KEYCLOAK_URL/admin/realms/$REALM/users?username=$username" \
            -H "Authorization: Bearer $ADMIN_TOKEN" \
            | jq -r '.[0].id')
        
        if [ "$user_id" != "null" ] && [ ! -z "$user_id" ]; then
            # Update user attributes
            curl -s -X PUT \
                "$KEYCLOAK_URL/admin/realms/$REALM/users/$user_id" \
                -H "Authorization: Bearer $ADMIN_TOKEN" \
                -H "Content-Type: application/json" \
                -d "{
                    \"id\": \"$user_id\",
                    \"username\": \"$username\",
                    \"email\": \"$email\",
                    \"firstName\": \"$first_name\",
                    \"lastName\": \"$last_name\",
                    \"enabled\": true,
                    \"emailVerified\": true,
                    \"attributes\": {
                        \"phoneNumber\": [\"$phone\"],
                        \"phoneVerified\": [\"true\"],
                        \"loginType\": [\"both\"]
                    }
                }"
            echo "   📱 Phone number updated: $phone"
        fi
    else
        echo "   ❌ Failed to create user (HTTP: $http_code)"
        echo "   Response: $response_body"
    fi
}

# Function to list users
list_users() {
    echo "👥 Current users in realm:"
    
    response=$(curl -s -X GET \
        "$KEYCLOAK_URL/admin/realms/$REALM/users?max=20" \
        -H "Authorization: Bearer $ADMIN_TOKEN")
    
    echo "$response" | jq -r '.[] | "User: \(.username) | Email: \(.email // "N/A") | Phone: \(.attributes.phoneNumber[0] // "N/A") | Name: \(.firstName // "") \(.lastName // "")"'
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
    
    # Clean up existing users
    delete_existing_users
    
    echo ""
    echo "👤 Creating specific test users..."
    echo ""
    
    # Create the specific users requested
    create_combined_user "thanhnv@comacpro.vn" "0343499340" "thanhnv_comacpro" "Thanh" "Nguyen Van"
    
    echo ""
    echo "📊 Summary of created users:"
    echo "============================"
    list_users
    
    echo ""
    echo "🧪 Test Login Instructions:"
    echo "============================"
    echo "You can now login with either:"
    echo "   📧 Email: thanhnv@comacpro.vn"
    echo "   📱 Phone: 0343499340"
    echo ""
    echo "Test URLs:"
    echo "   🌐 Browser: $KEYCLOAK_URL/realms/$REALM/account"
    echo "   🔧 Admin: $KEYCLOAK_URL/admin"
    echo ""
    echo "Note: Since OTP config is not set, the system will show errors"
    echo "but you can see the authentication flow working."
}

# Run main function
main

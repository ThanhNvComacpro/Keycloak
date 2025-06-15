#!/bin/bash

# Configuration Script for Custom OTP Provider
# Author: Assistant
# Date: June 15, 2025

echo "🔧 Custom OTP Provider Configuration"
echo "===================================="
echo ""

# Function to read input with default value
read_with_default() {
    local prompt="$1"
    local default="$2"
    local var_name="$3"
    
    if [ -n "$default" ]; then
        read -p "$prompt [$default]: " input
        export $var_name="${input:-$default}"
    else
        read -p "$prompt: " input
        export $var_name="$input"
    fi
}

# Function to read password
read_password() {
    local prompt="$1"
    local var_name="$2"
    
    read -s -p "$prompt: " input
    echo ""
    export $var_name="$input"
}

echo "📧 EMAIL CONFIGURATION (SMTP)"
echo "-----------------------------"
read_with_default "SMTP Host" "smtp.gmail.com" "SMTP_HOST"
read_with_default "SMTP Port" "587" "SMTP_PORT"
read_with_default "SMTP Username" "" "SMTP_USERNAME"
read_password "SMTP Password (App Password for Gmail)" "SMTP_PASSWORD"
read_with_default "From Email" "$SMTP_USERNAME" "SMTP_FROM_EMAIL"
read_with_default "From Name" "Keycloak OTP Service" "SMTP_FROM_NAME"

echo ""
echo "📱 SMS CONFIGURATION (ESMS)"
echo "-----------------------------"
read_with_default "ESMS API Key" "" "ESMS_API_KEY"
read_password "ESMS Secret Key" "ESMS_SECRET_KEY"
read_with_default "Brand Name" "Keycloak" "ESMS_BRAND_NAME"

echo ""
echo "⚙️  OTP CONFIGURATION"
echo "--------------------"
read_with_default "OTP Length" "6" "OTP_LENGTH"
read_with_default "OTP Validity (minutes)" "5" "OTP_VALIDITY_MINUTES"
read_with_default "Max OTP Attempts" "3" "OTP_MAX_ATTEMPTS"

echo ""
echo "💾 SAVING CONFIGURATION"
echo "------------------------"

# Create environment file
ENV_FILE=".env.otp"
cat > "$ENV_FILE" << EOF
# Custom OTP Provider Configuration
# Generated on $(date)

# Email Configuration (SMTP)
export SMTP_HOST="$SMTP_HOST"
export SMTP_PORT="$SMTP_PORT"
export SMTP_USERNAME="$SMTP_USERNAME"
export SMTP_PASSWORD="$SMTP_PASSWORD"
export SMTP_FROM_EMAIL="$SMTP_FROM_EMAIL"
export SMTP_FROM_NAME="$SMTP_FROM_NAME"

# SMS Configuration (ESMS)
export ESMS_API_KEY="$ESMS_API_KEY"
export ESMS_SECRET_KEY="$ESMS_SECRET_KEY"
export ESMS_BRAND_NAME="$ESMS_BRAND_NAME"

# OTP Configuration
export OTP_LENGTH="$OTP_LENGTH"
export OTP_VALIDITY_MINUTES="$OTP_VALIDITY_MINUTES"
export OTP_MAX_ATTEMPTS="$OTP_MAX_ATTEMPTS"
EOF

echo "✅ Configuration saved to: $ENV_FILE"
echo ""
echo "📋 TO USE THIS CONFIGURATION:"
echo "------------------------------"
echo "1. Load environment variables:"
echo "   source $ENV_FILE"
echo ""
echo "2. Start Keycloak with these variables:"
echo "   source $ENV_FILE && ./start-keycloak.sh"
echo ""
echo "3. Or add to your shell profile (~/.zshrc or ~/.bashrc):"
echo "   echo 'source $(pwd)/$ENV_FILE' >> ~/.zshrc"
echo ""

# Make environment file executable
chmod +x "$ENV_FILE"

echo "✅ Configuration complete!"
echo ""
echo "🔍 TESTING CONNECTIONS:"
echo "-----------------------"

# Test email configuration if provided
if [ -n "$SMTP_USERNAME" ] && [ -n "$SMTP_PASSWORD" ]; then
    echo "📧 Testing email configuration..."
    if command -v python3 &> /dev/null; then
        python3 << EOF
import smtplib
from email.mime.text import MIMEText
import os

try:
    smtp_server = smtplib.SMTP('$SMTP_HOST', $SMTP_PORT)
    smtp_server.starttls()
    smtp_server.login('$SMTP_USERNAME', '$SMTP_PASSWORD')
    smtp_server.quit()
    print("✅ Email configuration is working!")
except Exception as e:
    print(f"❌ Email configuration error: {e}")
EOF
    else
        echo "⚠️  Python3 not found, skipping email test"
    fi
else
    echo "⚠️  Email credentials not provided, skipping test"
fi

# Test SMS configuration if provided
if [ -n "$ESMS_API_KEY" ] && [ -n "$ESMS_SECRET_KEY" ]; then
    echo "📱 Testing SMS configuration..."
    if command -v curl &> /dev/null; then
        response=$(curl -s -X POST \
            -H "Content-Type: application/json" \
            -d "{\"ApiKey\":\"$ESMS_API_KEY\",\"SecretKey\":\"$ESMS_SECRET_KEY\"}" \
            "https://rest.esms.vn/MainService.svc/json/GetBalance")
        
        if echo "$response" | grep -q "Balance"; then
            echo "✅ SMS configuration is working!"
            echo "💰 Account balance: $(echo "$response" | grep -o '"Balance":[0-9]*' | cut -d':' -f2)"
        else
            echo "❌ SMS configuration error: $response"
        fi
    else
        echo "⚠️  curl not found, skipping SMS test"
    fi
else
    echo "⚠️  SMS credentials not provided, skipping test"
fi

echo ""
echo "🎉 Setup complete! You can now build and deploy the provider:"
echo "   ./build-and-deploy.sh"

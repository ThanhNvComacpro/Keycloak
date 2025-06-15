#!/bin/bash

# Build and Deploy Custom OTP Provider for Keycloak
# Author: Assistant
# Date: June 15, 2025

echo "🚀 Building Custom OTP Provider for Keycloak..."
echo "================================================="

# Check if we're in the custom-providers directory
if [ ! -f "pom.xml" ]; then
    echo "❌ Error: pom.xml not found!"
    echo "Please run this script from the custom-providers directory"
    exit 1
fi

# Check if Maven is installed
if ! command -v mvn &> /dev/null; then
    echo "❌ Maven is not installed!"
    echo "Please install Maven:"
    echo "  brew install maven"
    exit 1
fi

# Clean and build the project
echo "🔨 Building JAR file..."
mvn clean package -DskipTests

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

# Check if JAR file was created
JAR_FILE="target/custom-otp-provider-1.0.0.jar"
if [ ! -f "$JAR_FILE" ]; then
    echo "❌ JAR file not found: $JAR_FILE"
    exit 1
fi

echo "✅ Build successful!"

# Copy JAR to Keycloak providers directory
KEYCLOAK_PROVIDERS_DIR="../providers"
if [ ! -d "$KEYCLOAK_PROVIDERS_DIR" ]; then
    echo "❌ Keycloak providers directory not found: $KEYCLOAK_PROVIDERS_DIR"
    echo "Please make sure you're running this from the custom-providers directory"
    exit 1
fi

echo "📦 Copying JAR to Keycloak providers directory..."
cp "$JAR_FILE" "$KEYCLOAK_PROVIDERS_DIR/"

if [ $? -eq 0 ]; then
    echo "✅ JAR file copied successfully!"
else
    echo "❌ Failed to copy JAR file!"
    exit 1
fi

# Build Keycloak to install the provider
echo "🔧 Building Keycloak to install the provider..."
cd ..
./bin/kc.sh build

if [ $? -eq 0 ]; then
    echo "✅ Keycloak build successful!"
    echo ""
    echo "🎉 Custom OTP Provider has been installed successfully!"
    echo ""
    echo "📋 Next Steps:"
    echo "1. Start Keycloak: ./start-keycloak.sh"
    echo "2. Go to Admin Console: http://localhost:8080/admin"
    echo "3. Navigate to: Authentication → Flows"
    echo "4. Create a new flow or modify existing one"
    echo "5. Add 'Custom OTP Login (Email/Phone)' authenticator"
    echo "6. Configure SMTP and ESMS settings in the authenticator config"
    echo ""
    echo "📧 Email Configuration (Environment Variables):"
    echo "   export SMTP_HOST=smtp.gmail.com"
    echo "   export SMTP_PORT=587"
    echo "   export SMTP_USERNAME=your-email@gmail.com"
    echo "   export SMTP_PASSWORD=your-app-password"
    echo "   export SMTP_FROM_EMAIL=your-email@gmail.com"
    echo "   export SMTP_FROM_NAME='Your Service Name'"
    echo ""
    echo "📱 SMS Configuration (Environment Variables):"
    echo "   export ESMS_API_KEY=your-esms-api-key"
    echo "   export ESMS_SECRET_KEY=your-esms-secret-key"
    echo "   export ESMS_BRAND_NAME=YourBrand"
    echo ""
else
    echo "❌ Keycloak build failed!"
    echo "Please check the logs for errors"
    exit 1
fi

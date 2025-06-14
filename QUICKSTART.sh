#!/bin/bash

# Quick start guide for Keycloak
echo "=========================================="
echo "🚀 KEYCLOAK QUICK START GUIDE"
echo "=========================================="
echo ""

echo "📋 STEP 1: Install Java (if not installed)"
echo "Run these commands in Terminal:"
echo ""
echo "# Install Homebrew (package manager)"
echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
echo ""
echo "# Install Java 17"
echo "brew install openjdk@17"
echo ""
echo "# Set Java environment (for current session)"
echo "export JAVA_HOME=\"/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home\""
echo "export PATH=\"\$JAVA_HOME/bin:\$PATH\""
echo ""
echo "# Add to your shell profile permanently"
echo "echo 'export JAVA_HOME=\"/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home\"' >> ~/.zshrc"
echo "echo 'export PATH=\"\$JAVA_HOME/bin:\$PATH\"' >> ~/.zshrc"
echo ""

echo "📋 STEP 2: Verify Java installation"
echo "java -version"
echo ""

echo "📋 STEP 3: Start Keycloak"
echo "cd /Users/thanh/Downloads/keycloak-26.2.5"
echo "./bin/kc.sh start-dev"
echo ""

echo "📋 STEP 4: Access Keycloak"
echo "Open browser and go to: http://localhost:8080"
echo "Admin Console: http://localhost:8080/admin"
echo ""

echo "📋 STEP 5: First time setup"
echo "1. Create admin user when prompted"
echo "2. Username: admin"
echo "3. Password: (choose a secure password)"
echo ""

echo "🔧 Alternative: Use our custom scripts"
echo "./setup.sh        # Install dependencies"
echo "./start-keycloak.sh # Start Keycloak with helpful output"
echo ""

echo "📚 Documentation"
echo "Read DEVELOPMENT.md for detailed instructions"
echo ""

echo "=========================================="
echo "Have questions? Check the troubleshooting section in DEVELOPMENT.md"
echo "=========================================="

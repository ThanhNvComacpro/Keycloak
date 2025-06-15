#!/bin/bash

# Setup script for Keycloak
# This script will install Java and prepare the environment

echo "🛠️  Keycloak Setup Script"
echo "========================="

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This script is designed for macOS"
    exit 1
fi

# Install Homebrew if not present
if ! command -v brew &> /dev/null; then
    echo "📦 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for M1/M2 Macs
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo "✅ Homebrew is already installed"
fi

# Install Java 17
echo ""
echo "☕ Checking Java 17..."
if brew list openjdk@17 &>/dev/null; then
    echo "✅ Java 17 is already installed"
else
    echo "📦 Installing Java 17..."
    brew install openjdk@17
fi

# Set up Java environment
echo ""
echo "🔧 Setting up Java environment..."

# For M1/M2 Macs
if [[ $(uname -m) == "arm64" ]]; then
    JAVA_HOME_PATH="/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
else
    # For Intel Macs
    JAVA_HOME_PATH="/usr/local/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
fi

# Add to shell profile
if [[ -f ~/.zshrc ]]; then
    if ! grep -q "JAVA_HOME.*openjdk@17" ~/.zshrc; then
        echo "" >> ~/.zshrc
        echo "# Java 17 for Keycloak" >> ~/.zshrc
        echo "export JAVA_HOME=\"$JAVA_HOME_PATH\"" >> ~/.zshrc
        echo "export PATH=\"\$JAVA_HOME/bin:\$PATH\"" >> ~/.zshrc
    fi
    echo "✅ Updated ~/.zshrc with Java settings"
fi

# Set for current session
export JAVA_HOME="$JAVA_HOME_PATH"
export PATH="$JAVA_HOME/bin:$PATH"

echo ""
echo "🎉 Setup completed!"
echo ""
echo "Java version:"
java -version

echo ""
echo "📚 Next steps:"
echo "1. Restart your terminal or run: source ~/.zshrc"
echo "2. Run Keycloak with: ./start-keycloak.sh"
echo ""
echo "🌐 Keycloak will be available at:"
echo "   • Main: http://localhost:8080"
echo "   • Admin Console: http://localhost:8080/admin"
echo ""
echo "🔐 First time setup:"
echo "   • Create admin user when prompted"
echo "   • Default realm: 'master'"

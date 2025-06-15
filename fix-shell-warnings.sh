#!/bin/bash

# Clean up .zshrc to avoid duplicate Java entries and warnings

echo "🧹 Cleaning up .zshrc..."

# Backup original .zshrc
cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)

# Remove all Java-related lines
sed -i '' '/# Java 17 for Keycloak/d' ~/.zshrc
sed -i '' '/JAVA_HOME.*openjdk@17/d' ~/.zshrc
sed -i '' '/PATH.*JAVA_HOME/d' ~/.zshrc

# Add clean Java configuration
echo "" >> ~/.zshrc
echo "# Java 17 for Keycloak" >> ~/.zshrc

# Detect architecture and set correct path
if [[ $(uname -m) == "arm64" ]]; then
    JAVA_HOME_PATH="/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
else
    JAVA_HOME_PATH="/usr/local/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
fi

echo "export JAVA_HOME=\"$JAVA_HOME_PATH\"" >> ~/.zshrc
echo "export PATH=\"\$JAVA_HOME/bin:\$PATH\"" >> ~/.zshrc

echo "✅ .zshrc cleaned up successfully"
echo "🔄 Please restart your terminal or run: source ~/.zshrc"
echo ""
echo "📋 Current Java configuration:"
echo "JAVA_HOME: $JAVA_HOME_PATH"

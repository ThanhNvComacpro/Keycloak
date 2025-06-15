#!/bin/bash

# Script to start Keycloak easily
# Author: Assistant
# Date: June 14, 2025

echo "🚀 Starting Keycloak Server..."
echo "================================="

# Check if Java is installed
if ! command -v java &> /dev/null; then
    echo "❌ Java is not installed!"
    echo "Please install Java 17 or later:"
    echo "  brew install openjdk@17"
    echo ""
    echo "After installation, set JAVA_HOME:"
    echo "  export JAVA_HOME=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
    echo "  export PATH=\$JAVA_HOME/bin:\$PATH"
    exit 1
fi

# Show Java version
echo "☕ Java version:"
java -version
echo ""

# Set JAVA_HOME if not set
if [ -z "$JAVA_HOME" ]; then
    echo "⚠️  JAVA_HOME is not set. Trying to detect Java..."
    if [ -d "/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home" ]; then
        export JAVA_HOME="/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
        export PATH="$JAVA_HOME/bin:$PATH"
        echo "✅ Set JAVA_HOME to: $JAVA_HOME"
    elif [ -d "/usr/local/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home" ]; then
        export JAVA_HOME="/usr/local/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
        export PATH="$JAVA_HOME/bin:$PATH"
        echo "✅ Set JAVA_HOME to: $JAVA_HOME"
    elif [ -d "/usr/libexec/java_home" ]; then
        export JAVA_HOME=$(/usr/libexec/java_home)
        echo "✅ Set JAVA_HOME to: $JAVA_HOME"
    fi
fi

echo ""
echo "🔧 Starting Keycloak in development mode..."
echo "This will:"
echo "  • Start the server on http://localhost:8080"
echo "  • Enable development features"
echo "  • Use H2 in-memory database (data will be lost on restart)"
echo ""
echo "Access the admin console at: http://localhost:8080/admin"
echo "First time setup: Create admin user when prompted"
echo ""
echo "Press Ctrl+C to stop the server"
echo "================================="

# Change to Keycloak directory
cd "$(dirname "$0")"

# Start Keycloak in development mode
./bin/kc.sh start-dev

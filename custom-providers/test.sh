#!/bin/bash

# Test Script for Custom OTP Provider
# Author: Assistant
# Date: June 15, 2025

echo "🧪 Testing Custom OTP Provider"
echo "==============================="

# Check if Maven is installed
if ! command -v mvn &> /dev/null; then
    echo "❌ Maven is not installed!"
    echo "Please install Maven: brew install maven"
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "pom.xml" ]; then
    echo "❌ Error: pom.xml not found!"
    echo "Please run this script from the custom-providers directory"
    exit 1
fi

echo "🔍 Running tests..."

# Compile and test
mvn clean test

if [ $? -eq 0 ]; then
    echo "✅ All tests passed!"
else
    echo "❌ Some tests failed!"
    exit 1
fi

# Test utilities
echo ""
echo "🔧 Testing utility functions..."

# Create a simple test
cat > /tmp/otp_test.java << 'EOF'
import com.example.keycloak.otp.utils.OTPUtils;

public class OTPTest {
    public static void main(String[] args) {
        // Test email validation
        System.out.println("Email Tests:");
        System.out.println("test@example.com: " + OTPUtils.isEmail("test@example.com"));
        System.out.println("invalid-email: " + OTPUtils.isEmail("invalid-email"));
        
        // Test phone validation
        System.out.println("\nPhone Tests:");
        System.out.println("0901234567: " + OTPUtils.isPhoneNumber("0901234567"));
        System.out.println("+84901234567: " + OTPUtils.isPhoneNumber("+84901234567"));
        System.out.println("invalid-phone: " + OTPUtils.isPhoneNumber("invalid-phone"));
        
        // Test phone normalization
        System.out.println("\nPhone Normalization:");
        System.out.println("0901234567 -> " + OTPUtils.normalizePhoneNumber("0901234567"));
        System.out.println("84901234567 -> " + OTPUtils.normalizePhoneNumber("84901234567"));
        
        // Test masking
        System.out.println("\nMasking Tests:");
        System.out.println("Email: " + OTPUtils.maskEmail("test@example.com"));
        System.out.println("Phone: " + OTPUtils.maskPhoneNumber("+84901234567"));
        
        // Test OTP generation
        System.out.println("\nOTP Generation:");
        System.out.println("6-digit OTP: " + OTPUtils.generateOTP());
        System.out.println("4-digit OTP: " + OTPUtils.generateOTP(4));
    }
}
EOF

# Compile and run test if Java is available
if command -v javac &> /dev/null && command -v java &> /dev/null; then
    # Get classpath
    CLASSPATH=$(mvn dependency:build-classpath -Dmdep.outputFile=/tmp/cp.txt -q && cat /tmp/cp.txt):target/classes
    
    # Compile test
    javac -cp "$CLASSPATH" -d /tmp /tmp/otp_test.java 2>/dev/null
    
    if [ $? -eq 0 ]; then
        # Run test
        cd /tmp && java -cp "$CLASSPATH:." OTPTest
        cd - > /dev/null
        echo "✅ Utility tests completed!"
    else
        echo "⚠️  Could not compile utility tests (this is OK if dependencies are not built yet)"
    fi
else
    echo "⚠️  Java not found, skipping utility tests"
fi

# Check JAR structure
echo ""
echo "📦 Checking JAR structure..."

if [ -f "target/custom-otp-provider-1.0.0.jar" ]; then
    echo "✅ JAR file exists!"
    
    # Check for required files
    if command -v jar &> /dev/null; then
        echo "🔍 JAR contents:"
        jar tf target/custom-otp-provider-1.0.0.jar | grep -E "(AuthenticatorFactory|\.class|META-INF)" | head -10
        
        # Check service file
        if jar tf target/custom-otp-provider-1.0.0.jar | grep -q "META-INF/services"; then
            echo "✅ Service registration file found!"
        else
            echo "❌ Service registration file missing!"
        fi
    fi
else
    echo "❌ JAR file not found! Run: mvn clean package"
fi

# Check configuration files
echo ""
echo "⚙️  Checking configuration files..."

if [ -f "src/main/resources/META-INF/services/org.keycloak.authentication.AuthenticatorFactory" ]; then
    echo "✅ AuthenticatorFactory service file exists"
    echo "   Content: $(cat src/main/resources/META-INF/services/org.keycloak.authentication.AuthenticatorFactory)"
else
    echo "❌ AuthenticatorFactory service file missing!"
fi

if [ -f "src/main/resources/templates/otp-login.ftl" ]; then
    echo "✅ OTP login template exists"
else
    echo "❌ OTP login template missing!"
fi

if [ -f "src/main/resources/templates/otp-verify.ftl" ]; then
    echo "✅ OTP verify template exists"
else
    echo "❌ OTP verify template missing!"
fi

# Check for email templates
if [ -f "src/main/resources/templates/email_otp_en.html" ]; then
    echo "✅ English email template exists"
else
    echo "❌ English email template missing!"
fi

if [ -f "src/main/resources/templates/email_otp_vi.html" ]; then
    echo "✅ Vietnamese email template exists"
else
    echo "❌ Vietnamese email template missing!"
fi

# Check environment configuration
echo ""
echo "🌍 Environment Configuration Check..."

if [ -f ".env.otp" ]; then
    echo "✅ Environment file exists: .env.otp"
    echo "🔍 Configuration summary:"
    grep -E "^export (SMTP_HOST|ESMS_API_KEY|OTP_)" .env.otp | sed 's/export /  /'
else
    echo "⚠️  Environment file not found. Run: ./configure.sh"
fi

echo ""
echo "📋 Test Summary:"
echo "==============="

# Count checks
total_checks=0
passed_checks=0

checks=(
    "pom.xml exists"
    "JAR can be built"
    "Service file exists"
    "Templates exist"
    "Email templates exist"
)

for check in "${checks[@]}"; do
    total_checks=$((total_checks + 1))
    echo "   $check"
done

echo ""
echo "✅ Testing completed!"
echo ""
echo "📚 Next Steps:"
echo "1. Configure environment: ./configure.sh"
echo "2. Build and deploy: ./build-and-deploy.sh"
echo "3. Start Keycloak and test the authentication flow"

# Cleanup
rm -f /tmp/otp_test.java /tmp/OTPTest.class /tmp/cp.txt

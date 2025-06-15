#!/bin/bash

# Git setup script for Keycloak project

echo "🔧 Setting up Git repository for Keycloak project"
echo "==============================================="

# Initialize git if not already initialized
if [ ! -d ".git" ]; then
    echo "📦 Initializing Git repository..."
    git init
    echo "✅ Git repository initialized"
else
    echo "✅ Git repository already exists"
fi

# Add gitignore
echo "📝 Git ignore setup:"
echo "   - node_modules/"
echo "   - data/"
echo "   - temp directories"
echo "   - logs and IDE files"

# Check git status
echo ""
echo "📊 Current git status:"
git status --short

echo ""
echo "🎯 Ready to commit files:"
echo "   git add ."
echo "   git commit -m 'Initial Keycloak setup with Node.js API testing'"
echo ""
echo "📚 Project structure:"
echo "   ├── bin/                    # Keycloak executables"
echo "   ├── conf/                   # Configuration files"
echo "   ├── examples/               # Node.js API testing tools"
echo "   │   ├── .gitignore         # Node.js specific ignores"
echo "   │   ├── package.json       # Dependencies"
echo "   │   ├── interactive-test.js # Interactive testing tool"
echo "   │   ├── test-*.js          # Various test scripts"
echo "   │   └── README.md          # Testing documentation"
echo "   ├── lib/                    # Keycloak libraries"
echo "   ├── .gitignore             # Project-wide ignores"
echo "   ├── KEYCLOAK_APIS.md       # Complete API documentation"
echo "   ├── DEVELOPMENT.md         # Development guide"
echo "   └── README.md              # Main project README"
echo ""
echo "🚀 Next steps:"
echo "1. Review files to commit: git status"
echo "2. Add files: git add ."
echo "3. Commit: git commit -m 'Initial setup'"
echo "4. Add remote if needed: git remote add origin <url>"
echo "5. Push: git push -u origin main"

#!/bin/bash

echo "🚀 NotificationAPI Flutter SDK Example Setup"
echo "============================================="

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    echo "Please install Flutter: https://docs.flutter.dev/get-started/install"
    exit 1
fi

echo "✅ Flutter found: $(flutter --version | head -n 1)"

# Navigate to example directory
cd "$(dirname "$0")"

echo "📦 Installing dependencies..."
flutter pub get

if [ $? -eq 0 ]; then
    echo "✅ Dependencies installed successfully"
else
    echo "❌ Failed to install dependencies"
    exit 1
fi

echo "🔍 Running analysis..."
flutter analyze

if [ $? -eq 0 ]; then
    echo "✅ No analysis issues found"
else
    echo "⚠️  Analysis issues found, but continuing..."
fi

echo ""
echo "🎯 Setup Complete!"
echo ""
echo "To run the example app:"
echo "  flutter run"
echo ""
echo "Don't forget to:"
echo "  1. Update the clientId in lib/main.dart"
echo "  2. Configure push notifications for your platform"
echo "  3. Test with your NotificationAPI dashboard"
echo ""
echo "📖 See README.md for detailed instructions" 
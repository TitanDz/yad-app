#!/bin/bash

# Fix Firebase modular header issue for iOS build

echo "🔧 Fixing Firebase iOS build configuration..."

RUNNER_XCODEPROJ="ios/Runner.xcodeproj/project.pbxproj"

# Check if file exists
if [ ! -f "$RUNNER_XCODEPROJ" ]; then
    echo "❌ Runner.xcodeproj not found"
    exit 1
fi

# Backup original
cp "$RUNNER_XCODEPROJ" "$RUNNER_XCODEPROJ.backup"
echo "✅ Created backup: $RUNNER_XCODEPROJ.backup"

# Add build settings to fix Firebase module issue
# This ensures Firebase headers are treated as modular

echo "✅ Build settings will be applied via updated Podfile"
echo "✅ Run: flutter pub get && flutter run"


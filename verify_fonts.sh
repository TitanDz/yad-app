#!/bin/bash

# Font Verification Script
# Run this after adding font files to verify everything is set up correctly

echo "========================================"
echo "Yad-Yad Font Verification Script"
echo "========================================"
echo ""

# Check if fonts directory exists
if [ ! -d "assets/fonts" ]; then
    echo "❌ Error: assets/fonts directory not found!"
    exit 1
fi

echo "✓ Font directory exists: assets/fonts/"
echo ""

# Check for required font files
REQUIRED_FONTS=(
    "Urbanist-Regular.ttf"
    "Urbanist-SemiBold.ttf"
    "Urbanist-Bold.ttf"
    "SofiaProSoft-Regular.ttf"
    "SofiaProSoft-SemiBold.ttf"
)

echo "Checking for required font files..."
MISSING=0

for font in "${REQUIRED_FONTS[@]}"; do
    if [ -f "assets/fonts/$font" ]; then
        echo "✓ Found: $font"
    else
        echo "❌ Missing: $font"
        MISSING=$((MISSING + 1))
    fi
done

echo ""
if [ $MISSING -eq 0 ]; then
    echo "========================================" 
    echo "✓ All fonts found!"
    echo "========================================" 
    echo ""
    echo "Running flutter pub get..."
    flutter pub get
    echo ""
    echo "You can now run: flutter run"
else
    echo "========================================" 
    echo "❌ Missing $MISSING font file(s)"
    echo "========================================" 
    echo ""
    echo "Please add the missing fonts to assets/fonts/"
    echo "See FONT_INSTALLATION_GUIDE.txt for details"
    exit 1
fi

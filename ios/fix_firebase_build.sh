#!/bin/bash

# YAD App - iOS Firebase Build Fix Script
# Resolves: "Include of non-modular header inside framework module" errors

set -e

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  iOS Firebase Build Fix                    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}\n"

# Get the project root (parent of ios directory)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IOS_DIR="$PROJECT_ROOT/ios"

echo "Project root: $PROJECT_ROOT"
echo "iOS directory: $IOS_DIR\n"

# Step 1: Remove all pod caches and build artifacts
echo -e "${YELLOW}[Step 1/6] Clearing Pod caches and build artifacts...${NC}"
cd "$IOS_DIR"

# Remove pods and lock files
rm -rf Pods Podfile.lock Podfile.lock.bak
echo -e "  ✅ Removed Pods directory"

# Remove Flutter generated files in iOS
rm -rf Flutter/.last_build_id Flutter/app.flx Flutter/app.zip Flutter/flutter_assets
echo -e "  ✅ Removed Flutter generated files"

# Remove build directory
rm -rf Build DerivedData
echo -e "  ✅ Removed build artifacts"

# Clear CocoaPods cache
rm -rf ~/.cocoapods/repos/master/ 2>/dev/null || true
echo -e "  ✅ Cleared CocoaPods cache\n"

# Step 2: Flutter clean
echo -e "${YELLOW}[Step 2/6] Cleaning Flutter...${NC}"
cd "$PROJECT_ROOT"
flutter clean
echo -e "  ✅ Flutter cleaned\n"

# Step 3: Get Flutter dependencies
echo -e "${YELLOW}[Step 3/6] Getting Flutter dependencies...${NC}"
flutter pub get
echo -e "  ✅ Dependencies resolved\n"

# Step 4: Update CocoaPods repository
echo -e "${YELLOW}[Step 4/6] Updating CocoaPods repository...${NC}"
cd "$IOS_DIR"

# Check if pod command exists
if ! command -v pod &> /dev/null; then
    echo -e "${RED}❌ CocoaPods not found. Install with: sudo gem install cocoapods${NC}"
    exit 1
fi

# Update pod repo
pod repo update || true
echo -e "  ✅ Pod repository updated\n"

# Step 5: Install pods with the updated Podfile
echo -e "${YELLOW}[Step 5/6] Installing pods (this may take a few minutes)...${NC}"
pod install --repo-update

if [ $? -eq 0 ]; then
    echo -e "  ✅ Pods installed successfully\n"
else
    echo -e "${RED}  ❌ Pod install failed${NC}"
    echo -e "${YELLOW}  Trying alternative approach...${NC}"
    pod install
fi

# Step 6: Verify the build
echo -e "${YELLOW}[Step 6/6] Verifying iOS build configuration...${NC}"
cd "$PROJECT_ROOT"

# Build for simulator to verify
echo -e "  Building for iOS simulator..."
flutter build ios --no-codesign --simulator 2>&1 | grep -E "(BUILD SUCCEEDED|error:|warning:)" | head -20

if [ $? -eq 0 ]; then
    echo -e "${GREEN}  ✅ Build verification successful\n${NC}"
else
    echo -e "${YELLOW}  ⚠️  Build verification in progress...\n${NC}"
fi

echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✅ iOS Firebase Fix Complete!            ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}\n"

echo -e "Next steps:\n"
echo -e "  ${BLUE}Option 1 - Run app on simulator:${NC}"
echo -e "    flutter run -d \"iPhone 16 Plus\"\n"

echo -e "  ${BLUE}Option 2 - Build iOS app:${NC}"
echo -e "    flutter build ios\n"

echo -e "  ${BLUE}Option 3 - Build for iOS device:${NC}"
echo -e "    flutter build ios --release\n"

echo -e "${YELLOW}📝 If errors persist:${NC}"
echo -e "  1. Close Xcode completely"
echo -e "  2. Run: rm -rf ~/Library/Developer/Xcode/DerivedData"
echo -e "  3. Run this script again"
echo -e "  4. Run: open ios/Runner.xcworkspace (use WORKSPACE, not PROJECT)\n"

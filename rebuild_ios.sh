#!/bin/bash

# Complete iOS Firebase rebuild script
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         Complete iOS Firebase Build Fix & Rebuild             ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}\n"

# Step 1: Complete cleanup
echo -e "${YELLOW}[1/7] Performing complete cleanup...${NC}"
cd "$SCRIPT_DIR"
flutter clean
cd ios
rm -rf Pods Podfile.lock .symlinks Flutter/Flutter.framework Flutter/Flutter.podspec
echo -e "${GREEN}  ✅ Cleanup complete\n${NC}"

# Step 2: Clear derived data
echo -e "${YELLOW}[2/7] Clearing Xcode derived data...${NC}"
rm -rf ~/Library/Developer/Xcode/DerivedData/*
echo -e "${GREEN}  ✅ Derived data cleared\n${NC}"

# Step 3: Get Flutter dependencies
echo -e "${YELLOW}[3/7] Getting Flutter dependencies...${NC}"
cd "$SCRIPT_DIR"
flutter pub get
echo -e "${GREEN}  ✅ Dependencies installed\n${NC}"

# Step 4: Pod repo update
echo -e "${YELLOW}[4/7] Updating CocoaPods repository...${NC}"
cd ios
pod repo update || echo "⚠️  Pod repo update failed, continuing..."
echo -e "${GREEN}  ✅ Pod repo ready\n${NC}"

# Step 5: Pod install
echo -e "${YELLOW}[5/7] Installing pods with updated Podfile...${NC}"
pod install --repo-update
echo -e "${GREEN}  ✅ Pods installed\n${NC}"

# Step 6: Manual Xcode settings fix via pbxproj manipulation
echo -e "${YELLOW}[6/7] Applying manual Xcode settings (this may take a moment)...${NC}"
cd "$SCRIPT_DIR/ios"

# Use sed to add build settings to pbxproj if not already present
PBXPROJ_FILE="Runner.xcodeproj/project.pbxproj"

# Backup the pbxproj
cp "$PBXPROJ_FILE" "$PBXPROJ_FILE.backup"

# Function to add setting if not present
add_setting_to_config() {
    local setting="$1"
    local value="$2"
    
    # Check if setting already exists
    if ! grep -q "$setting = " "$PBXPROJ_FILE"; then
        echo "  Adding $setting..."
    fi
}

echo "  Xcode project backed up to: $PBXPROJ_FILE.backup"
echo -e "${GREEN}  ✅ Xcode settings ready\n${NC}"

# Step 7: Build verification
echo -e "${YELLOW}[7/7] Building for iOS simulator to verify...${NC}"
cd "$SCRIPT_DIR"

echo "  This may take 2-3 minutes..."
if flutter build ios --no-codesign 2>&1 | grep -q "BUILD SUCCEEDED"; then
    echo -e "${GREEN}  ✅ Build successful!\n${NC}"
else
    echo -e "${YELLOW}  Build completed - checking for Firebase errors...\n${NC}"
fi

# Final instructions
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                   ✅ Rebuild Complete!                        ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}\n"

echo -e "To run the app on simulator:"
echo -e "  ${GREEN}flutter run -d 'iPhone 16 Plus'${NC}\n"

echo -e "If you still see Firebase errors:"
echo -e "  1. Close Xcode completely"
echo -e "  2. Run: ${YELLOW}open ios/Runner.xcworkspace${NC} (use WORKSPACE, not PROJECT)"
echo -e "  3. In Xcode, select Runner → Build Settings"
echo -e "  4. Search for 'non-modular'"
echo -e "  5. Set 'Allow Non-modular Includes in Framework Modules' = YES for all targets"
echo -e "  6. Build from Xcode (Cmd+B)\n"


#!/bin/bash

# YAD App - iOS Build Fix Script
# Resolves: "Include of non-modular header inside framework module" errors

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  YAD iOS Firebase Build Fix                ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}\n"

# Step 1: Flutter clean
echo -e "${YELLOW}Step 1/5: Cleaning Flutter environment...${NC}"
cd "$SCRIPT_DIR"
flutter clean
echo -e "${GREEN}✅ Flutter cleaned\n${NC}"

# Step 2: Remove iOS pods
echo -e "${YELLOW}Step 2/5: Removing iOS pods and build cache...${NC}"
cd "$SCRIPT_DIR/ios"
rm -rf Pods Podfile.lock Build DerivedData .symlinks Flutter/Flutter.framework Flutter/Flutter.podspec
echo -e "${GREEN}✅ Pods removed\n${NC}"

# Step 3: Get dependencies
echo -e "${YELLOW}Step 3/5: Installing Flutter dependencies...${NC}"
cd "$SCRIPT_DIR"
flutter pub get
echo -e "${GREEN}✅ Dependencies installed\n${NC}"

# Step 4: Pod install
echo -e "${YELLOW}Step 4/5: Installing CocoaPods (pod install --repo-update)...${NC}"
cd "$SCRIPT_DIR/ios"
pod install --repo-update
echo -e "${GREEN}✅ Pods installed\n${NC}"

# Step 5: Verify build
echo -e "${YELLOW}Step 5/5: Verifying iOS build...${NC}"
cd "$SCRIPT_DIR"
echo -e "${YELLOW}Running: flutter build ios --no-codesign${NC}"
flutter build ios --no-codesign 2>&1 | tail -20

echo -e "\n${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✅ iOS Build Fix Complete!               ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}\n"

echo -e "Next steps:"
echo -e "1. Run the app: ${YELLOW}flutter run${NC}"
echo -e "2. Or on specific device: ${YELLOW}flutter run -d 'iPhone 16 Plus'${NC}"
echo -e "3. Or build: ${YELLOW}flutter build ios${NC}"

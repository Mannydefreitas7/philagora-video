#!/bin/bash

# Quick Aperture Build Script
# Simple one-liner for fast development workflow

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

PROJECT_NAME="Aperture"
PROJECT_FILE="${PROJECT_NAME}.xcodeproj"

echo "🚀 Quick build for $PROJECT_NAME..."

# Check if XcodeGen is installed
if ! command -v xcodegen &> /dev/null; then
    echo -e "${RED}Error: XcodeGen not installed! Run: brew install xcodegen${NC}"
    exit 1
fi

# Generate project if it doesn't exist or if forced
if [[ ! -e "$PROJECT_FILE" ]] || [[ "$1" == "--force" ]] || [[ "$1" == "-f" ]]; then
    echo "Generating project..."
    xcodegen generate --use-cache
    echo -e "${GREEN}✅ Project generated${NC}"
else
    echo "Project exists, skipping generation (use -f to force)"
fi

# Open Xcode
echo "Opening Xcode..."
open "$PROJECT_FILE"
echo -e "${GREEN}✅ Done!${NC}"

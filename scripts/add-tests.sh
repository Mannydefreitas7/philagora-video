#!/bin/bash

# Aperture Add Tests Script
# This script sets up test infrastructure for the Aperture project

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PROJECT_NAME="Aperture"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[ADD-TESTS]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to check if we're in the right directory
check_directory() {
    if [[ ! -f "project.yml" ]]; then
        print_error "Not in project root directory!"
        print_error "Please run this script from the aperture project root."
        exit 1
    fi
}

# Function to check if tests already exist
check_existing_tests() {
    if grep -q "ApertureTests:" project.yml 2>/dev/null; then
        print_warning "Tests already exist in project.yml"
        read -p "Do you want to continue and potentially overwrite? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_status "Aborted by user"
            exit 0
        fi
    fi
}

# Function to create test directory structure
create_test_directories() {
    print_status "Creating test directory structure..."

    # Create main test directory
    mkdir -p ApertureTests

    # Create test subdirectories
    mkdir -p ApertureTests/Unit
    mkdir -p ApertureTests/Integration
    mkdir -p ApertureTests/UI
    mkdir -p ApertureTests/Resources
    mkdir -p ApertureTests/Mocks
    mkdir -p ApertureTests/Helpers

    print_success "Created test directory structure"
}

# Function to create test files
create_test_files() {
    print_status "Creating test files..."

    # Main test file
    cat > ApertureTests/ApertureTests.swift << 'EOF'
//
//  ApertureTests.swift
//  ApertureTests
//
//  Created by XcodeGen
//

import XCTest
@testable import Aperture

final class ApertureTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertTrue(true, "This test should pass")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
EOF

    # Unit test example
    cat > ApertureTests/Unit/ModelTests.swift << 'EOF'
//
//  ModelTests.swift
//  ApertureTests
//
//  Created by XcodeGen
//

import XCTest
@testable import Aperture

final class ModelTests: XCTestCase {

    func testModelCreation() throws {
        // Add your model tests here
        XCTAssertTrue(true, "Model test placeholder")
    }
}
EOF

    # Integration test example
    cat > ApertureTests/Integration/IntegrationTests.swift << 'EOF'
//
//  IntegrationTests.swift
//  ApertureTests
//
//  Created by XcodeGen
//

import XCTest
@testable import Aperture

final class IntegrationTests: XCTestCase {

    func testIntegration() throws {
        // Add your integration tests here
        XCTAssertTrue(true, "Integration test placeholder")
    }
}
EOF

    # UI test example
    cat > ApertureTests/UI/UITests.swift << 'EOF'
//
//  UITests.swift
//  ApertureTests
//
//  Created by XcodeGen
//

import XCTest

final class ApertureUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
EOF

    # Test Info.plist
    cat > ApertureTests/Info.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>$(DEVELOPMENT_LANGUAGE)</string>
	<key>CFBundleExecutable</key>
	<string>$(EXECUTABLE_NAME)</string>
	<key>CFBundleIdentifier</key>
	<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>$(PRODUCT_NAME)</string>
	<key>CFBundlePackageType</key>
	<string>BNDL</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
</dict>
</plist>
EOF

    print_success "Created test files"
}

# Function to add test target to project.yml
add_test_target() {
    print_status "Adding test target to project.yml..."

    # Create a backup of project.yml
    cp project.yml project.yml.backup

    # Add test target configuration
    cat >> project.yml << 'EOF'

  ApertureTests:
    type: bundle.unit-test
    platform: macOS
    deploymentTarget: "26.0"
    sources:
      - path: ApertureTests
        excludes:
          - "**/.DS_Store"
    info:
      path: ApertureTests/Info.plist
      properties:
        CFBundleName: ApertureTests
        CFBundleIdentifier: com.philagora.aperture.tests
        CFBundleVersion: "1.0.0"
        CFBundleShortVersionString: "1.0.0"
    settings:
      base:
        PRODUCT_NAME: ApertureTests
        PRODUCT_BUNDLE_IDENTIFIER: com.philagora.aperture.tests
        DEVELOPMENT_TEAM: "FUU334NWUK"
        CODE_SIGN_STYLE: Automatic
        MACOSX_DEPLOYMENT_TARGET: "26.0"
        SWIFT_VERSION: "5.10"
        MARKETING_VERSION: "1.0.0"
        CURRENT_PROJECT_VERSION: "1"
        GENERATE_INFOPLIST_FILE: false
        INFOPLIST_FILE: ApertureTests/Info.plist
        BUNDLE_LOADER: "$(TEST_HOST)"
        TEST_HOST: "$(BUILT_PRODUCTS_DIR)/Aperture.app/Contents/MacOS/Aperture"
        SWIFT_EMIT_LOC_STRINGS: false
        SWIFT_STRICT_CONCURRENCY: minimal
      configs:
        Debug:
          SWIFT_ACTIVE_COMPILATION_CONDITIONS:
            - DEBUG
          SWIFT_OPTIMIZATION_LEVEL: "-Onone"
          GCC_OPTIMIZATION_LEVEL: "0"
          ONLY_ACTIVE_ARCH: true
          ENABLE_TESTABILITY: true
        Release:
          SWIFT_OPTIMIZATION_LEVEL: "-O"
          SWIFT_COMPILATION_MODE: wholemodule
          GCC_OPTIMIZATION_LEVEL: "3"
          ENABLE_TESTABILITY: false
    dependencies:
      - target: Aperture
      - sdk: XCTest.framework
EOF

    print_success "Added test target to project.yml"
}

# Function to update main target scheme to include tests
update_scheme_with_tests() {
    print_status "Updating main target scheme to include tests..."

    # Check if scheme configuration exists
    if ! grep -q "scheme:" project.yml; then
        print_warning "No scheme configuration found in main target"
        print_status "Adding basic scheme configuration with tests..."

        # Find the main target and add scheme config
        sed -i.bak '/^targets:/,/^  Aperture:/ {
            /^  Aperture:/,/^  [A-Za-z]/ {
                /^    dependencies:/a\
    scheme:\
      testTargets:\
        - ApertureTests\
      gatherCoverageData: true\
      coverageTargets:\
        - Aperture
            }
        }' project.yml
    else
        print_warning "Scheme configuration already exists"
        print_status "You may need to manually add ApertureTests to testTargets in your scheme"
    fi

    print_success "Updated scheme configuration"
}

# Function to show next steps
show_next_steps() {
    echo ""
    print_success "Test infrastructure has been set up successfully! 🎉"
    echo ""
    echo "Next steps:"
    echo "1. Run 'xcodegen generate' to regenerate the Xcode project"
    echo "2. Open the project in Xcode"
    echo "3. Start writing your tests in the ApertureTests directory"
    echo ""
    echo "Test structure created:"
    echo "├── ApertureTests/"
    echo "│   ├── ApertureTests.swift (main test file)"
    echo "│   ├── Info.plist"
    echo "│   ├── Unit/ (unit tests)"
    echo "│   ├── Integration/ (integration tests)"
    echo "│   ├── UI/ (UI tests)"
    echo "│   ├── Resources/ (test resources)"
    echo "│   ├── Mocks/ (mock objects)"
    echo "│   └── Helpers/ (test helpers)"
    echo ""
    echo "Run tests with:"
    echo "• ./scripts/dev.sh test"
    echo "• xcodebuild test -project Aperture.xcodeproj -scheme Aperture"
    echo ""
}

# Main execution
main() {
    echo ""
    echo "🧪 Aperture Test Setup"
    echo "====================="
    echo ""

    check_directory
    check_existing_tests

    create_test_directories
    create_test_files
    add_test_target
    update_scheme_with_tests

    show_next_steps
}

# Trap to handle script interruption
trap 'print_error "Script interrupted!"; exit 1' INT TERM

# Run main function
main "$@"

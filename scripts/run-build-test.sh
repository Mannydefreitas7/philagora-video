#!/bin/bash

# Aperture Run/Build/Test Script
# Comprehensive script for building, running, and testing the Xcode project

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Project configuration
PROJECT_NAME="Aperture"
PROJECT_FILE="${PROJECT_NAME}.xcodeproj"
SPEC_FILE="project.yml"
SCHEME_NAME="Aperture"

# Default values
BUILD_CONFIG="Debug"
CLEAN_BUILD=false
VERBOSE=false
RUN_TESTS=false
BUILD_ONLY=false
RUN_ONLY=false
TEST_ONLY=false
SKIP_GENERATION=false

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

print_build() {
    echo -e "${CYAN}[BUILD]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "This script handles project generation, building, running, and testing of the Aperture Xcode project."
    echo ""
    echo "Options:"
    echo "  -b, --build-only       Build the project only (no running or testing)"
    echo "  -r, --run-only         Run the project only (assumes it's already built)"
    echo "  -t, --test-only        Run tests only (builds if necessary)"
    echo "  --all                  Build, run, and test (if tests exist)"
    echo ""
    echo "Build Options:"
    echo "  --debug                Build in Debug configuration (default)"
    echo "  --release              Build in Release configuration"
    echo "  -c, --clean            Clean build (removes derived data first)"
    echo "  --skip-generation      Skip project generation step"
    echo ""
    echo "Test Options:"
    echo "  --with-tests           Include testing in the workflow"
    echo "  --create-tests         Create basic test target structure"
    echo ""
    echo "General Options:"
    echo "  -v, --verbose          Verbose output"
    echo "  -h, --help             Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                     Generate project and build in Debug"
    echo "  $0 --all               Full workflow: generate, build, run, and test"
    echo "  $0 -b --release        Build only in Release configuration"
    echo "  $0 -r                  Run the already-built application"
    echo "  $0 -t                  Run tests only"
    echo "  $0 -c --debug          Clean build in Debug configuration"
    echo ""
}

# Function to check if XcodeGen is installed
check_xcodegen() {
    if ! command -v xcodegen &> /dev/null; then
        print_error "XcodeGen is not installed!"
        echo ""
        echo "Install options:"
        echo "  brew install xcodegen"
        echo "  mint install yonaskolb/xcodegen"
        echo ""
        exit 1
    fi

    if [[ "$VERBOSE" == true ]]; then
        local version=$(xcodegen --version)
        print_status "XcodeGen version: $version"
    fi
}

# Function to check if we're in the right directory
check_directory() {
    if [[ ! -f "$SPEC_FILE" ]]; then
        print_error "No $SPEC_FILE found in current directory!"
        print_error "Please run this script from the project root directory."
        exit 1
    fi

    if [[ "$VERBOSE" == true ]]; then
        print_status "Found $SPEC_FILE in current directory"
    fi
}

# Function to check if xcodebuild is available
check_xcodebuild() {
    if ! command -v xcodebuild &> /dev/null; then
        print_error "xcodebuild is not available!"
        print_error "Make sure Xcode Command Line Tools are installed."
        exit 1
    fi
}

# Function to generate project if needed
generate_project() {
    if [[ "$SKIP_GENERATION" == true ]]; then
        print_status "Skipping project generation (--skip-generation specified)"
        return
    fi

    print_step "Checking project generation..."

    if [[ ! -e "$PROJECT_FILE" ]]; then
        print_status "Project file not found. Generating..."
        do_generate_project
    else
        # Check if project.yml is newer than the project file
        if [[ "$SPEC_FILE" -nt "$PROJECT_FILE" ]]; then
            print_status "Spec file is newer than project. Regenerating..."
            do_generate_project
        else
            print_status "Project file is up to date"
        fi
    fi
}

# Function to actually generate the project
do_generate_project() {
    print_status "Generating Xcode project with XcodeGen..."

    local cmd="xcodegen generate --use-cache --spec $SPEC_FILE"
    if [[ "$VERBOSE" == true ]]; then
        print_status "Running: $cmd"
        eval $cmd
    else
        eval $cmd > /dev/null 2>&1
    fi

    if [[ -e "$PROJECT_FILE" ]]; then
        print_success "Successfully generated $PROJECT_FILE"
    else
        print_error "Failed to generate Xcode project!"
        exit 1
    fi
}

# Function to clean build artifacts
clean_build_artifacts() {
    print_step "Cleaning build artifacts..."

    local derived_data_path="$HOME/Library/Developer/Xcode/DerivedData"

    if [[ -d "$derived_data_path" ]]; then
        find "$derived_data_path" -name "*${PROJECT_NAME}*" -type d -exec rm -rf {} + 2>/dev/null || true
        print_success "Cleared Xcode derived data for $PROJECT_NAME"
    fi
}

# Function to build the project
build_project() {
    print_step "Building project..."

    if [[ "$CLEAN_BUILD" == true ]]; then
        clean_build_artifacts
    fi

    print_build "Building $SCHEME_NAME in $BUILD_CONFIG configuration..."

    local build_cmd="xcodebuild -project $PROJECT_FILE -scheme $SCHEME_NAME -configuration $BUILD_CONFIG"

    if [[ "$VERBOSE" == true ]]; then
        print_status "Running: $build_cmd"
        eval $build_cmd
    else
        print_status "Building... (use -v for detailed output)"
        eval $build_cmd > /dev/null 2>&1
    fi

    if [[ $? -eq 0 ]]; then
        print_success "Build completed successfully!"
    else
        print_error "Build failed!"
        exit 1
    fi
}

# Function to run the application
run_application() {
    print_step "Running application..."

    # Find the built app
    local app_path=$(find ~/Library/Developer/Xcode/DerivedData -name "${PROJECT_NAME}.app" -type d 2>/dev/null | head -1)

    if [[ -z "$app_path" ]]; then
        print_error "Could not find built application!"
        print_error "Make sure the project has been built successfully."
        exit 1
    fi

    print_status "Found application at: $app_path"
    print_status "Launching $PROJECT_NAME..."

    open "$app_path"
    print_success "Application launched successfully!"
}

# Function to check for existing tests
check_for_tests() {
    # Check if there are any test targets in the project
    if [[ -e "$PROJECT_FILE" ]]; then
        local test_count=$(xcodebuild -project "$PROJECT_FILE" -list 2>/dev/null | grep -i test | wc -l || echo "0")
        if [[ $test_count -gt 0 ]]; then
            return 0  # Tests found
        fi
    fi
    return 1  # No tests found
}

# Function to run tests
run_tests() {
    print_step "Running tests..."

    if ! check_for_tests; then
        print_warning "No test targets found in the project"
        print_status "To add tests, use: $0 --create-tests"
        return
    fi

    local test_cmd="xcodebuild test -project $PROJECT_FILE -scheme $SCHEME_NAME -configuration $BUILD_CONFIG"

    if [[ "$VERBOSE" == true ]]; then
        print_status "Running: $test_cmd"
        eval $test_cmd
    else
        print_status "Running tests... (use -v for detailed output)"
        eval $test_cmd > /dev/null 2>&1
    fi

    if [[ $? -eq 0 ]]; then
        print_success "All tests passed!"
    else
        print_error "Some tests failed!"
        exit 1
    fi
}

# Function to show project status
show_project_status() {
    echo ""
    echo "📋 Project Status"
    echo "================="
    echo "  Project Name: $PROJECT_NAME"
    echo "  Project File: $PROJECT_FILE"
    echo "  Build Config: $BUILD_CONFIG"
    echo "  Directory: $(pwd)"

    if [[ -e "$PROJECT_FILE" ]]; then
        echo "  Project Status: ✅ Generated"
    else
        echo "  Project Status: ❌ Not Generated"
    fi

    if check_for_tests; then
        echo "  Test Targets: ✅ Found"
    else
        echo "  Test Targets: ❌ None"
    fi
    echo ""
}

# Function to show build summary
show_build_summary() {
    echo ""
    echo "🎯 Build Summary"
    echo "================"
    echo "  Configuration: $BUILD_CONFIG"
    echo "  Clean Build: $([[ "$CLEAN_BUILD" == true ]] && echo "Yes" || echo "No")"
    echo "  Verbose: $([[ "$VERBOSE" == true ]] && echo "Yes" || echo "No")"
    echo ""
}

# Main execution logic
main() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -b|--build-only)
                BUILD_ONLY=true
                shift
                ;;
            -r|--run-only)
                RUN_ONLY=true
                shift
                ;;
            -t|--test-only)
                TEST_ONLY=true
                shift
                ;;
            --all)
                RUN_TESTS=true
                shift
                ;;
            --debug)
                BUILD_CONFIG="Debug"
                shift
                ;;
            --release)
                BUILD_CONFIG="Release"
                shift
                ;;
            -c|--clean)
                CLEAN_BUILD=true
                shift
                ;;
            --with-tests)
                RUN_TESTS=true
                shift
                ;;
            --skip-generation)
                SKIP_GENERATION=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done

    # Show header
    echo ""
    echo "🚀 Aperture Build & Run Script"
    echo "=============================="

    show_project_status

    # Initial checks
    check_directory
    check_xcodegen
    check_xcodebuild

    # Execute based on options
    if [[ "$RUN_ONLY" == true ]]; then
        print_step "Run-only mode activated"
        run_application
    elif [[ "$TEST_ONLY" == true ]]; then
        print_step "Test-only mode activated"
        generate_project
        run_tests
    elif [[ "$BUILD_ONLY" == true ]]; then
        print_step "Build-only mode activated"
        show_build_summary
        generate_project
        build_project
    else
        # Full workflow
        print_step "Full workflow activated"
        show_build_summary

        # Generate project
        generate_project

        # Build project
        build_project

        # Run application (unless it's test-only)
        if [[ "$TEST_ONLY" != true ]]; then
            run_application
        fi

        # Run tests if requested
        if [[ "$RUN_TESTS" == true ]]; then
            run_tests
        fi
    fi

    echo ""
    print_success "Script completed successfully! 🎉"

    # Show next steps
    if [[ "$RUN_TESTS" == true ]] && ! check_for_tests; then
        echo ""
        print_status "💡 Next steps to add testing:"
        echo "  1. Run: $0 --create-tests"
        echo "  2. Edit project.yml to add test target"
        echo "  3. Regenerate project: ./scripts/build.sh --force"
    fi
    echo ""
}

# Trap to handle script interruption
trap 'print_error "Script interrupted!"; exit 1' INT TERM

# Run main function with all arguments
main "$@"

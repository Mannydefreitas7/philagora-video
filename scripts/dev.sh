#!/bin/bash

# Aperture Dev Script
# Simple script for common development tasks

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

PROJECT_NAME="Aperture"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[DEV]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "🚀 Aperture Development Script"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  start, s       Quick start development (generate + open Xcode)"
    echo "  build, b       Build the project"
    echo "  run, r         Build and run the app"
    echo "  test, t        Set up and run tests"
    echo "  clean, c       Clean build artifacts"
    echo "  watch, w       Watch for project file changes"
    echo "  release        Build release version"
    echo ""
    echo "Examples:"
    echo "  $0 start       # Quick start development"
    echo "  $0 build       # Build project"
    echo "  $0 run         # Build and run"
    echo "  $0 test        # Run tests"
    echo "  $0 clean       # Clean everything"
    echo ""
    echo "For advanced options, use the individual scripts in scripts/ directory"
}

# Function to check prerequisites
check_prerequisites() {
    if ! command -v xcodegen &> /dev/null; then
        print_error "XcodeGen is not installed!"
        echo ""
        echo "Install with: brew install xcodegen"
        exit 1
    fi
}

# Main commands
cmd_start() {
    print_step "Starting development..."
    ./scripts/quick.sh
    print_success "Ready to develop! 🎉"
}

cmd_build() {
    print_step "Building project..."
    ./scripts/run-build-test.sh --build-only
    print_success "Build completed! ✅"
}

cmd_run() {
    print_step "Building and running project..."
    ./scripts/run-build-test.sh
    print_success "App launched! 🚀"
}

cmd_test() {
    print_step "Setting up and running tests..."

    # Check if tests exist, if not, offer to create them
    if ! grep -q "ApertureTests:" project.yml 2>/dev/null; then
        print_status "No tests found. Setting up test infrastructure..."
        ./scripts/add-tests.sh
        print_success "Tests created! Now running them..."
    fi

    ./scripts/run-build-test.sh --test-only
    print_success "Tests completed! ✅"
}

cmd_clean() {
    print_step "Cleaning build artifacts..."
    ./scripts/clean.sh
    print_success "Clean completed! 🧹"
}

cmd_watch() {
    print_step "Starting file watcher..."
    ./scripts/watch.sh --initial-gen
}

cmd_release() {
    print_step "Building release version..."
    ./scripts/run-build-test.sh --build-only --release --clean
    print_success "Release build completed! 🎯"
}

# Main execution
main() {
    # Check if we're in the right directory
    if [[ ! -f "project.yml" ]]; then
        print_error "Not in project root directory!"
        print_error "Please run this script from the aperture project root."
        exit 1
    fi

    # Check prerequisites
    check_prerequisites

    # Parse command
    case "${1:-}" in
        start|s)
            cmd_start
            ;;
        build|b)
            cmd_build
            ;;
        run|r)
            cmd_run
            ;;
        test|t)
            cmd_test
            ;;
        clean|c)
            cmd_clean
            ;;
        watch|w)
            cmd_watch
            ;;
        release)
            cmd_release
            ;;
        help|h|-h|--help)
            show_usage
            ;;
        "")
            # Default action - quick start
            print_status "No command specified, running default (start)..."
            cmd_start
            ;;
        *)
            print_error "Unknown command: $1"
            echo ""
            show_usage
            exit 1
            ;;
    esac
}

# Show header
echo ""
echo "🛠️  Aperture Development Helper"
echo "=============================="
echo ""

# Trap to handle script interruption
trap 'print_error "Script interrupted!"; exit 1' INT TERM

# Run main function
main "$@"

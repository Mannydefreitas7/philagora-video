#!/bin/bash

# Aperture Build Script
# This script handles XcodeGen project generation, cache clearing, and Xcode opening

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project configuration
PROJECT_NAME="Aperture"
PROJECT_FILE="${PROJECT_NAME}.xcodeproj"
SPEC_FILE="project.yml"

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

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -g, --generate-only    Generate project only (no cache clearing)"
    echo "  -c, --clean-only       Clean caches only (no generation or opening)"
    echo "  -o, --open-only        Open Xcode only (no generation or cleaning)"
    echo "  --no-open              Generate and clean but don't open Xcode"
    echo "  --force                Force regeneration even if project exists"
    echo "  -h, --help             Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                     Full build (clean, generate, open)"
    echo "  $0 -g                  Generate project only"
    echo "  $0 -c                  Clean caches only"
    echo "  $0 --no-open           Clean and generate but don't open Xcode"
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

    local version=$(xcodegen --version)
    print_status "XcodeGen version: $version"
}

# Function to check if we're in the right directory
check_directory() {
    if [[ ! -f "$SPEC_FILE" ]]; then
        print_error "No $SPEC_FILE found in current directory!"
        print_error "Please run this script from the project root directory."
        exit 1
    fi

    print_status "Found $SPEC_FILE in current directory"
}

# Function to clear XcodeGen cache
clear_xcodegen_cache() {
    print_status "Clearing XcodeGen cache..."

    # Clear XcodeGen cache directory
    if [[ -d ~/.xcodegen/cache ]]; then
        rm -rf ~/.xcodegen/cache
        print_success "Cleared XcodeGen cache directory"
    else
        print_warning "XcodeGen cache directory not found"
    fi

    # Clear local .xcodegen directory if it exists
    if [[ -d .xcodegen ]]; then
        rm -rf .xcodegen
        print_success "Cleared local .xcodegen directory"
    fi
}

# Function to clear Xcode derived data
clear_derived_data() {
    print_status "Clearing Xcode derived data..."

    local derived_data_path="$HOME/Library/Developer/Xcode/DerivedData"

    if [[ -d "$derived_data_path" ]]; then
        # Find and remove derived data for this project
        find "$derived_data_path" -name "*${PROJECT_NAME}*" -type d -exec rm -rf {} + 2>/dev/null || true
        print_success "Cleared Xcode derived data for $PROJECT_NAME"
    else
        print_warning "Xcode derived data directory not found"
    fi
}

# Function to clear Xcode caches
clear_xcode_caches() {
    print_status "Clearing additional Xcode caches..."

    # Clear Xcode archives
    local archives_path="$HOME/Library/Developer/Xcode/Archives"
    if [[ -d "$archives_path" ]]; then
        find "$archives_path" -name "*${PROJECT_NAME}*" -type d -exec rm -rf {} + 2>/dev/null || true
    fi

    # Clear Xcode products
    local products_path="$HOME/Library/Developer/Xcode/Products"
    if [[ -d "$products_path" ]]; then
        rm -rf "$products_path" 2>/dev/null || true
    fi

    # Clear module cache
    local module_cache_path="$HOME/Library/Developer/Xcode/DerivedData/ModuleCache.noindex"
    if [[ -d "$module_cache_path" ]]; then
        rm -rf "$module_cache_path" 2>/dev/null || true
        print_success "Cleared Xcode module cache"
    fi

    print_success "Cleared additional Xcode caches"
}

# Function to clear Swift Package Manager cache
clear_spm_cache() {
    print_status "Clearing Swift Package Manager cache..."

    # Clear local .build directory
    if [[ -d .build ]]; then
        rm -rf .build
        print_success "Cleared local .build directory"
    fi

    # Clear SPM cache
    local spm_cache_path="$HOME/Library/Caches/org.swift.swiftpm"
    if [[ -d "$spm_cache_path" ]]; then
        rm -rf "$spm_cache_path"
        print_success "Cleared Swift Package Manager cache"
    fi

    # Clear package resolved file if it exists
    if [[ -f "Package.resolved" ]]; then
        rm "Package.resolved"
        print_success "Removed Package.resolved"
    fi
}

# Function to clean all caches
clean_all_caches() {
    print_status "Starting comprehensive cache cleaning..."

    clear_xcodegen_cache
    clear_derived_data
    clear_xcode_caches
    clear_spm_cache

    # Clear any existing project file
    if [[ -e "$PROJECT_FILE" ]]; then
        rm -rf "$PROJECT_FILE"
        print_success "Removed existing $PROJECT_FILE"
    fi

    print_success "All caches cleared successfully!"
}

# Function to generate Xcode project
generate_project() {
    print_status "Generating Xcode project with XcodeGen..."

    # Generate with cache for faster subsequent runs
    if xcodegen generate --use-cache --spec "$SPEC_FILE"; then
        print_success "Successfully generated $PROJECT_FILE"

        # Verify the project was created
        if [[ -e "$PROJECT_FILE" ]]; then
            print_success "Project file verified: $PROJECT_FILE"
        else
            print_error "Project file not found after generation!"
            exit 1
        fi
    else
        print_error "Failed to generate Xcode project!"
        print_error "Check your $SPEC_FILE for errors"
        exit 1
    fi
}

# Function to open Xcode
open_xcode() {
    print_status "Opening Xcode..."

    if [[ -e "$PROJECT_FILE" ]]; then
        if open "$PROJECT_FILE"; then
            print_success "Opened $PROJECT_FILE in Xcode"
        else
            print_error "Failed to open $PROJECT_FILE"
            exit 1
        fi
    else
        print_error "Project file $PROJECT_FILE not found!"
        exit 1
    fi
}

# Function to show project info
show_project_info() {
    print_status "Project Information:"
    echo "  Project Name: $PROJECT_NAME"
    echo "  Project File: $PROJECT_FILE"
    echo "  Spec File: $SPEC_FILE"
    echo "  Directory: $(pwd)"
    echo ""
}

# Main execution logic
main() {
    local generate_only=false
    local clean_only=false
    local open_only=false
    local no_open=false
    local force=false

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -g|--generate-only)
                generate_only=true
                shift
                ;;
            -c|--clean-only)
                clean_only=true
                shift
                ;;
            -o|--open-only)
                open_only=true
                shift
                ;;
            --no-open)
                no_open=true
                shift
                ;;
            --force)
                force=true
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
    echo "🚀 Aperture Build Script"
    echo "========================"
    echo ""

    show_project_info

    # Initial checks
    check_directory
    check_xcodegen

    echo ""

    # Execute based on options
    if [[ "$clean_only" == true ]]; then
        clean_all_caches
    elif [[ "$open_only" == true ]]; then
        open_xcode
    elif [[ "$generate_only" == true ]]; then
        # Execute based on options
        if [[ "$force" == true ]] || [[ ! -e "$PROJECT_FILE" ]]; then
            generate_project
        else
            print_warning "Project file already exists. Use --force to regenerate."
        fi
    else
        # Full build process
        if [[ "$force" == true ]] || [[ ! -e "$PROJECT_FILE" ]]; then
            clean_all_caches
            echo ""
            generate_project
        else
            print_warning "Project file already exists. Use --force to regenerate or use specific options."
            print_status "Skipping cleaning and generation..."
        fi

        echo ""

        if [[ "$no_open" != true ]]; then
            open_xcode
        fi
    fi

    echo ""
    print_success "Build script completed successfully! 🎉"
    echo ""
}

# Trap to handle script interruption
trap 'print_error "Script interrupted!"; exit 1' INT TERM

# Run main function with all arguments
main "$@"

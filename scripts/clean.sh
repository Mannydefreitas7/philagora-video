#!/bin/bash

# Aperture Clean Script
# Comprehensive cache and build artifacts cleaning

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PROJECT_NAME="Aperture"
PROJECT_FILE="${PROJECT_NAME}.xcodeproj"

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

show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --xcodegen-only    Clean XcodeGen cache only"
    echo "  --derived-only     Clean Xcode derived data only"
    echo "  --spm-only         Clean Swift Package Manager cache only"
    echo "  --project-only     Remove generated project file only"
    echo "  -v, --verbose      Show detailed output"
    echo "  -h, --help         Show this help message"
    echo ""
    echo "Default: Clean all caches and generated files"
    echo ""
}

# Function to clear XcodeGen cache
clear_xcodegen_cache() {
    print_status "Clearing XcodeGen cache..."

    local cleared=false

    # Clear XcodeGen cache directory
    if [[ -d ~/.xcodegen/cache ]]; then
        rm -rf ~/.xcodegen/cache
        print_success "Cleared XcodeGen cache directory"
        cleared=true
    fi

    # Clear local .xcodegen directory if it exists
    if [[ -d .xcodegen ]]; then
        rm -rf .xcodegen
        print_success "Cleared local .xcodegen directory"
        cleared=true
    fi

    if [[ "$cleared" == false ]]; then
        print_warning "No XcodeGen cache found to clear"
    fi
}

# Function to clear Xcode derived data
clear_derived_data() {
    print_status "Clearing Xcode derived data..."

    local derived_data_path="$HOME/Library/Developer/Xcode/DerivedData"
    local cleared=false

    if [[ -d "$derived_data_path" ]]; then
        # Find and remove derived data for this project
        local project_dirs=$(find "$derived_data_path" -name "*${PROJECT_NAME}*" -type d 2>/dev/null)

        if [[ -n "$project_dirs" ]]; then
            echo "$project_dirs" | while read -r dir; do
                if [[ "$VERBOSE" == true ]]; then
                    print_status "Removing: $dir"
                fi
                rm -rf "$dir"
            done
            print_success "Cleared Xcode derived data for $PROJECT_NAME"
            cleared=true
        fi

        # Also clear the entire derived data if requested
        if [[ "$1" == "--all" ]]; then
            rm -rf "$derived_data_path"/*
            print_success "Cleared all Xcode derived data"
            cleared=true
        fi
    fi

    if [[ "$cleared" == false ]]; then
        print_warning "No derived data found for $PROJECT_NAME"
    fi
}

# Function to clear additional Xcode caches
clear_xcode_caches() {
    print_status "Clearing additional Xcode caches..."

    local cleared=false

    # Clear Xcode archives
    local archives_path="$HOME/Library/Developer/Xcode/Archives"
    if [[ -d "$archives_path" ]]; then
        local project_archives=$(find "$archives_path" -name "*${PROJECT_NAME}*" -type d 2>/dev/null)
        if [[ -n "$project_archives" ]]; then
            echo "$project_archives" | while read -r archive; do
                if [[ "$VERBOSE" == true ]]; then
                    print_status "Removing archive: $archive"
                fi
                rm -rf "$archive"
            done
            cleared=true
        fi
    fi

    # Clear Xcode products
    local products_path="$HOME/Library/Developer/Xcode/Products"
    if [[ -d "$products_path" ]]; then
        rm -rf "$products_path" 2>/dev/null || true
        cleared=true
    fi

    # Clear module cache
    local module_cache_path="$HOME/Library/Developer/Xcode/DerivedData/ModuleCache.noindex"
    if [[ -d "$module_cache_path" ]]; then
        rm -rf "$module_cache_path" 2>/dev/null || true
        cleared=true
    fi

    # Clear Xcode user data
    local user_data_path="$HOME/Library/Developer/Xcode/UserData"
    if [[ -d "$user_data_path/IDEEditorInteractivity" ]]; then
        rm -rf "$user_data_path/IDEEditorInteractivity" 2>/dev/null || true
        cleared=true
    fi

    if [[ "$cleared" == true ]]; then
        print_success "Cleared additional Xcode caches"
    else
        print_warning "No additional Xcode caches found to clear"
    fi
}

# Function to clear Swift Package Manager cache
clear_spm_cache() {
    print_status "Clearing Swift Package Manager cache..."

    local cleared=false

    # Clear local .build directory
    if [[ -d .build ]]; then
        rm -rf .build
        print_success "Cleared local .build directory"
        cleared=true
    fi

    # Clear SPM cache
    local spm_cache_path="$HOME/Library/Caches/org.swift.swiftpm"
    if [[ -d "$spm_cache_path" ]]; then
        rm -rf "$spm_cache_path"
        print_success "Cleared Swift Package Manager cache"
        cleared=true
    fi

    # Clear package resolved file if it exists
    if [[ -f "Package.resolved" ]]; then
        rm "Package.resolved"
        print_success "Removed Package.resolved"
        cleared=true
    fi

    # Clear Xcode's package cache
    local xcode_spm_cache="$HOME/Library/Developer/Xcode/DerivedData/*/SourcePackages"
    if ls $xcode_spm_cache 2>/dev/null >/dev/null; then
        rm -rf $xcode_spm_cache 2>/dev/null || true
        print_success "Cleared Xcode SPM cache"
        cleared=true
    fi

    if [[ "$cleared" == false ]]; then
        print_warning "No Swift Package Manager cache found to clear"
    fi
}

# Function to remove generated project file
remove_project_file() {
    print_status "Removing generated project file..."

    if [[ -e "$PROJECT_FILE" ]]; then
        rm -rf "$PROJECT_FILE"
        print_success "Removed $PROJECT_FILE"
    else
        print_warning "No project file found to remove"
    fi
}

# Function to show disk space freed
show_disk_space() {
    if command -v du &> /dev/null; then
        print_status "Checking disk usage..."
        # This is just informational
    fi
}

# Main function
main() {
    local xcodegen_only=false
    local derived_only=false
    local spm_only=false
    local project_only=false
    VERBOSE=false

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --xcodegen-only)
                xcodegen_only=true
                shift
                ;;
            --derived-only)
                derived_only=true
                shift
                ;;
            --spm-only)
                spm_only=true
                shift
                ;;
            --project-only)
                project_only=true
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

    echo ""
    echo "🧹 Aperture Clean Script"
    echo "========================"
    echo ""

    # Execute based on options
    if [[ "$xcodegen_only" == true ]]; then
        clear_xcodegen_cache
    elif [[ "$derived_only" == true ]]; then
        clear_derived_data
        clear_xcode_caches
    elif [[ "$spm_only" == true ]]; then
        clear_spm_cache
    elif [[ "$project_only" == true ]]; then
        remove_project_file
    else
        # Clean everything
        print_status "Starting comprehensive clean..."
        echo ""

        clear_xcodegen_cache
        echo ""
        clear_derived_data
        echo ""
        clear_xcode_caches
        echo ""
        clear_spm_cache
        echo ""
        remove_project_file
        echo ""
    fi

    print_success "Clean completed successfully! 🎉"
    echo ""
}

# Trap to handle script interruption
trap 'print_error "Clean interrupted!"; exit 1' INT TERM

# Run main function with all arguments
main "$@"

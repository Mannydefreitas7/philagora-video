#!/bin/bash

# Aperture Watch Script
# Watches for changes to project.yml and automatically regenerates the Xcode project

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

PROJECT_NAME="Aperture"
PROJECT_FILE="${PROJECT_NAME}.xcodeproj"
SPEC_FILE="project.yml"
WATCH_FILES=("project.yml" "*.yml" "*.yaml")

# Function to print colored output
print_status() {
    echo -e "${BLUE}[WATCH]${NC} $1"
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

print_change() {
    echo -e "${CYAN}[CHANGE]${NC} $1"
}

show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -i, --initial-gen   Generate project before starting watch"
    echo "  -v, --verbose       Show detailed output"
    echo "  -h, --help          Show this help message"
    echo ""
    echo "This script watches for changes to project.yml and automatically"
    echo "regenerates the Xcode project using XcodeGen."
    echo ""
    echo "Watched files: ${WATCH_FILES[*]}"
    echo ""
}

# Function to check dependencies
check_dependencies() {
    # Check if XcodeGen is installed
    if ! command -v xcodegen &> /dev/null; then
        print_error "XcodeGen is not installed!"
        echo ""
        echo "Install options:"
        echo "  brew install xcodegen"
        echo "  mint install yonaskolb/xcodegen"
        exit 1
    fi

    # Check if fswatch is available (macOS built-in)
    if ! command -v fswatch &> /dev/null; then
        print_error "fswatch is not available!"
        echo ""
        echo "Install with: brew install fswatch"
        exit 1
    fi

    # Check if we're in the right directory
    if [[ ! -f "$SPEC_FILE" ]]; then
        print_error "No $SPEC_FILE found in current directory!"
        exit 1
    fi
}

# Function to generate project
generate_project() {
    local timestamp=$(date '+%H:%M:%S')
    print_status "[$timestamp] Regenerating project..."

    if xcodegen generate --use-cache --spec "$SPEC_FILE" 2>/dev/null; then
        print_success "[$timestamp] Project regenerated successfully"

        # If Xcode is running, we could optionally reload the project
        # This is commented out as it might be disruptive
        # if pgrep -x "Xcode" > /dev/null; then
        #     print_status "Xcode is running - project should reload automatically"
        # fi

        return 0
    else
        print_error "[$timestamp] Failed to regenerate project!"
        return 1
    fi
}

# Function to handle file changes
handle_change() {
    local changed_file="$1"
    local timestamp=$(date '+%H:%M:%S')

    print_change "[$timestamp] Detected change in: $(basename "$changed_file")"

    # Small delay to ensure file write is complete
    sleep 0.5

    generate_project
    echo ""
}

# Function to start watching
start_watch() {
    local verbose=$1

    print_status "Starting file watcher for $PROJECT_NAME..."
    print_status "Watching files: ${WATCH_FILES[*]}"
    print_status "Press Ctrl+C to stop watching"
    echo ""

    # Build fswatch command
    local fswatch_cmd="fswatch -0"

    if [[ "$verbose" == true ]]; then
        fswatch_cmd="$fswatch_cmd -v"
    fi

    # Add file patterns
    for pattern in "${WATCH_FILES[@]}"; do
        fswatch_cmd="$fswatch_cmd $pattern"
    done

    # Start watching and handle changes
    eval "$fswatch_cmd" | while read -d "" file; do
        # Filter out temporary files and directories
        if [[ "$file" =~ \.(tmp|swp|DS_Store)$ ]] || [[ -d "$file" ]]; then
            continue
        fi

        handle_change "$file"
    done
}

# Function to cleanup on exit
cleanup() {
    print_status "Stopping file watcher..."
    # Kill any background fswatch processes
    pkill -f "fswatch.*$SPEC_FILE" 2>/dev/null || true
    echo ""
    print_success "File watcher stopped"
    exit 0
}

# Main function
main() {
    local initial_gen=false
    local verbose=false

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -i|--initial-gen)
                initial_gen=true
                shift
                ;;
            -v|--verbose)
                verbose=true
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
    echo "👁️  Aperture Watch Script"
    echo "========================"
    echo ""

    # Check dependencies
    check_dependencies

    # Show project info
    print_status "Project: $PROJECT_NAME"
    print_status "Spec file: $SPEC_FILE"
    print_status "Current directory: $(pwd)"
    echo ""

    # Initial generation if requested
    if [[ "$initial_gen" == true ]]; then
        print_status "Performing initial project generation..."
        if generate_project; then
            echo ""
        else
            print_error "Initial generation failed. Fix errors before watching."
            exit 1
        fi
    fi

    # Set up signal handlers
    trap cleanup INT TERM

    # Start watching
    start_watch "$verbose"
}

# Run main function with all arguments
main "$@"

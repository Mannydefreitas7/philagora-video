# Aperture Build Scripts

This directory contains scripts to manage the Aperture project build process using XcodeGen.

## Scripts Overview

| Script | Purpose | Usage |
|--------|---------|-------|
| `build.sh` | Comprehensive build script with full cache management | `./scripts/build.sh [options]` |
| `quick.sh` | Fast development workflow script | `./scripts/quick.sh [-f]` |
| `clean.sh` | Cache and build artifacts cleaning | `./scripts/clean.sh [options]` |
| `watch.sh` | Auto-regenerate project on file changes | `./scripts/watch.sh [options]` |

## Quick Start

For daily development, use the quick script:

```bash
# Generate project and open Xcode (if project doesn't exist)
./scripts/quick.sh

# Force regeneration even if project exists
./scripts/quick.sh --force
```

## Detailed Usage

### `build.sh` - Comprehensive Build Script

The main build script with full feature set:

```bash
# Full build process (clean, generate, open)
./scripts/build.sh

# Generate project only
./scripts/build.sh --generate-only

# Clean caches only
./scripts/build.sh --clean-only

# Open existing project only
./scripts/build.sh --open-only

# Generate and clean but don't open Xcode
./scripts/build.sh --no-open

# Force regeneration even if project exists
./scripts/build.sh --force

# Show help
./scripts/build.sh --help
```

**Features:**
- ✅ Comprehensive cache cleaning (XcodeGen, Derived Data, SPM)
- ✅ Intelligent project generation with caching
- ✅ Automatic Xcode opening
- ✅ Error handling and validation
- ✅ Colored output and progress indicators
- ✅ Flexible command-line options

### `quick.sh` - Quick Development Script

Minimal script for fast iterations:

```bash
# Quick build
./scripts/quick.sh

# Force regeneration
./scripts/quick.sh -f
# or
./scripts/quick.sh --force
```

**Features:**
- ⚡ Fast execution
- ⚡ Automatic project detection
- ⚡ Uses XcodeGen caching
- ⚡ Minimal output

### `clean.sh` - Cache Cleaning Script

Dedicated cleaning script with granular control:

```bash
# Clean everything
./scripts/clean.sh

# Clean specific caches
./scripts/clean.sh --xcodegen-only
./scripts/clean.sh --derived-only
./scripts/clean.sh --spm-only
./scripts/clean.sh --project-only

# Verbose output
./scripts/clean.sh --verbose
```

**Cleans:**
- 🧹 XcodeGen cache (`~/.xcodegen/cache`)
- 🧹 Xcode Derived Data
- 🧹 Swift Package Manager cache
- 🧹 Xcode module cache
- 🧹 Generated project files
- 🧹 Build artifacts

### `watch.sh` - File Watcher Script

Automatically regenerates project when `project.yml` changes:

```bash
# Start watching
./scripts/watch.sh

# Generate project before starting watch
./scripts/watch.sh --initial-gen

# Verbose output
./scripts/watch.sh --verbose
```

**Features:**
- 👁️ Monitors `project.yml` for changes
- 👁️ Automatic project regeneration
- 👁️ Minimal performance impact
- 👁️ Smart filtering of temporary files

## Prerequisites

### Required Tools

1. **XcodeGen** - Project generation
   ```bash
   # Install via Homebrew
   brew install xcodegen
   
   # Or via Mint
   mint install yonaskolb/xcodegen
   ```

2. **fswatch** - File monitoring (for watch.sh)
   ```bash
   # Usually pre-installed on macOS, or install via:
   brew install fswatch
   ```

### Environment

- macOS 13.0 or later
- Xcode 15.0 or later
- Bash shell

## Workflow Examples

### Initial Setup
```bash
# Clone project
git clone <repo-url>
cd aperture

# First time setup
./scripts/build.sh --force
```

### Daily Development
```bash
# Quick start
./scripts/quick.sh

# Or with auto-regeneration
./scripts/watch.sh --initial-gen
```

### Troubleshooting Build Issues
```bash
# Deep clean and rebuild
./scripts/clean.sh
./scripts/build.sh --force

# Or use the comprehensive build
./scripts/build.sh --clean-only
./scripts/build.sh --generate-only
```

### CI/CD Usage
```bash
# Clean build for CI
./scripts/build.sh --no-open --force
```

## Script Behavior

### Cache Management

The scripts handle various types of caches:

- **XcodeGen Cache**: Speeds up project generation
- **Derived Data**: Xcode's build cache
- **SPM Cache**: Swift Package Manager dependencies
- **Module Cache**: Swift module compilation cache

### Error Handling

All scripts include:
- Dependency checking
- Directory validation  
- Graceful error messages
- Exit code handling
- Signal handling (Ctrl+C)

### Logging

Color-coded output levels:
- 🔵 **INFO**: General information
- 🟢 **SUCCESS**: Completed operations
- 🟡 **WARNING**: Non-critical issues
- 🔴 **ERROR**: Critical failures
- 🟦 **CHANGE**: File modifications (watch script)

## Troubleshooting

### Common Issues

**"XcodeGen not found"**
```bash
# Install XcodeGen
brew install xcodegen
```

**"No project.yml found"**
```bash
# Ensure you're in project root
cd aperture
ls project.yml  # Should exist
```

**"Permission denied"**
```bash
# Make scripts executable
chmod +x scripts/*.sh
```

**Project generation fails**
```bash
# Check project.yml syntax
xcodegen generate --spec project.yml
```

### Performance Tips

1. Use `quick.sh` for daily development
2. Enable watch mode during active development
3. Use `--use-cache` flag when possible
4. Clean caches only when necessary

## Customization

### Environment Variables

You can customize script behavior with environment variables:

```bash
# Custom project name
export PROJECT_NAME="MyApp"

# Custom spec file
export SPEC_FILE="custom.yml"
```

### Script Modification

All scripts are designed to be easily customizable:
- Modify colors in the color definition section
- Add new cleaning targets in clean functions
- Extend watch patterns in `WATCH_FILES` array

## Integration

### Git Hooks

Add to `.git/hooks/post-merge`:
```bash
#!/bin/bash
./scripts/quick.sh --force
```

### Editor Integration

**VS Code tasks.json**:
```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Generate Xcode Project",
            "type": "shell",
            "command": "./scripts/quick.sh",
            "group": "build"
        }
    ]
}
```

## Support

If you encounter issues with the scripts:

1. Check the prerequisites are installed
2. Ensure you're in the project root directory
3. Verify `project.yml` syntax is correct
4. Try cleaning all caches and regenerating
5. Check Xcode and XcodeGen versions

For XcodeGen-specific issues, refer to the [XcodeGen documentation](https://github.com/yonaskolb/XcodeGen).

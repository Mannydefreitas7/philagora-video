# Aperture

A macOS screen recording application built with SwiftUI.

## Prerequisites

- macOS 13.0 or later
- Xcode 15.0 or later
- XcodeGen (for project generation)

## Quick Start

The fastest way to get started:

```bash
# Clone the repository
git clone <repository-url>
cd aperture

# Install XcodeGen if you haven't already
brew install xcodegen

# Quick setup - generates project and opens Xcode
./scripts/quick.sh
```

## Setup

This project uses [XcodeGen](https://github.com/yonaskolb/XcodeGen) to generate the Xcode project file from a YAML specification. This approach eliminates merge conflicts in project files and makes project configuration more maintainable.

### Installing XcodeGen

Choose one of the following installation methods:

#### Homebrew

```bash
brew install xcodegen
```

#### Mint

```bash
mint install yonaskolb/xcodegen
```

#### Manual Installation

```bash
git clone https://github.com/yonaskolb/XcodeGen.git
cd XcodeGen
make install
```

## Build Scripts

This project includes convenient build scripts in the `scripts/` directory to streamline your development workflow:

### 🚀 Quick Development (`quick.sh`)

For daily development - the fastest way to get up and running:

```bash
# Generate project and open Xcode (if project doesn't exist)
./scripts/quick.sh

# Force regeneration even if project exists
./scripts/quick.sh --force
```

### 🔧 Comprehensive Build (`build.sh`)

Full-featured build script with complete control:

```bash
# Full build process (clean, generate, open)
./scripts/build.sh

# Generate project only
./scripts/build.sh --generate-only

# Clean caches only
./scripts/build.sh --clean-only

# Generate and clean but don't open Xcode
./scripts/build.sh --no-open

# Force regeneration
./scripts/build.sh --force

# Show all options
./scripts/build.sh --help
```

### 🧹 Cache Cleaning (`clean.sh`)

Comprehensive cache and build artifacts cleaning:

```bash
# Clean everything
./scripts/clean.sh

# Clean specific caches
./scripts/clean.sh --xcodegen-only
./scripts/clean.sh --derived-only
./scripts/clean.sh --spm-only

# Verbose output
./scripts/clean.sh --verbose
```

### 👁️ Auto-Regeneration (`watch.sh`)

Automatically regenerates project when `project.yml` changes:

```bash
# Start watching for changes
./scripts/watch.sh

# Generate project before starting watch
./scripts/watch.sh --initial-gen

# Verbose output
./scripts/watch.sh --verbose
```

## Development Workflows

### First Time Setup

```bash
git clone <repository-url>
cd aperture
./scripts/build.sh --force
```

### Daily Development

```bash
# Quick start
./scripts/quick.sh

# Or enable auto-regeneration while working
./scripts/watch.sh --initial-gen
```

### Troubleshooting Build Issues

```bash
# Deep clean and rebuild
./scripts/clean.sh
./scripts/build.sh --force
```

### Working with Project Configuration

When modifying `project.yml`:

```bash
# Start auto-regeneration
./scripts/watch.sh

# Edit project.yml - project regenerates automatically
# Stop with Ctrl+C when done
```

## Project Structure

```
aperture/
├── project.yml          # XcodeGen project specification
├── scripts/            # Build and development scripts
│   ├── build.sh        # Comprehensive build script
│   ├── quick.sh        # Quick development script
│   ├── clean.sh        # Cache cleaning script
│   ├── watch.sh        # File watcher for auto-regeneration
│   └── README.md       # Detailed scripts documentation
├── Aperture/           # Main app source code
│   ├── Actors/         # Actor-based components
│   ├── Controllers/    # App controllers
│   ├── Delegates/      # Delegate implementations
│   ├── Extensions/     # Swift extensions
│   ├── Features/       # Feature-specific views and logic
│   ├── Models/         # Data models
│   ├── Protocols/      # Protocol definitions
│   ├── Resources/      # App resources
│   ├── Shared/         # Shared components
│   ├── Utilities/      # Utility classes
│   ├── Views/          # SwiftUI views
│   ├── Windows/        # Window management
│   ├── Assets.xcassets # App assets
│   ├── Info.plist      # App configuration
│   └── Aperture.entitlements # App entitlements
└── README.md           # This file
```

## Dependencies

This project uses Swift Package Manager for dependency management. The following packages are automatically resolved:

- **Onboarding**: User onboarding flow
- **SFSafeSymbols**: Type-safe SF Symbols
- **AppInformation**: App information utilities
- **WelcomeWindow**: Welcome window components
- **Pow**: Animation and effects library
- **Engine**: Core engine components
- **AppState**: State management

## Manual Project Generation

If you prefer to use XcodeGen directly without the scripts:

```bash
# Basic generation
xcodegen generate

# With caching for faster subsequent builds
xcodegen generate --use-cache

# Specify custom spec file
xcodegen generate --spec project.yml

# Generate to specific directory
xcodegen generate --project ./build
```

## Development

### Making Changes

1. Edit the source code in the `Aperture/` directory
2. If you need to modify project settings, edit `project.yml`
3. Regenerate the project:
   ```bash
   ./scripts/quick.sh
   # or for auto-regeneration
   ./scripts/watch.sh
   ```

### Project Configuration

The `project.yml` file contains all project configuration including:

- Build settings
- Target configuration
- Dependencies
- Schemes
- Info.plist properties
- Entitlements

### Cache Management

The build scripts intelligently manage various caches:

- **XcodeGen Cache**: Speeds up project generation
- **Derived Data**: Xcode's build cache
- **SPM Cache**: Swift Package Manager dependencies
- **Module Cache**: Swift module compilation cache

## Building and Running

### Using Scripts (Recommended)

```bash
# Quick build and run
./scripts/quick.sh
```

### Manual Process

1. Ensure you have generated the Xcode project
2. Open `Aperture.xcodeproj`
3. Select the Aperture target
4. Build and run (⌘R)

## Permissions

Aperture requires the following permissions:

- **Screen Recording**: For capturing screen content
- **Microphone** (if audio recording is enabled): For recording audio

Make sure to grant these permissions when prompted.

## Troubleshooting

### Common Issues

**"XcodeGen not found"**

```bash
brew install xcodegen
```

**"No project.yml found"**

```bash
# Ensure you're in the project root
ls project.yml  # Should exist
```

**"Permission denied" for scripts**

```bash
chmod +x scripts/*.sh
```

**Build issues after pulling changes**

```bash
./scripts/clean.sh
./scripts/build.sh --force
```

**Project generation fails**

```bash
# Check project.yml syntax
xcodegen generate --spec project.yml
```

## CI/CD Integration

For continuous integration:

```bash
# Clean build without opening Xcode
./scripts/build.sh --no-open --force

# Or just generate for build systems
./scripts/build.sh --generate-only --force
```

## Contributing

1. Make your changes to the source code
2. Update `project.yml` if you modify project structure
3. Test your changes:
   ```bash
   ./scripts/clean.sh
   ./scripts/build.sh --force
   ```
4. Ensure the project builds and runs correctly
5. Submit a pull request

### Development Tips

- Use `./scripts/quick.sh` for daily development
- Use `./scripts/watch.sh` when actively modifying project configuration
- Run `./scripts/clean.sh` if you encounter mysterious build issues
- Check `scripts/README.md` for detailed script documentation

## License

[Add your license information here]

## Important Notes

- The `.xcodeproj` file is **not tracked in git** - it's generated from `project.yml`
- Always use the build scripts or `xcodegen generate` after pulling changes
- The scripts handle all cache management automatically
- For detailed script documentation, see `scripts/README.md`

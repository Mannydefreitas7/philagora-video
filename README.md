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

# Simple development workflow
./scripts/dev.sh start

# Or use the quick setup script directly
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

## Development Scripts

This project includes comprehensive development scripts to streamline your workflow:

### 🛠️ Simple Development (`dev.sh`)

The easiest way to work with the project:

```bash
# Quick start development
./scripts/dev.sh start     # or just: ./scripts/dev.sh

# Build project
./scripts/dev.sh build

# Build and run
./scripts/dev.sh run

# Set up and run tests
./scripts/dev.sh test

# Clean build artifacts
./scripts/dev.sh clean

# Build release version
./scripts/dev.sh release

# Watch for project changes
./scripts/dev.sh watch
```

## Build Scripts

The project also includes specialized build scripts for advanced workflows:

### 🚀 Quick Development (`quick.sh`)

For daily development - the fastest way to get up and running:

```bash
# Generate project and open Xcode (if project doesn't exist)
./scripts/quick.sh

# Force regeneration even if project exists
./scripts/quick.sh --force
```

### 🚀 Complete Workflow (`run-build-test.sh`)

Comprehensive script for building, running, and testing:

```bash
# Complete workflow (generate, build, run)
./scripts/run-build-test.sh

# Build only
./scripts/run-build-test.sh --build-only

# Run only (assumes already built)
./scripts/run-build-test.sh --run-only

# Test only
./scripts/run-build-test.sh --test-only

# Full workflow with tests
./scripts/run-build-test.sh --all

# Build configurations
./scripts/run-build-test.sh --debug      # Debug (default)
./scripts/run-build-test.sh --release    # Release build
./scripts/run-build-test.sh --clean      # Clean build
```

### 🧪 Test Setup (`add-tests.sh`)

Set up test infrastructure:

```bash
# Add test target and create test files
./scripts/add-tests.sh

# Force overwrite existing tests
./scripts/add-tests.sh --force
```

### 🔧 Comprehensive Build (`build.sh`)

Advanced build script with complete control:

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
./scripts/dev.sh start
```

### Daily Development

```bash
# Simple workflow
./scripts/dev.sh run

# Quick start (just open Xcode)
./scripts/dev.sh start

# Or use the quick script directly
./scripts/quick.sh

# Enable auto-regeneration while working
./scripts/dev.sh watch
```

### Working with Tests

```bash
# First-time test setup
./scripts/dev.sh test

# Run tests after setup
./scripts/run-build-test.sh --test-only

# Full development cycle with tests
./scripts/run-build-test.sh --all
```

### Troubleshooting Build Issues

```bash
# Simple clean and rebuild
./scripts/dev.sh clean
./scripts/dev.sh build

# Or deep clean and rebuild
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
├── .zed/               # Zed IDE configuration
│   ├── tasks.json      # Task definitions for build/run/test
│   ├── keymap.json     # Keyboard shortcuts
│   ├── settings.json   # Project-specific settings
│   └── README.md       # Zed integration documentation
├── ZED_SETUP.md        # Complete Zed IDE setup guide
├── SCRIPTS_GUIDE.md    # Comprehensive scripts documentation
├── SCRIPTS_REFERENCE.md # Quick reference for all scripts
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

### Using Zed IDE (Recommended)

If you're using Zed IDE:

```bash
# Open project in Zed
zed .

# Use keyboard shortcuts:
# Cmd+Shift+B - Build
# Cmd+Shift+R - Run
# Cmd+Shift+T - Test
# Cmd+Shift+S - Quick Start
```

See `ZED_SETUP.md` for complete Zed IDE integration guide.

### Using Scripts

```bash
# Simple build and run
./scripts/dev.sh run

# Or quick build and open
./scripts/dev.sh start
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

## IDE Integration

### Zed IDE

This project includes complete Zed IDE integration with:

- **Task Definitions**: Pre-configured tasks for build, run, test operations
- **Keyboard Shortcuts**: Quick access to common development tasks
- **Project Settings**: Optimized Swift development environment
- **Documentation**: Complete setup and usage guides

**Quick Setup:**

```bash
# Install Zed IDE
brew install zed

# Open project
zed .

# Use Cmd+Shift+P → "task spawn" to see all available tasks
```

**Essential Shortcuts:**

- `Cmd+Shift+B` - Build project
- `Cmd+Shift+R` - Build and run
- `Cmd+Shift+T` - Set up and run tests
- `Cmd+Shift+S` - Quick start (generate + open Xcode)

For complete setup instructions, see `ZED_SETUP.md`.

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

## Zed IDE Setup

Complete guide to set up and use Zed IDE with the Aperture macOS screen recording application.

### 🚀 Quick Setup

1. **Install Zed IDE**

   ```bash
   # Via Homebrew
   brew install zed

   # Or download from https://zed.dev
   ```

2. **Install Prerequisites**

   ```bash
   # Install XcodeGen (required for project generation)
   brew install xcodegen

   # Install Xcode (required for Swift development)
   # Download from Mac App Store or Apple Developer
   ```

3. **Open Project in Zed**

   ```bash
   cd aperture
   zed .
   ```

4. **Verify Setup**
   - Press `Cmd+Shift+P` to open command palette
   - Type "task spawn" and press Enter
   - You should see all Aperture development tasks

### 📁 Configuration Files

The `.zed/` directory contains:

| File            | Purpose                                          |
| --------------- | ------------------------------------------------ |
| `tasks.json`    | Task definitions for build, run, test operations |
| `keymap.json`   | Keyboard shortcuts for common tasks              |
| `settings.json` | Project-specific Zed settings                    |
| `README.md`     | Detailed documentation for Zed integration       |

### ⌨️ Keyboard Shortcuts

#### Essential Commands

- `Cmd+Shift+B` - **Build** project
- `Cmd+Shift+R` - **Run** application
- `Cmd+Shift+T` - **Test** (setup and run tests)
- `Cmd+Shift+C` - **Clean** build artifacts
- `Cmd+Shift+S` - **Quick Start** (generate project, open Xcode)

#### Advanced Commands

- `Cmd+Shift+W` - **Watch Changes** (auto-regenerate project)
- `Cmd+Shift+Alt+R` - **Release Build**
- `Cmd+Shift+Alt+T` - **Test Only**
- `Cmd+Shift+Alt+F` - **Full Workflow** (build + run + test)

#### Task Management

- `Cmd+Shift+P` then type "task spawn" - Open task selector
- `Cmd+Shift+P` then type "task rerun" - Rerun last task

### 🛠️ Available Tasks

#### Daily Development

- **Build** - Build project in Debug mode
- **Run** - Build and launch application
- **Test** - Set up and run tests
- **Clean** - Clean build artifacts
- **Quick Start** - Generate project and open Xcode

#### Advanced Workflows

- **Release Build** - Optimized production build
- **Watch Changes** - Auto-regenerate on project.yml changes
- **Advanced: Test Only** - Run tests without building
- **Advanced: Full Workflow** - Complete build + run + test cycle
- **Advanced: Clean Build (Verbose)** - Clean build with detailed output

#### Setup & Maintenance

- **Setup: Add Tests** - Create test infrastructure
- **Maintenance: Deep Clean** - Clean all caches
- **Maintenance: Force Rebuild** - Force project regeneration

### 🎯 Common Workflows

#### First-Time Project Setup

1. Open project in Zed: `zed .`
2. Run Quick Start: `Cmd+Shift+S`
3. Verify build: `Cmd+Shift+B`

#### Daily Development Cycle

1. **Code** - Make changes in Zed
2. **Build** - `Cmd+Shift+B` to compile
3. **Run** - `Cmd+Shift+R` to test
4. **Iterate** - Repeat as needed

#### Adding Tests (First Time)

1. Run: `Cmd+Shift+T` (creates test infrastructure)
2. Edit test files in `ApertureTests/` directory
3. Run tests: `Cmd+Shift+Alt+T`

#### Troubleshooting Build Issues

1. **Clean**: `Cmd+Shift+C`
2. **Force Rebuild**: Use "Maintenance: Force Rebuild" task
3. **Deep Clean**: Use "Maintenance: Deep Clean" task

#### Release Preparation

1. **Release Build**: `Cmd+Shift+Alt+R`
2. **Full Testing**: `Cmd+Shift+Alt+F`
3. **Final Clean Build**: Use "Advanced: Clean Build (Verbose)"

#### Maintenance

1. **Clean**: `Cmd+Shift+C`
2. **Force Rebuild**: Use "Maintenance: Force Rebuild" task
3. **Deep Clean**: Use "Maintenance: Deep Clean" task

### 🔧 Language Support

#### Swift Configuration

- **Tab Size**: 4 spaces
- **Line Length**: 120 characters
- **Format on Save**: Enabled
- **SourceKit LSP**: Configured for Xcode toolchain

#### File Type Associations

- `.swift` - Swift language support
- `.yml`, `.yaml` - YAML with 2-space indentation
- `.json` - JSON with formatting
- `.md` - Markdown with 80-character wrapping
- `.sh` - Shell script support

### 🎨 Editor Features

#### Visual Settings

- **Theme**: One Dark (configurable)
- **Font**: SF Mono
- **Font Size**: 14pt for code, 16pt for UI
- **Line Numbers**: Enabled
- **Git Integration**: Enabled with inline blame

#### Code Intelligence

- **Inlay Hints**: Type and parameter hints enabled
- **Format on Save**: Automatic code formatting
- **Git Gutter**: Shows git status in editor
- **Diagnostics**: Real-time error/warning display

#### Panel Layout

- **Project Panel**: Left side
- **Outline Panel**: Right side
- **Terminal**: Bottom (integrated with tasks)

### 🔍 File Management

#### Excluded from Search

- `.git/` - Git repository data
- `DerivedData/` - Xcode build artifacts
- `*.xcodeproj/` - Generated Xcode projects
- `.build/` - Swift Package Manager builds
- Build outputs and temporary files

#### File Icons and Git Status

- File icons enabled in tabs
- Git status indicators in project panel
- Modified files highlighted in tabs

### 🧪 Testing Integration

#### Test Infrastructure

- Automatic test target creation
- XCTest framework integration
- Test file templates provided
- Code coverage support available

#### Running Tests

- **Setup Tests**: First-time test infrastructure creation
- **Run All Tests**: Complete test suite execution
- **Test Only**: Quick test runs without building
- **Verbose Testing**: Detailed test output

### ⚡ Performance Optimization

#### File Scanning

- Optimized exclusions for faster project loading
- Swift Package Manager cache ignored
- Build artifacts excluded from search
- Large binary files filtered out

#### Terminal Integration

- Task output in integrated terminal
- Terminal reuse for efficiency
- Persistent terminal sessions
- Command history maintained

### 🔄 Integration with Build Scripts

All Zed tasks use the project's shell scripts:

#### Script Hierarchy

1. **`dev.sh`** - Simple, user-friendly commands
2. **`run-build-test.sh`** - Comprehensive workflow management
3. **`build.sh`** - Advanced build control
4. **`add-tests.sh`** - Test infrastructure setup
5. **`clean.sh`** - Cache and artifact management

#### Task → Script Mapping

- Build → `./scripts/dev.sh build`
- Run → `./scripts/dev.sh run`
- Test → `./scripts/dev.sh test`
- Clean → `./scripts/dev.sh clean`
- Quick Start → `./scripts/dev.sh start`

### 🛠️ Customization

#### Adding Custom Tasks

Edit `.zed/tasks.json` to add new tasks:

```json
{
  "label": "Your Custom Task",
  "command": "./scripts/your-script.sh",
  "args": ["--your-args"],
  "cwd": "$ZED_WORKTREE_ROOT",
  "tags": ["custom"]
}
```

#### Custom Keyboard Shortcuts

Edit `.zed/keymap.json`:

```json
{
  "context": "Workspace",
  "bindings": {
    "your-shortcut": ["task::Spawn", { "task_name": "Your Custom Task" }]
  }
}
```

#### Environment Variables

Access Zed variables in tasks:

- `$ZED_WORKTREE_ROOT` - Project root
- `$ZED_FILE` - Current file path
- `$ZED_SELECTED_TEXT` - Selected text
- `$ZED_FILENAME` - Current filename

### 🐛 Troubleshooting

#### Common Issues

**Tasks Not Showing**

```bash
# Check file permissions
chmod +x scripts/*.sh

# Verify you're in project root
ls project.yml  # Should exist
```

**XcodeGen Errors**

```bash
# Install XcodeGen
brew install xcodegen

# Test project generation
xcodegen generate --spec project.yml
```

**Build Failures**

1. Use Clean task: `Cmd+Shift+C`
2. Try Force Rebuild from task menu
3. Check Xcode is installed and up to date

**Script Permissions**

```bash
# Make all scripts executable
chmod +x scripts/*.sh
```

#### Getting Help

- Use `--help` with any script: `./scripts/dev.sh --help`
- Check script documentation in `scripts/README.md`
- Review comprehensive guide in `SCRIPTS_GUIDE.md`
- Check Zed documentation at https://zed.dev/docs

### 🔮 Advanced Tips

#### Oneshot Tasks

- Type custom commands in task modal
- Use `Opt+Enter` to run ad-hoc commands
- Commands persist for session duration

#### Task Rerunning

- Use "Task: Rerun" to repeat last task
- Set `"reevaluate_context": true` for dynamic tasks
- Use `Cmd` modifier for ephemeral tasks

#### Terminal Management

- Tasks reuse terminals by default
- Use `"use_new_terminal": true` for persistent processes
- Configure `"allow_concurrent_runs"` for parallel execution

#### Code Actions

- Use `Cmd+.` for quick task access on runnable lines
- Tasks with matching tags appear in code actions
- Immediate execution if no other actions available

### 📚 Additional Resources

- **Zed Documentation**: https://zed.dev/docs
- **Zed Tasks Guide**: https://zed.dev/docs/tasks
- **Swift Package Manager**: https://swift.org/package-manager/
- **XcodeGen**: https://github.com/yonaskolb/XcodeGen
- **Project Scripts**: See `scripts/README.md` for detailed documentation

---

**Ready to develop with Zed! 🚀**

For questions or issues, check the troubleshooting section above or refer to the comprehensive documentation in the `scripts/` directory.

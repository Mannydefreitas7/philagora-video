# Aperture

A macOS screen recording application built with SwiftUI.

## Prerequisites

- macOS 13.0 or later
- Xcode 15.0 or later
- XcodeGen (for project generation)

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

### Generating the Xcode Project

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd aperture
   ```

2. Generate the Xcode project:
   ```bash
   xcodegen generate
   ```

3. Open the generated project:
   ```bash
   open Aperture.xcodeproj
   ```

## Project Structure

```
aperture/
├── project.yml          # XcodeGen project specification
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

## Development

### Making Changes

1. Edit the source code in the `Aperture/` directory
2. If you need to modify project settings, edit `project.yml`
3. Regenerate the project if needed:
   ```bash
   xcodegen generate
   ```

### Project Configuration

The `project.yml` file contains all project configuration including:
- Build settings
- Target configuration
- Dependencies
- Schemes
- Info.plist properties
- Entitlements

### Caching

To improve generation speed, you can use XcodeGen's caching feature:

```bash
xcodegen generate --use-cache
```

## Building and Running

1. Ensure you have generated the Xcode project
2. Open `Aperture.xcodeproj`
3. Select the Aperture target
4. Build and run (⌘R)

## Permissions

Aperture requires the following permissions:
- **Screen Recording**: For capturing screen content
- **Microphone** (if audio recording is enabled): For recording audio

Make sure to grant these permissions when prompted.

## Contributing

1. Make your changes
2. Test thoroughly
3. Update `project.yml` if you modify project structure
4. Regenerate the project to ensure it builds correctly
5. Submit a pull request

## License

[Add your license information here]

## Notes

- The `.xcodeproj` file is not tracked in git - it's generated from `project.yml`
- Always use `xcodegen generate` after pulling changes that might affect project structure
- If you encounter build issues, try cleaning derived data and regenerating the project

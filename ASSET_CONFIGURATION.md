# Asset Configuration Documentation

This document explains how assets are configured in the Aperture project using XcodeGen.

## Overview

The project has been configured to properly include and manage assets according to XcodeGen best practices. The asset configuration ensures that:

1. Assets are properly included in the build process
2. Asset names follow the file naming convention
3. Asset compilation is optimized for the target platform

## Asset Structure

The project contains two main asset directories:

### 1. Assets.xcassets
Located at `Aperture/Assets.xcassets`, this directory contains:
- **AccentColor.colorset** - The app's accent color
- **AdobeStock_1611812896_Preview.imageset** - Preview image asset
- **go-pro.imageset** - GoPro related image
- **imac.imageset** - iMac image asset
- **instagram.symbolset** - Instagram symbol
- **laptop.imageset** - Laptop image asset
- **mac-mini.imageset** - Mac Mini image asset
- **mic.imageset** - Microphone image asset
- **microphone-15535673.imageset** - Alternative microphone image
- **monitor.imageset** - Monitor image asset
- **recordingRed.colorset** - Recording red color
- **tiktok.symbolset** - TikTok symbol
- **video-placeholder.imageset** - Video placeholder image
- **youtube.symbolset** - YouTube symbol

### 2. AppIcon.icon
Located at `Aperture/AppIcon.icon`, this directory contains:
- App icon configuration with gradient fills
- Support for multiple platforms (shared squares, watchOS circles)
- Tinted appearance variants
- Glass and shadow effects

## XcodeGen Configuration

### File Groups
Assets are included in the project's file groups for proper organization:
```yaml
fileGroups:
  - Aperture/Assets.xcassets
  - Aperture/AppIcon.icon
```

### Target Sources
Assets are explicitly included in the target sources with proper configuration:
```yaml
sources:
  - path: Aperture/Assets.xcassets
    name: Assets
    buildPhase: resources
    type: folder
  - path: Aperture/AppIcon.icon
    name: AppIcon
    buildPhase: resources
    type: folder
```

### Build Settings
The following build settings are configured for optimal asset compilation:

- `ASSETCATALOG_COMPILER_APPICON_NAME: AppIcon` - Sets the app icon name
- `ASSETCATALOG_COMPILER_INCLUDE_ALL_APPICON_ASSETS: YES` - Includes all app icon assets
- `ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME: AccentColor` - Sets the global accent color
- `ASSETCATALOG_COMPILER_GENERATE_ASSET_SYMBOLS: YES` - Generates Swift symbols for assets
- `ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS: YES` - Generates Swift extensions for type-safe asset access

## Asset Naming Convention

Assets follow the file naming convention where:
- Asset names in code correspond directly to the file/folder names
- Image assets use `.imageset` extension
- Color assets use `.colorset` extension  
- Symbol assets use `.symbolset` extension
- App icons use `.icon` extension

## Usage in Code

With the configured build settings, you can access assets type-safely in Swift:

```swift
// Colors
let accentColor = Color.accentColor
let recordingRed = Color.recordingRed

// Images
let laptopImage = Image.laptop
let micImage = Image.mic
let videoPlaceholder = Image.videoPlaceholder

// App Icon (automatically handled by the system)
// CFBundlePrimaryIcon is set to "AppIcon" in Info.plist
```

## Benefits of This Configuration

1. **Type Safety** - Swift symbol generation prevents runtime errors from typos
2. **Proper Organization** - Assets are properly grouped and organized in Xcode
3. **Build Optimization** - Asset catalog compilation is optimized for macOS
4. **Maintainability** - Clear separation of assets from source code
5. **Platform Support** - App icon supports multiple platforms and appearances

## Regenerating the Project

After making changes to assets, regenerate the Xcode project using:
```bash
xcodegen generate
```

This will ensure all new assets are properly included and configured in the Xcode project.

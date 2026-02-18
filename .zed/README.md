# Zed IDE Integration for Aperture

This directory contains Zed IDE-specific configuration files to enhance your development experience with the Aperture project.

## Files Overview

- `tasks.json` - Task definitions for building, running, and testing
- `keymap.json` - Suggested keyboard shortcuts for common tasks
- `README.md` - This documentation file

## Quick Start

1. Open the Aperture project in Zed
2. Use `Cmd+Shift+P` to open the command palette
3. Type "task spawn" and select it to see all available tasks
4. Or use the keyboard shortcuts defined in `keymap.json`

## Available Tasks

### 🎯 Essential Tasks (Tagged)

| Task | Shortcut | Description |
|------|----------|-------------|
| **Build** | `Cmd+Shift+B` | Build the project in Debug mode |
| **Run** | `Cmd+Shift+R` | Build and run the application |
| **Test** | `Cmd+Shift+T` | Set up and run tests |
| **Clean** | `Cmd+Shift+C` | Clean build artifacts |
| **Quick Start** | `Cmd+Shift+S` | Generate project and open Xcode |

### 🚀 Development Tasks

| Task | Shortcut | Description |
|------|----------|-------------|
| **Release Build** | `Cmd+Shift+Alt+R` | Build optimized release version |
| **Watch Changes** | `Cmd+Shift+W` | Auto-regenerate on file changes |

### 🔧 Advanced Tasks

| Task | Shortcut | Description |
|------|----------|-------------|
| **Advanced: Test Only** | `Cmd+Shift+Alt+T` | Run tests without building |
| **Advanced: Full Workflow** | `Cmd+Shift+Alt+F` | Complete build + run + test cycle |
| **Advanced: Build Only (Debug)** | - | Build only in Debug configuration |
| **Advanced: Build Only (Release)** | - | Build only in Release configuration |
| **Advanced: Clean Build (Verbose)** | - | Clean build with detailed output |

### 🛠️ Maintenance Tasks

| Task | Description |
|------|-------------|
| **Setup: Add Tests** | Create test infrastructure for the project |
| **Maintenance: Deep Clean** | Clean all caches and build artifacts |
| **Maintenance: Force Rebuild** | Force regenerate project and rebuild |

## Using Tasks

### Via Command Palette
1. Open command palette: `Cmd+Shift+P`
2. Type "task spawn" and press Enter
3. Select your desired task from the list
4. Task will run in the integrated terminal

### Via Keyboard Shortcuts
Use the predefined shortcuts in `keymap.json` for quick access to common tasks.

### Via Task Menu
1. Use `Task: Spawn` command
2. Browse and select tasks from the modal
3. Use `Tab` to modify task commands before running

## Task Behavior

All tasks are configured with:
- **Working Directory**: Project root (`$ZED_WORKTREE_ROOT`)
- **Terminal Reuse**: Tasks reuse the same terminal tab
- **No Concurrent Runs**: Tasks wait for previous runs to complete
- **Always Reveal**: Terminal pane is shown when task runs
- **Persistent Output**: Terminal stays open after task completion

### Special Configurations

- **Watch Changes**: Uses a new terminal tab (runs continuously)
- **All Tasks**: Show command line and summary information
- **Tagged Tasks**: Can be used with runnable indicators

## Customizing Tasks

### Modifying Existing Tasks
Edit `tasks.json` to customize:
- Command arguments
- Working directories
- Terminal behavior
- Environment variables

### Adding New Tasks
Follow this template:
```json
{
  "label": "Your Task Name",
  "command": "./scripts/your-script.sh",
  "args": ["--your-args"],
  "cwd": "$ZED_WORKTREE_ROOT",
  "use_new_terminal": false,
  "allow_concurrent_runs": false,
  "reveal": "always",
  "hide": "never",
  "show_summary": true,
  "show_command": true,
  "tags": ["your-tag"]
}
```

### Customizing Keyboard Shortcuts
Edit `keymap.json` to:
- Change existing shortcuts
- Add new shortcuts for tasks
- Create shortcuts for advanced workflows

Example:
```json
{
  "context": "Workspace", 
  "bindings": {
    "your-shortcut": ["task::Spawn", { "task_name": "Your Task Name" }]
  }
}
```

## Environment Variables

Tasks have access to Zed's environment variables:
- `ZED_WORKTREE_ROOT` - Project root directory
- `ZED_FILE` - Currently open file path
- `ZED_FILENAME` - Current file name
- `ZED_SELECTED_TEXT` - Selected text in editor

## Workflows

### Daily Development
1. **Start**: `Cmd+Shift+S` (Quick Start)
2. **Code**: Make your changes
3. **Build**: `Cmd+Shift+B` (Build)
4. **Run**: `Cmd+Shift+R` (Run)
5. **Test**: `Cmd+Shift+T` (Test)

### First-Time Setup
1. Use "Quick Start" task to generate project
2. Use "Setup: Add Tests" if you need testing
3. Use "Build" to verify everything works

### Troubleshooting
1. Use "Clean" task for build issues
2. Use "Maintenance: Deep Clean" for serious problems
3. Use "Maintenance: Force Rebuild" to start fresh

### Release Preparation
1. Use "Release Build" for optimized builds
2. Use "Advanced: Full Workflow" for comprehensive testing
3. Use "Clean" before final builds

## Tips and Best Practices

1. **Use Tagged Tasks**: The essential tasks (Build, Run, Test, etc.) are tagged for easy identification
2. **Rerun Tasks**: Use `Task: Rerun` to repeat the last task quickly
3. **Oneshot Tasks**: Type custom commands in the task modal for ad-hoc operations
4. **Terminal Management**: Tasks reuse terminals by default for cleaner workspace
5. **Watch Mode**: Use "Watch Changes" during active project configuration editing

## Integration with Scripts

All tasks use the project's shell scripts in the `scripts/` directory:
- `dev.sh` - Simple development commands
- `run-build-test.sh` - Advanced workflow management
- `build.sh` - Comprehensive build control
- `add-tests.sh` - Test infrastructure setup
- `clean.sh` - Cache and artifact cleaning

## Troubleshooting

### Tasks Not Appearing
- Ensure you're in the project root directory
- Check that script files are executable: `chmod +x scripts/*.sh`
- Verify `tasks.json` syntax is valid

### Permission Errors
```bash
chmod +x scripts/*.sh
```

### Script Not Found Errors
- Ensure you're running Zed from the project root
- Check that all scripts exist in the `scripts/` directory

### XcodeGen Not Found
```bash
brew install xcodegen
```

## Advanced Configuration

### Global vs Project Tasks
- These tasks are project-specific (stored in `.zed/tasks.json`)
- For global tasks, use `~/.config/zed/tasks.json`
- Project tasks take precedence over global tasks

### Task Templates
Tasks support template variables for dynamic behavior:
- Use `$ZED_FILE` for current file operations
- Use `$ZED_SELECTED_TEXT` for text-based operations
- Use `${VAR:default}` syntax for default values

### Custom Shell Configuration
Tasks use the system shell by default. Customize with:
```json
"shell": {
  "with_arguments": {
    "program": "/bin/bash",
    "args": ["--login"]
  }
}
```

## Support

For task-related issues:
1. Check this README
2. Verify script permissions and existence
3. Test scripts manually in terminal
4. Check Zed's task documentation
5. Review script documentation in `scripts/README.md`

---

**Happy coding with Zed! 🚀**

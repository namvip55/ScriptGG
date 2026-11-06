# Mindustry Architecture Analysis

## Entry Point
- **ClientLauncher.java**: Desktop application launcher (ClientLauncher extends ApplicationCore)
- **Vars.java**: Global constants and static state container
- **Version.java**: Version information loader from version.properties

## Core Architecture Components

### 1. Platform Layer
- `ClientLauncher`: Main application entry point
- `Platform`: Interface implemented by ClientLauncher
- Uses `arc.Core` framework (Arc Engine)

### 2. Global State Management
- `Vars.java`: Contains:
  - Game configuration (resolution, settings, directories)
  - Global game state objects (world, maps, units, etc.)
  - Static utilities and constants
  - Asset management (assets, atlas, fonts)
  
### 3. Game Logic Structure
- `arc` package: Core framework (graphics, math, utilities)
- `mindustry` package: Game-specific implementations
- `mindustry.gen`: Generated code (compiled from source)
- `mindustry.content`: Game content (blocks, items, units)
- `mindustry.entities`: Game entities (units, buildings, effects)
- `mindustry.world`: World simulation (tiles, sectors, maps)
- `mindustry.ui`: User interface

### 4. Build System
- Gradle with Java 17+ requirement
- Modules: desktop, core, server, android
- Arc engine integration (compiled or cloned locally)

## Key Modules

### Desktop Entry Point
- `ClientLauncher.setup()`: Initializes graphics, assets, game systems
- `ClientLauncher.update()`: Main game loop
- Handles OpenGL initialization, asset loading, UI setup

### Global Constants
- `Vars`: Static global state singleton
- Manages game directories, settings, cache
- Contains all game configuration and constants

### Core Game Loop
- `ClientLauncher.update()`: Main update loop
- `Time.delta`: Frame timing
- `assets.update()`: Asset loading management

## Technology Stack
- **Language**: Java
- **Framework**: Arc (by Anuken)
- **Build System**: Gradle
- **Platform**: Desktop (Windows/Linux/Mac), Android, Server
- **Graphics**: OpenGL ES 2.0/3.0

## Notable Patterns
- Static global state management (Vars)
- Asset pipeline with lazy loading
- Event system (Events.fire())
- Mod support with mod patching system
- State management through GameState class
- Generated code for units and packets

## Dependencies
- Arc engine (required for compilation)
- Java 17+
- Android SDK (for Android builds)
- Gradle 7+ recommended

*Analysis in progress - more detailed system analysis ongoing*
# Mindustry Source Inventory

## Overview
- **Game ID**: mindustry
- **Source Path**: D:/project/GameGuardian/srcgame/Mindustry
- **Language**: Java
- **Engine/Framework**: Arc (custom engine by Anuken)
- **Build System**: Gradle with Java 17+ requirement

## Directory Structure

```
srcgame/Mindustry/
├── core/src/mindustry/
│   ├── ai/                 # AI logic
│   ├── async/              # Async operations
│   ├── audio/              # Sound/music
│   ├── content/            # Game content definitions
│   ├── core/               # Core game classes (Vars, Version, GameState)
│   ├── ctype/              # Content type enums
│   ├── editor/             # Map editor
│   ├── entities/           # Units, buildings, abilities, bullets, effects
│   ├── game/               # Game state, rules, campaign, difficulty
│   ├── graphics/           # Rendering
│   ├── input/              # Input handling
│   ├── io/                 # Save/load, serialization
│   ├── logic/              # Logic program interpreter
│   ├── maps/               # Map handling, generators, planet generation
│   ├── mod/                # Mod system
│   ├── net/                # Networking
│   ├── service/            # Game service
│   ├── type/               # Data types
│   ├── ui/                 # User interface
│   ├── world/              # World simulation
│   └── Vars.java, ClientLauncher.java
├── assets/                 # Game assets
├── assets-raw/             # Raw assets
└── build.gradle, settings.gradle
```

## Key Source Files
- `core/src/mindustry/Vars.java` - Global state and constants
- `core/src/mindustry/ClientLauncher.java` - Main entry point
- `core/src/mindustry/core/Version.java` - Version information
- `core/src/mindustry/core/GameState.java` - Game state machine

## Package Details

### ai/ - Artificial Intelligence
- Files: 9 AI classes
- Key classes: RtsAI, BaseBuilderAI, Pathfinder integration

### entities/
- 7 subpackages: abilities, bullet, comp, effect, part, pattern, units

### world/
- 5 subpackages: blocks, consumers, draw, meta, modules

### ui/
- 4 subpackages: builder, dialogs, fragments, layout

### net/
- Networking implementations

## Important Notes
- Version properties are loaded from version.properties at runtime
- Game uses static global state (Vars)
- Logic programs are interpreted from text
- Save file format uses custom serialization (TypeIO)

*Inventory complete - ready for architecture analysis*
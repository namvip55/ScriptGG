# Mindustry Data Flow Analysis

## Overview
This document traces the primary data flows in Mindustry's source code. All paths are verified from source at:
- D:/project/GameGuardian/srcgame/Mindustry/core/src/mindustry/

## Entry Point Data Flow

### 1. Client Initialization (ClientLauncher.setup → Vars.init)
```
ClientLauncher.setup()
  → Assets loading (Vars.load → ContentLoader)
  → Content.createBaseContent()
  → Vars.init()  [line 311 in Vars.java]
    → Groups.init()
    → Version.init()  [line 330]
    → CacheLayer.init()
    → World construction: new World(), new Universe()
    → new GameState()
    → BlockIndexer, Pathfinder, FogControl init
    → new MapEditor() (non-headless)
    → Maps init
    → Waves init
    → Mods load()
    → Vars.init() completes
```

### 2. Game State Initialization
```
Vars.init()
  → state = new GameState()  [line 377]
    → Rules construction with default gamemode
    → Teams initialization
    → Universe sector generation
    → Map generation from world tiles
```

## Core Data Flows

### 1. Rules Configuration Flow
```
Gamemode.apply()  [Gamemode.java]
  → Rules.rules.get(teamRule)  [Rules.java:69]
    → TeamRules.get(team)  [Rules.TeamRules.get:422]
      → TeamRule constructor or retrieval from values[]
    → Rules field access (infiniteResources, waves, etc.)
  → Map validation (mode.valid())
  → Rules.mode()  [Rules.java:276]
    → Returns Gamemode based on pvp, editor, attackMode, infiniteResources
```

### 2. World Generation Flow
```
Map generation → World creation
  → world.tiles generation from map data
  → spawns placement
  → sector assignment
  → initial resources setup
```

### 3. Mod Loading Flow
```
ClientLauncher.update() [line 256+]
  → assets.loadRun("contentinit", ContentLoader.class)
    → content.createBaseContent()  [line 167]
    → content.load()  [line 187]
    → mods.loadModPatches()  [line 189]
  → mods.eachClass(Mod::init)  [line 243]
    → Mod.load() → Mod.init()
```

### 4. Update Loop Flow
```
ClientLauncher.update() [line 217+]
  → PerfCounter.update.begin()
  → FPS cap logic [line 220-224]
  → asyncCore.begin()
  → super.update()
  → asyncCore.end()
  → FPS limit enforcement [line 264-270]
  → PerfCounter.checkUpdate() for all counters
```

### 5. Network Flow
```
Vars.net = new Net(platform.getNet())  [ClientLauncher:148]
  → Net initialization with platform Net
  → NetClient / NetServer setup
  → Packet handling per EventType
  → World state synchronization
```

## Data Flow by Category

### Configuration Data
- **Source**: Vars.java static fields + version.properties
- **Flow**: Loaded at startup → persists in static state
- **Key vars**: Rules, gamemode, difficulty, teams

### Game State Data
- **Source**: World, Universe, GameState objects
- **Flow**: Constructed at init → updated each frame → saved/loaded
- **Key objects**: world tiles, units, buildings, sectors, teams

### Asset Data
- **Source**: AssetManager, AssetDescriptor, generated gen package
- **Flow**: Asynchronous loading at startup → runtime access
- **Key types**: Textures, Sounds, Music, Fonts, Block definitions

### Logic Program Data
- **Source**: logic package (LStatement, LExecutor)
- **Flow**: Parsed from text → compiled → executed each update
- **Key mechanism**: Logic blocks can control units/blocks

## Data Persistence Flow

### Save/Load Cycle
```
Client file operations
  → SaveIO.getMeta(file)  [io/SaveIO.java]
  → SaveIO/SaveIO.readWrite()
  → TypeIO serialization/deserialization
  → Vars.saveDirectory for file storage
  → Core.settings persists app settings
```

### Mod Content Persistence
```
mods.load() → Data patch loading
  → DataPatchLoadEvent fired
  → Content re-initialization with patched data
  → Runtime content modification
```

## Runtime Validation Points

1. **Version.properties**: Must exist at build output
   - Type: version.properties
   - Location: Android: assets/, Desktop: resources/
   - Content: type, number, modifier, commitHash, build, buildDate

2. **World seed consistency**: World generation must match seed
3. **Save format compatibility**: Version checks on load
4. **Mod compatibility**: Content patch format version checks

## Feature: Rules Configuration Update Flow

When rules are modified during gameplay:
```
1. Rules field access/modification
2. → Teams rules update propagation
3. → Game rules re-evaluation (e.g., wave spawning)
4. → UI update if rules dialog open
5. → Net packet sync if multiplayer
```

*Analysis ongoing - feature analysis to follow*
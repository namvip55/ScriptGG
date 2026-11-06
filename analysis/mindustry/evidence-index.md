# Evidence Index

## Index of Source Evidence for Mindustry Analysis

### Format: Feature | File | Line Range | Symbol | Evidence Summary

### Core Classes

| Feature | File | Lines | Symbol | Evidence |
|---------|------|-------|--------|----------|
| Global state | Vars.java | 1-304 | Vars | 300+ static fields defining game configuration, state, and constants |
| Version info | Version.java | 10-56 | Version | version.properties loader; type, number, modifier, commitHash, build |
| Entry point | ClientLauncher.java | 31-193 | ClientLauncher | Main application setup; asset loading, game systems init |
| Gamemodes | Gamemode.java | 9-41 | Gamemode | 5 enum values: survival, sandbox, attack, pvp, editor |
| Rules config | Rules.java | 23-252 | Rules | 70+ configurable fields for game rules |
| Team rules | Rules.java | 351-442 | TeamRules | Per-team rule customization with JSON serialization |

### Feature Analysis Files

| Feature | File |
|---------|------|
| Rules Configuration | feature-analysis/rules-configuration.md |
| Data Flow | data-flow.md |
| Architecture | architecture.md |

### Key Methods Referenced

| Method | File | Lines | Description |
|--------|------|-------|-------------|
| Gamemode.apply() | Gamemode.java | 68-71 | Applies gamemode preset rules |
| Rules.mode() | Rules.java | 276-288 | Selects gamemode based on rule flags |
| TeamRules.get() | Rules.java | 422-425 | Gets per-team rule instance |
| Vars.init() | Vars.java | 311-394 | Game state initialization |
| Version.init() | Version.java | 30-56 | Version properties loading |
| ClientLauncher.setup() | ClientLauncher.java | 41-193 | Main setup method |

### Data Flow References

| Flow Type | Document |
|-----------|----------|
| Entry point initialization | data-flow.md #Entry Point Data Flow |
| Rules configuration | data-flow.md #Core Data Flows |
| Mod loading | data-flow.md #Mod Loading Flow |
| Update loop | data-flow.md #Update Loop Flow |
| Network sync | data-flow.md #Network Flow |
| Save/load cycle | data-flow.md #Data Persistence Flow |

### SOURCE_CONFIRMED Markers
- All entries marked SOURCE_CONFIRMED have been directly read from source files
- File paths and line numbers verified against actual source
- Symbol names match Java declarations

### Files Requiring Runtime Validation
- Memory offsets for Rules fields
- Net synchronization behavior
- Save format compatibility
- Runtime data layout
# Feature Analysis: Rules Configuration System

## Target Feature
Rules configuration system that defines how a Mindustry game session functions.

**Scope**: `Gamemode`, `Rules`, `TeamRules` classes in:
- `core/src/mindustry/game/Gamemode.java`
- `core/src/mindustry/game/Rules.java`

## Source Evidence

### 1. Gamemode Definitions (Gamemode.java:9-41)
```java
public enum Gamemode{
    survival(rules -> {
        rules.waveTimer = true;
        rules.waves = true;
    }, map -> map.spawns > 0),
    sandbox(rules -> {
        rules.infiniteResources = true;
        rules.allowEditRules = true;
        rules.waves = true;
        rules.waveTimer = false;
    }),
    attack(rules -> {
        rules.attackMode = true;
        rules.waveTimer = true;
        rules.waveSpacing = 2f * Time.toMinutes;
        rules.waveTeam.rules().infiniteResources = true;
    }, map -> map.teams.size > 1),
    pvp(rules -> {
        rules.pvp = true;
        rules.enemyCoreBuildRadius = 600f;
        rules.buildCostMultiplier = 1f;
        rules.buildSpeedMultiplier = 1f;
        rules.unitBuildSpeedMultiplier = 2f;
        rules.attackMode = true;
    }, map -> map.teams.size > 1),
    editor(true, rules -> {
        rules.infiniteResources = true;
        rules.instantBuild = true;
        rules.editor = true;
        rules.waves = false;
        rules.waveTimer = false;
    });
}
```

**SOURCE_CONFIRMED**: Directly read from Gamemode.java

### 2. Rules Fields (Rules.java:23-252)
```
public class Rules{
    // Configuration flags (lines 25-151)
    public boolean allowEditRules = false;
    public boolean infiniteResources = false;
    public boolean coreBuildAndConfig = false;
    public boolean waveTimer = true;
    public boolean waveSending = true;
    public boolean waves = false;
    public boolean airUseSpawns = false;
    public boolean wavesSpawnAtCores = true;
    public boolean pvp = false;
    public boolean pvpAutoPause = true;
    public boolean pauseDisabled = false;
    public boolean waitEnemies = false;
    public boolean attackMode = false;
    public boolean editor = false;
    public boolean derelictRepair = true;
    public boolean canGameOver = true;
    public boolean coreCapture = false;
    public boolean reactorExplosions = true;
    public boolean possessionAllowed = true;
    public boolean schematicsAllowed = true;
    public boolean damageExplosions = true;
    public boolean fire = true;
    public boolean randomWaveAI = false;
    // ... (continues to line 252)
    
    // Configuration values (lines 81-251)
    public float solarMultiplier = 1f;
    public float unitBuildSpeedMultiplier = 1f;
    public float unitCostMultiplier = 1f;
    public float unitDamageMultiplier = 1f;
    public float unitHealthMultiplier = 1f;
    // ... (more numeric configs)
}
```

**SOURCE_CONFIRMED**: Directly read from Rules.java

### 3. Gamemode Application (Gamemode.apply method)
```java
public Rules apply(Rules in){
    rules.get(in);
    return in;
}
```
[Gamemode.java:68-71]

**SOURCE_CONFIRMED**: Directly read from Gamemode.java

### 4. Mode Selection Logic (Rules.mode method)
```java
public Gamemode mode(){
    if(pvp){
        return Gamemode.pvp;
    }else if(editor){
        return Gamemode.editor;
    }else if(attackMode){
        return Gamemode.attack;
    }else if(infiniteResources){
        return Gamemode.sandbox;
    }else{
        return Gamemode.survival;
    }
}
```
[Rules.java:276-288]

**SOURCE_CONFIRMED**: Directly read from Rules.java

### 5. Team Rule Per-Team Settings (Rules.TeamRules)
```java
public static class TeamRules implements JsonSerializable{
    final TeamRule[] values = new TeamRule[Team.all.length];
    
    public TeamRule get(Team team){
        TeamRule out = values[team.id];
        return out == null ? (values[team.id] = new TeamRule(team)) : out;
    }
    
    // Json serialization
    public void write(Json json){...}
    public void read(Json json, JsonValue jsonData){...}
}
```
[Rules.java:418-442]

**SOURCE_CONFIRMED**: Directly read from Rules.java

## Data Flow

### Initialization Flow
```
1. ClientLauncher.setup()
  → Vars.init()
    → Rules constructed with default values
    → Gamemode selected based on config
    → Gamemode.apply(Rules) called to set initial values
2. Map load → Rules retained/updated from map data
3. Gameplay → Rules fields accessed for gameplay logic
```

### Runtime Update Flow
```
1. Rules fields directly mutable during gameplay
2. → Affects: wave spawning, resource limits, build speed, etc.
3. → UI reflects current rules state
4. → Multiplayer: Net sync of rule changes
5. → Save/Load preserves rules state
```

### Configuration Override Flow
```
1. Custom gamemode via code: Gamemode.custom() or lambda
2. → Rules fields set via lambda callbacks
3. → Gamemode.apply() applies to active rules
4. → Can be overridden per-team via TeamRules
```

## Runtime Validation Points

1. **Gamemode compatibility**: Gamemode.valid(Map) checks map spawns
2. **Rule consistency**: infiniteResources + waves behavior
3. **Team rules**: protectCores, checkPlacement per team
4. **Save format**: Rules serialization version

## Feature Readiness for GameGuardian

### SOURCE_CONFIRMED Evidence:
- ✅ Gamemode enum with 5 preset modes
- ✅ Rules class with 70+ configurable fields
- ✅ TeamRules per-team customization
- ✅ Rules.mode() selection logic
- ✅ Gamemode.apply() application method
- ✅ JSON serialization for save/load

### Unknown/Inferred:
- ⚠️ Exact field memory offsets (requires runtime testing)
- ⚠️ Net sync behavior for rule changes
- ⚠️ Save format version compatibility
- ⚠️ Interaction with mod content patches

### Data Ready for GENSCRIPT:
- ✅ Class names and field types
- ✅ Field default values
- ✅ Application flow (Gamemode → Rules)
- ✅ Serialization structure
- ✅ Validation methods
- ⚠️ Runtime addresses/offsets - need GameGuardian testing

**Confidence**: HIGH for source structure, LOW for runtime offsets without testing.
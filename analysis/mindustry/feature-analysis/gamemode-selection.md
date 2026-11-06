# Feature Analysis: Gamemode Selection and Rules

## Target Feature
Understanding how Mindustry game modes (survival, sandbox, attack, pvp, editor) are defined and applied.

**Scope**: `Gamemode`, `Rules` classes.

## Source Evidence

### Gamemode Values (Gamemode.java lines 9-41)
- **survival**: waveTimer = true, waves = true
- **sandbox**: infiniteResources = true, allowEditRules = true, waves = true, waveTimer = false
- **attack**: attackMode = true, waveTimer = true, waveSpacing = 2 min, waveTeam infiniteResources = true
- **pvp**: pvp = true, enemyCoreBuildRadius = 600, buildCostMultiplier = 1, buildSpeedMultiplier = 1, unitBuildSpeedMultiplier = 2, attackMode = true
- **editor**: hidden = true, infiniteResources = true, instantBuild = true, editor = true, waves = false, waveTimer = false

### Mode Selection Logic (Rules.java lines 276-288)
```java
public Gamemode mode(){
    if(pvp) return Gamemode.pvp;
    else if(editor) return Gamemode.editor;
    else if(attackMode) return Gamemode.attack;
    else if(infiniteResources) return Gamemode.sandbox;
    else return Gamemode.survival;
}
```

### Mode Application (Gamemode.java lines 67-77)
```java
public Rules apply(Rules in){
    rules.get(in);
    return in;
}
```

## Data Flow for Mode Selection

```
1. Rules fields set by user/Campaign
2. → Rules.mode() evaluates flags
3. → Returns appropriate Gamemode
4. → Gamemode.apply(Rules) sets mode-specific values
5. → Runtime gameplay follows applied rules
```

## Source References

- `D:/project/GameGuardian/srcgame/Mindustry/core/src/mindustry/game/Gamemode.java` - lines 9-41 (definitions), 67-77 (apply), 83-86 (descriptions)
- `D:/project/GameGuardian/srcgame/Mindustry/core/src/mindustry/game/Rules.java` - lines 23-252 (fields), 276-288 (mode selection), 351-442 (TeamRules)
- `D:/project/GameGuardian/srcgame/Mindustry/core/src/mindustry/game/CampaignRules.java` - lines 7-44 (difficulty-based overrides)

## Evidence Classification
- **SOURCE_CONFIRMED**: All code segments above directly read from source
- **RUNTIME_CONFIRMED**: NONE - all analysis is static
- **INFERRED**: Mode application behavior across all scenarios
- **UNKNOWN**: Runtime behavior, actual memory addresses

## Next Steps
1. Validate with actual Mindustry runtime
2. Confirm GameGuardian memory scan approach for Rules fields
3. Prepare GameGuardian Lua script for mode switching
4. Test save file structure for Rules serialization

*Analysis complete for gamemode system*
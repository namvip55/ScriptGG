# Runtime Validation Guide

## Overview
This document provides runtime validation tests and findings for Mindustry, based on source evidence from:
- D:/project/GameGuardian/srcgame/Mindustry/core/src/mindustry/

## Runtime Validation Tests

### Test 1: Version.properties Validation
**Purpose**: Verify version.properties exists and contains expected fields

**Test Plan**:
1. Check for version.properties in game build
2. Verify content structure: type, number, modifier, commitHash, build, buildDate
3. Compare Version.init() behavior with source code

**Source Evidence**: Version.java lines 30-56

### Test 2: Vars Static State Validation
**Purpose**: Confirm Vars.java static state integrity

**Test Points**:
- All static fields defined in Vars.java initialized correctly
- Core game systems (world, universe, gameState, rules) accessible
- AssetManager and core game classes properly instantiated

**Source Evidence**: Vars.java lines 1-304

### Test 3: Gamemode Application Validation
**Purpose**: Verify Gamemode presets apply correctly

**Test Scenarios**:
1. Survival mode: waves + waveTimer enabled
2. Sandbox mode: infiniteResources + allowEditRules enabled  
3. Attack mode: attackMode + waveTimer enabled
4. PvP mode: pvp + attackMode enabled
5. Editor mode: editor + instantBuild enabled

**Source Evidence**: Gamemode.java lines 9-41, Rules.java lines 276-288

### Test 4: Rules Configuration Validation
**Purpose**: Verify Rules.java fields affect gameplay

**Critical Fields to Test**:
- infiniteResources (sandbox vs survival behavior)
- waveTimer (manual vs auto waves)
- attackMode (PvP vs normal behavior)
- editor (edit mode vs normal gameplay)
- coreBuildAndConfig (team editing permissions)

**Source Evidence**: Rules.java lines 23-252

## Runtime Validation Findings

### Source-Confirmed Features

| Feature | Source Confirmed | Test Status | Comments |
|---------|------------------|-------------|----------|
| Gamemode enum | ✅ | Ready to test | Defined in Gamemode.java lines 9-41 |
| Rules data structure | ✅ | Ready to test | 70+ fields in Rules.java lines 23-252 |
| TeamRules per-team | ✅ | Ready to test | Team-specific customization |
| Version properties | ⚠️ | Needs test | version.properties loader in Version.java |
| Vars init sequence | ✅ | Ready to test | Vars.init() at Vars.java line 311 |
| Asset loading | ✅ | Ready to test | Arc engine based |
| Mod system | ✅ | Ready to test | Mod.load() in ClientLauncher |

### Runtime Properties Unknown

| Property | Status | Notes |
|----------|--------|-------|
| Exact memory offsets | ❌ | Requires GameGuardian scan |
| Field addresses | ❌ | Need runtime testing |
| Net sync behavior | ❌ | Multiplayer testing needed |
| Save format version | ⚠️ | Source evidence, needs runtime confirm |
| Data layout | ❌ | Internal structure unknown |

## Runtime Testing Methodology

### 1. Static Field Validation
```java
// Test: Verify key rules fields exist
Assert.assertTrue(Rules.infiniteResources);
Assert.assertTrue(Rules.waveTimer);
Assert.assertTrue(!Rules.editor);
```

### 2. Gamemode Validation
```java
// Test: Gamemode selection logic
Rules rules = new Rules();
rules.infiniteResources = true;
rules.editor = false;
assert rules.mode() == Gamemode.sandbox;

rules.pvp = true;
assert rules.mode() == Gamemode.pvp;
```

### 3. TeamRules Validation
```java
// Test: Team-specific rules
TeamRule playerRules = rules.teams.get(Team.sharded);
playerRules.protectCores = true;
playerRules.infiniteResources = true;
```

## GameGuardian Implementation Guide

### Step 1: Static Analysis
- ✅ Complete source structure mapping
- ✅ Rule field identification
- ✅ Gamemode logic confirmed

### Step 2: Runtime Testing Required
- ⏳ Scan Vars.java static fields in game memory
- ⏳ Scan Rules objects in runtime memory  
- ⏳ Test Gamemode.apply() behavior
- ⏳ Validate TeamRules serialization

### Step 3: Data Type Confirmation
- Java booleans → typically 1 byte
- Java floats → 4 bytes
- Java objects → 4 or 8 bytes (depending on 32/64-bit)

### Step 4: Offset Discovery
- Need to run Mindustry to get baseline memory addresses
- Identify Rule class location
- Scan for field patterns (booleans, floats, objects)

## Integration with GENSCRIPT

### Source-Confirmed Data
- ✅ Class names and package structure
- ✅ Field names and types
- ✅ Application flow (Gamemode → Rules)
- ✅ Serialization structure (JSON)

### Runtime Data Required
- Memory offsets for each Rules field
- Field access patterns (static vs instance)
- Thread safety considerations

## Notes
- All source analysis COMPLETE
- Runtime testing NEEDED for GameGuardian integration
- Arc framework requires runtime validation of field access patterns
- Multiplayer behavior unknown without testing
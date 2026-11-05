# GameGuardian Lua Scripting Knowledge Synthesis

Based on analysis of 3 GameGuardian script projects: `gameguardian-lua-script`, `GGLuaTemplate`, and `GG-Script-Collection`

---

## Core Concepts

### 1. Memory Manipulation API

**Search Functions:**
- `gg.searchNumber(value, type)` - searches for specific values in memory
  - `gg.TYPE_DWORD`: 32-bit integers (whole numbers)
  - `gg.TYPE_FLOAT`: floating-point decimals
  - `gg.TYPE_BYTE`: single bytes
  - `gg.TYPE_WORD`: 16-bit values

- `gg.TYPE_DWORD, gg.TYPE_FLOAT, gg.TYPE_BYTE, gg.TYPE_WORD` - type parameters for search/edit

**Edit Functions:**
- `gg.editAll(new_value, type)` - modifies ALL found memory values
- `gg.clearResults()` - clears current search results
- `gg.getResults(n)` - gets first n results (returns table of tables with address/value/flags)

**Reset Functions:**
- `gg.clearResults()` - resets search state

**Protection Mechanisms:**
- Name protection: Check filename at runtime (`gg.getFile():match('[^/]+$')`)
- Version protection: Define expected game versions array

### 2. Script Structure Patterns

#### Welcome/Loading Sequence
```lua
gg.toast("Starting hook...")
gg.sleep(2250)

-- Welcome Phase
gg.setVisible(false)
gg.alert("RHQ Script Template", "「START」")
gg.clearResults()
gg.toast("\n□□□□□0%")
gg.sleep(500)
gg.toast("\n■□□□□20%")
gg.sleep(500)
-- ... progress to 100%
gg.toast("\n■■■■■100%")
gg.sleep(500)

gg.alert("Welcome to RHQ Script Template")

local startAlert = gg.alert("Start script by clicking the GG Icon!", "OK")
```

#### Main Menu Loop (while true pattern)
```lua
while true do
    local menu = gg.choice({
        "Option 1",
        "Option 2",
        "Option 3",
        "Exit Script"
    }, nil, 'Home Menu - RHQ Script Template')

    if menu == nil then
        gg.toast("🕐 Waiting...")
        gg.sleep(1000)
    elseif menu == 4 then  -- Exit
        gg.toast("👋 Goodbye!")
        os.exit()
    elseif menu == 1 then
        option1()
    elseif menu == 2 then
        option2()
    -- ... etc
    end
end
```

### 3. Common Script Patterns

#### Search and Modify
```lua
gg.clearResults()
gg.searchNumber("999999", gg.TYPE_DWORD)
local results = gg.getResults(20)
gg.editAll("99999999", gg.TYPE_DWORD)
gg.clearResults()
gg.toast("✅ Operation completed!")
```

#### Menu-Driven Scripts
```lua
-- Main menu
local menu = gg.choice({
    "💰 Money Menu",
    "🪙 Coin Menu",
    "🛠 Suspension Menu",
    "🏁 Race Menu",
    "❌ Exit"
}, nil, "Main Menu")

if menu == nil then
    gg.toast("Returning to main menu")
    return mainMenu()
end

-- Handle choices
if menu == 1 then moneyMenu() end
if menu == 2 then coinMenu() end
if menu == 3 then suspensionMenu() end
if menu == 4 then raceMenu() end
if menu == 5 then return end  -- Exit
```

#### Protection Checks
```lua
-- Version check
local scriptVersion = "4.9.4"
local expectedGameVersions = {"4.9.4"}

function checkVersions()
    local gameVersion = gg.getTargetInfo().versionName
    local versionMatch = false
    for _, v in ipairs(expectedGameVersions) do
        if gameVersion == v then versionMatch = true break end
    end
    if not versionMatch then
        gg.alert("Game version unsupported. Please update.")
        os.exit()
    end
    return true
end

-- Name check
if gg.getFile():match('[^/]+$') ~= "_CPMGARAGEULTIMATE.lua" then
    gg.alert("Please rename the script file correctly.")
    os.exit()
end
```

### 4. Key Functions Reference

| Function | Description |
|---|---|
| `gg.searchNumber(value, type [, flag])` | Search memory for value |
| `gg.editAll(value, type)` | Modify ALL found values |
| `gg.clearResults()` | Reset search state |
| `gg.alert(message)` | Show information dialog |
| `gg.toast(message)` | Show temporary notification |
| `gg.prompt(fields)` | Get user input |
| `gg.choice(list, [default], [prompt])` | Show selection menu |
| `gg.getFile()` | Get current script filename |
| `gg.sleep(milliseconds)` | Pause execution |
| `gg.setRanges(type)` | Set memory search region |
| `gg.getTargetInfo()` | Get game target info (version, label, etc.) |
| `gg.getTargetPackage()` | Get target package name |

### 5. Memory Regions (setRanges)

| Region | Description |
|---|---|
| `gg.REGION_ANONYMOUS` | General anonymous memory |
| `gg.REGION_CODE_APP` | App code region |
| `gg.REGION_CODE_SYS` | System code region |
| `gg.REGION_C_ALLOC` | C allocator memory |
| `gg.REGION_C_BSS` | BSS segment |
| `gg.REGION_VIDEO` | Video memory |
| `gg.REGION_BAD` | Bad/invalid memory |
| Combinations: `gg.REGION_CODE_APP | gg.REGION_CODE_SYS` | Multiple regions |

### 6. Advanced Functions

**Refine Search:**
```lua
gg.refineNumber("1.5", gg.TYPE_FLOAT)  -- Narrow search results
```

**Process Resume:**
```lua
gg.processResume()  -- Resume game process for editing
```

**Go to Address:**
```lua
gg.gotoAddress(address)  -- Jump to memory address
```

**Set Values (targeted):**
```lua
gg.setValues({{address = 0x12345678, value = 999, flags = gg.TYPE_DWORD}})
```

**List Management:**
```lua
gg.addListItems(results)  -- Add results to list
gg.removeListItems(items)  -- Remove from list
gg.clearList()  -- Clear list
```

### 7. User Input Functions

```lua
-- Simple prompt
local input = gg.prompt({"Enter value"}, nil, {"number"})
if input then
    gg.editAll(input[1], gg.TYPE_DWORD)
end

-- Choice menu
local choice = gg.choice({
    "Option A",
    "Option B", 
    "Option C"
}, nil, "Select Option")

-- Multi-choice
local choices = gg.multiChoice({
    "Option 1",
    "Option 2",
    "Option 3"
})
if choices then
    -- choices is a table of booleans, one per option
end
```

### 8. Version/Update Protection

```lua
local scriptVersion = "4.9.4"
local expectedGameVersions = {"4.9.4", "5.0.0"}  -- Support multiple versions

function checkVersions()
    local gameVersion = gg.getTargetInfo().versionName
    local versionMatch = false
    for _, v in ipairs(expectedGameVersions) do
        if gameVersion == v then versionMatch = true break end
    end
    
    if not versionMatch then
        gg.alert("This script requires game version " .. table.concat(expectedGameVersions, " or ") .. ". Current: " .. gameVersion)
        print("DOWNLOAD NEW UPDATE")
        os.exit()
    end
    
    -- Also check script version
    if scriptVersion ~= "4.9.4" then  -- Compare with expected
        gg.alert("This script is outdated. Contact owner for renewal.")
        os.exit()
    end
    
    return true
end

-- Run version check before continuing
if not checkVersions() then return end
```

### 9. Common Memory Search Patterns

**Basic DWORD Search:**
```lua
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("5000", gg.TYPE_DWORD)
gg.getResults(100)
gg.editAll("9999", gg.TYPE_DWORD)
gg.clearResults()
```

**Float Search:**
```lua
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("1.25", gg.TYPE_FLOAT)
gg.getResults(50)
gg.editAll("2.50", gg.TYPE_FLOAT)
gg.clearResults()
```

**Advanced Flag Search:**
```lua
gg.searchNumber("123456", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
-- Parameters: value, type, flag, sign, min, max, index
```

**Float with Mask:**
```lua
gg.searchNumber("1.0", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1)
```

### 10. Progress/Toggle Patterns

**Progressive Search (incremental):**
```lua
-- Search for value, refine, search again
gg.searchNumber("value", gg.TYPE_FLOAT)
gg.getResults(10)
gg.refineNumber("new_value", gg.TYPE_FLOAT)
gg.searchNumber("new_value", gg.TYPE_FLOAT)
gg.getResults(10)
gg.editAll("final_value", gg.TYPE_FLOAT)
```

**On/Off Toggle:**
```lua
local isOn = false

function toggleFeature()
    if isOn then
        -- Disable: restore original values
        gg.alert("Feature OFF")
        isOn = false
    else
        -- Enable: search and modify
        gg.searchNumber("value", gg.TYPE_FLOAT)
        gg.editAll("new_value", gg.TYPE_FLOAT)
        gg.toast("Feature ON ✅")
        isOn = true
    end
end
```

### 11. Menu Systems Across Projects

**Simple Choice Menu:**
```lua
local choice = gg.choice({
    "💰 Money Menu",
    "🪙 Coin Menu", 
    "🛠 Suspension Menu",
    "❌ Exit"
}, nil, "Main Menu")
```

**Suspension Menu (while loop):**
```lua
function suspensionMenu()
    while true do
        local choice = gg.choice({
            "📏 Camber Menu",
            "🛸 UFO Mode",
            "🏎 Steering Angle",
            "❌ Back to Main"
        }, nil, "Suspension Menu")
        
        if choice == nil or choice == 4 then
            gg.toast("Returning to main menu")
            return mainMenu()
        end
        
        -- Handle choice
        if choice == 1 then camberMenu() end
        if choice == 2 then ufoMode() end
        if choice == 3 then steeringAngleMenu() end
    end
end
```

### 12. Specific Patterns From Scripts

**Body Kit Price Reset:**
```lua
-- Step 1: Find first price ($5,000)
gg.searchNumber("5000", gg.TYPE_DWORD)
gg.getResults(100)
gg.sleep(4000)

-- Step 2: Find second price ($10,000)
gg.searchNumber("10000", gg.TYPE_DWORD)
local results = gg.getResults(1)

-- Step 3: Get user input for current money and car price
local input = gg.prompt({
    {"Enter Current Money Value", "number"},
    {"Enter Car Price", "number"}
})

if input then
    local moneyValue = tonumber(input[1])
    local carPrice = tonumber(input[2])
    
    -- Calculate: (money - carPrice) + (-5000)
    local editedValue = (moneyValue - carPrice) + (-5000)
    results[1].value = editedValue
    gg.setValues(results)
end
```

**Coin Hack Pattern (500;100 search):**
```lua
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("500;100", gg.TYPE_DWORD)
gg.sleep(2000)
local results = gg.getResults(50)

if #results > 0 then
    -- Edit to reset coins
    gg.editAll("-2000000000", gg.TYPE_DWORD)  -- Set to large negative
    gg.sleep(2000)
    -- Then set to specific values based on desired amount
    gg.editAll("-294967296", gg.TYPE_DWORD)  -- 100k coins
    gg.toast("✅ Coins hacked!")
end
```

**Speed Hack Pattern:**
```lua
gg.setRanges(gg.REGION_CODE_APP | gg.REGION_CODE_SYS)
gg.searchNumber("-1.13333332539", gg.TYPE_FLOAT)
gg.getResults(1)
gg.editAll("-0.97", gg.TYPE_FLOAT)
gg.toast("✓ Speed hack enabled ✓")
```

**Fly Hack Pattern:**
```lua
gg.setRanges(gg.REGION_CODE_APP | gg.REGION_CODE_SYS)
gg.searchNumber("1.21408491E-11", gg.TYPE_FLOAT)
gg.getResults(1)
gg.editAll("9.32067518e-21", gg.TYPE_FLOAT)
gg.toast("✓ Fly hack enabled ✓")
```

### 13. Glitch Speed / Shift Speed Patterns

```lua
-- Toggle glitch speed effects
GLITCH1 = off  -- " 🔴⃢  "
on = "      ⃢🔵"

function glitchSpeed()
    local choice = gg.choice({
        "⚡️ Glitch 1125hp" .. GLITCH1,
        "⚡️ Glitch 2000hp" .. GLITCH2,
        -- ... more options
        "❌ Exit"
    }, nil, "Glitch Speed Menu")
    
    -- Toggle logic
    if choice == 1 then
        if GLITCH1 == on then
            GL1()  -- Disable
            GLITCH1 = off
        else
            GL2()  -- Enable first level
            GLITCH1 = on
        end
    end
    -- ... etc
end
```

### 14. HP Presets Pattern

Large presets table with positive and negative values:
```lua
local hpPresets = {
    -- Positive values (increase HP)
    {2400, 2300, 8000, 7998},  -- HP, Torque, Inner HP, Inner Torque
    {2300, 2300, 8000, 7998},
    -- ... more presets
    -- Negative values (decrease HP)
    {-0.1, 2300, 8000, 7998},
    {-1, 2300, 8000, 7998},
    -- ... etc
}

function hpPresetsMenu()
    local menuOptions = {}
    for i, preset in ipairs(hpPresets) do
        table.insert(menuOptions, tostring(preset[1]) .. "HP🚀")
    end
    table.insert(menuOptions, "❌ Back")
    
    local choice = gg.choice(menuOptions, nil, "HP Presets Menu")
    if choice and choice ~= #menuOptions then
        applyHP(hpPresets[choice])
    end
end

function applyHP(preset)
    local searchValues = {240, 310, 6800, 4500}  -- HP, Torque, Inner HP, Inner Torque
    local valueNames = {'HP', 'Torque', 'Inner HP', 'Inner Torque'}
    
    for i = 1, 4 do
        gg.setRanges(gg.REGION_ANONYMOUS)
        gg.searchNumber(searchValues[i], gg.TYPE_FLOAT)
        local results = gg.getResults(50)
        
        if #results > 0 then
            gg.editAll(preset[i], gg.TYPE_FLOAT)
        else
            gg.alert(valueNames[i] .. " values not found!")
        end
        gg.clearResults()
    end
    
    gg.toast("HP adjusted!")
    waitForGG(hpMenu)
end
```

### 15. Maintenance/On-Off Toggle Pattern

```lua
toggle_Y10 = false  -- State variable
revert_Y10 = nil  -- Store original values for restore

function toggleY10()
    if toggle_Y10 then
        -- Restore original values
        if revert_Y10 then gg.setValues(revert_Y10) end
        gg.toast("Y10 OFF❌")
        toggle_Y10 = false
    else
        -- Save original, then modify
        gg.clearResults()
        gg.setRanges(gg.REGION_ANONYMOUS)
        gg.searchNumber("0.40000000596F;5;0.10000000149F;1:13", gg.TYPE_FLOAT)
        gg.refineNumber("5", gg.TYPE_FLOAT)
        revert_Y10 = gg.getResults(9999)
        gg.editAll("1999", gg.TYPE_FLOAT)
        toggle_Y10 = true
        gg.toast("Y10 ON✅")
    end
    waitForGG(maintenanceMenu)
end
```

### 16. UFO / Custom Camber Patterns

**UFO Mode:**
```lua
function ufoMode()
    while true do
        local choice = gg.choice({
            "UFO Mode 1 👽",
            "UFO Mode 2 👾",
            "UFO Mode 3 🛸",
            "❌ Back"
        }, nil, "UFO Menu")
        
        if choice == nil or choice == 4 then
            return suspensionMenu()
        end
        
        local ufoValues = {-90, -120, -180}  -- camber values
        applyUfoPreset(ufoValues[choice])
    end
end

function applyUfoPreset(value)
    gg.setRanges(gg.REGION_ANONYMOUS)
    gg.searchNumber("-10", gg.TYPE_FLOAT)
    gg.getResults(100)
    gg.clearResults()
    gg.sleep(1000)
    
    gg.alert("Set Incline to 10")
    gg.sleep(15000)
    gg.setVisible(false)
    gg.alert("Set Incline to 0")
    gg.sleep(5000)
    gg.alert("Set Incline to 10")
    gg.sleep(5000)
    
    gg.toast("Applying UFO mode...")
    gg.searchNumber("-10", gg.TYPE_FLOAT)
    local results = gg.getResults(100)
    
    if #results > 0 then
        gg.editAll(tostring(value), gg.TYPE_FLOAT)
        gg.toast("UFO mode applied!👽✅")
    else
        gg.alert("UFO values not found!")
    end
    
    waitForGG(suspensionMenu)
end
```

**Custom Camber:**
```lua
function customCamber()
    -- Pre-search
    gg.searchNumber("-10", gg.TYPE_FLOAT)
    local results = gg.getResults(100)
    
    if #results > 0 then
        gg.editAll("-10", gg.TYPE_FLOAT)  -- Reset
        gg.clearResults()
    else
        gg.toast("❌ Pre-search failed!")
        return
    end
    
    -- Prompt for custom value
    local input = gg.prompt({"Enter Custom Camber"}, {nil}, {"number"})
    if input and input[1] then
        local value = input[1]
        
        -- Main sequence
        gg.alert("Set Incline to 10")
        gg.sleep(15000)
        gg.setVisible(false)
        gg.alert("Set Incline to 0")
        gg.sleep(5000)
        gg.alert("Set Incline to 10")
        gg.sleep(5000)
        
        gg.searchNumber("-10", gg.TYPE_FLOAT)
        local results = gg.getResults(100)
        
        if #results > 0 then
            gg.editAll(tostring(value), gg.TYPE_FLOAT)
            gg.toast("Camber adjusted to " .. value .. " ✅")
            gg.sleep(5000)
            gg.clearResults()
            gg.toast("Returning to menu...")
            waitForGG(suspensionMenu)
        end
    end
end
```

### 17. Glitch Speed Toggling Pattern

```lua
off = " 🔴⃢  "
on = "      ⃢🔵"
GLITCH1 = off
GLITCH2 = off
-- ... up to GLITCH10

function glitchSpeed()
    local choice = gg.choice({
        "⚡️ Glitch 1125hp" .. GLITCH1,
        "⚡️ Glitch 2000hp" .. GLITCH2,
        "⚡️ Glitch 1195hp" .. GLITCH3,
        "⚡️ Glitch 1234hp" .. GLITCH4,
        "⚡️ Glitch 11000hp" .. GLITCH5,
        "⚡️ Glitch 999hp" .. GLITCH6,
        "⚡️ Glitch 800hp" .. GLITCH7,
        "⚡️ Glitch 414hp" .. GLITCH8,
        "⚡️ Glitch 300hp" .. GLITCH9,
        "⚡️ Glitch 250hp" .. GLITCH10,
        "❌ Back to HP Menu"
    }, nil, "Glitch Speed Menu")
    
    if choice == nil or choice == 11 then
        gg.toast("Returning to HP menu")
        return hpMenu()
    end
    
    -- Toggle logic
    local function toggleGlitch(choiceIndex, enableFunc, disableFunc, glitchVarName)
        if _G[glitchVarName] == on then
            disableFunc()
            _G[glitchVarName] = off
        else
            enableFunc()
            _G[glitchVarName] = on
        end
    end
    
    if choice == 1 then
        toggleGlitch(1, GL1, GL_undefined, "GLITCH1")
    elseif choice == 2 then
        toggleGlitch(2, GL2, GL_undefined, "GLITCH2")
    -- ... etc up to 10
    end
    
    gg.toast("Returning to glitch menu")
    waitForGG(glitchSpeed)
end
```

### 18. HP Preset Application Pattern

```lua
function applyHP(preset)
    gg.alert("Buy Engine 3.0")
    gg.sleep(15000)
    gg.toast("Applying HP mod...")
    gg.sleep(5000)
    
    local searchValues = {240, 310, 6800, 4500}  -- HP, Torque, Inner HP, Inner Torque
    local valueNames = {'HP', 'Torque', 'Inner HP', 'Inner Torque'}
    
    for i = 1, 4 do
        gg.setRanges(gg.REGION_ANONYMOUS)
        gg.searchNumber(searchValues[i], gg.TYPE_FLOAT)
        local results = gg.getResults(100)
        
        if #results > 0 then
            gg.editAll(preset[i], gg.TYPE_FLOAT)
        else
            gg.alert(valueNames[i] .. " values not found! Try again.")
        end
        gg.clearResults()
    end
    
    gg.alert("Click on Engine 3.0 then buy & set tires")
    gg.sleep(6000)
    gg.alert("HP adjustment complete!")
    gg.toast("Return to presets menu")
    waitForGG(hpMenu)
end
```

### 19. Custom HP Input Pattern

```lua
function customHPInput()
    gg.alert("Buy engine and remember torque add tire sound/pos")
    gg.sleep(10000)
    
    local input = gg.prompt({
        'Current HP:', 'New HP:',
        'Current Torque:', 'New Torque:',
        'Current Inner HP:', 'New Inner HP:',
        'Current Inner Torque:', 'New Inner Torque:'
    }, {}, {'number', 'number', 'number', 'number', 'number', 'number', 'number', 'number'})
    
    if not input then return end
    
    local values = {
        {input[1], input[2]},
        {input[3], input[4]},
        {input[5], input[6]},
        {input[7], input[8]}
    }
    
    for i, v in ipairs(values) do
        gg.setRanges(gg.REGION_ANONYMOUS)
        gg.searchNumber(v[1], gg.TYPE_FLOAT)
        local results = gg.getResults(100)
        
        if #results > 0 then
            gg.editAll(v[2], gg.TYPE_FLOAT)
        else
            gg.alert("Value not found! Try again.")
        end
        gg.clearResults()
    end
    
    gg.alert("HP adjustment complete!")
    gg.sleep(6000)
    gg.alert("Click on engine & buy tires")
    gg.toast("Return to HP menu")
    waitForGG(hpMenu)
end
```

### 20. Shift Speed Glitch Pattern

```lua
function shiftSpeedMenu()
    local choice = gg.choice({
        "1E-25 💣",   -- shift speed 1
        "1E-26 💢",   -- shift speed 2
        "1E-27 💥",   -- shift speed 3
        "1E-28 🚀",   -- shift speed 4
        "1E-29 🥇",   -- shift speed 5
        "1E-30 🔥",   -- shift speed 6
        "1E-31 🏁",   -- shift speed 7
        "1E-32 🏆",   -- shift speed 8
        "1E-33 🏴‍☠️", -- shift speed 9
        "1E-34 ⚡️", -- shift speed 10
        "❌ Back to HP Menu"
    }, nil, "Shift Speed Menu")
    
    if choice == nil or choice == 11 then
        gg.toast("Returning to HP menu")
        return hpMenu()
    end
    
    -- Apply shift speed 1E-(24+choice)
    local exponent = 24 + choice
    gg.setRanges(gg.REGION_CODE_APP)
    gg.alert("Buy fast gear")
    gg.sleep(15000)
    gg.setVisible(false)
    gg.searchNumber("0.1", gg.TYPE_FLOAT)
    local results = gg.getResults(250)
    
    if #results > 0 then
        gg.sleep(2000)
        gg.editAll("1E-" .. exponent, gg.TYPE_FLOAT)
        gg.alert("Shift speed applied! " .. exponent .. " zeros")
    else
        gg.alert("Shift speed values not found!")
    end
    
    gg.clearResults()
    gg.toast("Return to shift speed menu")
    waitForGG(hpMenu)
end
```

### 21. Maintenance Menu Toggle Pattern

```lua
on = "      ⃢🔵"
off = " 🔴⃢  "

toggle_Y10 = false
toggle_Y12 = false
revert_Y10 = nil
revert_Y12 = nil

function maintenanceMenu()
    local menu = gg.choice({
        "💥 Y10 " .. (toggle_Y10 and off or on),
        "💣 Y12 " .. (toggle_Y12 and off or on),
        "❌ Back"
    }, nil, "Car Maintenance Menu")
    
    if menu == nil or menu == 3 then
        return mainMenu()
    end
    
    if menu == 1 then toggleY10() end
    if menu == 2 then toggleY12() end
end

function toggleY10()
    if toggle_Y10 then
        if revert_Y10 then gg.setValues(revert_Y10) end
        gg.toast("Y10 OFF❌")
        toggle_Y10 = false
    else
        gg.clearResults()
        gg.setRanges(gg.REGION_ANONYMOUS)
        gg.searchNumber("0.40000000596F;5;0.10000000149F;1:13", gg.TYPE_FLOAT)
        gg.refineNumber("5", gg.TYPE_FLOAT)
        revert_Y10 = gg.getResults(9999)
        gg.editAll("1999", gg.TYPE_FLOAT)
        toggle_Y10 = true
        gg.toast("Y10 ON✅")
    end
    waitForGG(maintenanceMenu)
end
```

### 22. Race Menu Pattern

```lua
function raceMenu()
    while true do
        local choice = gg.choice({
            "🏁 Autowin Hack",
            "🏎 Downforce Hack",
            "💨 Fly Hack",
            "❌ Back"
        }, nil, "Race Menu")
        
        if choice == nil or choice == 4 then
            return mainMenu()
        end
        
        if choice == 1 then autowin() end
        if choice == 2 then downforce() end
        if choice == 3 then flyhack() end
    end
end
```

### 23. Info/About Alert Pattern

```lua
gg.alert([[
₴₵Ɽł₱₮ ฿Ɏ _₵₱₥₂₳Ɽ₳₂Ɇ    
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⣀⣀⣀⣀⣀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⢀⠀⣀⣠⣴⣾⡿⠟⢛⡿⠟⠛⠿⣯⡛⠉⠉⠛⠒⠀⠀
-- ... ASCII art
]])

print("Script by: Ethan (github.com/ethanlabs101)")
print("Version: 4.9.4")
```

### 24. Exit/Reset Pattern

```lua
function Exit()
    gg.alert("Thank you for using my script!")
    gg.skipRestoreState()
    os.exit()
end

-- Or simpler:
gg.toast("Have a great day!")
gg.sleep(2000)
os.exit()
```

### 25. Wait for GG Pattern (common across all scripts)

```lua
function waitForGG(callback)
    while not gg.isVisible() do
        gg.sleep(100)
    end
    gg.setVisible(false)  -- Hide GG UI
    if callback then
        callback()  -- Return to the correct menu
    end
end
```

Or the simpler version:
```lua
function waitForGG()
    gg.toast("Tap GG to continue...")
    while true do
        if gg.isVisible() then
            gg.sleep(1000)
            break
        end
        gg.sleep(100)
    end
end
```

### 26. Coin Amount Editing Pattern

Different offsets for different coin amounts (all based on searching "500;100"):

| Target Coins | Edit Value |
|---|
| 1 coin | -294966296 |
| 10 coins | -294957296 |
| 15 coins | -294952296 |
| 20 coins | -294947296 |
| 25 coins | -294942296 |
| 30 coins | -294937296 |
| 35 coins | -294932296 |
| 40 coins | -294927296 |
| 45 coins | -294922296 |
| 50 coins | -294917296 |
| 60 coins | -294907296 |
| 70 coins | -294897296 |
| 80 coins | -294887296 |
| 90 coins | -294877296 |
| 100 coins | -294867296 |
| 150 coins | -294807296 |
| 200 coins | -294767296 |
| 250 coins | -294707296 |
| 300 coins | -294667296 |
| 400 coins | -294567296 |
| 500 coins | -294467296 |
| 1000 coins | -294133332 (approx) |

Pattern: Each 50 coin increment changes the edit value by approximately 50,000.

### 27. Summary of Key Lua Patterns for GameGuardian Scripting

1. **Always start with version/name protection** if distributing scripts
2. **Use while true loop for main menu** with gg.choice()
3. **Set memory ranges before searching** (REGION_ANONYMOUS most common)
4. **Search with proper type** (TYPE_DWORD for integers, TYPE_FLOAT for decimals)
5. **Get results before editing** (gg.getResults(n))
6. **Edit all found values** (gg.editAll(value, type))
7. **Clear results after editing** (gg.clearResults())
8. **Use toast for user feedback** (gg.toast("message"))
9. **Use alert for important messages** (gg.alert("message"))
10. **Wait for GG to be visible** before proceeding (while not gg.isVisible() loop)
11. **Use gg.sleep() between operations** for stability (typically 100-5000ms)
12. **Implement on/off toggles** with state variables
13. **Use gg.prompt() for user input** when values need to be specified
14. **Multi-region searches** combine regions with `|` (pipe)
15. **Progressive refinement** with gg.refineNumber() for better results
16. **Version/Update checks** before script execution
17. **ASCII art/branding** in alerts for identity
18. **Exit handling** with gg.skipRestoreState() and os.exit()
19. **Menu nesting** with while loops for submenus
20. **Return to main menu** pattern using waitForGG() or direct returns

These patterns form the foundation of most GameGuardian Lua scripts and can be combined/modified to create scripts for various games and modifications.
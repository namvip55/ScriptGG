# GameGuardian Lua Scripting Knowledge Synthesis

Based on analysis of 3 GameGuardian script projects: `gameguardian-lua-script`, `GGLuaTemplate`, and `GG-Script-Collection`

---

## Core Concepts

### Memory Manipulation API

**Search Functions:**
- `gg.searchNumber(value, type)` - searches for specific values in memory
  - `gg.TYPE_DWORD`: 32-bit integers (whole numbers)
  - `gg.TYPE_FLOAT`: floating-point decimals
  - `gg.TYPE_BYTE`: single bytes
  - `gg.TYPE_WORD`: 16-bit values

**Edit Functions:**
- `gg.editAll(new_value, type)` - modifies found memory values
- `gg.clearResults()` - clears current search results

**Alert Functions:**
- `gg.alert(message)` - shows popup dialog
- `gg.toast(message)` - shows temporary notification
- `gg.prompt(fields)` - gets user input

### Script Structure Patterns

1. **Welcome Message**: `gg.alert("Welcome message")`
2. **Menu Definition**: Table with string options
3. **Choice Loop**: `gg.choice(menu, nil, "Prompt")` in while loop
4. **Mod Functions**: Individual functions for each menu option
5. **Protection Mechanisms**:
   - Name protection: Check filename at runtime (`gg.getFile():match('[^/]+$')`)
   - Version protection: Define expected game versions array

### Common Script Patterns

```lua
-- Search and modify example
gg.clearResults()
gg.searchNumber("999999", gg.TYPE_DWORD)
local results = gg.getResults(20)
gg.editAll("99999999", gg.TYPE_DWORD)
gg.clearResults()
gg.toast("✅ Operation completed!")
```

### File Organization

- `/script`: Main master scripts (e.g., `_CPMGARAGEULTIMATE.lua`)
- `/templates`: Script templates for beginners (`gg-template.lua`)
- `/delta-script`: Specialized scripts
- `/first-script`: Initial learning scripts

### Key References

- GameGuardian API: https://gameguardian.net/
- Lua Documentation: https://www.lua.org/manual/5.1/
- Template examples show practical patterns for:
  - Number hacks (DWORD)
  - Float value modifications
  - Advanced flag-based searches
  - User-input driven modifications

## Implementation Guidelines

1. **Start with Templates**: Use `gg-template.lua` as base structure
2. **Modular Design**: Create separate functions for each functionality
3. **Memory Safety**: Always clear results after operations
4. **User Feedback**: Use toast notifications for completion status
5. **Protection**: Implement name and version checks for production scripts
6. **Testing**: Test each modification type (DWORD, FLOAT) independently

## Common Functions Reference

- `gg.searchNumber(value, type [, flag])` - search memory
- `gg.editAll(value, type)` - modify found values
- `gg.clearResults()` - reset search state
- `gg.alert(message)` - show information dialog
- `gg.toast(message)` - show temporary notification
- `gg.prompt(fields)` - get user input
- `gg.choice(list, [default], [prompt])` - show selection menu
- `gg.getFile()` - get current script filename
- `gg.sleep(milliseconds)` - pause execution

---

## Extended Knowledge: Advanced Patterns

This section is expanded based on analysis of all three projects.

### 1. Welcome/Loading Sequence Pattern

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
gg.toast("\n■■□□□40%")
gg.sleep(500)
gg.toast("\n■■■□□60%")
gg.sleep(500)
gg.toast("\n■■■■□80%")
gg.sleep(500)
gg.toast("\n■■■■■100%")
gg.sleep(500)

gg.alert("Welcome to Script Template")

local startAlert = gg.alert("Start script by clicking the GG Icon!", "OK")

if startAlert == 1 then
    gg.setVisible(false)
    gg.processKill()
    gg.sleep(500)
    gg.toast("Starting Menu...")
    gg.setVisible(true)
    gg.sleep(500)
end
```

### 2. Main Menu Loop (while true pattern)

```lua
while true do
    local menu = gg.choice({
        "💰 Money Menu",
        "🪙 Coin Menu",
        "🛠 Suspension Menu",
        "🏁 Race Menu",
        "❌ Exit Script"
    }, nil, "Main Menu")

    if menu == nil then
        gg.toast("🕐 Waiting...")
        gg.sleep(1000)
    elseif menu == 5 then
        gg.toast("👋 Goodbye!")
        os.exit()
    elseif menu == 1 then
        moneyMenu()
    elseif menu == 2 then
        coinMenu()
    elseif menu == 3 then
        suspensionMenu()
    elseif menu == 4 then
        raceMenu()
    end
end
```

### 3. Version/Update Protection

```lua
local scriptVersion = "4.9.4"
local expectedGameVersions = {"4.9.4", "5.0.0"}  -- Support multiple versions

function checkVersions()
    local gameVersion = gg.getTargetInfo().versionName

    local versionMatch = false
    for _, v in ipairs(expectedGameVersions) do
        if gameVersion == v then
            versionMatch = true
            break
        end
    end

    if not versionMatch then
        gg.alert("This script requires game version " .. table.concat(expectedGameVersions, " or ") .. ". Current: " .. gameVersion)
        print("DOWNLOAD NEW UPDATE")
        os.exit()
    end

    if scriptVersion ~= "4.9.4" then
        gg.alert("This script is outdated. Contact owner for renewal.")
        os.exit()
    end

    return true
end

-- Run version check before continuing
if not checkVersions() then return end
```

### 4. Name Protection

```lua
-- Check filename at runtime
local filename = gg.getFile():match('[^/]+$')
if filename ~= "_CPMGARAGEULTIMATE.lua" then
    gg.alert("Please rename the script file correctly.")
    os.exit()
end
```

### 5. Memory Regions (setRanges)

| Region | Description |
|---|---|
| `gg.REGION_ANONYMOUS` | General anonymous memory (most common) |
| `gg.REGION_CODE_APP` | App code region |
| `gg.REGION_CODE_SYS` | System code region |
| `gg.REGION_C_ALLOC` | C allocator memory |
| `gg.REGION_C_BSS` | BSS segment |
| `gg.REGION_VIDEO` | Video memory |
| `gg.REGION_BAD` | Bad/invalid memory |

**Combine regions with `|` (pipe):**
```lua
gg.setRanges(gg.REGION_CODE_APP | gg.REGION_CODE_SYS)
gg.setRanges(gg.REGION_C_DATA | gg.REGION_CODE_APP)
gg.setRanges(gg.REGION_VIDEO | gg.REGION_BAD)
```

### 6. Basic Search Patterns

**DWORD Search:**
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

### 7. Progressive/Refined Search

```lua
-- Search for value, refine, search again
gg.searchNumber("value", gg.TYPE_FLOAT)
gg.getResults(10)
gg.refineNumber("new_value", gg.TYPE_FLOAT)
gg.searchNumber("new_value", gg.TYPE_FLOAT)
gg.getResults(10)
gg.editAll("final_value", gg.TYPE_FLOAT)
```

### 8. On/Off Toggle Pattern

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

### 9. Toggle with State Restoration

```lua
toggle_Y10 = false
revert_Y10 = nil

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

### 10. UI Display Toggles

```lua
on = "      ⃢🔵"
off = " 🔴⃢  "

local function menuWithToggle()
    local menu = gg.choice({
        "Feature " .. (isOn and off or on),
        "❌ Back"
    }, nil, "Feature Menu")
    
    if menu == nil or menu == 2 then return mainMenu() end
    toggleFeature()
end
```

### 11. User Input Functions

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

-- 8-field prompt (custom HP input pattern)
local input = gg.prompt({
    'Current HP:', 'New HP:',
    'Current Torque:', 'New Torque:',
    'Current Inner HP:', 'New Inner HP:',
    'Current Inner Torque:', 'New Inner Torque:'
}, {}, {'number', 'number', 'number', 'number', 'number', 'number', 'number', 'number'})
```

### 12. Menu Nesting Pattern

```lua
function currencyMenu()
    while true do
        local choice = gg.choice({
            "💵 Money Menu",
            "🪙 Coin Menu",
            "❌ Back"
        }, nil, "Currency Menu")

        if choice == nil or choice == 3 then
            return mainMenu()
        end

        if choice == 1 then moneyMenu() end
        if choice == 2 then coinMenu() end
    end
end

function suspensionMenu()
    while true do
        local choice = gg.choice({
            "📏 Camber Menu",
            "🛸 UFO Mode",
            "🏎 Steering Angle",
            "❌ Back to Main"
        }, nil, "Suspension Menu")

        if choice == nil or choice == 4 then
            return mainMenu()
        end

        if choice == 1 then camberMenu() end
        if choice == 2 then ufoMode() end
        if choice == 3 then steeringAngleMenu() end
    end
end
```

### 13. UFO Mode Pattern

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

        local ufoValues = {-90, -120, -180}
        applyUfoPreset(ufoValues[choice])
    end
end

function applyUfoPreset(value)
    -- Pre-search
    gg.setRanges(gg.REGION_ANONYMOUS)
    gg.searchNumber("-10", gg.TYPE_FLOAT)
    gg.getResults(100)
    gg.clearResults()
    gg.sleep(1000)

    -- User interaction sequence
    gg.alert("Set Incline to 10")
    gg.sleep(15000)
    gg.setVisible(false)
    gg.alert("Set Incline to 0")
    gg.sleep(5000)
    gg.alert("Set Incline to 10")
    gg.sleep(5000)

    -- Main search and edit
    gg.toast("Applying UFO mode...")
    gg.searchNumber("-10", gg.TYPE_FLOAT)
    local results = gg.getResults(100)

    if #results > 0 then
        gg.editAll(tostring(value), gg.TYPE_FLOAT)
        gg.toast("UFO mode applied!👽✅")
    else
        gg.alert("UFO values not found!")
    end

    gg.sleep(5000)
    gg.clearResults()
    gg.toast("Returning to suspension menu")
    waitForGG(suspensionMenu)
end
```

### 14. Custom Camber Pattern

```lua
function customCamber()
    -- Pre-search step
    gg.searchNumber("-10", gg.TYPE_FLOAT)
    local results = gg.getResults(100)

    if #results > 0 then
        gg.editAll("-10", gg.TYPE_FLOAT)
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

### 15. Glitch Speed Pattern

```lua
off = " 🔴⃢  "
on = "      ⃢🔵"
GLITCH1 = off
GLITCH2 = off
GLITCH3 = off
GLITCH4 = off
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

    -- Toggle logic: each choice toggles its own state
    if choice == 1 then
        if GLITCH1 == on then
            GL1()  -- disable
            GLITCH1 = off
        else
            GL2()  -- enable first level
            GLITCH1 = on
        end
    elseif choice == 2 then
        if GLITCH2 == on then
            GL3()
            GLITCH2 = off
        else
            GL4()
            GLITCH2 = on
        end
    end
    -- ... etc for choices 3-10

    gg.toast("Returning to glitch menu")
    waitForGG(glitchSpeed)
end
```

### 16. HP Presets Pattern

```lua
local hpPresets = {
    -- Positive values: {HP, Torque, Inner HP, Inner Torque}
    {2400, 2300, 8000, 7998},
    {2300, 2300, 8000, 7998},
    {2299, 2300, 8000, 7998},
    {2250, 2300, 8000, 7998},
    -- ... more positive presets down to small values
    {0.1, 2300, 8000, 7998},
    {0.01, 2300, 8000, 7998},
    {0.001, 2300, 8000, 7998},
    -- Negative values
    {-0.1, 2300, 8000, 7998},
    {-1, 2300, 8000, 7998},
    {-5000000, 2300, 8000, 7998},
    -- ... more negative presets down to -9999999
}

function hpPresetsMenu()
    local menuOptions = {}
    for i, preset in ipairs(hpPresets) do
        table.insert(menuOptions, tostring(preset[1]) .. "HP🚀")
    end
    table.insert(menuOptions, "❌ Back")

    local choice = gg.choice(menuOptions, nil, "HP Presets Menu")

    if choice == nil or choice == #menuOptions then
        gg.toast("Returning to performance menu")
        return hpMenu()
    end

    applyHP(hpPresets[choice])
    waitForGG()
end

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

### 17. Custom HP Input Pattern

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

### 18. Shift Speed Pattern

```lua
function shiftSpeedMenu()
    local choice = gg.choice({
        "1E-25 💣",
        "1E-26 💢",
        "1E-27 💥",
        "1E-28 🚀",
        "1E-29 🥇",
        "1E-30 🔥",
        "1E-31 🏁",
        "1E-32 🏆",
        "1E-33 🏴‍☠️",
        "1E-34 ⚡️",
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

### 19. Maintenance Menu Toggle Pattern

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
```

### 20. Coin Hack Pattern

The coin hack follows a consistent pattern across both projects:

1. Search for "500;100" as DWORD
2. Get results
3. Edit to "-2000000000" (large negative to bypass)
4. Sleep/wait for user to buy item in-game
5. Edit to specific coin value based on desired amount
6. Clear results and return to menu

**Coin amount edit values:**

| Target Coins | Edit Value |
|---|---|
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

Pattern: Each 50-coin increment changes the edit value by approximately 50,000.

```lua
function fiveHundred()
    gg.alert("GO TO DRIVER EDIT MENU")
    gg.sleep(15000)
    gg.setVisible(false)
    gg.setRanges(gg.REGION_ANONYMOUS)
    gg.sleep(15000)

    gg.searchNumber("500;100", gg.TYPE_DWORD)
    gg.sleep(2000)
    local results = gg.getResults(50)

    if #results > 0 then
        gg.editAll("-2000000000", gg.TYPE_DWORD)
        gg.sleep(2000)
        gg.alert("Now go to animations and buy 2 with -$")
        gg.sleep(6000)
        gg.toast("✅ Coins hack applied!")
        gg.alert("After buying both -$ wait in driver menu for final edit")
        gg.editAll("-294467296", gg.TYPE_DWORD)
        gg.sleep(3000)
        gg.alert("Now go to animations and buy 1 with changed price")
        gg.sleep(5000)
        gg.clearResults()
    else
        gg.alert("No values found!")
    end

    gg.toast("Tap GG to return to coin menu")
    waitForGG(coinMenu)
end
```

### 21. Money Reset Pattern

```lua
function resetMoney()
    gg.alert("GO TO CAR BUY LIST AND FIND CAR WITH UNBOUGHT BODY KIT")
    gg.toast("You have 15 seconds......")
    gg.sleep(15000)
    gg.setRanges(gg.REGION_ANONYMOUS)

    -- Step 1: Search first body kit price ($5,000)
    gg.alert("FIND BODY KIT WORTH = $5,000")
    gg.sleep(6000)
    gg.searchNumber('5000', gg.TYPE_DWORD)
    gg.getResults(100)
    gg.sleep(4000)

    -- Step 2: Search second body kit price ($10,000)
    gg.alert("NOW ADD ANOTHER PART SO = $10,000")
    gg.sleep(4000)
    gg.searchNumber('10000', gg.TYPE_DWORD)
    local results = gg.getResults(1)
    gg.sleep(3000)

    -- Step 3: Prompt for money and car price input
    local input = gg.prompt(
        {'Enter Current Money Value', 'Enter Car Price'},
        {nil, nil},
        {'number', 'number'}
    )

    if input and input[1] and input[2] then
        local moneyValue = tonumber(input[1])
        local carPrice = tonumber(input[2])

        -- Step 4: Calculate and edit
        if results and #results > 0 then
            local editedValue = (moneyValue - carPrice) + (-5000)
            results[1].value = editedValue
            gg.setValues(results)
        end

        gg.sleep(2000)
        gg.alert("NOW FIND BODY KIT PART WITH NEW PRICE AND BUY CAR")
        gg.sleep(5000)
        gg.clearResults()
        gg.toast('Money successfully reset')
        gg.toast('Tap GG to return to currency menu')
        waitForGG(currencyMenu)
    else
        gg.alert('Invalid input. Please enter valid numbers.')
    end
end
```

### 22. Steering Angle Pattern

```lua
function applySteeringAngle(value)
    gg.alert('Move steering angle to 60 then click GG to start')
    gg.sleep(10000)
    gg.searchNumber('60', gg.TYPE_FLOAT)
    gg.getResults(100)

    gg.alert('Move steering angle to 30')
    gg.sleep(5000)
    gg.searchNumber('30', gg.TYPE_FLOAT)
    local results = gg.getResults(100)

    if #results > 0 then
        gg.editAll(tostring(value), gg.TYPE_FLOAT)
        gg.toast('✅ Steering angle adjusted!')
    else
        gg.alert('❌ Steering values not found! Try again.')
    end

    gg.sleep(5000)
    gg.clearResults()
    gg.toast('Click GG to return to suspension menu')
    waitForGG(suspensionMenu)
end
```

### 23. Wait for GG Pattern

```lua
-- Version with callback
function waitForGG(callback)
    while not gg.isVisible() do
        gg.sleep(100)
    end
    gg.setVisible(false)  -- Hide GG UI
    if callback then
        callback()  -- Return to the correct menu
    end
end

-- Simpler version
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

### 24. Info/About Alert Pattern

```lua
gg.alert([[
₴₵Ɽł₱₮ ฿Ɏ _₵₱₥₂₳Ɽ₳₂Ɇ    
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⣀⣀⣀⣀⣀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⢀⠀⣀⣠⣴⣾⡿⠟⢛⡿⠟⠛⠿⣯⡛⠉⠉⠛⠒⠀⠀
⠀⠀⠀⣀⡤⠼⢛⣿⢿⣿⠟⠃⠀⠀⢸⡇⠀⠀⠀⠀⠻⡄⠀⠀⠀⠀⠀
⠀⣠⣾⣭⣶⣶⣿⢱⠟⠁⠀⠀⠀⠀⠈⠻⠿⠛⠉⠉⠳⣽⠀⠀⠀⠀⠀
⠞⠉⠀⠀⢠⡟⠃⠈⠀⠀⠀⠀⢀⣤⣶⣿⠇⠀⠀⠀⠀⡈⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⣽⣷⣦⣠⣀⣤⠴⠿⠿⠟⠋⠀⠀⠀⠀⣼⡏⠙⢿⣿⠶⠄
⠀⠀⠀⠀⠀⢈⡿⠏⢹⢹⠀⠀⠀⠀⠀⠀⠀⠀⣀⣾⠏⠀⣰⡿⠁⠀⠀
⠀⠀⠀⠀⠀⣾⠁⢀⡾⠀⣷⠀⠀⣀⡴⣶⠞⠛⣿⡀⠀⣰⡏⠁⠀⠀⠀
⠀⠀⠀⠀⠀⢾⠀⠀⠀⠀⠀⣠⣞⠙⢁⣿⠀⠐⢿⡆⢠⣿⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠈⢷⣴⡶⠶⢿⡅⠉⠀⢀⡿⠀⠐⢾⡇⢰⣟⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠙⠀⠀⠀⠁⠀⡄⢠⡇⢠⣤⣾⠃⠘⣷⠀⠀⠀⠀⠀
⠀     ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⣿⣿⠛⠛⠛⠀⠀⢹⣦⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⠶⠶⠶⠟⠛⠉⠀⠀⠀⠀
]])

print("Script by: Ethan (github.com/ethanlabs101)")
print("Version: 4.9.4")
```

### 25. Exit Pattern

```lua
-- With restore state
function Exit()
    gg.alert("Thank you for using my script!")
    gg.skipRestoreState()
    os.exit()
end

-- Simple exit
gg.toast("Have a great day!")
gg.sleep(2000)
os.exit()
```

### 26. GameGuardian Specific Functions Reference

| Function | Description |
|---|---|
| `gg.searchNumber(value, type [, flag, sign, min, max, index])` | Search memory for value |
| `gg.editAll(value, type)` | Modify ALL found values |
| `gg.clearResults()` | Reset search state |
| `gg.getResults(n)` | Get first n results (returns table) |
| `gg.getResultCount()` | Get count of current results |
| `gg.alert(message)` | Show information dialog |
| `gg.toast(message)` | Show temporary notification |
| `gg.prompt(fields)` | Get user input |
| `gg.choice(list, [default], [prompt])` | Show selection menu |
| `gg.multiChoice(list)` | Show multi-select menu |
| `gg.getFile()` | Get current script filename |
| `gg.sleep(milliseconds)` | Pause execution |
| `gg.setRanges(type)` | Set memory search region |
| `gg.getTargetInfo()` | Get game target info (version, label, etc.) |
| `gg.getTargetPackage()` | Get target package name |
| `gg.processResume()` | Resume game process |
| `gg.processKill()` | Kill game process |
| `gg.isVisible(bool)` | Check if GG is visible |
| `gg.setVisible(bool)` | Show/hide GG UI |
| `gg.gotoAddress(address)` | Jump to memory address |
| `gg.setValues(table)` | Set values at addresses |
| `gg.getValues(table)` | Get values at addresses |
| `gg.addListItems(results)` | Add results to list |
| `gg.removeListItems(items)` | Remove from list |
| `gg.clearList()` | Clear list |
| `gg.loadList(path, flags)` | Load list from file |
| `gg.saveList()` | Save list to file |
| `gg.skipRestoreState()` | Skip state restoration on exit |
| `gg.refineNumber(value, type [, flag])` | Refine search results |

### 27. Key Lua Patterns Summary for GameGuardian Scripting

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
21. **Use gg.setVisible(false)** to hide GG during user interaction steps
22. **Store original values** in variables for toggle restoration
23. **Search-Edit-Clear cycle** is the core pattern for all mods
24. **Large value offsets** (like -2949xxxxx for coins) are game-specific constants
25. **Extensible menu structure** allows adding new mods without breaking existing ones

These patterns form the foundation of most GameGuardian Lua scripts and can be combined/modified to create scripts for various games and modifications.
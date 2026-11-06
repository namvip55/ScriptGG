-- ============================================================================
-- GameGuardian Lua Script for Mindustry
-- Target Game ID: mindustry
-- Based on Source Analysis of Mindustry (Vars.java, Rules.java, Gamemode.java)
-- Target Version: Arc Engine / Java Runtime
-- ============================================================================

local SCRIPT_NAME = "Mindustry Rules & Gameplay Helper"
local VERSION = "1.0.0"
local GAME_ID = "mindustry"

-- State tracking
local isTargetChecked = false

-- Utility: Toast notification
local function notify(msg)
    gg.toast("[" .. SCRIPT_NAME .. "] " .. msg)
end

-- Utility: Alert dialog
local function alert(msg)
    gg.alert("[" .. SCRIPT_NAME .. "]\n\n" .. msg)
end

-- Target Process Verification
local function verifyTarget()
    local target = gg.getTargetInfo()
    if not target then
        alert("Warning: Could not fetch target process info.\nMake sure Mindustry process is selected in GameGuardian.")
        return false
    end
    isTargetChecked = true
    notify("Target process: " .. (target.label or target.packageName or "Unknown"))
    return true
end

-- Preset 1: Gamemode Rule Configurations (Theoretical / Runtime Scanning Template)
local function applyGamemodePreset(modeName)
    if not isTargetChecked then
        if not verifyTarget() then return end
    end

    alert("Gamemode Preset: " .. modeName .. "\n\n"
        .. "NOTE: Rules flags (infiniteResources, waveTimer, waves, etc.) "
        .. "require runtime address verification (TODO_RUNTIME_CONFIRMATION).\n"
        .. "Use the 'Runtime Validation Helper' menu to find Rules memory addresses.")
end

-- Rules Configuration Menu
local function menuRulesConfig()
    local choices = {
        "1. Infinite Resources Mode (Sandbox Rule)",
        "2. Wave Control (Timer & Spawning)",
        "3. Instant Build & Editor Mode",
        "4. PvP / Attack Mode Toggle",
        "5. Back to Main Menu"
    }

    local sel = gg.choice(choices, nil, SCRIPT_NAME .. " - Rules Configuration")
    if not sel then return end

    if sel == 1 then
        applyGamemodePreset("Sandbox (Infinite Resources)")
    elseif sel == 2 then
        applyGamemodePreset("Wave Control")
    elseif sel == 3 then
        applyGamemodePreset("Instant Build & Editor")
    elseif sel == 4 then
        applyGamemodePreset("PvP / Attack Mode")
    end
end

-- Multiplier Values Editor (Float Values)
local function menuMultipliers()
    local prompts = {
        "Build Speed Multiplier (Default: 1.0)",
        "Unit Build Speed Multiplier (Default: 1.0)",
        "Solar Energy Multiplier (Default: 1.0)"
    }
    local defaults = { "1.0", "1.0", "1.0" }
    local types = { "number", "number", "number" }

    local input = gg.prompt(prompts, defaults, types)
    if not input then
        notify("Multiplier update canceled.")
        return
    end

    local buildSpeed = tonumber(input[1]) or 1.0
    local unitBuildSpeed = tonumber(input[2]) or 1.0
    local solarMult = tonumber(input[3]) or 1.0

    alert("Multiplier Configuration Set:\n"
        .. "- Build Speed Multiplier: " .. buildSpeed .. "\n"
        .. "- Unit Build Speed Multiplier: " .. unitBuildSpeed .. "\n"
        .. "- Solar Multiplier: " .. solarMult .. "\n\n"
        .. "Status: SOURCE_CONFIRMED logic.\n"
        .. "Requires RUNTIME_CONFIRMED memory scan to apply values to Java Rules object.")
end

-- Runtime Memory Scan Helper (Guided GameGuardian search for Rules fields)
local function menuRuntimeValidationHelper()
    local choices = {
        "1. Scan Float Multipliers (Build / Solar Speed)",
        "2. Scan Integer Wave Counter / Timer",
        "3. Clear Search Results",
        "4. Help & Instructions for Runtime Validation",
        "5. Back"
    }

    local sel = gg.choice(choices, nil, SCRIPT_NAME .. " - Runtime Validation Helper")
    if not sel then return end

    if sel == 1 then
        local promptRes = gg.prompt({ "Enter current Build Speed Multiplier float value (e.g. 1.0):" }, { "1.0" }, { "number" })
        if not promptRes then return end
        local val = tonumber(promptRes[1])
        if not val then
            notify("Invalid input value.")
            return
        end
        gg.clearResults()
        gg.setRanges(gg.REGION_ANONYMOUS | gg.REGION_JAVA_HEAP | gg.REGION_C_HEAP)
        gg.searchNumber(tostring(val), gg.TYPE_FLOAT)
        local count = gg.getResultCount()
        notify("Found " .. count .. " results for float value " .. val)
    elseif sel == 2 then
        local promptRes = gg.prompt({ "Enter current Wave Number (e.g. 1):" }, { "1" }, { "number" })
        if not promptRes then return end
        local val = tonumber(promptRes[1])
        if not val then
            notify("Invalid input value.")
            return
        end
        gg.clearResults()
        gg.setRanges(gg.REGION_ANONYMOUS | gg.REGION_JAVA_HEAP | gg.REGION_C_HEAP)
        gg.searchNumber(tostring(val), gg.TYPE_AUTO)
        local count = gg.getResultCount()
        notify("Found " .. count .. " results for wave number " .. val)
    elseif sel == 3 then
        gg.clearResults()
        notify("Results cleared.")
    elseif sel == 4 then
        alert("Runtime Validation Instructions:\n\n"
            .. "1. Mindustry is written in Java (Arc Framework).\n"
            .. "2. Rules fields exist inside the active 'Rules' object in Java Heap.\n"
            .. "3. To locate the Rules object:\n"
            .. "   - Change a multiplier or wave number in game settings.\n"
            .. "   - Search for the changed float/int value in GameGuardian (JAVA_HEAP / ANONYMOUS).\n"
            .. "   - Modify the value in-game and filter results in GG.\n"
            .. "   - Note the confirmed memory address/offset for runtime integration.")
    end
end

-- Main Menu
local function mainMenu()
    while true do
        local options = {
            "1. Gamemode & Rules Configuration",
            "2. Gameplay Multipliers (Build Speed, Solar, Units)",
            "3. Runtime Validation Helper (Memory Scan)",
            "4. Script Info & Evidence Status",
            "5. Exit"
        }

        local sel = gg.choice(options, nil, SCRIPT_NAME .. " v" .. VERSION .. " (" .. GAME_ID .. ")")

        if not sel or sel == 5 then
            notify("Script closed.")
            break
        elseif sel == 1 then
            menuRulesConfig()
        elseif sel == 2 then
            menuMultipliers()
        elseif sel == 3 then
            menuRuntimeValidationHelper()
        elseif sel == 4 then
            alert("Script Information & Evidence Status:\n\n"
                .. "Game: Mindustry (" .. GAME_ID .. ")\n"
                .. "Source Evidence: SOURCE_CONFIRMED (Vars.java, Rules.java, Gamemode.java)\n"
                .. "Runtime Evidence: TODO_RUNTIME_CONFIRMATION (Memory offsets require runtime scan)\n\n"
                .. "Source mapped fields:\n"
                .. "- infiniteResources (boolean)\n"
                .. "- waveTimer (boolean)\n"
                .. "- waves (boolean)\n"
                .. "- instantBuild (boolean)\n"
                .. "- buildSpeedMultiplier (float)\n"
                .. "- unitBuildSpeedMultiplier (float)\n"
                .. "- solarMultiplier (float)")
        end
    end
end

-- Script Entry Point
verifyTarget()
mainMenu()

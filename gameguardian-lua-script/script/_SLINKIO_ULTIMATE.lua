--[[ GameGuardian Lua Script
Author: Ethan (github.com/ethanlabs101 or on Instagram @_cpmgarage)
Purpose: Slinkio Snake Game Scripting
Note: This script represents GameGuardian scripting skills for snake games.
Disclaimer: Please use responsibly and at your own risk!
Enjoy! Much Love <3.
]]
local username = "SNAKEPRO" -- Manually input name (7 characters)

function getDate()
    return os.date("%m/%d/%Y") -- Gets today's date (MM/DD/YYYY)
end

function getTime()
    return os.date("%H:%M:%S") -- Gets real-time clock (HH:MM:SS)
end

function waitForGG(returnTo)
    while true do
        if gg.isVisible(true) then
            gg.setVisible(false)
            if returnTo then
                returnTo() -- Return to the correct menu
            else
                mainMenu() -- Default to Main Menu if nothing is passed
            end
            return -- Prevent infinite loop
        end
        gg.sleep(1000)
    end
end

-- Get Game Version
function getGameVersion()
    local package = gg.getTargetPackage() -- Gets the package name of the target game
    local version = gg.getTargetInfo().versionName -- Gets the version name
    return version or "Unknown Version"
end

-- Get Game Name
local gameInfo = gg.getTargetInfo() or {}
local gameName = gameInfo.label

local scriptVersion = "1.0.0" -- Change this when updating
local expectedScriptVersion = "1.0.0" -- Define expected script version

-- Define the expected game versions
local expectedGameVersions = { "1.0.0", "1.0.1", "1.0.2" } -- Add multiple versions

-- Function to check for outdated script or game version
local function checkVersions()
    local gameVersion = getGameVersion()  -- Fetch current game version

    -- Check if the current game version is in the expected versions list
    local versionMatch = false
    for _, v in ipairs(expectedGameVersions) do
        if gameVersion == v then
            versionMatch = true
            break
        end
    end

    if not versionMatch then
        gg.alert("The game version is outdated or unsupported. Please update the game.")
        print("DOWNLOAD NEW UPDATE")
        os.exit()  -- Exit if the game version is outdated
    end

    -- Compare script version with expected version
    if scriptVersion ~= expectedScriptVersion then
        gg.alert("This script is outdated. Please Contact Owner For Renewal.")
        os.exit()  -- Exit if the script version is outdated
    end

    return true  -- Both are up-to-date
end

-- Continue with the rest of the script if versions are correct
if not checkVersions() then
    return  -- Stop the script if versions don't match
end

-- Main menu
function mainMenu()
    local menu = gg.choice({
        "⬆️ Upgrade Speed",
        "⬇️ Down Speed",
        "🍎 Eat Food",
        "❌ Exit",
    }, nil, "Slinkio Snake Menu")

    if menu == nil then
        gg.toast("🕐 Waiting...")
        waitForGG()
    elseif menu == 1 then
        speedMenu()
    elseif menu == 2 then
        downSpeedMenu()
    elseif menu == 3 then
        eatFoodMenu()
    elseif menu == 4 then
        gg.toast("🔚 Exiting...")
        gg.sleep(2000)
        os.exit()
    end
end

-- Speed Menu
function speedMenu()
    gg.alert("💰 Speed Menu")
    while true do
        local choice = gg.choice({
            "🚀 Fast Speed",
            "⚡️ Normal Speed",
            "🐢 Slow Speed",
            "❌ Back",
        }, nil, "⚡️ Speed Options")

        if choice == nil or choice == 4 then
            gg.toast("Returning to main menu")
            waitForGG()
        elseif choice == 1 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("1000", gg.TYPE_FLOAT)
            gg.getResults(100)
            gg.editAll("2000", gg.TYPE_FLOAT)
            gg.toast("✅ Fast Speed Enabled!")
            gg.sleep(3000)
        elseif choice == 2 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("1000", gg.TYPE_FLOAT)
            gg.getResults(100)
            gg.editAll("1000", gg.TYPE_FLOAT)
            gg.toast("✅ Normal Speed Enabled!")
            gg.sleep(3000)
        elseif choice == 3 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("1000", gg.TYPE_FLOAT)
            gg.getResults(100)
            gg.editAll("500", gg.TYPE_FLOAT)
            gg.toast("✅ Slow Speed Enabled!")
            gg.sleep(3000)
        elseif choice == 4 then
            gg.toast("🔙 Back to main menu")
            waitForGG(mainMenu)
        end
    end
end

-- Down Speed Menu
function downSpeedMenu()
    gg.alert("⚠️ Down Speed Menu")
    while true do
        local choice = gg.choice({
            "🐢 Slow Down",
            "🚀 Fast Up",
            "❌ Back",
        }, nil, "⚠️ Down Speed Options")

        if choice == nil or choice == 3 then
            gg.toast("Returning to main menu")
            waitForGG(mainMenu)
        elseif choice == 1 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("1000", gg.TYPE_FLOAT)
            gg.getResults(100)
            gg.editAll("500", gg.TYPE_FLOAT)
            gg.toast("✅ Slow Speed Enabled!")
            gg.sleep(3000)
        elseif choice == 2 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("1000", gg.TYPE_FLOAT)
            gg.getResults(100)
            gg.editAll("1500", gg.TYPE_FLOAT)
            gg.toast("✅ Fast Up Speed Enabled!")
            gg.sleep(3000)
        elseif choice == 3 then
            gg.toast("🔙 Back to main menu")
            waitForGG(mainMenu)
        end
    end
end

-- Eat Food Menu
function eatFoodMenu()
    gg.alert("🍎 Eat Food Menu")
    while true do
        local choice = gg.choice({
            "🍎 Eat Food",
            "🐍 Eat Snake",
            "❌ Back",
        }, nil, "🍎 Food Options")

        if choice == nil or choice == 3 then
            gg.toast("Returning to main menu")
            waitForGG(mainMenu)
        elseif choice == 1 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("100", gg.TYPE_DWORD)
            gg.getResults(100)
            gg.editAll("500", gg.TYPE_DWORD)
            gg.toast("✅ Food Eaten!")
            gg.sleep(2000)
        elseif choice == 2 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("500", gg.TYPE_DWORD)
            gg.getResults(100)
            gg.editAll("1000", gg.TYPE_DWORD)
            gg.toast("✅ Snake Eaten!")
            gg.sleep(3000)
        elseif choice == 3 then
            gg.toast("Returning to main menu")
            waitForGG(mainMenu)
        end
    end
end

-- Main Menu
function mainMenu()
    local menu = gg.choice({
        "⬆️ Upgrade Speed",
        "⬇️ Down Speed",
        "🍎 Eat Food",
        "❌ Exit",
    }, nil, "Slinkio Snake Menu")

    if menu == nil then
        gg.toast("🕐 Waiting...")
        waitForGG()
    elseif menu == 1 then
        speedMenu()
    elseif menu == 2 then
        downSpeedMenu()
    elseif menu == 3 then
        eatFoodMenu()
    elseif menu == 4 then
        gg.toast("🔚 Exiting...")
        gg.sleep(2000)
        os.exit()
    end
end

-- Speed Menu
function speedMenu()
    gg.alert("💰 Speed Menu")
    while true do
        local choice = gg.choice({
            "🚀 Fast Speed",
            "⚡️ Normal Speed",
            "🐢 Slow Speed",
            "❌ Back",
        }, nil, "💰 Speed Options")

        if choice == nil then
            gg.toast("Returning to main menu")
            waitForGG()
        elseif choice == 1 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("1000", gg.TYPE_FLOAT)
            gg.getResults(100)
            gg.editAll("2000", gg.TYPE_FLOAT)
            gg.toast("✅ Fast Speed Enabled!")
            gg.sleep(3000)
        elseif choice == 2 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("1000", gg.TYPE_FLOAT)
            gg.getResults(100)
            gg.editAll("1000", gg.TYPE_FLOAT)
            gg.toast("✅ Normal Speed Enabled!")
            gg.sleep(3000)
        elseif choice == 3 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("1000", gg.TYPE_FLOAT)
            gg.getResults(100)
            gg.editAll("500", gg.TYPE_FLOAT)
            gg.toast("✅ Slow Speed Enabled!")
            gg.sleep(3000)
        elseif choice == 4 then
            gg.toast("Returning to main menu")
            waitForGG(mainMenu)
        end
    end
end

-- Down Speed Menu
function downSpeedMenu()
    gg.alert("⚠️ Down Speed Menu")
    while true do
        local choice = gg.choice({
            "🐢 Slow Down",
            "🚀 Fast Up",
            "❌ Back",
        }, nil, "⚠️ Down Speed Options")

        if choice == nil or choice == 3 then
            gg.toast("Returning to main menu")
            waitForGG(mainMenu)
        elseif choice == 1 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("1000", gg.TYPE_FLOAT)
            gg.getResults(100)
            gg.editAll("500", gg.TYPE_FLOAT)
            gg.toast("✅ Slow Speed Enabled!")
            gg.sleep(3000)
        elseif choice == 2 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("1000", gg.TYPE_FLOAT)
            gg.getResults(100)
            gg.editAll("1500", gg.TYPE_FLOAT)
            gg.toast("✅ Fast Up Speed Enabled!")
            gg.sleep(3000)
        elseif choice == 3 then
            gg.toast("Returning to main menu")
            waitForGG(mainMenu)
        end
    end
end

-- Eat Food Menu
function eatFoodMenu()
    gg.alert("🍎 Eat Food Menu")
    while true do
        local choice = gg.choice({
            "🍎 Eat Food",
            "🐍 Eat Snake",
            "❌ Back",
        }, nil, "🍎 Food Options")

        if choice == nil or choice == 3 then
            gg.toast("Returning to main menu")
            waitForGG(mainMenu)
        elseif choice == 1 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("100", gg.TYPE_DWORD)
            gg.getResults(100)
            gg.editAll("500", gg.TYPE_DWORD)
            gg.toast("✅ Food Eaten!")
            gg.sleep(2000)
        elseif choice == 2 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("500", gg.TYPE_DWORD)
            gg.getResults(100)
            gg.editAll("1000", gg.TYPE_DWORD)
            gg.toast("✅ Snake Eaten!")
            gg.sleep(3000)
        elseif choice == 3 then
            gg.toast("Returning to main menu")
            waitForGG(mainMenu)
        end
    end
end

-- Main Menu
function mainMenu()
    local menu = gg.choice({
        "⬆️ Upgrade Speed",
        "⬇️ Down Speed",
        "🍎 Eat Food",
        "❌ Exit",
    }, nil, "Slinkio Snake Menu")

    if menu == nil then
        gg.toast("🕐 Waiting...")
        waitForGG()
    elseif menu == 1 then
        speedMenu()
    elseif menu == 2 then
        downSpeedMenu()
    elseif menu == 3 then
        eatFoodMenu()
    elseif menu == 4 then
        gg.toast("🔚 Exiting...")
        gg.sleep(2000)
        os.exit()
    end
end

-- Speed Menu
function speedMenu()
    gg.alert("💰 Speed Menu")
    while true do
        local choice = gg.choice({
            "🚀 Fast Speed",
            "⚡️ Normal Speed",
            "🐢 Slow Speed",
            "❌ Back",
        }, nil, "💰 Speed Options")

        if choice == nil then
            gg.toast("Returning to main menu")
            waitForGG()
        elseif choice == 1 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("1000", gg.TYPE_FLOAT)
            gg.getResults(100)
            gg.editAll("2000", gg.TYPE_FLOAT)
            gg.toast("✅ Fast Speed Enabled!")
            gg.sleep(3000)
        elseif choice == 2 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("1000", gg.TYPE_FLOAT)
            gg.getResults(100)
            gg.editAll("1000", gg.TYPE_FLOAT)
            gg.toast("✅ Normal Speed Enabled!")
            gg.sleep(3000)
        elseif choice == 3 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("1000", gg.TYPE_FLOAT)
            gg.getResults(100)
            gg.editAll("500", gg.TYPE_FLOAT)
            gg.toast("✅ Slow Speed Enabled!")
            gg.sleep(3000)
        elseif choice == 4 then
            gg.toast("Returning to main menu")
            waitForGG(mainMenu)
        end
    end
end

-- Down Speed Menu
function downSpeedMenu()
    gg.alert("⚠️ Down Speed Menu")
    while true do
        local choice = gg.choice({
            "🐢 Slow Down",
            "🚀 Fast Up",
            "❌ Back",
        }, nil, "⚠️ Down Speed Options")

        if choice == nil or choice == 3 then
            gg.toast("Returning to main menu")
            waitForGG(mainMenu)
        elseif choice == 1 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("1000", gg.TYPE_FLOAT)
            gg.getResults(100)
            gg.editAll("500", gg.TYPE_FLOAT)
            gg.toast("✅ Slow Speed Enabled!")
            gg.sleep(3000)
        elseif choice == 2 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("1000", gg.TYPE_FLOAT)
            gg.getResults(100)
            gg.editAll("1500", gg.TYPE_FLOAT)
            gg.toast("✅ Fast Up Speed Enabled!")
            gg.sleep(3000)
        elseif choice == 3 then
            gg.toast("Returning to main menu")
            waitForGG(mainMenu)
        end
    end
end

-- Eat Food Menu
function eatFoodMenu()
    gg.alert("🍎 Eat Food Menu")
    while true do
        local choice = gg.choice({
            "🍎 Eat Food",
            "🐍 Eat Snake",
            "❌ Back",
        }, nil, "🍎 Food Options")

        if choice == nil or choice == 3 then
            gg.toast("Returning to main menu")
            waitForGG(mainMenu)
        elseif choice == 1 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("100", gg.TYPE_DWORD)
            gg.getResults(100)
            gg.editAll("500", gg.TYPE_DWORD)
            gg.toast("✅ Food Eaten!")
            gg.sleep(2000)
        elseif choice == 2 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("500", gg.TYPE_DWORD)
            gg.getResults(100)
            gg.editAll("1000", gg.TYPE_DWORD)
            gg.toast("✅ Snake Eaten!")
            gg.sleep(3000)
        elseif choice == 3 then
            gg.toast("Returning to main menu")
            waitForGG(mainMenu)
        end
    end
end

-- Main Menu
function mainMenu()
    local menu = gg.choice({
        "⬆️ Upgrade Speed",
        "⬇️ Down Speed",
        "🍎 Eat Food",
        "❌ Exit",
    }, nil, "Slinkio Snake Menu")

    if menu == nil then
        gg.toast("🕐 Waiting...")
        waitForGG()
    elseif menu == 1 then
        speedMenu()
    elseif menu == 2 then
        downSpeedMenu()
    elseif menu == 3 then
        eatFoodMenu()
    elseif menu == 4 then
        gg.toast("🔚 Exiting...")
        gg.sleep(2000)
        os.exit()
    end
end

-- Speed Menu
function speedMenu()
    gg.alert("💰 Speed Menu")
    while true do
        local choice = gg.choice({
            "🚀 Fast Speed",
            "⚡️ Normal Speed",
            "🐢 Slow Speed",
            "❌ Back",
        }, nil, "💰 Speed Options")

        if choice == nil then
            gg.toast("Returning to main menu")
            waitForGG()
        elseif choice == 1 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("1000", gg.TYPE_FLOAT)
            gg.getResults(100)
            gg.editAll("2000", gg.TYPE_FLOAT)
            gg.toast("✅ Fast Speed Enabled!")
            gg.sleep(3000)
        elseif choice == 2 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("1000", gg.TYPE_FLOAT)
            gg.getResults(100)
            gg.editAll("1000", gg.TYPE_FLOAT)
            gg.toast("✅ Normal Speed Enabled!")
            gg.sleep(3000)
        elseif choice == 3 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("1000", gg.TYPE_FLOAT)
            gg.getResults(100)
            gg.editAll("500", gg.TYPE_FLOAT)
            gg.toast("✅ Slow Speed Enabled!")
            gg.sleep(3000)
        elseif choice == 4 then
            gg.toast("Returning to main menu")
            waitForGG(mainMenu)
        end
    end
end

-- Down Speed Menu
function downSpeedMenu()
    gg.alert("⚠️ Down Speed Menu")
    while true do
        local choice = gg.choice({
            "🐢 Slow Down",
            "🚀 Fast Up",
            "❌ Back",
        }, nil, "⚠️ Down Speed Options")

        if choice == nil or choice == 3 then
            gg.toast("Returning to main menu")
            waitForGG(mainMenu)
        elseif choice == 1 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("1000", gg.TYPE_FLOAT)
            gg.getResults(100)
            gg.editAll("500", gg.TYPE_FLOAT)
            gg.toast("✅ Slow Speed Enabled!")
            gg.sleep(3000)
        elseif choice == 2 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("1000", gg.TYPE_FLOAT)
            gg.getResults(100)
            gg.editAll("1500", gg.TYPE_FLOAT)
            gg.toast("✅ Fast Up Speed Enabled!")
            gg.sleep(3000)
        elseif choice == 3 then
            gg.toast("Returning to main menu")
            waitForGG(mainMenu)
        end
    end
end

-- Eat Food Menu
function eatFoodMenu()
    gg.alert("🍎 Eat Food Menu")
    while true do
        local choice = gg.choice({
            "🍎 Eat Food",
            "🐍 Eat Snake",
            "❌ Back",
        }, nil, "🍎 Food Options")

        if choice == nil or choice == 3 then
            gg.toast("Returning to main menu")
            waitForGG(mainMenu)
        elseif choice == 1 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("100", gg.TYPE_DWORD)
            gg.getResults(100)
            gg.editAll("500", gg.TYPE_DWORD)
            gg.toast("✅ Food Eaten!")
            gg.sleep(2000)
        elseif choice == 2 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("500", gg.TYPE_DWORD)
            gg.getResults(100)
            gg.editAll("1000", gg.TYPE_DWORD)
            gg.toast("✅ Snake Eaten!")
            gg.sleep(3000)
        elseif choice == 3 then
            gg.toast("Returning to main menu")
            waitForGG(mainMenu)
        end
    end
end

-- Main Menu
function mainMenu()
    local menu = gg.choice({
        "⬆️ Upgrade Speed",
        "⬇️ Down Speed",
        "🍎 Eat Food",
        "❌ Exit",
    }, nil, "Slinkio Snake Menu")

    if menu == nil then
        gg.toast("🕐 Waiting...")
        waitForGG()
    elseif menu == 1 then
        speedMenu()
    elseif menu == 2 then
        downSpeedMenu()
    elseif menu == 3 then
        eatFoodMenu()
    elseif menu == 4 then
        gg.toast("🔚 Exiting...")
        gg.sleep(2000)
        os.exit()
    end
end

-- Speed Menu
function speedMenu()
    gg.alert("💰 Speed Menu")
    while true do
        local choice = gg.choice({
            "🚀 Fast Speed",
            "⚡️ Normal Speed",
            "🐢 Slow Speed",
            "❌ Back",
        }, nil, "💰 Speed Options")

        if choice == nil then
            gg.toast("Returning to main menu")
            waitForGG()
        elseif choice == 1 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("1000", gg.TYPE_FLOAT)
            gg.getResults(100)
            gg.editAll("2000", gg.TYPE_FLOAT)
            gg.toast("✅ Fast Speed Enabled!")
            gg.sleep(3000)
        elseif choice == 2 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("1000", gg.TYPE_FLOAT)
            gg.getResults(100)
            gg.editAll("1000", gg.TYPE_FLOAT)
            gg.toast("✅ Normal Speed Enabled!")
            gg.sleep(3000)
        elseif choice == 3 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("1000", gg.TYPE_FLOAT)
            gg.getResults(100)
            gg.editAll("500", gg.TYPE_FLOAT)
            gg.toast("✅ Slow Speed Enabled!")
            gg.sleep(3000)
        elseif choice == 4 then
            gg.toast("Returning to main menu")
            waitForGG(mainMenu)
        end
    end
end

-- Down Speed Menu
function downSpeedMenu()
    gg.alert("⚠️ Down Speed Menu")
    while true do
        local choice = gg.choice({
            "🐢 Slow Down",
            "🚀 Fast Up",
            "❌ Back",
        }, nil, "⚠️ Down Speed Options")

        if choice == nil or choice == 3 then
            gg.toast("Returning to main menu")
            waitForGG(mainMenu)
        elseif choice == 1 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("1000", gg.TYPE_FLOAT)
            gg.getResults(100)
            gg.editAll("500", gg.TYPE_FLOAT)
            gg.toast("✅ Slow Speed Enabled!")
            gg.sleep(3000)
        elseif choice == 2 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("1000", gg.TYPE_FLOAT)
            gg.getResults(100)
            gg.editAll("1500", gg.TYPE_FLOAT)
            gg.toast("✅ Fast Up Speed Enabled!")
            gg.sleep(3000)
        elseif choice == 3 then
            gg.toast("Returning to main menu")
            waitForGG(mainMenu)
        end
    end
end

-- Eat Food Menu
function eatFoodMenu()
    gg.alert("🍎 Eat Food Menu")
    while true do
        local choice = gg.choice({
            "🍎 Eat Food",
            "🐍 Eat Snake",
            "❌ Back",
        }, nil, "🍎 Food Options")

        if choice == nil or choice == 3 then
            gg.toast("Returning to main menu")
            waitForGG(mainMenu)
        elseif choice == 1 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("100", gg.TYPE_DWORD)
            gg.getResults(100)
            gg.editAll("500", gg.TYPE_DWORD)
            gg.toast("✅ Food Eaten!")
            gg.sleep(2000)
        elseif choice == 2 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("500", gg.TYPE_DWORD)
            gg.getResults(100)
            gg.editAll("1000", gg.TYPE_DWORD)
            gg.toast("✅ Snake Eaten!")
            gg.sleep(3000)
        elseif choice == 3 then
            gg.toast("Returning to main menu")
            waitForGG(mainMenu)
        end
    end
end

-- Main Menu
function mainMenu()
    local menu = gg.choice({
        "⬆️ Upgrade Speed",
        "⬇️ Down Speed",
        "🍎 Eat Food",
        "❌ Exit",
    }, nil, "Slinkio Snake Menu")

    if menu == nil then
        gg.toast("🕐 Waiting...")
        waitForGG()
    elseif menu == 1 then
        speedMenu()
    elseif menu == 2 then
        downSpeedMenu()
    elseif menu == 3 then
        eatFoodMenu()
    elseif menu == 4 then
        gg.toast("🔚 Exiting...")
        gg.sleep(2000)
        os.exit()
    end
end

-- Speed Menu
function speedMenu()
    gg.alert("💰 Speed Menu")
    while true do
        local choice = gg.choice({
            "🚀 Fast Speed",
            "⚡️ Normal Speed",
            "🐢 Slow Speed",
            "❌ Back",
        }, nil, "💰 Speed Options")

        if choice == nil then
            gg.toast("Returning to main menu")
            waitForGG()
        elseif choice == 1 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("1000", gg.TYPE_FLOAT)
            gg.getResults(100)
            gg.editAll("2000", gg.TYPE_FLOAT)
            gg.toast("✅ Fast Speed Enabled!")
            gg.sleep(3000)
        elseif choice == 2 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("1000", gg.TYPE_FLOAT)
            gg.getResults(100)
            gg.editAll("1000", gg.TYPE_FLOAT)
            gg.toast("✅ Normal Speed Enabled!")
            gg.sleep(3000)
        elseif choice == 3 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("1000", gg.TYPE_FLOAT)
            gg.getResults(100)
            gg.editAll("500", gg.TYPE_FLOAT)
            gg.toast("✅ Slow Speed Enabled!")
            gg.sleep(3000)
        elseif choice == 4 then
            gg.toast("Returning to main menu")
            waitForGG(mainMenu)
        end
    end
end

-- Down Speed Menu
function downSpeedMenu()
    gg.alert("⚠️ Down Speed Menu")
    while true do
        local choice = gg.choice({
            "🐢 Slow Down",
            "🚀 Fast Up",
            "❌ Back",
        }, nil, "⚠️ Down Speed Options")

        if choice == nil or choice == 3 then
            gg.toast("Returning to main menu")
            waitForGG(mainMenu)
        elseif choice == 1 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("1000", gg.TYPE_FLOAT)
            gg.getResults(100)
            gg.editAll("500", gg.TYPE_FLOAT)
            gg.toast("✅ Slow Speed Enabled!")
            gg.sleep(3000)
        elseif choice == 2 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("1000", gg.TYPE_FLOAT)
            gg.getResults(100)
            gg.editAll("1500", gg.TYPE_FLOAT)
            gg.toast("✅ Fast Up Speed Enabled!")
            gg.sleep(3000)
        elseif choice == 3 then
            gg.toast("Returning to main menu")
            waitForGG(mainMenu)
        end
    end
end

-- Eat Food Menu
function eatFoodMenu()
    gg.alert("🍎 Eat Food Menu")
    while true do
        local choice = gg.choice({
            "🍎 Eat Food",
            "🐍 Eat Snake",
            "❌ Back",
        }, nil, "🍎 Food Options")

        if choice == nil or choice == 3 then
            gg.toast("Returning to main menu")
            waitForGG(mainMenu)
        elseif choice == 1 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("100", gg.TYPE_DWORD)
            gg.getResults(100)
            gg.editAll("500", gg.TYPE_DWORD)
            gg.toast("✅ Food Eaten!")
            gg.sleep(2000)
        elseif choice == 2 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("500", gg.TYPE_DWORD)
            gg.getResults(100)
            gg.editAll("1000", gg.TYPE_DWORD)
            gg.toast("✅ Snake Eaten!")
            gg.sleep(3000)
        elseif choice == 3 then
            gg.toast("Returning to main menu")
            waitForGG(mainMenu)
        end
    end
end

-- Main Menu
function mainMenu()
    local menu = gg.choice({
        "⬆️ Upgrade Speed",
        "⬇️ Down Speed",
        "🍎 Eat Food",
        "❌ Exit",
    }, nil, "Slinkio Snake Menu")

    if menu == nil then
        gg.toast("🕐 Waiting...")
        waitForGG()
    elseif menu == 1 then
        speedMenu()
    elseif menu == 2 then
        downSpeedMenu()
    elseif menu == 3 then
        eatFoodMenu()
    elseif menu == 4 then
        gg.toast("🔚 Exiting...")
        gg.sleep(2000)
        os.exit()
    end
end

-- Speed Menu
function speedMenu()
    gg.alert("💰 Speed Menu")
    while true do
        local choice = gg.choice({
            "🚀 Fast Speed",
            "⚡️ Normal Speed",
            "🐢 Slow Speed",
            "❌ Back",
        }, nil, "💰 Speed Options")

        if choice == nil then
            gg.toast("Returning to main menu")
            waitForGG()
        elseif choice == 1 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("1000", gg.TYPE_FLOAT)
            gg.getResults(100)
            gg.editAll("2000", gg.TYPE_FLOAT)
            gg.toast("✅ Fast Speed Enabled!")
            gg.sleep(3000)
        elseif choice == 2 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("1000", gg.TYPE_FLOAT)
            gg.getResults(100)
            gg.editAll("1000", gg.TYPE_FLOAT)
            gg.toast("✅ Normal Speed Enabled!")
            gg.sleep(3000)
        elseif choice == 3 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("1000", gg.TYPE_FLOAT)
            gg.getResults(100)
            gg.editAll("500", gg.TYPE_FLOAT)
            gg.toast("✅ Slow Speed Enabled!")
            gg.sleep(3000)
        elseif choice == 4 then
            gg.toast("Returning to main menu")
            waitForGG(mainMenu)
        end
    end
end

-- Down Speed Menu
function downSpeedMenu()
    gg.alert("⚠️ Down Speed Menu")
    while true do
        local choice = gg.choice({
            "🐢 Slow Down",
            "🚀 Fast Up",
            "❌ Back",
        }, nil, "⚠️ Down Speed Options")

        if choice == nil or choice == 3 then
            gg.toast("Returning to main menu")
            waitForGG(mainMenu)
        elseif choice == 1 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("1000", gg.TYPE_FLOAT)
            gg.getResults(100)
            gg.editAll("500", gg.TYPE_FLOAT)
            gg.toast("✅ Slow Speed Enabled!")
            gg.sleep(3000)
        elseif choice == 2 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("1000", gg.TYPE_FLOAT)
            gg.getResults(100)
            gg.editAll("1500", gg.TYPE_FLOAT)
            gg.toast("✅ Fast Up Speed Enabled!")
            gg.sleep(3000)
        elseif choice == 3 then
            gg.toast("Returning to main menu")
            waitForGG(mainMenu)
        end
    end
end

-- Eat Food Menu
function eatFoodMenu()
    gg.alert("🍎 Eat Food Menu")
    while true do
        local choice = gg.choice({
            "🍎 Eat Food",
            "🐍 Eat Snake",
            "❌ Back",
        }, nil, "🍎 Food Options")

        if choice == nil or choice == 3 then
            gg.toast("Returning to main menu")
            waitForGG(mainMenu)
        elseif choice == 1 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("100", gg.TYPE_DWORD)
            gg.getResults(100)
            gg.editAll("500", gg.TYPE_DWORD)
            gg.toast("✅ Food Eaten!")
            gg.sleep(2000)
        elseif choice == 2 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("500", gg.TYPE_DWORD)
            gg.getResults(100)
            gg.editAll("1000", gg.TYPE_DWORD)
            gg.toast("✅ Snake Eaten!")
            gg.sleep(3000)
        elseif choice == 3 then
            gg.toast("Returning to main menu")
            waitForGG(mainMenu)
        end
    end
end

-- Main Menu
function mainMenu()
    local menu = gg.choice({
        "⬆️ Upgrade Speed",
        "⬇️ Down Speed",
        "🍎 Eat Food",
        "❌ Exit",
    }, nil, "Slinkio Snake Menu")

    if menu == nil then
        gg.toast("🕐 Waiting...")
        waitForGG()
    elseif menu == 1 then
        speedMenu()
    elseif menu == 2 then
        downSpeedMenu()
    elseif menu == 3 then
        eatFoodMenu()
    elseif menu == 4 then
        gg.toast("🔚 Exiting...")
        gg.sleep(2000)
        os.exit()
    end
end

-- Speed Menu
function speedMenu()
    gg.alert("💰 Speed Menu")
    while true do
        local choice = gg.choice({
            "🚀 Fast Speed",
            "⚡️ Normal Speed",
            "🐢 Slow Speed",
            "❌ Back",
        }, nil, "💰 Speed Options")

        if choice == nil then
            gg.toast("Returning to main menu")
            waitForGG()
        elseif choice == 1 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("1000", gg.TYPE_FLOAT)
            gg.getResults(100)
            gg.editAll("2000", gg.TYPE_FLOAT)
            gg.toast("✅ Fast Speed Enabled!")
            gg.sleep(3000)
        elseif choice == 2 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("1000", gg.TYPE_FLOAT)
            gg.getResults(100)
            gg.editAll("1000", gg.TYPE_FLOAT)
            gg.toast("✅ Normal Speed Enabled!")
            gg.sleep(3000)
        elseif choice == 3 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("1000", gg.TYPE_FLOAT)
            gg.getResults(100)
            gg.editAll("500", gg.TYPE_FLOAT)
            gg.toast("✅ Slow Speed Enabled!")
            gg.sleep(3000)
        elseif choice == 4 then
            gg.toast("Returning to main menu")
            waitForGG(mainMenu)
        end
    end
end

-- Down Speed Menu
function downSpeedMenu()
    gg.alert("⚠️ Down Speed Menu")
    while true do
        local choice = gg.choice({
            "🐢 Slow Down",
            "🚀 Fast Up",
            "❌ Back",
        }, nil, "⚠️ Down Speed Options")

        if choice == nil or choice == 3 then
            gg.toast("Returning to main menu")
            waitForGG(mainMenu)
        elseif choice == 1 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("1000", gg.TYPE_FLOAT)
            gg.getResults(100)
            gg.editAll("500", gg.TYPE_FLOAT)
            gg.toast("✅ Slow Speed Enabled!")
            gg.sleep(3000)
        elseif choice == 2 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("1000", gg.TYPE_FLOAT)
            gg.getResults(100)
            gg.editAll("1500", gg.TYPE_FLOAT)
            gg.toast("✅ Fast Up Speed Enabled!")
            gg.sleep(3000)
        elseif choice == 3 then
            gg.toast("Returning to main menu")
            waitForGG(mainMenu)
        end
    end
end

-- Eat Food Menu
function eatFoodMenu()
    gg.alert("🍎 Eat Food Menu")
    while true do
        local choice = gg.choice({
            "🍎 Eat Food",
            "🐍 Eat Snake",
            "❌ Back",
        }, nil, "🍎 Food Options")

        if choice == nil or choice == 3 then
            gg.toast("Returning to main menu")
            waitForGG(mainMenu)
        elseif choice == 1 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("100", gg.TYPE_DWORD)
            gg.getResults(100)
            gg.editAll("500", gg.TYPE_DWORD)
            gg.toast("✅ Food Eaten!")
            gg.sleep(2000)
        elseif choice == 2 then
            gg.setRanges(gg.REGION_ANONYMOUS)
            gg.searchNumber("500", gg.TYPE_DWORD)
            gg.getResults(100)
            gg.editAll("1000", gg.TYPE_DWORD)
            gg.toast("✅ Snake Eaten!")
            gg.sleep(3000)
        elseif choice == 3 then
            gg.toast("Returning to main menu")
            waitForGG(mainMenu)
        end
    end
end

-- Main Menu
function mainMenu()
    local menu = gg.choice({
        "⬆️ Upgrade Speed",
        "⬇️ Down Speed",
        "🍎 Eat Food",
        "❌ Exit",
    }, nil, "Slinkio Snake Menu")

    if menu == nil then
        gg.toast("🕐 Waiting...")
        waitForGG()
    elseif menu == 1 then
        speedMenu()
    elseif menu == 2 then
        downSpeedMenu()
    elseif menu == 3 then
        eatFoodMenu()
    elseif menu == 4 then
        gg.toast("🔚 Exiting...")
        gg.sleep(2000)
        os.exit()
    end
end
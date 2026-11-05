
--========================================
-- HILL CLIMB RACING - GAMEGUARDIAN
-- Version: 1.0
-- Environment: LDPlayer 9 / Android 9
--========================================

local SCRIPT_NAME = "HCR SCRIPT"
local SCRIPT_VERSION = "1.0"

--========================================
-- CHECK TARGET GAME
--========================================

local function checkTarget()

    local info = gg.getTargetInfo()
    local package = gg.getTargetPackage()

    if not info or not package then
        gg.alert("Không thể lấy thông tin game!")
        return
    end

    local message = {
        "SCRIPT: " .. SCRIPT_NAME,
        "VERSION: " .. SCRIPT_VERSION,
        "",
        "GAME: " .. tostring(info.label),
        "PACKAGE: " .. tostring(package),
        "GAME VERSION: " .. tostring(info.versionName),
        "",
        "ANDROID: 9",
        "EMULATOR: LDPlayer 9"
    }

    gg.alert(table.concat(message, "\n"))
end

--========================================
-- ABOUT
--========================================

local function about()

    gg.alert(
        SCRIPT_NAME .. "\n" ..
        "Version: " .. SCRIPT_VERSION .. "\n\n" ..
        "Platform: GameGuardian\n" ..
        "Emulator: LDPlayer 9\n" ..
        "Status: Development"
    )

end

--========================================
-- MAIN MENU
--========================================

local function mainMenu()

    while true do

        local choice = gg.choice({
            "1. CHECK GAME INFORMATION",
            "2. SCRIPT INFORMATION",
            "3. EXIT"
        }, nil, SCRIPT_NAME)

        if choice == nil then

            gg.toast("Waiting for selection...")

        elseif choice == 1 then

            checkTarget()

        elseif choice == 2 then

            about()

        elseif choice == 3 then

            gg.toast("Script closed!")
            os.exit()

        end

    end

end

--========================================
-- START
--========================================

gg.clearResults()
gg.toast("Loading " .. SCRIPT_NAME)

mainMenu()


--========================================
-- HCR COIN SCANNER
-- Hill Climb Racing 1.73.2
--========================================

local SCRIPT_NAME = "HCR COIN SCANNER"

local function scanCoin()

    local input = gg.prompt({
        "Nhập số Coin hiện tại:"
    }, {
        "1000"
    }, {
        "number"
    })

    if not input then
        return
    end

    local coin = tonumber(input[1])

    if not coin or coin < 0 then
        gg.alert("Giá trị Coin không hợp lệ!")
        return
    end

    local results = {}

    gg.setRanges(gg.REGION_ANONYMOUS)

    -- Test DWORD
    gg.clearResults()
    gg.searchNumber(
        tostring(coin),
        gg.TYPE_DWORD
    )

    results.DWORD = gg.getResultsCount()

    gg.clearResults()

    -- Test FLOAT
    gg.searchNumber(
        tostring(coin),
        gg.TYPE_FLOAT
    )

    results.FLOAT = gg.getResultsCount()

    gg.clearResults()

    gg.alert(
        "COIN SCAN RESULT\n\n" ..
        "Current Coin: " .. coin .. "\n\n" ..
        "DWORD: " .. results.DWORD .. "\n" ..
        "FLOAT: " .. results.FLOAT .. "\n\n" ..
        "No memory values modified."
    )

end

local function mainMenu()

    while true do

        local choice = gg.choice({
            "1. SCAN COIN",
            "2. EXIT"
        }, nil, SCRIPT_NAME)

        if choice == nil then
            return

        elseif choice == 1 then
            scanCoin()

        elseif choice == 2 then
            os.exit()
        end

    end

end

gg.clearResults()
mainMenu()

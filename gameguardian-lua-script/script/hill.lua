
-- HCR COIN SCRIPT - SIMPLE VERSION

local hasScan = false
local lastCoin = nil
local savedResult = nil
local isModified = false

local function inputCoin(title)
    local input = gg.prompt({title}, {""}, {"number"})
    if input == nil then return nil end

    local value = tonumber(input[1])
    if value == nil or value < 0 or value ~= math.floor(value) then
        gg.alert("Coin khong hop le.")
        return nil
    end

    return value
end

local function scanCoin()
    if isModified then
        gg.alert("Hay Restore truoc.")
        return
    end

    local title = "Nhap Coin hien tai:"
    if hasScan then
        title = "Nhap Coin de Refine:"
    end

    local coin = inputCoin(title)
    if coin == nil then return end

    gg.setRanges(gg.REGION_ANONYMOUS)

    if hasScan == false then
        gg.clearResults()
        gg.searchNumber(tostring(coin), gg.TYPE_DWORD)
    else
        gg.refineNumber(tostring(coin), gg.TYPE_DWORD)
    end

    local count = gg.getResultsCount()

    if count == 0 then
        gg.clearResults()
        hasScan = false
        lastCoin = nil
        gg.alert("Khong tim thay ket qua.")
        return
    end

    hasScan = true
    lastCoin = coin

    gg.alert("Tim thay: " .. tostring(count) .. " ket qua.")
end

local function showResults()
    if hasScan == false then
        gg.alert("Chua Scan.")
        return
    end

    gg.alert(
        "Coin: " .. tostring(lastCoin) ..
        "\nKet qua: " .. tostring(gg.getResultsCount())
    )
end

local function modifyCoin()
    if hasScan == false or isModified then
        gg.alert("Khong the Modify luc nay.")
        return
    end

    if gg.getResultsCount() ~= 1 then
        gg.alert("Can dung 1 ket qua.")
        return
    end

    local results = gg.getResults(1)
    if results == nil or results[1] == nil then
        gg.alert("Khong doc duoc ket qua.")
        return
    end

    local result = results[1]

    if tonumber(result.value) ~= tonumber(lastCoin) then
        gg.alert("Gia tri khong khop.")
        return
    end

    local newCoin = inputCoin("Nhap Coin moi:")
    if newCoin == nil then return end

    savedResult = {
        address = result.address,
        flags = result.flags,
        value = result.value
    }

    local ok, err = pcall(function()
        gg.setValues({
            {
                address = savedResult.address,
                flags = savedResult.flags,
                value = newCoin
            }
        })
    end)

    if ok == false then
        savedResult = nil
        gg.alert("Modify loi: " .. tostring(err))
        return
    end

    isModified = true
    lastCoin = newCoin
    gg.alert("Da gui lenh Modify.")
end

local function restoreCoin()
    if isModified == false or savedResult == nil then
        gg.alert("Khong co du lieu Restore.")
        return
    end

    local ok, err = pcall(function()
        gg.setValues({
            {
                address = savedResult.address,
                flags = savedResult.flags,
                value = savedResult.value
            }
        })
    end)

    if ok == false then
        gg.alert("Restore loi: " .. tostring(err))
        return
    end

    isModified = false
    savedResult = nil
    hasScan = false
    lastCoin = nil

    gg.clearResults()
    gg.alert("Da gui lenh Restore.")
end

while true do
    local choice = gg.choice({
        "Scan / Refine Coin",
        "Xem ket qua",
        "Modify Coin",
        "Restore Coin",
        "Thoat"
    }, nil, "HCR COIN SCRIPT")

    if choice == nil then
        break
    end

    if choice == 1 then
        scanCoin()
    end

    if choice == 2 then
        showResults()
    end

    if choice == 3 then
        modifyCoin()
    end

    if choice == 4 then
        restoreCoin()
    end

    if choice == 5 then
        break
    end
end

gg.clearResults()

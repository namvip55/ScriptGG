
-- GG Value Editor
-- Version 1.0

local MAX_RESULTS = 500

-- Chuc nang tim va sua gia tri
function changeValue()

    local selected = gg.choice({
        "DWORD - So nguyen",
        "FLOAT - So thuc",
    }, nil, "CHON KIEU DU LIEU")

    if selected == nil then
        return
    end

    local valueType

    if selected == 1 then
        valueType = gg.TYPE_DWORD
    else
        valueType = gg.TYPE_FLOAT
    end

    -- Nhap gia tri
    local input = gg.prompt({
        "Gia tri hien tai:",
        "Gia tri muon thay doi:"
    }, {
        "100",
        "999"
    }, {
        "number",
        "number"
    })

    if input == nil then
        return
    end

    local oldValue = tostring(input[1])
    local newValue = tostring(input[2])

    if oldValue == "" or newValue == "" then
        gg.alert("Vui long nhap day du gia tri!")
        return
    end

    -- Bat dau tim kiem
    gg.clearResults()
    gg.searchNumber(oldValue, valueType)

    local count = gg.getResultsCount()

    if count == 0 then
        gg.alert("Khong tim thay gia tri!")
        return
    end

    if count > MAX_RESULTS then
        gg.alert(
            "Tim thay " .. count ..
            " ket qua.\n\nSo luong qua lon!\n" ..
            "Hay loc ket qua truoc khi sua."
        )
        return
    end

    -- Xac nhan truoc khi sua
    local confirm = gg.alert(
        "Tim thay: " .. count ..
        " ket qua.\n\n" ..
        "Gia tri cu: " .. oldValue ..
        "\nGia tri moi: " .. newValue ..
        "\n\nBan co muon thay doi?",
        "DONG Y",
        "HUY"
    )

    if confirm ~= 1 then
        return
    end

    -- Lay ket qua va chinh sua
    gg.getResults(count)

    local edited = gg.editAll(newValue, valueType)

    gg.alert(
        "HOAN THANH!\n\n" ..
        "So ket qua tim thay: " .. count ..
        "\nSo gia tri da sua: " .. tostring(edited)
    )

    gg.clearResults()
end

-- Menu chinh
function main()

    local menu = gg.choice({
        "1. Tim va thay doi gia tri",
        "2. Xem so ket qua tim kiem",
        "3. Xoa ket qua tim kiem",
        "4. Thoat"
    }, nil, "GG VALUE EDITOR v1.0")

    if menu == 1 then

        changeValue()

    elseif menu == 2 then

        local count = gg.getResultsCount()

        gg.alert("So ket qua: " .. count)

    elseif menu == 3 then

        gg.clearResults()
        gg.toast("Da xoa ket qua!")

    elseif menu == 4 then

        os.exit()

    end
end

-- Vong lap hien menu
while true do

    if gg.isVisible() then

        gg.setVisible(false)
        main()

    end

    gg.sleep(100)

end

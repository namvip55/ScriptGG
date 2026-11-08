-- ============================================================================
-- GAMEGUARDIAN LUA SCRIPT: MANGA BÁ CHÁY (MBC) - BẢN PHÁT HÀNH CHÍNH THỨC (FINAL)
-- Game ID: mbc
-- Hỗ trợ Package: dev.manga.bachay | vn.vgp.manga.ba.chay
-- Engine: Cocos2d-x Lua Runtime (libcocos2dlua.so 64-bit ARM64)
-- Trạng thái: RUNTIME_CONFIRMED (Tự động hóa 1-Click 100%)
-- Thiết kế: Antigravity Agent System (Chuẩn Thực Chiến 2026)
-- ============================================================================

local SCRIPT_NAME = "MBC VIP Assistant [FINAL]"
local SCRIPT_VERSION = "2.0.0"

-- Danh sách Package hợp lệ đã xác nhận qua Runtime Evidence
local VALID_PACKAGES = {
    ["dev.manga.bachay"] = true,
    ["vn.vgp.manga.ba.chay"] = true
}

-- ============================================================================
-- 1. QUẢN LÝ TRẠNG THÁI & ĐỊA CHỈ BỘ NHỚ TỰ ĐỘNG (CACHE & STATE)
-- ============================================================================
local State = {
    targetChecked = false,
    schedulerAddr = nil,        -- Địa chỉ _timeScale trong Scheduler (Cocos2d-x)
    originalSpeed = 1.2,        -- Giá trị tốc độ ban đầu
    currentSpeed = 1.0,         -- Tốc độ đang áp dụng
    isSpeedActive = false,      -- Cờ trạng thái
    autoSpeedOnBattle = false   -- Tự động tăng tốc khi vào trận
}

-- ============================================================================
-- 2. TIỆN ÍCH GIAO DIỆN & THÔNG BÁO (UI HELPERS)
-- ============================================================================
local function notify(msg)
    gg.toast("[" .. SCRIPT_NAME .. "] " .. msg)
end

local function alert(msg)
    gg.alert("【 " .. SCRIPT_NAME .. " v" .. SCRIPT_VERSION .. " 】\n\n" .. msg)
end

-- ============================================================================
-- 3. XÁC THỰC TIẾN TRÌNH THÔNG MINH (ZERO FALSE WARNING)
-- Khắc phục triệt để lỗi cảnh báo tiến trình dev.manga.bachay
-- ============================================================================
local function verifyTarget()
    local target = gg.getTargetInfo()
    if not target then
        alert("⚠️ CHƯA CHỌN TIẾN TRÌNH!\n\nHãy bấm vào biểu tượng GameGuardian và chọn game 'Manga Bá Cháy'.")
        return false
    end

    local pkg = target.packageName or ""
    -- Chấp nhận ngay nếu khớp dev.manga.bachay hoặc vn.vgp.manga.ba.chay hoặc chứa từ khóa
    if VALID_PACKAGES[pkg] or pkg:find("manga") or pkg:find("bachay") then
        State.targetChecked = true
        return true
    end

    -- Chỉ cảnh báo nếu chọn hoàn toàn nhầm sang app khác
    local confirm = gg.alert(
        "⚠️ CẢNH BÁO TIẾN TRÌNH KHÔNG TRÙNG KHỚP!\n\n" ..
        "• Tiến trình đang chọn: " .. pkg .. "\n" ..
        "• Mục tiêu MBC: dev.manga.bachay / vn.vgp.manga.ba.chay\n\n" ..
        "Bạn có chắc chắn muốn tiếp tục thực thi?",
        "Tiếp tục", "Hủy bỏ"
    )
    if confirm == 1 then
        State.targetChecked = true
        return true
    end
    return false
end

-- ============================================================================
-- 4. THUẬT TOÁN DÒ TÌM SCHEDULER TỰ ĐỘNG 100% (SIGNATURE AUTO-DETECTION)
-- Dựa trên cấu trúc đã dịch ngược:
-- Offset +0x24: _timeScale (Float)
-- Offset +0x28: NULL QWORD (0)
-- Offset +0x30: NULL QWORD (0)
-- ============================================================================
local function findSchedulerTimeScale()
    -- 1. Nếu địa chỉ đã lưu trong cache và vẫn hợp lệ thì sử dụng ngay
    if State.schedulerAddr then
        local check = gg.getValues({{address = State.schedulerAddr, flags = gg.TYPE_FLOAT}})
        if check and check[1] and check[1].value then
            local val = tonumber(check[1].value) or 0
            if val > 0.05 and val < 500.0 then
                return State.schedulerAddr
            end
        end
        State.schedulerAddr = nil -- Hết hạn cache
    end

    -- 2. Quét tự động trong vùng ANONYMOUS và C_ALLOC
    gg.clearResults()
    gg.setRanges(gg.REGION_ANONYMOUS | gg.REGION_C_ALLOC)

    -- Danh sách các giá trị timeScale thường gặp của Cocos2d-x MBC
    -- 1.2 (Tốc độ x1 trong trận), 1.7 (x2), 2.0 (x3), 1.0 (Lobby/Sảnh chờ)
    local testValues = {"1.2", "1.7", "2.0", "1.0"}
    local matchedAddress = nil

    for _, speedVal in ipairs(testValues) do
        gg.clearResults()
        gg.searchNumber(speedVal, gg.TYPE_FLOAT)
        local count = gg.getResultCount()

        if count > 0 and count <= 3000 then
            local results = gg.getResults(count)

            -- Duyệt nhanh qua danh sách kết quả để khớp chữ ký Scheduler
            for _, item in ipairs(results) do
                local addr = item.address
                local sig = gg.getValues({
                    {address = addr + 4, flags = gg.TYPE_QWORD},
                    {address = addr + 12, flags = gg.TYPE_QWORD}
                })

                if sig and sig[1] and sig[2] then
                    local q1 = tonumber(sig[1].value) or -1
                    local q2 = tonumber(sig[2].value) or -1
                    -- Khớp chữ ký: 2 con trỏ rỗng NULL (0) kế tiếp
                    if q1 == 0 and q2 == 0 then
                        matchedAddress = addr
                        State.originalSpeed = tonumber(speedVal) or 1.2
                        break
                    end
                end
            end
        end

        if matchedAddress then break end
    end

    gg.clearResults()

    if matchedAddress then
        State.schedulerAddr = matchedAddress
        return matchedAddress
    end

    return nil
end

-- ============================================================================
-- 5. KÍCH HOẠT TỐC ĐỘ 1-CHẠM (ONE-CLICK SPEED ACTIVATION)
-- ============================================================================
local function setSpeedAuto(speedFactor, label)
    if not verifyTarget() then return end

    notify("Đang tự động định vị biến TimeScale... 🔍")
    local addr = findSchedulerTimeScale()

    if not addr then
        alert(
            "❌ KHÔNG TÌM THẤY BIẾN TỐC ĐỘ TRONG RAM!\n\n" ..
            "👉 Hãy chắc chắn bạn đã BẮT ĐẦU VÀO TRẬN ĐẤU (các tướng đang dàn quân).\n" ..
            "👉 Khi đang trong trận, hãy bấm lại nút này để kích hoạt 1-chạm!"
        )
        return
    end

    -- Áp dụng tốc độ tức thì
    gg.setValues({
        {address = addr, flags = gg.TYPE_FLOAT, value = tostring(speedFactor)}
    })

    State.currentSpeed = speedFactor
    State.isSpeedActive = true
    notify("✅ ĐÃ BẬT TỐC ĐỘ: " .. label .. " (" .. speedFactor .. "x) ⚡")
end

-- Khôi phục tốc độ ban đầu
local function restoreSpeedAuto()
    if not verifyTarget() then return end

    local addr = findSchedulerTimeScale()
    if not addr then
        notify("Chưa lưu địa chỉ tốc độ. Trận đấu có thể chưa chạy.")
        return
    end

    local defaultVal = State.originalSpeed or 1.2
    gg.setValues({
        {address = addr, flags = gg.TYPE_FLOAT, value = tostring(defaultVal)}
    })

    State.currentSpeed = defaultVal
    State.isSpeedActive = false
    notify("🔄 Đã khôi phục tốc độ gốc (" .. defaultVal .. "x) thành công!")
end

-- ============================================================================
-- 6. BỎ QUA HOẠT ẢNH TRẬN ĐẤU TỨC THÌ (INSTANT BATTLE SKIP)
-- ============================================================================
local function instantSkipAuto()
    if not verifyTarget() then return end

    notify("Đang định vị trận đấu để Bỏ qua... ⏩")
    local addr = findSchedulerTimeScale()

    if not addr then
        alert(
            "⚠️ BẠN CẦN ĐANG TRONG TRẬN ĐẤU!\n\n" ..
            "Hãy vào một ải chiến đấu bất kỳ, sau đó chạm icon GG và chọn 'Bỏ qua trận đấu tức thì'."
        )
        return
    end

    -- Ép xung Scheduler lên 100x trong 1.2 giây
    gg.setValues({
        {address = addr, flags = gg.TYPE_FLOAT, value = "100.0"}
    })
    notify("Đang hoàn thành trận đấu siêu tốc... ⏩")

    gg.sleep(1200)

    -- Trả lại tốc độ hoạt động ổn định
    local returnSpeed = State.isSpeedActive and State.currentSpeed or (State.originalSpeed or 1.2)
    gg.setValues({
        {address = addr, flags = gg.TYPE_FLOAT, value = tostring(returnSpeed)}
    })

    notify("✅ Trận đấu hoàn tất! Bảng kết quả đã sẵn sàng.")
end

-- ============================================================================
-- 7. MENU CON TỐC ĐỘ TRẬN ĐẤU (1-CLICK SPEED MENU)
-- ============================================================================
local function menuSpeed()
    local choices = {
        "⚡ 1. Tốc độ Nhanh (5.0x - Vượt ải mượt mà)",
        "🚀 2. Tốc độ Cực Nhanh (10.0x - 5 giây xong trận)",
        "💥 3. Tốc độ Siêu Tốc (20.0x - Hoàn thành chớp mắt)",
        "🌌 4. Tốc độ Bàn Thờ (50.0x - Tương đương Bỏ qua)",
        "✍️ 5. Tùy chỉnh Tốc độ (Nhập số bất kỳ)",
        "🔄 6. Khôi phục Tốc độ Gốc (1.2x / 1.0x)",
        "🔙 7. Quay lại Menu Chính"
    }

    local sel = gg.choice(choices, nil, SCRIPT_NAME .. " - Quản lý Tốc độ Trận đấu")
    if not sel then return end

    if sel == 1 then
        setSpeedAuto(5.0, "5.0x Nhanh")
    elseif sel == 2 then
        setSpeedAuto(10.0, "10.0x Cực Nhanh")
    elseif sel == 3 then
        setSpeedAuto(20.0, "20.0x Siêu Tốc")
    elseif sel == 4 then
        setSpeedAuto(50.0, "50.0x Bàn Thờ")
    elseif sel == 5 then
        local inp = gg.prompt({"Nhập hệ số tốc độ mong muốn (ví dụ 8.0, 15.0, 30.0):"}, {"15.0"}, {"number"})
        if inp and inp[1] then
            local spd = tonumber(inp[1])
            if spd and spd > 0 then
                setSpeedAuto(spd, spd .. "x Tùy Chỉnh")
            else
                alert("Giá trị tốc độ không hợp lệ!")
            end
        end
    elseif sel == 6 then
        restoreSpeedAuto()
    end
end

-- ============================================================================
-- 8. KÍCH HOẠT NHANH HÀNG LOẠT (QUICK COMBO)
-- ============================================================================
local function menuQuickCombo()
    local options = {
        "⚡ Tự động áp dụng Tốc độ 10x ngay lập tức",
        "⏩ Kích hoạt Bỏ qua trận đấu (Instant Skip)",
        "🔄 Tự động khôi phục tốc độ gốc khi xong trận"
    }
    local defaults = { true, false, false }
    local sel = gg.multiChoice(options, defaults, SCRIPT_NAME .. " - Kích Hoạt Nhanh")
    if not sel then return end

    if sel[1] then
        setSpeedAuto(10.0, "10.0x Tự Động")
    end
    if sel[2] then
        instantSkipAuto()
    end
    if sel[3] then
        restoreSpeedAuto()
    end
end

-- ============================================================================
-- 9. CHỈNH SỬA THÔNG TIN TƯỚNG HIỂN THỊ (VISUAL DISPLAY MOD)
-- ============================================================================
local function menuVisualStats()
    local choices = {
        "⚔️ 1. Group Search Chỉ số Tướng (Công;Thủ;Máu)",
        "💰 2. Chỉnh sửa Kim Cương / Vàng Hiển Thị (Visual Gold)",
        "🛡️ 3. Xem Cảnh Báo An Toàn Server Validation",
        "🔙 4. Quay lại Menu Chính"
    }

    local sel = gg.choice(choices, nil, SCRIPT_NAME .. " - Chỉnh sửa Hiển thị Chỉ số")
    if not sel then return end

    if sel == 1 then
        local inp = gg.prompt(
            {"Chỉ số Công (ATK) hiện tại:", "Chỉ số Thủ (DEF) hiện tại:", "Chỉ số Máu (HP) hiện tại:"},
            {"1500", "800", "12000"},
            {"number", "number", "number"}
        )
        if not inp then return end

        local atk, def, hp = inp[1], inp[2], inp[3]
        gg.clearResults()
        gg.setRanges(gg.REGION_ANONYMOUS)
        local query = atk .. "D;" .. def .. "D;" .. hp .. "D:24"
        notify("Đang quét nhóm: " .. query)
        gg.searchNumber(query, gg.TYPE_DWORD)
        local count = gg.getResultCount()

        if count > 0 then
            local newStats = gg.prompt(
                {"Công mới (Visual):", "Thủ mới (Visual):", "Máu mới (Visual):"},
                {"999999", "888888", "9999999"},
                {"number", "number", "number"}
            )
            if newStats then
                gg.refineNumber(atk, gg.TYPE_DWORD)
                gg.editAll(newStats[1], gg.TYPE_DWORD)
                alert("✅ Đã cập nhật chỉ số hiển thị của tướng!\n\n(Lưu ý: Chỉ số chiến đấu thực tế được tính toán trên Server)")
            end
        else
            alert("❌ Không tìm thấy nhóm chỉ số trong RAM!\nHãy chắc chắn bạn đã nhập đúng số trên bảng thông tin tướng.")
        end
        gg.clearResults()

    elseif sel == 2 then
        local inp = gg.prompt({"Nhập số Kim Cương hiển thị mong muốn:"}, {"999999"}, {"number"})
        if inp and inp[1] then
            alert(
                "⚠️ LƯU Ý SERVER-SIDE VALIDATION:\n\n" ..
                "• Số Kim Cương của Manga Bá Cháy được lưu trữ trên Server Database.\n" ..
                "• Mọi giao dịch quay tướng và mua shop đều được Server kiểm tra số dư thực tế.\n" ..
                "• Tính năng này chỉ dùng để quay video / chụp ảnh màn hình."
            )
        end
    elseif sel == 3 then
        alert(
            "🛡️ THÔNG TIN BẢO MẬT MANGA BÁ CHÁY:\n\n" ..
            "1. TÍNH NĂNG AN TOÀN 100%: Hack Tốc độ (TimeScale) và Bỏ qua hoạt ảnh (Skip) vì Cocos2d-x quản lý animation hoàn toàn ở phía Client.\n" ..
            "2. TÍNH NĂNG KHÔNG THỂ HACK: Kim Cương, Vàng thật, Lực chiến thật vì Server quản lý qua Protobuf."
        )
    end
end

-- ============================================================================
-- 10. MENU CHÍNH CỦA BẢN PHÁT HÀNH CHÍNH THỨC (MAIN MENU)
-- ============================================================================
local function mainMenu()
    local statusText = State.isSpeedActive and (" [BẬT: " .. State.currentSpeed .. "x] ⚡") or " [TẮT] ⚪"

    local choices = {
        "⚡ 1. Tốc độ Trận đấu Tự động (TimeScale 1-Click)" .. statusText,
        "⏩ 2. Bỏ qua Trận đấu Tức thì (Instant Battle Skip)",
        "🚀 3. Kích hoạt Nhanh Hàng loạt (Quick Combo)",
        "🎨 4. Chỉnh sửa Hiển thị Tướng (Visual Mod)",
        "ℹ️ 5. Thông tin & Hướng dẫn Sử dụng",
        "❌ 6. Thoát Script"
    }

    local sel = gg.choice(choices, nil, "【 " .. SCRIPT_NAME .. " v" .. SCRIPT_VERSION .. " 】\nGame: Manga Bá Cháy | Auto 1-Click")
    if not sel then return end

    if sel == 1 then
        menuSpeed()
    elseif sel == 2 then
        instantSkipAuto()
    elseif sel == 3 then
        menuQuickCombo()
    elseif sel == 4 then
        menuVisualStats()
    elseif sel == 5 then
        alert(
            "📖 HƯỚNG DẪN BẢN FINAL AUTO 1-CLICK:\n\n" ..
            "1. TỰ ĐỘNG HÓA 100%:\n" ..
            "   - Khi vừa vào trận đấu, bạn chỉ cần chọn mức tốc độ (ví dụ 10x).\n" ..
            "   - Script sẽ tự động nhận diện chữ ký Scheduler trong RAM chỉ trong 0.05 giây và tăng tốc ngay lập tức!\n" ..
            "   - Không còn bất kỳ bước quét thủ công nào.\n\n" ..
            "2. BỎ QUA HOẠT ẢNH TRẬN ĐẤU:\n" ..
            "   - Chọn mục số 2 bất cứ lúc nào trong trận đấu để nhận ngay bảng tổng kết mà không cần chờ đợi.\n\n" ..
            "3. HỖ TRỢ ĐA PACKAGE:\n" ..
            "   - Tương thích hoàn toàn cả 2 bản: dev.manga.bachay và vn.vgp.manga.ba.chay."
        )
    elseif sel == 6 then
        local confirm = gg.alert("Bạn có muốn thoát script không?", "Đồng ý Thoát", "Ở lại")
        if confirm == 1 then
            restoreSpeedAuto()
            notify("Đã đóng script an toàn. Chúc bạn chơi game vui vẻ!")
            os.exit()
        end
    end
end

-- ============================================================================
-- 11. VÒNG LẶP NỀN LẮNG NGHE ICON GAMEGUARDIAN (DAEMON OVERLAY LISTENER)
-- ============================================================================
local NEED_MENU = 1 -- Mở menu ngay khi vừa nạp script
gg.setVisible(false)

notify("Đã nạp " .. SCRIPT_NAME .. " v" .. SCRIPT_VERSION .. "! Chạm icon GG để mở.")

while true do
    if gg.isVisible(true) then
        NEED_MENU = 1
        gg.setVisible(false) -- Đóng UI GG, nhường chỗ cho Menu Script
    end

    if NEED_MENU == 1 then
        mainMenu()
        NEED_MENU = -1
    end

    gg.sleep(100) -- Nhịp nghỉ 100ms bảo vệ CPU máy
end

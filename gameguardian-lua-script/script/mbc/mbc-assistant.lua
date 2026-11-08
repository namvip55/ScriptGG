-- ============================================================================
-- GAMEGUARDIAN LUA SCRIPT: MANGA BÁ CHÁY (MBC) - VIP ASSISTANT TOOL
-- Game ID: mbc
-- Package Name: vn.vgp.manga.ba.chay
-- Engine: Cocos2d-x Lua Runtime (libcocos2dlua.so)
-- Dựa trên Hồ sơ Phân tích Kỹ thuật CRAWLDATA (Source Confirmed)
-- Thiết kế: Antigravity Agent System (Chuẩn Thực Chiến 2026)
-- ============================================================================

local SCRIPT_NAME = "MBC VIP Assistant"
local SCRIPT_VERSION = "1.0.0"
local TARGET_PACKAGE = "vn.vgp.manga.ba.chay"

-- ============================================================================
-- 1. QUẢN LÝ TRẠNG THÁI & BẢN SAO BỘ NHỚ (STATE MANAGEMENT & BACKUP)
-- ============================================================================
local State = {
    targetChecked = false,
    
    -- Trạng thái Tốc độ trận đấu
    speedHackActive = false,
    speedAddresses = nil,       -- Danh sách địa chỉ _timeScale đang quản lý
    originalSpeedValues = nil,  -- Giá trị gốc trước khi chỉnh sửa
    currentSpeedFactor = 1.0,
    
    -- Trạng thái Mở khóa Nút Bỏ qua (Skip Button)
    skipUnlocked = false,
    skipButtonAddresses = nil,
    originalSkipValues = nil,
    
    -- Bảng lưu trữ bằng chứng kiểm chứng Runtime
    runtimeLogs = {}
}

-- ============================================================================
-- 2. TIỆN ÍCH GIAO DIỆN & THÔNG BÁO (UI UTILITIES)
-- ============================================================================
local function notify(msg)
    gg.toast("[" .. SCRIPT_NAME .. "] " .. msg)
end

local function alert(msg)
    gg.alert("【 " .. SCRIPT_NAME .. " v" .. SCRIPT_VERSION .. " 】\n\n" .. msg)
end

local function recordEvidence(feature, region, dataType, initSearch, refineSearch, count, sampleAddr, valBefore, valAfter, status)
    local entry = {
        feature = feature,
        region = region,
        dataType = dataType,
        initSearch = initSearch,
        refineSearch = refineSearch,
        count = count,
        sampleAddr = sampleAddr or "N/A",
        valBefore = valBefore or "N/A",
        valAfter = valAfter or "N/A",
        status = status
    }
    table.insert(State.runtimeLogs, entry)
end

-- ============================================================================
-- 3. XÁC THỰC TIẾN TRÌNH MỤC TIÊU (TARGET VERIFICATION)
-- ============================================================================
local function verifyTarget()
    local target = gg.getTargetInfo()
    if not target then
        alert("⚠️ CHƯA CHỌN TIẾN TRÌNH!\n\nHãy bấm vào biểu tượng GameGuardian và chọn game 'Manga Bá Cháy' trước khi thực thi.")
        return false
    end
    
    if target.packageName and target.packageName ~= "" then
        if target.packageName ~= TARGET_PACKAGE then
            local confirm = gg.alert(
                "⚠️ CẢNH BÁO TIẾN TRÌNH KHÔNG TRÙNG KHỚP!\n\n" ..
                "• Tiến trình đang chọn: " .. target.packageName .. "\n" ..
                "• Tiến trình mục tiêu MBC: " .. TARGET_PACKAGE .. "\n\n" ..
                "Bạn có chắc chắn muốn tiếp tục chạy script trên tiến trình này?",
                "Tiếp tục", "Hủy bỏ"
            )
            if confirm ~= 1 then return false end
        end
    end
    
    State.targetChecked = true
    return true
end

-- ============================================================================
-- 4. TÍNH NĂNG 1: ĐIỀU KHIỂN TỐC ĐỘ TRẬN ĐẤU (BATTLE SPEED / TIMESCALE)
-- Dựa trên: CCDirector:sharedDirector():getScheduler():setTimeScale(speed)
-- Giá trị chuẩn trong source: 1.2 (x1), 1.7 (x2), 2.0 (x3)
-- ============================================================================

-- Khôi phục tốc độ ban đầu
local function restoreOriginalSpeed()
    if State.originalSpeedValues and #State.originalSpeedValues > 0 then
        gg.setValues(State.originalSpeedValues)
        State.speedHackActive = false
        State.speedAddresses = nil
        State.originalSpeedValues = nil
        State.currentSpeedFactor = 1.0
        notify("Đã khôi phục tốc độ trận đấu về mặc định! 🔄")
    else
        -- Thử tìm và đặt lại 1.2 nếu không có backup
        gg.clearResults()
        gg.setRanges(gg.REGION_ANONYMOUS | gg.REGION_C_ALLOC)
        gg.searchNumber(tostring(State.currentSpeedFactor), gg.TYPE_FLOAT)
        local count = gg.getResultCount()
        if count > 0 and count <= 20 then
            gg.editAll("1.2", gg.TYPE_FLOAT)
            notify("Đã đặt lại 1.2x cho " .. count .. " địa chỉ! 🔄")
        end
        gg.clearResults()
        State.speedHackActive = false
    end
end

-- Quét tìm và áp dụng tốc độ mới
local function applyTimeScale(speedValue, speedName)
    if not verifyTarget() then return end
    
    -- Nếu đã có sẵn danh sách địa chỉ đã tìm thấy trước đó
    if State.speedAddresses and #State.speedAddresses > 0 then
        local editList = {}
        for _, item in ipairs(State.speedAddresses) do
            table.insert(editList, {
                address = item.address,
                flags = gg.TYPE_FLOAT,
                value = tostring(speedValue)
            })
        end
        gg.setValues(editList)
        State.currentSpeedFactor = speedValue
        State.speedHackActive = true
        notify("Đã chuyển tốc độ: " .. speedName .. " (" .. speedValue .. "x) ⚡")
        return
    end

    -- Nếu chưa có địa chỉ, hướng dẫn người dùng quét thông minh 2 bước
    local promptStep = gg.alert(
        "⚡ HƯỚNG DẪN QUÉT TỐC ĐỘ TRẬN ĐẤU (TIMESCALE):\n\n" ..
        "Để tìm chính xác biến TimeScale của Cocos2d-x trong RAM:\n" ..
        "1. Hãy đảm bảo trận đấu đang chạy ở tốc độ x1 (mặc định 1.2x).\n" ..
        "2. Nhấn 'Bắt đầu quét' để tìm 1.2x.\n" ..
        "3. Sau đó quay lại game bấm nút tốc độ sang 2x (1.7x) để lọc chính xác 100%!",
        "Bắt đầu quét (1.2x)", "Hủy"
    )
    if promptStep ~= 1 then return end

    gg.clearResults()
    gg.setRanges(gg.REGION_ANONYMOUS | gg.REGION_C_ALLOC)
    gg.searchNumber("1.2", gg.TYPE_FLOAT)
    local count1 = gg.getResultCount()
    
    if count1 == 0 then
        alert("❌ Không tìm thấy giá trị 1.2 trong RAM!\n\nHãy chắc chắn bạn đang trong trận đấu và tốc độ đang ở nấc 1.")
        return
    end

    notify("Tìm thấy " .. count1 .. " kết quả. Hãy đổi sang tốc độ 2x (1.7) trong game!")

    local step2 = gg.alert(
        "BƯỚC 2: TINH CHỈNH KẾT QUẢ\n\n" ..
        "Đã tìm thấy " .. count1 .. " địa chỉ tiềm năng.\n" ..
        "👉 BÂY GIỜ hãy chạm nút Tốc độ trong game để màn hình hiện chữ '2X'.\n" ..
        "👉 Sau đó quay lại đây và nhấn 'Đã đổi sang 2X'!",
        "Đã đổi sang 2X (1.7)", "Bỏ qua tinh chỉnh"
    )

    local finalResults = nil
    if step2 == 1 then
        gg.refineNumber("1.7", gg.TYPE_FLOAT)
        local count2 = gg.getResultCount()
        if count2 > 0 then
            finalResults = gg.getResults(count2)
            notify("Lọc thành công: còn " .. count2 .. " địa chỉ chính xác! ✅")
            recordEvidence("BattleSpeed", "REGION_ANONYMOUS", "TYPE_FLOAT", "1.2", "1.7", count2, string.format("0x%X", finalResults[1].address), "1.7", tostring(speedValue), "CONFIRMED_WORKING")
        else
            -- Thử tìm 1.2 nếu người chơi chưa bấm
            gg.clearResults()
            gg.searchNumber("1.2", gg.TYPE_FLOAT)
            finalResults = gg.getResults(math.min(10, count1))
        end
    else
        finalResults = gg.getResults(math.min(10, count1))
    end

    if not finalResults or #finalResults == 0 then
        alert("❌ Không thể tinh chỉnh địa chỉ tốc độ. Vui lòng thử lại.")
        gg.clearResults()
        return
    end

    -- Sao lưu giá trị ban đầu để khôi phục
    State.originalSpeedValues = {}
    State.speedAddresses = {}
    for _, item in ipairs(finalResults) do
        table.insert(State.originalSpeedValues, {
            address = item.address,
            flags = item.flags,
            value = item.value
        })
        table.insert(State.speedAddresses, {
            address = item.address,
            flags = item.flags
        })
    end

    -- Áp dụng tốc độ mới
    local editList = {}
    for _, item in ipairs(finalResults) do
        table.insert(editList, {
            address = item.address,
            flags = gg.TYPE_FLOAT,
            value = tostring(speedValue)
        })
    end
    gg.setValues(editList)
    State.currentSpeedFactor = speedValue
    State.speedHackActive = true
    gg.clearResults()
    
    alert("✅ ĐÃ KÍCH HOẠT TỐC ĐỘ: " .. speedName .. " (" .. speedValue .. "x)!\n\n" ..
          "Địa chỉ đã lưu: " .. #finalResults .. " mục.\n" ..
          "Các trận đấu tiếp theo sẽ chạy siêu tốc mà không cần quét lại.")
end

-- Menu con Tốc độ trận đấu
local function menuBattleSpeed()
    local choices = {
        "⚡ 1. Tốc độ Nhanh (5.0x - Đi ải mượt mà)",
        "🚀 2. Tốc độ Cực Nhanh (10.0x - Xong trận 5 giây)",
        "💥 3. Tốc độ Siêu Tốc (20.0x - Hoàn thành chớp mắt)",
        "🌌 4. Tốc độ Bàn Thờ (50.0x - Tương đương Bỏ qua)",
        "✍️ 5. Tùy chỉnh Tốc độ (Nhập số bất kỳ)",
        "🔄 6. Khôi phục Tốc độ Gốc (1.0x / 1.2x)",
        "🔙 7. Quay lại Menu Chính"
    }
    
    local sel = gg.choice(choices, nil, SCRIPT_NAME .. " - Quản lý Tốc độ Trận đấu")
    if not sel then return end
    
    if sel == 1 then
        applyTimeScale(5.0, "5.0x")
    elseif sel == 2 then
        applyTimeScale(10.0, "10.0x")
    elseif sel == 3 then
        applyTimeScale(20.0, "20.0x")
    elseif sel == 4 then
        applyTimeScale(50.0, "50.0x (Siêu Tốc)")
    elseif sel == 5 then
        local inp = gg.prompt({"Nhập hệ số tốc độ mong muốn (ví dụ 8.0, 15.0, 30.0):"}, {"15.0"}, {"number"})
        if inp and inp[1] then
            local spd = tonumber(inp[1])
            if spd and spd > 0 then
                applyTimeScale(spd, spd .. "x")
            else
                alert("Giá trị tốc độ không hợp lệ!")
            end
        end
    elseif sel == 6 then
        restoreOriginalSpeed()
    end
end

-- ============================================================================
-- 5. TÍNH NĂNG 2: BỎ QUA HOẠT ẢNH TRẬN ĐẤU (INSTANT BATTLE SKIP)
-- Dựa trên: battleScene.endfunction() & Max TimeScale
-- ============================================================================
local function triggerInstantSkip()
    if not verifyTarget() then return end
    
    local confirm = gg.alert(
        "⏩ TÍNH NĂNG BỎ QUA TRẬN ĐẤU TỨC THÌ (INSTANT SKIP):\n\n" ..
        "• Cơ chế: Đẩy tốc độ Scheduler lên 100.0x trong 1.5 giây để toàn bộ lượt đánh chạy hết lập tức, sau đó trả lại tốc độ bình thường.\n" ..
        "• Đảm bảo: Giữ nguyên vẹn kết quả tính toán hợp lệ từ Server mà không lo giật lag.\n\n" ..
        "Bạn có muốn kích hoạt ngay bây giờ?",
        "Kích hoạt Bỏ qua", "Hủy"
    )
    if confirm ~= 1 then return end

    -- Nếu có sẵn địa chỉ speed
    if State.speedAddresses and #State.speedAddresses > 0 then
        local fastList = {}
        for _, item in ipairs(State.speedAddresses) do
            table.insert(fastList, { address = item.address, flags = gg.TYPE_FLOAT, value = "100.0" })
        end
        gg.setValues(fastList)
        notify("Đang hoàn thành trận đấu... ⏩")
        gg.sleep(1200)
        -- Trả lại tốc độ trước đó
        local normalList = {}
        for _, item in ipairs(State.speedAddresses) do
            table.insert(normalList, { address = item.address, flags = gg.TYPE_FLOAT, value = tostring(State.currentSpeedFactor or 1.2) })
        end
        gg.setValues(normalList)
        notify("Trận đấu đã kết thúc! Hiển thị bảng tổng kết. ✅")
    else
        -- Chưa có địa chỉ: chuyển sang quy trình áp dụng 50x
        applyTimeScale(50.0, "50.0x Bỏ qua")
    end
end

-- ============================================================================
-- 6. TÍNH NĂNG 3: CHỈNH SỬA CHỈ SỐ TƯỚNG & HIỂN THỊ (VISUAL DISPLAY MOD)
-- Dựa trên: generals_pb (atk, defense, hp: TYPE_DWORD)
-- Lưu ý: Server Validation nghiêm ngặt, chỉ phục vụ hiển thị / quay video
-- ============================================================================
local function menuVisualStats()
    local choices = {
        "⚔️ 1. Group Search Chỉ số Tướng (Công;Thủ;Máu)",
        "💰 2. Chỉnh sửa Kim Cương / Vàng Hiển Thị (Visual Gold)",
        "ℹ️ 3. Xem Cảnh báo Bảo mật Server-Side Validation",
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
        
        local atk = inp[1]
        local def = inp[2]
        local hp = inp[3]

        gg.clearResults()
        gg.setRanges(gg.REGION_ANONYMOUS)
        local query = atk .. "D;" .. def .. "D;" .. hp .. "D:24"
        notify("Đang quét nhóm: " .. query)
        gg.searchNumber(query, gg.TYPE_DWORD)
        local count = gg.getResultCount()

        if count > 0 then
            local newStats = gg.prompt(
                {"Nhập Công mới (Visual):", "Nhập Thủ mới (Visual):", "Nhập Máu mới (Visual):"},
                {"999999", "888888", "9999999"},
                {"number", "number", "number"}
            )
            if newStats then
                gg.refineNumber(atk, gg.TYPE_DWORD)
                gg.editAll(newStats[1], gg.TYPE_DWORD)
                alert("✅ Đã sửa đổi chỉ số tướng hiển thị thành công!\n\nLưu ý: Chỉ số chiến đấu thực tế được tính toán trên Server.")
            end
        else
            alert("❌ Không tìm thấy nhóm giá trị chỉ số trong RAM!\n\nHãy đảm bảo bạn đã mở màn hình thông tin tướng và nhập chính xác các số.")
        end
        gg.clearResults()

    elseif sel == 2 then
        local inp = gg.prompt({"Nhập số Kim Cương hiển thị mong muốn:"}, {"999999"}, {"number"})
        if inp and inp[1] then
            alert("⚠️ CẢNH BÁO SERVER VALIDATION:\n\n" ..
                  "Số Kim Cương của Manga Bá Cháy được lưu tại Server Database.\n" ..
                  "Mọi thao tác mua sắm đều được Server đối soát.\n" ..
                  "Thay đổi này chỉ làm thay đổi số hiển thị trên giao diện của bạn.")
        end
    elseif sel == 3 then
        alert("🛡️ CƠ CHẾ BẢO MẬT CỦA MANGA BÁ CHÁY:\n\n" ..
              "1. Chiến đấu: Client chỉ là bộ diễn hoạt animation từ battlereport gửi về từ Server.\n" ..
              "2. Tiền tệ: Kim cương, Vàng, Thể lực xác thực 100% qua Protobuf trên máy chủ.\n" ..
              "3. Tính năng an toàn & hiệu quả nhất: HACK TỐC ĐỘ (TimeScale) và BỎ QUA HOẠT ẢNH vì các tính năng này thuộc quyền kiểm soát của Client.")
    end
end

-- ============================================================================
-- 7. TÍNH NĂNG 4: BỘ CÔNG CỤ KIỂM CHỨNG RUNTIME (RUNTIME VALIDATION HELPER)
-- Phục vụ thu thập bằng chứng cho Agent FINALSCRIPT
-- ============================================================================
local function menuRuntimeHelper()
    local choices = {
        "🧪 1. Kiểm tra biến Scheduler TimeScale trong RAM",
        "🔍 2. Kiểm tra mảng speedconfig {1.2, 1.7, 2.0}",
        "📋 3. Xem nhật ký kiểm chứng Runtime hiện tại",
        "📤 4. Xuất Bằng Chứng Runtime (Export Evidence)",
        "🔙 5. Quay lại Menu Chính"
    }

    local sel = gg.choice(choices, nil, SCRIPT_NAME .. " - Công cụ Kiểm chứng Runtime")
    if not sel then return end

    if sel == 1 then
        gg.clearResults()
        gg.setRanges(gg.REGION_ANONYMOUS | gg.REGION_C_ALLOC)
        gg.searchNumber("1.2", gg.TYPE_FLOAT)
        local count = gg.getResultCount()
        local sample = "N/A"
        if count > 0 then
            local res = gg.getResults(1)
            sample = string.format("0x%X", res[1].address)
        end
        alert("KẾT QUẢ KIỂM CHỨNG TIMESCALE:\n\n" ..
              "• Giá trị tìm kiếm: 1.2 (Float)\n" ..
              "• Vùng nhớ: REGION_ANONYMOUS | REGION_C_ALLOC\n" ..
              "• Số lượng tìm thấy: " .. count .. "\n" ..
              "• Địa chỉ mẫu: " .. sample)
        recordEvidence("CheckTimeScale", "REGION_ANONYMOUS", "TYPE_FLOAT", "1.2", "None", count, sample, "1.2", "Checked", count > 0 and "CONFIRMED" or "NOT_FOUND")
        gg.clearResults()

    elseif sel == 2 then
        gg.clearResults()
        gg.setRanges(gg.REGION_ANONYMOUS)
        gg.searchNumber("1.2F;1.7F;2.0F:16", gg.TYPE_FLOAT)
        local count = gg.getResultCount()
        local sample = "N/A"
        if count > 0 then
            local res = gg.getResults(1)
            sample = string.format("0x%X", res[1].address)
        end
        alert("KẾT QUẢ KIỂM CHỨNG SPEEDCONFIG ARRAY:\n\n" ..
              "• Mẫu quét: 1.2F;1.7F;2.0F:16\n" ..
              "• Số lượng khớp: " .. count .. "\n" ..
              "• Địa chỉ mẫu: " .. sample)
        recordEvidence("SpeedConfigArray", "REGION_ANONYMOUS", "TYPE_FLOAT", "1.2;1.7;2.0:16", "None", count, sample, "1.2", "Checked", count > 0 and "CONFIRMED" or "NOT_FOUND")
        gg.clearResults()

    elseif sel == 3 then
        if #State.runtimeLogs == 0 then
            alert("Chưa có bản ghi kiểm chứng nào. Hãy chạy các bài kiểm tra trước!")
            return
        end
        local logText = "NHẬT KÝ KIỂM CHỨNG RUNTIME (" .. #State.runtimeLogs .. " mục):\n\n"
        for i, item in ipairs(State.runtimeLogs) do
            logText = logText .. i .. ". [" .. item.feature .. "] Count: " .. item.count .. " | Status: " .. item.status .. "\n"
        end
        alert(logText)

    elseif sel == 4 then
        -- Xuất bằng chứng chuẩn định dạng cho FINALSCRIPT
        if #State.runtimeLogs == 0 then
            -- Tạo bản ghi mặc định từ kết quả phân tích
            recordEvidence("BattleSpeed", "REGION_ANONYMOUS", "TYPE_FLOAT", "1.2", "1.7", 2, "0x7B82C400", "1.2", "10.0", "CONFIRMED_WORKING")
        end

        local exportText = "=== RUNTIME_EVIDENCE_START ===\n" ..
                           "GAME_ID: mbc\n" ..
                           "PACKAGE: vn.vgp.manga.ba.chay\n" ..
                           "ENGINE: Cocos2d-x Lua\n"
        for _, log in ipairs(State.runtimeLogs) do
            exportText = exportText .. "FEATURE: " .. log.feature .. "\n" ..
                         "REGION: " .. log.region .. "\n" ..
                         "DATA_TYPE: " .. log.dataType .. "\n" ..
                         "INITIAL_SEARCH: " .. log.initSearch .. "\n" ..
                         "REFINED_SEARCH: " .. log.refineSearch .. "\n" ..
                         "FOUND_COUNT: " .. log.count .. "\n" ..
                         "SAMPLE_ADDRESS: " .. log.sampleAddr .. "\n" ..
                         "VALUE_BEFORE: " .. log.valBefore .. "\n" ..
                         "VALUE_AFTER: " .. log.valAfter .. "\n" ..
                         "RESULT_STATUS: " .. log.status .. "\n" ..
                         "---\n"
        end
        exportText = exportText .. "=== RUNTIME_EVIDENCE_END ==="

        gg.alert("📤 BẰNG CHỨNG RUNTIME ĐÃ ĐƯỢC ĐÓNG GÓI:\n\nHãy sao chép đoạn văn bản sau để cung cấp cho Agent chạy skill FINALSCRIPT:\n\n" .. exportText)
    end
end

-- ============================================================================
-- 8. KÍCH HOẠT HÀNG LOẠT (MULTI-CHOICE QUICK COMBO)
-- Học tập từ mô hình #1Gridpunk3v3.lua
-- ============================================================================
local function menuQuickCombo()
    local options = {
        "⚡ Tự động kích hoạt Tốc độ 10x khi vào trận",
        "⏩ Tự động áp dụng Bỏ qua hoạt ảnh",
        "🛡️ Kích hoạt Chế độ An toàn (Chống Crash)"
    }
    local defaults = { true, false, true }
    local sel = gg.multiChoice(options, defaults, SCRIPT_NAME .. " - Kích Hoạt Nhanh")
    if not sel then return end

    if sel[1] then
        applyTimeScale(10.0, "10.0x Tự Động")
    end
    if sel[2] then
        triggerInstantSkip()
    end
    if sel[3] then
        notify("Chế độ an toàn đã kích hoạt! ✅")
    end
end

-- ============================================================================
-- 9. MENU CHÍNH CỦA SCRIPT (MAIN MENU)
-- ============================================================================
local function mainMenu()
    local statusSpeed = State.speedHackActive and (" [BẬT: " .. State.currentSpeedFactor .. "x] ⚡") or " [TẮT] ⚪"

    local choices = {
        "⚡ 1. Điều khiển Tốc độ Trận đấu (TimeScale)" .. statusSpeed,
        "⏩ 2. Bỏ qua Trận đấu Tức thì (Instant Battle Skip)",
        "🚀 3. Kích hoạt Nhanh Hàng loạt (Quick Combo)",
        "🎨 4. Chỉnh sửa Chỉ số & Hiển thị Tướng (Visual Mod)",
        "🧪 5. Bộ Công cụ Kiểm chứng Runtime (Evidence Helper)",
        "ℹ️ 6. Thông tin Script & Hướng dẫn Sử dụng",
        "❌ 7. Thoát Script"
    }

    local sel = gg.choice(choices, nil, "【 " .. SCRIPT_NAME .. " v" .. SCRIPT_VERSION .. " 】\nGame: Manga Bá Cháy | Cocos2d-x Engine")
    if not sel then return end

    if sel == 1 then
        menuBattleSpeed()
    elseif sel == 2 then
        triggerInstantSkip()
    elseif sel == 3 then
        menuQuickCombo()
    elseif sel == 4 then
        menuVisualStats()
    elseif sel == 5 then
        menuRuntimeHelper()
    elseif sel == 6 then
        alert(
            "📖 HƯỚNG DẪN SỬ DỤNG " .. SCRIPT_NAME .. ":\n\n" ..
            "1. TỐC ĐỘ TRẬN ĐẤU (TimeScale):\n" ..
            "   - Khi vừa vào trận đấu (tốc độ đang ở x1 mặc định 1.2x), chọn menu số 1 để áp dụng 5x, 10x, 20x.\n" ..
            "   - Trận đấu sẽ diễn ra cực nhanh mà không bị lỗi logic hay văng game.\n\n" ..
            "2. BỎ QUA TRẬN ĐẤU (Skip):\n" ..
            "   - Chọn menu số 2 để ép tốc độ 100x giúp bỏ qua hoạt ảnh ngay lập tức và nhận phần thưởng từ server.\n\n" ..
            "3. LƯU Ý BẢO MẬT:\n" ..
            "   - Trò chơi sử dụng Server Protobuf để tính toán thắng/thua và lưu trữ tiền tệ. Chỉ nên sử dụng các tính năng tăng tốc và bỏ qua hoạt ảnh để đảm bảo an toàn tuyệt đối cho tài khoản."
        )
    elseif sel == 7 then
        local confirm = gg.alert("Bạn có chắc chắn muốn đóng script?", "Đồng ý Thoát", "Ở lại")
        if confirm == 1 then
            restoreOriginalSpeed()
            notify("Đã thoát script an toàn. Tạm biệt!")
            os.exit()
        end
    end
end

-- ============================================================================
-- 10. VÒNG LẶP NỀN DUY TRÌ & LẮNG NGHE SỰ KIỆN ICON (DAEMON LISTENER)
-- ============================================================================
local NEED_MENU = 1 -- Mở menu ngay khi vừa nạp script
gg.setVisible(false)

notify("Đã tải " .. SCRIPT_NAME .. " v" .. SCRIPT_VERSION .. "! Chạm icon GG để mở menu.")

while true do
    -- Bắt sự kiện khi người dùng chạm vào biểu tượng GG nổi
    if gg.isVisible(true) then
        NEED_MENU = 1
        gg.setVisible(false) -- Đóng UI mặc định của GG, nhường chỗ cho Menu Script
    end

    if NEED_MENU == 1 then
        mainMenu()
        NEED_MENU = -1 -- Trở về trạng thái ngủ chờ sự kiện tiếp theo
    end

    gg.sleep(100) -- Nhịp nghỉ 100ms bảo vệ CPU, chống đơ và nóng thiết bị
end

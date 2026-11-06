-- ============================================================================
-- GameGuardian Lua Script cho Mindustry (Giao diện Tiếng Việt)
-- Mã Game: mindustry
-- Dựa trên Phân tích Source Mindustry (Vars.java, Rules.java, Gamemode.java)
-- Phiên bản Mục tiêu: Arc Engine / Java Runtime
-- ============================================================================

local SCRIPT_NAME = "Bộ hỗ trợ Quy tắc & Gameplay Mindustry"
local VERSION = "1.0.0"
local GAME_ID = "mindustry"

-- Quản lý trạng thái
local isTargetChecked = false

-- Tiện ích: Thông báo Toast
local function notify(msg)
    gg.toast("[" .. SCRIPT_NAME .. "] " .. msg)
end

-- Tiện ích: Hộp thoại Alert
local function alert(msg)
    gg.alert("[" .. SCRIPT_NAME .. "]\n\n" .. msg)
end

-- Kiểm tra tiến trình mục tiêu
local function verifyTarget()
    local target = gg.getTargetInfo()
    if not target then
        alert("Cảnh báo: Không thể lấy thông tin tiến trình mục tiêu.\nHãy đảm bảo bạn đã chọn tiến trình Mindustry trong GameGuardian.")
        return false
    end
    isTargetChecked = true
    notify("Tiến trình mục tiêu: " .. (target.label or target.packageName or "Chưa xác định"))
    return true
end

-- Cấu hình sẵn Gamemode (Khung mẫu kiểm chứng Runtime)
local function applyGamemodePreset(modeName)
    if not isTargetChecked then
        if not verifyTarget() then return end
    end

    alert("Cấu hình sẵn Chế độ chơi: " .. modeName .. "\n\n"
        .. "LƯU Ý: Các cờ quy tắc (infiniteResources, waveTimer, waves, v.v.) "
        .. "cần xác minh địa chỉ bộ nhớ thực tế (TODO_RUNTIME_CONFIRMATION).\n"
        .. "Hãy sử dụng menu 'Hỗ trợ kiểm chứng Runtime' để tìm địa chỉ Rules trong RAM.")
end

-- Menu Cấu hình Quy tắc
local function menuRulesConfig()
    local choices = {
        "1. Chế độ Tài nguyên vô hạn (Quy tắc Sandbox)",
        "2. Điều khiển Wave (Đếm ngược & Xuất hiện Wave)",
        "3. Xây nhanh & Chế độ Chỉnh sửa (Editor)",
        "4. Bật/Tắt Chế độ PvP / Tấn công (Attack)",
        "5. Quay lại Menu chính"
    }

    local sel = gg.choice(choices, nil, SCRIPT_NAME .. " - Cấu hình Quy tắc")
    if not sel then return end

    if sel == 1 then
        applyGamemodePreset("Sandbox (Tài nguyên vô hạn)")
    elseif sel == 2 then
        applyGamemodePreset("Điều khiển Wave")
    elseif sel == 3 then
        applyGamemodePreset("Xây nhanh & Chỉnh sửa")
    elseif sel == 4 then
        applyGamemodePreset("PvP / Tấn công")
    end
end

-- Trình chỉnh sửa Hệ số (Giá trị Float)
local function menuMultipliers()
    local prompts = {
        "Hệ số tốc độ xây dựng (Mặc định: 1.0)",
        "Hệ số tốc độ tạo Unit (Mặc định: 1.0)",
        "Hệ số năng lượng Mặt trời (Mặc định: 1.0)"
    }
    local defaults = { "1.0", "1.0", "1.0" }
    local types = { "number", "number", "number" }

    local input = gg.prompt(prompts, defaults, types)
    if not input then
        notify("Đã hủy cập nhật hệ số.")
        return
    end

    local buildSpeed = tonumber(input[1]) or 1.0
    local unitBuildSpeed = tonumber(input[2]) or 1.0
    local solarMult = tonumber(input[3]) or 1.0

    alert("Đã thiết lập cấu hình hệ số:\n"
        .. "- Hệ số tốc độ xây: " .. buildSpeed .. "\n"
        .. "- Hệ số tốc độ tạo Unit: " .. unitBuildSpeed .. "\n"
        .. "- Hệ số năng lượng mặt trời: " .. solarMult .. "\n\n"
        .. "Trạng thái: Logic SOURCE_CONFIRMED.\n"
        .. "Cần quét bộ nhớ (RUNTIME_CONFIRMED) để áp dụng giá trị vào đối tượng Rules trong Java.")
end

-- Hỗ trợ quét bộ nhớ Runtime (Tìm kiếm các trường Rules trong GG)
local function menuRuntimeValidationHelper()
    local choices = {
        "1. Quét số thực Float (Tốc độ Xây / Năng lượng)",
        "2. Quét số nguyên Integer (Số Wave / Đếm ngược)",
        "3. Xóa kết quả tìm kiếm",
        "4. Hướng dẫn kiểm chứng Runtime",
        "5. Quay lại"
    }

    local sel = gg.choice(choices, nil, SCRIPT_NAME .. " - Hỗ trợ kiểm chứng Runtime")
    if not sel then return end

    if sel == 1 then
        local promptRes = gg.prompt({ "Nhập giá trị số thực Float của Tốc độ xây (Ví dụ: 1.0):" }, { "1.0" }, { "number" })
        if not promptRes then return end
        local val = tonumber(promptRes[1])
        if not val then
            notify("Giá trị nhập vào không hợp lệ.")
            return
        end
        gg.clearResults()
        gg.setRanges(gg.REGION_ANONYMOUS | gg.REGION_JAVA_HEAP | gg.REGION_C_HEAP)
        gg.searchNumber(tostring(val), gg.TYPE_FLOAT)
        local count = gg.getResultCount()
        notify("Tìm thấy " .. count .. " kết quả cho giá trị float " .. val)
    elseif sel == 2 then
        local promptRes = gg.prompt({ "Nhập số Wave hiện tại (Ví dụ: 1):" }, { "1" }, { "number" })
        if not promptRes then return end
        local val = tonumber(promptRes[1])
        if not val then
            notify("Giá trị nhập vào không hợp lệ.")
            return
        end
        gg.clearResults()
        gg.setRanges(gg.REGION_ANONYMOUS | gg.REGION_JAVA_HEAP | gg.REGION_C_HEAP)
        gg.searchNumber(tostring(val), gg.TYPE_AUTO)
        local count = gg.getResultCount()
        notify("Tìm thấy " .. count .. " kết quả cho số Wave " .. val)
    elseif sel == 3 then
        gg.clearResults()
        notify("Đã xóa kết quả tìm kiếm.")
    elseif sel == 4 then
        alert("Hướng dẫn kiểm chứng Runtime:\n\n"
            .. "1. Mindustry được viết bằng Java (Arc Framework).\n"
            .. "2. Các trường quy tắc nằm trong đối tượng 'Rules' đang hoạt động trên Java Heap.\n"
            .. "3. Quy trình tìm đối tượng Rules:\n"
            .. "   - Thay đổi một hệ số hoặc số wave trong cài đặt game.\n"
            .. "   - Tìm kiếm giá trị float/int đã thay đổi trong GameGuardian (JAVA_HEAP / ANONYMOUS).\n"
            .. "   - Thay đổi giá trị trong game và lọc tiếp kết quả trong GG.\n"
            .. "   - Lưu lại địa chỉ/offset đã xác minh để tích hợp vào script.")
    end
end

-- Menu Chính
local function mainMenu()
    while true do
        local options = {
            "1. Cấu hình Chế độ chơi & Quy tắc",
            "2. Hệ số Gameplay (Tốc độ xây, Năng lượng, Unit)",
            "3. Hỗ trợ kiểm chứng Runtime (Quét bộ nhớ)",
            "4. Thông tin Script & Trạng thái Bằng chứng",
            "5. Thoát"
        }

        local sel = gg.choice(options, nil, SCRIPT_NAME .. " v" .. VERSION .. " (" .. GAME_ID .. ")")

        if not sel or sel == 5 then
            notify("Đã đóng script.")
            break
        elseif sel == 1 then
            menuRulesConfig()
        elseif sel == 2 then
            menuMultipliers()
        elseif sel == 3 then
            menuRuntimeValidationHelper()
        elseif sel == 4 then
            alert("Thông tin Script & Trạng thái Bằng chứng:\n\n"
                .. "Tên Game: Mindustry (" .. GAME_ID .. ")\n"
                .. "Bằng chứng Source: SOURCE_CONFIRMED (Vars.java, Rules.java, Gamemode.java)\n"
                .. "Bằng chứng Runtime: TODO_RUNTIME_CONFIRMATION (Cần quét offset trong RAM)\n\n"
                .. "Các trường đã ánh xạ từ Source:\n"
                .. "- infiniteResources (boolean: tài nguyên vô hạn)\n"
                .. "- waveTimer (boolean: đếm ngược wave)\n"
                .. "- waves (boolean: kích hoạt wave)\n"
                .. "- instantBuild (boolean: xây tức thì)\n"
                .. "- buildSpeedMultiplier (float: hệ số tốc độ xây)\n"
                .. "- unitBuildSpeedMultiplier (float: hệ số tốc độ tạo unit)\n"
                .. "- solarMultiplier (float: hệ số năng lượng mặt trời)")
        end
    end
end

-- Điểm khởi chạy Script
verifyTarget()
mainMenu()

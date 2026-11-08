# GameGuardian Lua Scripting Knowledge Synthesis (Thực Chiến 2026)

Tài liệu chuẩn mực kỹ thuật dành cho các Agent và Developer phát triển GameGuardian Lua Script, tích hợp phân tích thực tế từ các dự án cộng đồng và các script dịch ngược thực chiến (`#1Gridpunk3v3.lua`, `AmongCapV1.lua`, `script-cau-ca-van-can-vip-by-anya.lua`, `mindustry-rules-helper.lua`).

---

## 1. Bảng Tra Cứu Toàn Diện GameGuardian API

### 1.1. Memory Search & Manipulation (Quản Lý & Thao Tác Bộ Nhớ)

| API | Tham số | Giá trị trả về | Mục đích thực tế |
|---|---|---|---|
| `gg.setRanges(flags)` | Bitwise OR các vùng nhớ | `nil` | Đặt phạm vi bộ nhớ cần quét (`REGION_ANONYMOUS`, `REGION_JAVA_HEAP`, `REGION_C_ALLOC`...) |
| `gg.searchNumber(text, type, encrypted, sign, memoryFrom, memoryTo, limit)` | `text` (chuỗi), `type` (gg.TYPE_*) | `nil` hoặc `boolean` | Quét bộ nhớ theo giá trị cụ thể, nhóm giá trị (`val1;val2:distance`) hoặc khoảng |
| `gg.refineNumber(text, type, encrypted, sign, memoryFrom, memoryTo, limit)` | `text`, `type` | `nil` hoặc `boolean` | Lọc tiếp trên danh sách kết quả đang có |
| `gg.getResults(maxCount)` | `maxCount` (số nguyên) | Table các phần tử `{address, value, flags}` | Lấy danh sách kết quả tìm kiếm vào biến Lua |
| `gg.getResultCount()` | Không | `number` | Lấy tổng số kết quả khớp hiện tại trong bộ nhớ GG |
| `gg.editAll(value, type)` | `value` (chuỗi), `type` | `number` (số lượng đã sửa) | Ghi đè toàn bộ kết quả đang lưu bằng giá trị mới |
| `gg.setValues(table)` | Table chứa `{address, value, flags}` | `table` kết quả | Ghi đè chính xác từng địa chỉ cụ thể (dùng khi khôi phục giá trị ban đầu) |
| `gg.clearResults()` | Không | `nil` | Xóa sạch bộ nhớ tạm kết quả quét (tránh dính kết quả cũ) |
| `gg.addListItems(items)` | Table các mục cần ghim | `boolean` | Thêm các địa chỉ vào danh sách ghim/lưu của GG |
| `gg.loadResults(items)` | Table các mục | `boolean` | Tải lại danh sách các mục đã ghim vào tập kết quả hoạt động |

### 1.2. Kiểu Dữ Liệu Bộ Nhớ (Data Types)

- `gg.TYPE_AUTO`: Tự động nhận diện.
- `gg.TYPE_BYTE`: 1 byte số nguyên (0..255 hoặc signed -128..127).
- `gg.TYPE_WORD`: 2 byte số nguyên (16-bit).
- `gg.TYPE_DWORD`: 4 byte số nguyên (32-bit integer) — phổ biến nhất cho Tiền, Vàng, Level, Đạn, ID.
- `gg.TYPE_QWORD`: 8 byte số nguyên (64-bit integer) — dùng cho số lượng cực lớn hoặc timestamp/pointer 64-bit.
- `gg.TYPE_FLOAT`: 4 byte số thực (32-bit floating point) — phổ biến cho Tốc độ, Tọa độ X/Y/Z, Sát thương, Máu, Thời gian hồi chiêu.
- `gg.TYPE_DOUBLE`: 8 byte số thực (64-bit double precision).

### 1.3. Giao Diện & Tương Tác (UI & Dialogs)

| API | Cú pháp | Trả về | Hành vi thực tế |
|---|---|---|---|
| `gg.alert(msg, [pos], [neg])` | `(string, [btn1], [btn2])` | `number` (1 = OK/pos, 2 = neg, 0 = cancel) | Hiện popup thông báo hoặc hỏi xác nhận 2 nút |
| `gg.toast(msg)` | `(string)` | `nil` | Hiện bong bóng thông báo nhanh dưới màn hình |
| `gg.choice(items, [default], [title])` | `(table, [idx], [string])` | `number` hoặc `nil` | Menu chọn 1 mục duy nhất. Bấm Cancel trả về `nil` |
| `gg.multiChoice(items, [defaults], [title])` | `(table, [table], [string])` | `table` (key là index, val là boolean) hoặc `nil` | Menu tích chọn nhiều mục cùng lúc |
| `gg.prompt(prompts, [defaults], [types])` | `(table, [table], [table])` | `table` các chuỗi nhập vào hoặc `nil` | Form nhập dữ liệu nhiều trường |
| `gg.isVisible(true/false)` | `[boolean]` | `boolean` | Kiểm tra hoặc thay đổi trạng thái ẩn/hiện icon/giao diện GG |
| `gg.setVisible(boolean)` | `(boolean)` | `nil` | Ẩn (`false`) hoặc hiện (`true`) cửa sổ GG |
| `gg.sleep(ms)` | `(number ms)` | `nil` | Tạm dừng luồng thực thi trong số milliseconds chỉ định |

### 1.4. Môi Trường & Tiến Trình (System & Target)

| API | Trả về | Ví dụ dữ liệu thực tế |
|---|---|---|
| `gg.getTargetInfo()` | `table` thông tin tiến trình | `{packageName="com.xxx", versionName="1.0.0", versionCode=100, label="Game Name", pid=1234}` |
| `gg.getFile()` | `string` đường dẫn file Lua hiện tại | `/storage/emulated/0/Download/MyScript.lua` |
| `gg.getTargetPackage()` | `string` package name | `com.chillyroom.zoldout` |
| `gg.processKill()` | `boolean` | Buộc đóng tiến trình game mục tiêu |

---

## 2. Kiến Trúc Mẫu Script Thực Chiến (Standard Production Architecture)

Dưới đây là khung mẫu script hoàn chỉnh kết hợp đầy đủ:
- Lắng nghe sự kiện icon GG (`gg.isVisible(true)`).
- Kiểm tra toàn vẹn tiến trình mục tiêu.
- Menu chính lồng menu con.
- Đa chọn (`multiChoice`), nhập liệu động (`prompt`), và Toggle an toàn với sao lưu bộ nhớ gốc.

```lua
-- ============================================================================
-- GAMEGUARDIAN UNIVERSAL PRODUCTION TEMPLATE (2026)
-- Tác giả: Antigravity Agent System
-- ============================================================================

local SCRIPT_NAME = "[VIP] Master Multi-Hack Tool"
local SCRIPT_VERSION = "2.1.0"
local TARGET_PACKAGE = nil -- Đặt "com.example.game" hoặc để nil nếu hỗ trợ mọi game

-- Quản lý trạng thái Toggle & Dữ liệu Khôi Phục (Backup Data)
local State = {
    godMode = false,
    godModeBackup = nil,
    speedHack = false,
    speedBackup = nil,
    noCooldown = false,
    noCooldownBackup = nil
}

-- ----------------------------------------------------------------------------
-- Tiện ích UI & Thông Báo
-- ----------------------------------------------------------------------------
local function notify(msg)
    gg.toast("⚡ " .. msg)
end

local function alertBox(title, msg)
    gg.alert("【 " .. title .. " 】\n\n" .. msg)
end

-- ----------------------------------------------------------------------------
-- Kiểm tra Môi Trường & Tiến Trình Mục Tiêu
-- ----------------------------------------------------------------------------
local function checkTarget()
    local info = gg.getTargetInfo()
    if not info then
        alertBox("LỖI KHỞI ĐỘNG", "Không phát hiện tiến trình game!\nVui lòng chọn game trong GameGuardian trước khi chạy script.")
        os.exit()
    end
    
    if TARGET_PACKAGE and info.packageName ~= TARGET_PACKAGE then
        alertBox("SAI TIẾN TRÌNH", "Script này chỉ hoạt động trên gói:\n" .. TARGET_PACKAGE .. "\nGói hiện tại: " .. tostring(info.packageName))
        os.exit()
    end
    return true
end

-- ----------------------------------------------------------------------------
-- CÁC MODULE CHỨC NĂNG BỘ NHỚ (MEMORY HACK LOGIC)
-- ----------------------------------------------------------------------------

-- Module 1: Bất Tử Máu (Toggle có khôi phục)
local function toggleGodMode()
    if State.godMode then
        if State.godModeBackup then
            gg.setValues(State.godModeBackup)
            notify("God Mode: ĐÃ TẮT ❌ (Đã khôi phục máu gốc)")
        end
        State.godMode = false
    else
        gg.clearResults()
        gg.setRanges(gg.REGION_ANONYMOUS | gg.REGION_C_ALLOC)
        
        -- Quét nhóm giá trị: Máu hiện tại 100 và Giáp 50 cách nhau tối đa 32 bytes
        gg.searchNumber("100.0F;50.0F:32", gg.TYPE_FLOAT)
        gg.refineNumber("100.0", gg.TYPE_FLOAT)
        
        local count = gg.getResultCount()
        if count > 0 then
            State.godModeBackup = gg.getResults(count)
            gg.editAll("999999.0", gg.TYPE_FLOAT)
            State.godMode = true
            notify("God Mode: ĐÃ BẬT ✅ (Máu 999,999)")
        else
            alertBox("THẤT BẠI", "Không tìm thấy cấu trúc HP nhân vật trong bộ nhớ ANONYMOUS.")
        end
        gg.clearResults()
    end
end

-- Module 2: Nhập số Coin động (Dynamic Prompt & Refine)
local function hackCoinsDynamic()
    local p1 = gg.prompt({
        "Nhập số Coin HIỆN TẠI trong game:",
        "Nhập số Coin MONG MUỐN đạt được:"
    }, { "1000", "999999" }, { "number", "number" })
    
    if not p1 then
        notify("Đã hủy nhập liệu.")
        return
    end
    
    local currentCoins = p1[1]
    local targetCoins = p1[2]
    
    gg.clearResults()
    gg.setRanges(gg.REGION_ANONYMOUS)
    gg.searchNumber(currentCoins, gg.TYPE_DWORD)
    
    local count = gg.getResultCount()
    if count == 0 then
        alertBox("KẾT QUẢ", "Không tìm thấy giá trị " .. currentCoins .. " trong bộ nhớ.")
        return
    end
    
    if count > 100 then
        local p2 = gg.prompt({
            "Tìm thấy " .. count .. " kết quả.\nHãy thay đổi số coin trong game rồi nhập số mới:"
        }, { currentCoins }, { "number" })
        
        if not p2 then return end
        gg.refineNumber(p2[1], gg.TYPE_DWORD)
        count = gg.getResultCount()
    end
    
    if count > 0 and count <= 100 then
        gg.editAll(targetCoins, gg.TYPE_DWORD)
        notify("Thành công! Đã đổi " .. count .. " địa chỉ sang " .. targetCoins)
    else
        alertBox("CẢNH BÁO", "Số lượng kết quả còn lại (" .. count .. ") quá nhiều hoặc bằng 0, không an toàn để ghi đè.")
    end
    gg.clearResults()
end

-- Module 3: Tốc độ di chuyển tùy biến
local function setCustomSpeed()
    local p = gg.prompt({ "Tốc độ di chuyển mong muốn (Gốc = 1.0, Gợi ý = 2.5 - 5.0):" }, { "2.5" }, { "number" })
    if not p then return end
    
    local val = tonumber(p[1]) or 1.0
    gg.clearResults()
    gg.setRanges(gg.REGION_ANONYMOUS)
    gg.searchNumber("1.0F;5.0F:16", gg.TYPE_FLOAT)
    gg.refineNumber("1.0", gg.TYPE_FLOAT)
    
    if gg.getResultCount() > 0 then
        gg.editAll(tostring(val), gg.TYPE_FLOAT)
        notify("Đã áp dụng tốc độ: x" .. val)
    else
        notify("Không tìm thấy cấu trúc Speed!")
    end
    gg.clearResults()
end

-- ----------------------------------------------------------------------------
-- HỆ THỐNG MENU (UI NAVIGATION)
-- ----------------------------------------------------------------------------

-- Sub-Menu: Chiến đấu & Sinh tồn
local function subCombatMenu()
    while true do
        local options = {
            (State.godMode and "🛡️ Bất Tử Máu [ĐANG BẬT]" or "🛡️ Bất Tử Máu [ĐANG TẮT]"),
            "⚡ Tùy chỉnh Tốc độ Di chuyển",
            "⬅️ Quay lại Menu chính"
        }
        local sel = gg.choice(options, nil, SCRIPT_NAME .. " > CHIẾN ĐẤU")
        if not sel or sel == 3 then break end
        
        if sel == 1 then toggleGodMode() end
        if sel == 2 then setCustomSpeed() end
    end
end

-- Sub-Menu: Đa chọn Hack Hàng Loạt (MultiChoice Pattern)
local function subBatchMenu()
    local options = {
        "🗡️ Tăng Tầm Đánh (Range x3)",
        "⏱️ Giảm Hồi Chiêu (No Cooldown)",
        "🏃 Nhảy Cao / Bay (Fly Hack)",
        "❌ Hủy / Đóng"
    }
    local sel = gg.multiChoice(options, nil, SCRIPT_NAME .. " > KÍCH HOẠT NHANH")
    if not sel or sel[4] then return end
    
    if sel[1] then
        gg.setRanges(gg.REGION_ANONYMOUS)
        gg.searchNumber("3.5", gg.TYPE_FLOAT)
        gg.editAll("15.0", gg.TYPE_FLOAT)
        gg.clearResults()
        notify("Đã tăng Tầm Đánh!")
    end
    if sel[2] then
        gg.setRanges(gg.REGION_ANONYMOUS)
        gg.searchNumber("5.0", gg.TYPE_FLOAT)
        gg.editAll("0.0", gg.TYPE_FLOAT)
        gg.clearResults()
        notify("Đã kích hoạt No Cooldown!")
    end
    if sel[3] then
        gg.setRanges(gg.REGION_ANONYMOUS)
        gg.searchNumber("1.5", gg.TYPE_FLOAT)
        gg.editAll("6.0", gg.TYPE_FLOAT)
        gg.clearResults()
        notify("Đã kích hoạt Fly Hack!")
    end
end

-- Menu Chính (Main Menu)
local function mainMenu()
    local options = {
        "⚔️ Menu Chiến Đấu & Sinh Tồn",
        "💰 Hack Tiền / Tiền Tệ Tùy Chỉnh",
        "🚀 Danh Sách Kích Hoạt Nhanh (Đa chọn)",
        "ℹ️ Giới thiệu & Hướng dẫn",
        "❌ Thoát Script"
    }
    
    local sel = gg.choice(options, nil, SCRIPT_NAME .. " v" .. SCRIPT_VERSION)
    if not sel then return end
    
    if sel == 1 then subCombatMenu() end
    if sel == 2 then hackCoinsDynamic() end
    if sel == 3 then subBatchMenu() end
    if sel == 4 then
        alertBox("HƯỚNG DẪN", "1. Chạm vào icon GameGuardian bất cứ lúc nào để gọi lại Menu này.\n2. Nên thực hiện các bước tinh chỉnh số coin sau mỗi lần giao dịch.\n3. Khi tắt tính năng, script sẽ tự động khôi phục dữ liệu gốc.")
    end
    if sel == 5 then
        notify("Tạm biệt! Script đã dừng hoàn toàn.")
        os.exit()
    end
end

-- ----------------------------------------------------------------------------
-- KHỞI TẠO & VÒNG LẶP SỰ KIỆN OVERLAY (EVENT DAEMON)
-- ----------------------------------------------------------------------------
checkTarget()

gg.setVisible(false)
notify("Script sẵn sàng! Hãy chạm vào icon GG trên màn hình để mở Menu.")

local needMenu = 1 -- Mở menu lần đầu tiên khi chạy script

while true do
    -- Kiểm tra nếu người dùng chạm vào icon nổi GameGuardian
    if gg.isVisible(true) then
        needMenu = 1
        gg.setVisible(false) -- Đóng màn hình mặc định của GG
    end
    
    if needMenu == 1 then
        mainMenu()
        needMenu = -1 -- Đóng menu, quay về chế độ lắng nghe ngầm
    end
    
    -- Giữ nhịp độ ổn định, tránh chiếm CPU
    gg.sleep(100)
end
```

---

## 3. Các Lỗi Phổ Biến & Giải Pháp Khắc Phục (Troubleshooting Matrix)

| Hiện tượng lỗi | Nguyên nhân gốc | Cách khắc phục chuẩn |
|---|---|---|
| **Vừa bấm Hủy (Cancel) trên popup thì script bị crash văng ra ngoài** | Truy cập `result[1]` khi biến `result` mang giá trị `nil` (`attempt to index a nil value`). | Luôn thêm: `if not result then return end` ngay sau khi gọi `gg.prompt` hoặc `gg.choice`. |
| **Script chạy làm điện thoại bị đơ, nóng máy hoặc game bị tắt đột ngột (Force Close)** | Vòng lặp `while true` không có hàm nghỉ; hoặc `gg.getResults(100000)` kéo hàng trăm nghìn phần tử vào RAM. | 1. Bắt buộc thêm `gg.sleep(100)` trong mọi vòng lặp.<br>2. Giới hạn `gg.getResults(100)` đến tối đa `gg.getResults(1000)`. |
| **Tìm kiếm không ra kết quả (Count = 0)** | 1. Chọn sai vùng nhớ (`setRanges`). Ví dụ: Game Java nhưng chỉ quét `REGION_ANONYMOUS` thay vì `REGION_JAVA_HEAP`.<br>2. Chọn sai kiểu dữ liệu (`DWORD` thay vì `FLOAT`).<br>3. Kết quả trước chưa xóa (`clearResults`). | 1. Thêm `gg.clearResults()` trước khi search.<br>2. Thử mở rộng vùng nhớ: `REGION_ANONYMOUS \| REGION_C_ALLOC \| REGION_JAVA_HEAP`.<br>3. Thử quét kiểu `gg.TYPE_AUTO`. |
| **Giá trị trong game đổi số một lát rồi bị nhảy ngược về số cũ** | Giá trị chỉ là UI hiển thị trên client, dữ liệu thật nằm trên server hoặc được mã hóa XOR trong RAM; hoặc giá trị bị game engine ghi đè mỗi frame. | 1. Dùng tính năng Đóng băng (`freeze = true`).<br>2. Tìm và sửa hàm logic trong App Code (`REGION_CODE_APP`) thay vì chỉ sửa giá trị biến. |
| **Script bị người khác xem trộm mã nguồn hoặc sửa đổi tên tác giả** | Lưu dưới dạng file text `.lua` thuần không qua bảo vệ. | 1. Dùng kiểm tra tên file: `gg.getFile()`.<br>2. Dùng thuật toán mã hóa Hex/Caesar shift như `#1Gridpunk3v3.lua`.<br>3. Biên dịch sang bytecode: `luac5.2 -s -o Output.lua Input.lua`. |

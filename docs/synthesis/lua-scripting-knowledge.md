# GameGuardian Lua Scripting Comprehensive Knowledge Base
## Cẩm nang Lập trình Script GameGuardian Thực Chiến & Phân Tích Cơ Chế Vận Hành

Tài liệu được tổng hợp và nâng cấp toàn diện dựa trên:
1. Phân tích các dự án mẫu: `gameguardian-lua-script`, `GGLuaTemplate`, `GG-Script-Collection`.
2. Phân tích mã nguồn và dịch ngược thực tế từ các kịch bản thực chiến:
   - `#1Gridpunk3v3.lua` (Gridpunk 3v3 Action Game Mod - 2 tầng mã hóa Hex/Caesar, cơ chế Overlay Hooking, Dynamic Input Range).
   - `AmongCapV1.lua` (Among Us / Action Mod - Lua 5.2 Bytecode, Module Dispatching, Identifier Obfuscation).
   - `script-cau-ca-van-can-vip-by-anya.lua` (Play Together VIP Fishing Script - LuaObfuscator VM, Memory Scanning Automation).
   - `mindustry-rules-helper.lua` (Mindustry Arc Engine - Cầu nối Source Code Java Heap sang GameGuardian Memory Ranges).

---

## 1. Cơ Chế Vận Hành Cốt Lõi Của GameGuardian Script (Runtime Architecture)

Khác với các chương trình Lua thông thường chạy tuần tự từ đầu đến cuối rồi dừng, một GameGuardian Lua Script hoàn chỉnh hoạt động như một **Overlay Daemon / Event-driven Service** chạy song song với game.

### 1.1. Mô Hình "Overlay Icon Listener" Thực Chiến (Vòng Lặp Bắt Sự Kiện)
Đây là kiến trúc chuẩn được sử dụng trong các script thực chiến như `#1Gridpunk3v3.lua`:

```lua
-- Biến cờ điều khiển trạng thái mở Menu
local MENU_ACTIVE = 1

-- Khởi tạo ban đầu
gg.setVisible(false)
gg.toast("Khởi chạy script thành công! Chạm vào icon GameGuardian để mở Menu.")

-- Vòng lặp lắng nghe vô tận
while true do
    -- Kiểm tra nếu người dùng bấm vào icon GG nổi trên màn hình
    if gg.isVisible(true) then
        MENU_ACTIVE = 1
        gg.setVisible(false) -- Ẩn bảng điều khiển gốc của GG để hiện menu tùy biến của script
    end

    -- Khi cờ được kích hoạt, gọi Menu chính
    if MENU_ACTIVE == 1 then
        mainMenu()
        MENU_ACTIVE = -1 -- Đặt lại cờ sau khi người dùng tương tác xong
    end

    -- Giữ nhịp vòng lặp, giải phóng CPU tránh đơ máy hoặc crash GG
    gg.sleep(100)
end
```

**Nguyên lý hoạt động:**
1. Script luôn chạy ngầm trong GameGuardian.
2. `gg.isVisible(true)` trả về `true` khi người chơi chạm vào icon con chó nổi của GameGuardian trên màn hình game.
3. Script ngay lập tức gọi `gg.setVisible(false)` để đóng cửa sổ mặc định của GG, thay vào đó hiển thị menu tương tác Lua (`gg.choice`, `gg.multiChoice` hoặc `gg.prompt`).
4. Sau khi người chơi thực hiện xong một chức năng, menu kết thúc và script quay trở lại vòng lặp `while true` kèm `gg.sleep(100)` để tiết kiệm pin và tránh chiếm dụng 100% CPU thread.

---

## 2. Hệ Thống Giao Diện Người Dùng (UI Framework & Input Handling)

GameGuardian hỗ trợ 4 hình thức tương tác người dùng chính: `gg.alert`, `gg.toast`, `gg.choice`, `gg.multiChoice`, và `gg.prompt`.

### 2.1. Đơn Chọn: `gg.choice(items, default, title)`
Dùng cho Menu điều hướng phân cấp (Main Menu -> Sub Menu).

```lua
local function subMenuSpeed()
    while true do
        local options = {
            "⚡ Tốc độ di chuyển x2",
            "🚀 Tốc độ di chuyển x5",
            "🔄 Khôi phục tốc độ gốc (1.0)",
            "⬅️ Quay lại Menu chính"
        }
        local sel = gg.choice(options, nil, "[ CẤU HÌNH TỐC ĐỘ ]")
        
        -- Xử lý an toàn: Nếu người dùng bấm ra ngoài (Cancel) hoặc chọn nút Quay lại
        if sel == nil or sel == 4 then
            break -- Thoát vòng lặp submenu, quay lại menu trước
        elseif sel == 1 then
            applySpeed(2.0)
        elseif sel == 2 then
            applySpeed(5.0)
        elseif sel == 3 then
            applySpeed(1.0)
        end
    end
end
```

### 2.2. Đa Chọn: `gg.multiChoice(items, defaults, title)`
Mô hình đặc trưng trong `#1Gridpunk3v3.lua`, cho phép người dùng bật/tắt nhiều chức năng cùng lúc trong 1 lần xác nhận:

```lua
local function batchHacksMenu()
    local options = {
        "❥ Vô hạn Đạn (No Reload)",
        "❥ Không Giật (No Recoil)",
        "❥ Nhảy Cao (High Jump)",
        "❥ Bất Tử (God Mode)",
        "❌ Thoát"
    }
    
    -- defaults có thể truyền table boolean hoặc nil
    local sel = gg.multiChoice(options, nil, "Gridpunk 3V3 - Chọn tính năng kích hoạt")
    
    if sel == nil then
        gg.toast("Đã hủy lựa chọn.")
        return
    end

    if sel[5] then return end -- Nút thoát

    -- Xử lý tuần tự từng lựa chọn được đánh dấu
    if sel[1] then setNoReload() end
    if sel[2] then setNoRecoil() end
    if sel[3] then setHighJump() end
    if sel[4] then setGodMode() end
end
```

### 2.3. Hộp Thoại Nhập Liệu Động: `gg.prompt(fields, defaults, types)`
Dùng khi giá trị bộ nhớ thay đổi linh hoạt theo từng người chơi hoặc cần can thiệp thông số tùy ý:

```lua
-- Mẫu nhập 2 trường: Giá trị hiện tại và Giá trị mong muốn
local p = gg.prompt(
    { "Nhập lượng Coin hiện tại:", "Nhập lượng Coin mong muốn:" },
    { "1000", "999999" },
    { "number", "number" }
)

-- BẮT BUỘC kiểm tra nil khi người dùng bấm HỦY (Cancel)
if not p then
    gg.toast("Đã hủy thao tác.")
    return
end

local currentVal = tonumber(p[1])
local targetVal = tonumber(p[2])
```

---

## 3. Bản Đồ Vùng Nhớ (Memory Regions Mapping) & Engine Architecture

Chọn đúng vùng nhớ (`gg.setRanges`) quyết định 90% tốc độ tìm kiếm và sự thành công của script.

| Vùng nhớ trong GG | Ký hiệu API | Ý nghĩa & Ứng dụng thực tế |
|---|---|---|
| **Anonymous** | `gg.REGION_ANONYMOUS` | Bộ nhớ cấp phát động qua `mmap(MAP_ANONYMOUS)`. Chứa hầu hết dữ liệu người chơi, biến số game Unity/Unreal/Native. Đây là vùng phổ biến nhất. |
| **Java Heap** | `gg.REGION_JAVA_HEAP` | Vùng heap của máy ảo Dalvik/ART. Bắt buộc dùng cho game Java thuần (như Mindustry) hoặc biến đối tượng Java Android. |
| **C++ Heap / Alloc** | `gg.REGION_C_ALLOC` | Vùng nhớ `malloc/calloc` của thư viện C/C++. Thường chứa object của game engine C++ (Cocos2d, Unreal Engine). |
| **C++ BSS / Data** | `gg.REGION_C_DATA \| gg.REGION_C_BSS` | Biến toàn cục tĩnh (static variables, global tables). |
| **App Code** | `gg.REGION_CODE_APP` | Mã máy nhị phân (.so, DEX). Dùng khi patch opcode (ARM/ARM64 Assembly NOP patching). |
| **Video** | `gg.REGION_VIDEO` | Bộ nhớ đồ họa/Vulkan/OpenGL textures và buffers. |
| **Bad** | `gg.REGION_BAD` | Vùng nhớ ảo tùy biến hoặc memory ngoài luồng. |

### 3.1. Kết hợp vùng nhớ theo từng Engine
- **Unity (IL2CPP / Mono):**
  ```lua
  gg.setRanges(gg.REGION_ANONYMOUS | gg.REGION_C_ALLOC)
  ```
- **Android Java thuần (Mindustry, LibGDX):**
  ```lua
  gg.setRanges(gg.REGION_ANONYMOUS | gg.REGION_JAVA_HEAP | gg.REGION_C_HEAP)
  ```
- **Unreal Engine / Native Game:**
  ```lua
  gg.setRanges(gg.REGION_ANONYMOUS | gg.REGION_C_ALLOC | gg.REGION_C_DATA)
  ```

---

## 4. Các Chiến Lược Thao Tác Bộ Nhớ Thực Chiến (Memory Manipulation Patterns)

### 4.1. Quét Cụm Giá Trị Liền Kề (Group Search)
Khi giá trị mục tiêu (như Số vàng) dễ bị trùng lặp với hàng triệu giá trị khác trong RAM, hãy quét kèm theo các thuộc tính lân cận của cấu trúc dữ liệu:

```lua
-- Cú pháp: "GiáTrị1;GiáTrị2;GiáTrị3:KhoảngCáchTốiĐaByte"
-- Ví dụ: Tìm cấu trúc Player gồm Máu (100.0F), Giáp (50.0F), Tốc độ (1.5F) nằm cách nhau không quá 32 byte
gg.clearResults()
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("100.0F;50.0F;1.5F:32", gg.TYPE_FLOAT)

-- Lọc riêng trường Máu (100.0F) để chỉnh sửa
gg.refineNumber("100.0", gg.TYPE_FLOAT)
local results = gg.getResults(10)
if #results > 0 then
    gg.editAll("999999.0", gg.TYPE_FLOAT)
    gg.toast("Đã kích hoạt Bất Tử Máu!")
else
    gg.toast("Không tìm thấy cấu trúc nhân vật!")
end
gg.clearResults()
```

### 4.2. Quét Tinh Chỉnh Qua Nhiều Bước (Search -> Refine -> Edit)
Áp dụng khi người chơi có thể thay đổi số lượng trong game (tiêu tiền, bắn bớt đạn):

```lua
function hackCoinRefineFlow()
    local p1 = gg.prompt({"Nhập số Coin ban đầu:"}, {"100"}, {"number"})
    if not p1 then return end
    
    gg.clearResults()
    gg.setRanges(gg.REGION_ANONYMOUS)
    gg.searchNumber(p1[1], gg.TYPE_DWORD)
    
    local count = gg.getResultCount()
    gg.alert("Đã tìm thấy " .. count .. " kết quả.\n\nHãy vào game, tiêu bớt hoặc kiếm thêm coin, sau đó nhấn OK để tiếp tục lọc.")
    
    local p2 = gg.prompt({"Nhập số Coin mới sau khi thay đổi:"}, {p1[1]}, {"number"})
    if not p2 then return end
    
    gg.refineNumber(p2[1], gg.TYPE_DWORD)
    local refinedCount = gg.getResultCount()
    
    if refinedCount > 0 and refinedCount <= 50 then
        local p3 = gg.prompt({"Nhập số Coin bạn muốn đạt được:"}, {"999999"}, {"number"})
        if p3 then
            gg.editAll(p3[1], gg.TYPE_DWORD)
            gg.toast("Hack Coin thành công!")
        end
    else
        gg.alert("Số lượng kết quả còn lại: " .. refinedCount .. ".\nChưa đủ hẹp để ghi đè an toàn, hãy thử lại.")
    end
    gg.clearResults()
end
```

### 4.3. Cơ Chế Toggle Bật/Tắt Khôi Phục Bộ Nhớ Gốc (Safe Restore)
Để tránh làm hỏng game khi tắt tính năng, script cần lưu lại bản sao giá trị gốc trước khi ghi đè:

```lua
local toggle_FlyHack = false
local backup_FlyHack = nil

function toggleFlyHack()
    if toggle_FlyHack then
        -- TẮT TÍNH NĂNG: Khôi phục lại chính xác các giá trị cũ
        if backup_FlyHack and #backup_FlyHack > 0 then
            gg.setValues(backup_FlyHack)
            gg.toast("Tắt Fly Hack - Đã khôi phục trạng thái ban đầu!")
        else
            gg.toast("Không có dữ liệu khôi phục!")
        end
        toggle_FlyHack = false
    else
        -- BẬT TÍNH NĂNG: Tìm kiếm, sao lưu rồi mới ghi đè
        gg.clearResults()
        gg.setRanges(gg.REGION_ANONYMOUS)
        gg.searchNumber("4.5", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1)
        
        local count = gg.getResultCount()
        if count > 0 then
            -- Lưu bản sao giá trị gốc trước khi edit
            backup_FlyHack = gg.getResults(count)
            gg.editAll("21.0", gg.TYPE_FLOAT)
            toggle_FlyHack = true
            gg.toast("Bật Fly Hack thành công! (x4.5 -> x21.0)")
        else
            gg.alert("Không tìm thấy giá trị trọng lực bay!")
        end
        gg.clearResults()
    end
end
```

### 4.4. Đóng Băng Giá Trị (Value Freezing)
Khóa cứng giá trị để game không thể trừ đạn hoặc máu:

```lua
local results = gg.getResults(5)
for i, item in ipairs(results) do
    item.value = "999"
    item.freeze = true
    item.freezeType = gg.FREEZE_NORMAL -- hoặc gg.FREEZE_MAY_INCREASE, gg.FREEZE_MAY_DECREASE
end
gg.addListItems(results) -- Đưa vào danh sách Giữ giá trị (Saved List)
gg.toast("Đã khóa giá trị vĩnh viễn!")
```

---

## 5. Cơ Chế Bảo Vệ, Mã Hóa & Chống Dịch Ngược (Script Security & Obfuscation)

Từ việc mổ xẻ `#1Gridpunk3v3.lua`, `AmongCapV1.lua` và script VIP của Anya, chúng ta thấy các modder chuyên nghiệp áp dụng 4 lớp bảo vệ:

### 5.1. Lớp 1: Khóa Tên File & Khóa Phiên Bản Game
Ngăn chặn người khác đổi tên script hoặc chạy trên bản game không tương thích:

```lua
local function verifyIntegrity()
    -- 1. Kiểm tra tên file script
    local currentFile = gg.getFile():match("[^/\\]+$")
    if currentFile ~= "ExpectedScriptName.lua" then
        gg.alert("Cảnh báo vi phạm bản quyền: Vui lòng không đổi tên script gốc!")
        os.exit()
    end

    -- 2. Kiểm tra package và version của game
    local info = gg.getTargetInfo()
    if not info or info.packageName ~= "com.target.game" then
        gg.alert("Tiến trình mục tiêu không chính xác!\nVui lòng chọn game đúng trước khi chạy.")
        os.exit()
    end
end
```

### 5.2. Lớp 2: Mã Hóa Hex + Dịch Chuyển Byte (Caesar Shift Cipher) & Khóa Mật Khẩu
Phương pháp giải mã động được phát hiện trong `#1Gridpunk3v3.lua`:

```lua
-- Hàm giải mã runtime bằng key mật khẩu
function decodePayload(key, hexStr)
    return (hexStr:gsub('..', function(h)
        -- Thuật toán xoay vòng byte với password key
        local byteVal = tonumber(h, 16)
        local origByte = (byteVal + 256 - 13 - key) % 256
        return string.char(origByte)
    end))
end

-- Yêu cầu nhập mật khẩu bảo vệ
local passInput = gg.prompt({"Nhập mã PIN kích hoạt:"}, {"0"}, {"number"})
if not passInput then os.exit() end

local key = tonumber(passInput[1])
local payloadHex = "FE5A696257685D..." -- Chuỗi hex đã mã hóa

-- Giải mã và thực thi an toàn bằng pcall
local ok, err = pcall(function()
    local luaCode = decodePayload(key, payloadHex)
    local loadedFunc = assert(load(luaCode) or loadstring(luaCode))
    loadedFunc()
end)

if not ok then
    gg.alert("Sai mã PIN hoặc kịch bản đã bị sửa đổi trái phép!")
    os.exit()
end
```

### 5.3. Lớp 3: Biên Dịch Sang Lua Bytecode Chuẩn (Lua 5.2 Luac)
Như trong `AmongCapV1.lua` (`\027LuaR...`), mã nguồn Lua được biên dịch bằng trình biên dịch chuẩn `luac -s` (strip debug symbols) thành bytecode nhị phân để ẩn mã nguồn gốc mà GameGuardian vẫn nạp trực tiếp được.

### 5.4. Lớp 4: Máy Ảo Hóa (Lua Virtual Machine Obfuscation)
Như trong `script-cau-ca-van-can-vip-by-anya.lua`, toàn bộ code logic được chuyển thành một bảng bytecode tùy biến và chạy qua một mini VM runtime. Đây là cấp độ bảo vệ chống crack cao nhất hiện nay.

---

## 6. Quy Tắc Lập Trình An Toàn & Chống Crash (Defensive Programming)

1. **Luôn kiểm tra `nil` khi nhận kết quả từ `gg.prompt` hoặc `gg.choice`:**
   Người dùng có thể nhấn phím Back trên điện thoại hoặc bấm nút Hủy. Nếu không kiểm tra `if not res then return end`, câu lệnh `res[1]` sẽ gây lỗi nghiêm trọng `attempt to index a nil value`.
2. **Luôn kiểm tra số lượng kết quả trước khi `gg.editAll`:**
   Nếu tìm kiếm ra 0 kết quả (`gg.getResultCount() == 0`), không được gọi `editAll` vì có thể gây crash hoặc thông báo lỗi khó chịu.
3. **Giới hạn số lượng kết quả lấy về `gg.getResults(maxCount)`:**
   Chỉ lấy từ 10 đến 500 kết quả thay vì lấy 100,000 kết quả. Lấy quá nhiều kết quả vào RAM sẽ khiến điện thoại bị đơ (Out Of Memory).
4. **Luôn có `gg.clearResults()` trước khi bắt đầu tìm kiếm mới:**
   Tránh trường hợp lệnh tìm kiếm tiếp theo vô tình trở thành lệnh `refine` trên tập kết quả cũ.
5. **Thêm `gg.sleep()` vào các vòng lặp polling:**
   Bất kỳ vòng lặp `while` nào cũng bắt buộc có `gg.sleep(50)` đến `gg.sleep(200)` để hệ điều hành Android thực hiện context switch, không bị Watchdog Killer tắt app.

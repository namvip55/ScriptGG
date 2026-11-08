# Phân tích Tính năng: Tốc độ Trận đấu (Battle Speed / TimeScale)
**Game ID:** `mbc`  
**Trạng thái bằng chứng:** `SOURCE_CONFIRMED`  

---

## 1. Mô tả Tính năng

Trong Manga Bá Cháy, các trận đấu thường kéo dài do các hoạt ảnh thi triển kỹ năng và đánh thường. Trò chơi cung cấp tính năng thay đổi tốc độ thông qua nút tốc độ trên màn hình trận đấu:
- Cấp độ 1: Tốc độ chuẩn (1.2x)
- Cấp độ 2: Tốc độ nhanh (1.7x)
- Cấp độ 3: Tốc độ cực nhanh (2.0x) - Bị giới hạn cấp độ người chơi hoặc VIP (`battle_speed_limit`).

---

## 2. Dẫn chứng Mã Nguồn

### 2.1. Cấu hình Tốc độ
Tại [battleScene.lua](file:///d:/project/GameGuardian/srcgame/mbc/decompiled_lua/scripts/battleScene.lua#L129):
```lua
speedconfig = {1.2, 1.7, 2},
```

### 2.2. Hàm Áp dụng Tốc độ và Kiểm tra Điều kiện VIP/Level
Tại [battleScene.lua](file:///d:/project/GameGuardian/srcgame/mbc/decompiled_lua/scripts/battleScene.lua#L1589-L1625):
```lua
function battleScene.setSpeed(self, step, isresave)
    if step == 3 then
        local openvip = ui.getVipLevelByStr("speed3")
        if GameScene and GameScene.roleinfo and GameScene.roleinfo.level then
            if GameScene.roleinfo.level < tonumber(gamedata.config.global_kv.battle_speed_limit.value) then
                if self.hasshow then
                    step = 1
                    self.hasshow = false
                else
                    runGamePrompt({msg = gamedata.config.global_kv.battle_speed_limit.value..gameConfig.strings:string_common("battleScene",10)})
                    self.hasshow = true
                    return
                end
            end
        else
            runGamePrompt({msg = gameConfig.strings:string_common("battleScene",26)})
            return
        end
    end

    self.speedstep = step
    if self.speedstep > 3 then self.speedstep = 1 end
    if isresave then self.savedSpeed = self.speedstep end

    CCDirector:sharedDirector():getScheduler():setTimeScale(self.speedconfig[self.speedstep])

    local animationManager = getAnimationManager(self.speeditem)
    animationManager:runAnimationsForSequenceNamed("speedbutton_"..self.speedstep)
end
```

---

## 3. Phân tích Bộ nhớ & Ánh xạ GameGuardian

### 3.1. Đối tượng Native C++ `Scheduler` trong Cocos2d-x
Khi gọi `CCDirector:sharedDirector():getScheduler():setTimeScale(float)`, Cocos2d-x ghi trực tiếp giá trị vào trường `_timeScale`:
- Kiểu dữ liệu trong C++: `float` (IEEE 754 đơn chính xác, 4 bytes)
- Kiểu dữ liệu GameGuardian: `gg.TYPE_FLOAT`
- Vùng nhớ lưu trữ: `gg.REGION_ANONYMOUS` hoặc `gg.REGION_C_ALLOC`
- Giá trị mặc định khi vào trận: `1.2` (hoặc `1.7` khi chuyển tốc độ 2, `2.0` khi chuyển tốc độ 3, và `1.0` khi ở màn hình chính).

### 3.2. Cấu trúc Bảng Cấu hình Lua `speedconfig`
Trong Lua state của game, `self.speedconfig` là một table chứa 3 phần tử số thực: `{1.2, 1.7, 2.0}`:
- Kiểu dữ liệu số trong Lua 5.1/LuaJIT (TValue): `double` (8 bytes, `gg.TYPE_DOUBLE`)
- Vùng nhớ: `gg.REGION_ANONYMOUS` (Lua Heap)

---

## 4. Chiến lược Quét & Hack trên GameGuardian

### Phương pháp 1: Quét và Đóng băng `_timeScale` của Cocos2d-x (Khuyến nghị cao)
1. Bắt đầu trận chiến (đang ở tốc độ x1 mặc định).
2. Thiết lập phạm vi tìm kiếm GameGuardian:
   ```lua
   gg.setRanges(gg.REGION_ANONYMOUS | gg.REGION_C_ALLOC)
   ```
3. Tìm kiếm giá trị float:
   ```lua
   gg.searchNumber("1.2", gg.TYPE_FLOAT)
   ```
4. Bấm nút tốc độ trong game để chuyển sang tốc độ x2 (1.7x).
5. Tinh chỉnh giá trị:
   ```lua
   gg.refineNumber("1.7", gg.TYPE_FLOAT)
   ```
6. (Tùy chọn) Bấm sang tốc độ x3 (2.0x nếu đã mở khóa) hoặc bấm về x1 (1.2x) để lọc còn 1-3 địa chỉ duy nhất.
7. Đổi giá trị thành `5.0`, `10.0` hoặc `20.0` và kích hoạt Đóng băng (Freeze). Trận đấu sẽ chạy với tốc độ siêu tốc, kết thúc chỉ trong vài giây.

### Phương pháp 2: Group Search Lua `speedconfig`
Quét nhóm 3 giá trị float/double liền kề:
```text
1.2;1.7;2.0:16
```
Sửa mảng này thành:
```text
10.0;20.0;50.0
```
Mỗi khi người chơi nhấn nút tốc độ trong game, game sẽ tự động áp dụng tốc độ siêu tốc mà không bị crash.

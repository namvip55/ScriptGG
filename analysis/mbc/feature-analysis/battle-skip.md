# Phân tích Tính năng: Bỏ qua Trận đấu (Battle Skip / Instant Finish)
**Game ID:** `mbc`  
**Trạng thái bằng chứng:** `SOURCE_CONFIRMED`  

---

## 1. Mô tả Tính năng

Manga Bá Cháy hỗ trợ tính năng "Bỏ qua" (`tiaoguo` / Skip) trong các trận đấu để người chơi không phải chờ hoạt ảnh kết thúc. Tuy nhiên, ở các ải mới, tài khoản cấp thấp hoặc chế độ đặc biệt, nút Bỏ qua (`endButton`) thường bị:
- Khóa (`setEnabled(false)`)
- Làm mờ xám (`ui.addGray("CCControlButton", self.bgcontrolitem.endButton)`)
- Bắt buộc chờ qua một số hiệp đấu nhất định (ví dụ sau hiệp 2 hoặc hiệp 3 mới mở nút).

Mục tiêu hack: Mở khóa ngay lập tức nút Bỏ qua từ giây đầu tiên của trận đấu để hoàn tất ải ngay lập tức.

---

## 2. Dẫn chứng Mã Nguồn

### 2.1. Logic Thực thi Bỏ qua Trận đấu
Tại [battleScene.lua](file:///d:/project/GameGuardian/srcgame/mbc/decompiled_lua/scripts/battleScene.lua#L2936-L2967):
```lua
function battleScene.endfunction(self)
    if self.isend then return end

    self.shakeanimationNode:stopAllActions()
    self.animationNode:stopAllActions()
    self.rootNode:stopAllActions()

    self.bgitem.backeffect:removeAllChildrenWithCleanup(true)
    self.bgitem.fronteffect:removeAllChildrenWithCleanup(true)
    self.bgitem.commonnode:removeAllChildrenWithCleanup(true)

    for k,v in pairs(self["atk"].general) do
        v:stopAllEffect()
    end
    for k,v in pairs(self["def"].general) do
        v:stopAllEffect()
    end

    local ccb, item = CCBReaderLoad("backGround/tiaoguo", nil, true, "tiaoguo")
    ccb:setPosition(0,0)
    self.bgcontrolitem.tiaoguonode:addChild(ccb,1999)
    local animationManager = getAnimationManager(item)
    animationManager:setAnimationCompletedCallback(function()
        ccb:removeFromParentAndCleanup(true)
    end)
    animationManager:runAnimationsForSequenceNamed("tiaoguo")
    self:shake("shake_tiaoguo")

    self.isend = true
    self:showResult()
    self.bgcontrolitem.endButton:setEnabled(false)
end
```

### 2.2. Kiểm soát Trạng thái Nút Bỏ qua
Tại [battleScene.lua](file:///d:/project/GameGuardian/srcgame/mbc/decompiled_lua/scripts/battleScene.lua#L1908-L1910):
Khi trận đấu bắt đầu, game thiết lập:
```lua
self.bgcontrolitem.endButton:setEnabled(false)
ui.addGray("CCControlButton", self.bgcontrolitem.endButton)
```
Và chỉ mở lại khi đạt điều kiện:
```lua
self.bgcontrolitem.endButton:setEnabled(true)
ui.removeGray("CCControlButton", self.bgcontrolitem.endButton)
```

---

## 3. Phân tích Bộ nhớ & Ánh xạ GameGuardian

### 3.1. Đối tượng `CCControlButton` (Cocos2d-x C++)
Trường `m_bEnabled` trong class `CCControl` (kế thừa từ `CCNode`):
- Kiểu dữ liệu trong C++: `bool` (1 byte, giá trị `0` = disabled, `1` = enabled)
- Kiểu dữ liệu GameGuardian: `gg.TYPE_BYTE`
- Vùng nhớ lưu trữ: `gg.REGION_ANONYMOUS` hoặc `gg.REGION_C_ALLOC`

### 3.2. Cờ Trạng thái Trận đấu `self.isend`
- Trong Lua state: kiểu `boolean` (false = đang đánh, true = đã kết thúc).

---

## 4. Chiến lược Quét & Can thiệp trên GameGuardian

1. **Cách 1: Sử dụng chung với TimeScale x50/x100 (Khuyến nghị thực tiễn)**
   - Vì trận đấu kết thúc thông qua `self:showResult()`, nếu tăng `timeScale` lên 50.0 hoặc 100.0, toàn bộ animation sẽ chạy hết chỉ trong chưa đầy 1 giây, đưa người chơi thẳng đến màn hình kết quả tương đương với tính năng Bỏ qua mà hoàn toàn an toàn, không lo lỗi logic UI.
2. **Cách 2: Quét địa chỉ `CCControlButton` của `endButton`**
   - Quét trạng thái boolean `0` (Disabled) của nút khi mới vào trận.
   - Khi sang hiệp 2 hoặc ải cho phép bỏ qua, nút bật sang `1` (Enabled) -> lọc refine `1`.
   - Lưu địa chỉ và đóng băng thành `1` để nút luôn bấm được ngay từ giây đầu tiên.

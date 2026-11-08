# SKILL: FINALSCRIPT
# Hoàn Thiện GameGuardian Lua Script Tự Động Hóa 100% (Production Release)

## 1. Vai trò

Bạn là Agent chuyên chuyển đổi các script thử nghiệm (`GENSCRIPT`) thành **Final Script (Bản Phát Hành Chính Thức)** với khả năng **tự động hóa 100%** việc dò tìm, lọc và can thiệp bộ nhớ RAM mà không cần người dùng phải thao tác quét thủ công.

Sự chuyển đổi này dựa trên **Bằng Chứng Kiểm Chứng Runtime (Runtime Evidence)** được người dùng thu thập thực tế từ GameGuardian.

---

## 2. Đường dẫn dự án cố định

- Báo cáo Runtime Evidence: `D:\project\GameGuardian\analysis\<game_id>\runtime-validation.md`
- Script thử nghiệm: `D:\project\GameGuardian\gameguardian-lua-script\script\<game_id>\<script-name>.lua`
- Script Final hoàn thiện: `D:\project\GameGuardian\gameguardian-lua-script\script\<game_id>\<script-name>-final.lua`

---

## 3. Tiêu Chí Của Một Final Script (100% Automation Standards)

1. **Loại bỏ hoàn toàn các bước quét thủ công:** Thay thế các hộp thoại yêu cầu người dùng nhập giá trị ban đầu / tiêu bớt tiền bằng **Cụm Quét Nhóm Cố Định (Group Search)** hoặc **Quét Giá Trị Đặc Trưng Đã Xác Minh**.
2. **Kích hoạt 1-Chạm (One-Click Activation):** Người chơi chỉ cần nhấn vào menu, script tự động:
   - Đặt đúng vùng nhớ (`gg.setRanges`).
   - Xóa kết quả cũ (`gg.clearResults()`).
   - Quét mẫu chữ ký bộ nhớ (`gg.searchNumber(...)`).
   - Lọc chính xác trường mục tiêu (`gg.refineNumber(...)`).
   - Kiểm tra số lượng kết quả (`gg.getResultCount() > 0`).
   - Ghi đè giá trị hacked (`gg.editAll(...)`).
   - Dọn dẹp bộ nhớ tạm và phát Toast thông báo thành công.
3. **Giữ nguyên kiến trúc chạy ngầm Event-Driven:**
   Bắt buộc duy trì vòng lặp lắng nghe `gg.isVisible(true)` để người chơi có thể bật/tắt hoặc gọi lại menu bất cứ lúc nào trong trận đấu.
4. **Tùy chọn Đóng gói & Bảo mật Thực Chiến:**
   Nếu người dùng yêu cầu bảo vệ bản quyền kịch bản, áp dụng mô hình mã hóa 2 tầng Hex/Caesar như phát hiện trong `#1Gridpunk3v3.lua` hoặc hướng dẫn biên dịch bytecode `luac -s`.

---

## 4. Mẫu Chuyển Đổi Từ Script Thử Nghiệm Sang Final Script

### Trước (GENSCRIPT - Thử nghiệm):
```lua
-- Người dùng phải tự nhập giá trị và tự lọc nhiều lần
local p = gg.prompt({"Nhập số coin hiện tại:"})
gg.searchNumber(p[1], gg.TYPE_DWORD)
-- ... chờ người dùng tiêu coin rồi nhập lại ...
```

### Sau (FINALSCRIPT - Tự động hóa 100%):
```lua
-- Đã xác minh qua Runtime Evidence: Cụm tài nguyên gồm Vàng và Kim Cương cách nhau 16 bytes
local function hackCoinsAuto()
    gg.clearResults()
    gg.setRanges(gg.REGION_ANONYMOUS)
    
    -- Cú pháp Group Search đặc trưng của Game
    gg.searchNumber("1000D;50D:16", gg.TYPE_DWORD)
    gg.refineNumber("1000", gg.TYPE_DWORD)
    
    local count = gg.getResultCount()
    if count > 0 then
        gg.editAll("999999", gg.TYPE_DWORD)
        gg.toast("✅ Đã hack 999,999 Coins thành công!")
    else
        gg.alert("⚠️ Không tìm thấy cấu trúc Coin! Hãy đảm bảo bạn đang ở màn hình Cửa hàng.")
    end
    gg.clearResults()
end
```

---

## 5. Quy Trình Thực Hiện Của Agent

1. **Bước 1 — Tiếp Nhận Runtime Evidence:**
   Đọc nội dung log bằng chứng do người dùng gửi hoặc trích xuất từ `analysis/<game_id>/runtime-validation.md`.
2. **Bước 2 — Phân Tích Chữ Ký Bộ Nhớ (Memory Signature):**
   Xác định vùng nhớ chuẩn (`REGION_*`), kiểu biến (`TYPE_*`), và cấu trúc group search hoặc khoảng cách offset.
3. **Bước 3 — Nâng Cấp Logic Script:**
   Thay thế các function dạng `prompt` bằng function tự động hóa 1-click. Cập nhật nhãn Menu từ `[Thử nghiệm]` sang `[Tự động]`.
4. **Bước 4 — Bổ Sung Bảo Vệ (Nếu cần):**
   Thêm kiểm tra phiên bản game (`gg.getTargetInfo()`) và tên file script (`gg.getFile()`).
5. **Bước 5 — Xuất Bản & Bàn Giao:**
   Lưu file vào `D:\project\GameGuardian\gameguardian-lua-script\script\<game_id>\<script-name>-final.lua`.

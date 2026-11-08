# SKILL: REBUILDSCRIPT
# Phân tích Lỗi, Sửa Chữa & Nâng Cấp GameGuardian Lua Script Đa Game

## 1. Vai trò

Bạn là Agent chuyên tiếp nhận lỗi, phân tích nguyên nhân gốc rễ (Root Cause Analysis) và tái cấu trúc (Rebuild) GameGuardian Lua Script.

Skill này áp dụng cho **NHIỀU GAME & ĐA NỀN TẢNG**, kết hợp kiến thức từ:
- Báo cáo lỗi của người dùng (ảnh chụp màn hình, text log, hành vi bất thường).
- Mã nguồn script hiện tại.
- Báo cáo phân tích source từ `CRAWLDATA`.
- Cẩm nang thực chiến GameGuardian tại `docs/synthesis/lua-scripting-knowledge-synthesis.md`.

---

## 2. Danh Mục Các Lỗi Thực Tế & Cách Khắc Phục Triệt Để

### 2.1. Lỗi Lua: `attempt to index a nil value` (Phổ biến nhất)
- **Hiện tượng:** Người chơi vừa bấm nút Hủy (Cancel), bấm phím Back trên điện thoại, hoặc chạm ra ngoài hộp thoại thì script bị crash văng lập tức.
- **Nguyên nhân:** Khi người dùng hủy, các hàm `gg.prompt`, `gg.choice`, `gg.multiChoice` trả về `nil`. Câu lệnh truy xuất `res[1]` cố gắng index vào một giá trị `nil`.
- **Cách sửa chuẩn:**
  ```lua
  -- SAI:
  local p = gg.prompt({"Nhập số tiền:"})
  gg.searchNumber(p[1], gg.TYPE_DWORD)

  -- ĐÚNG:
  local p = gg.prompt({"Nhập số tiền:"})
  if not p then
      gg.toast("Đã hủy thao tác.")
      return
  end
  gg.searchNumber(p[1], gg.TYPE_DWORD)
  ```

### 2.2. Lỗi Hệ Thống: Treo Máy, Nóng Máy, Ứng Dụng Bị Buộc Đóng (ANR / Crash)
- **Hiện tượng:** Điện thoại bị đơ cứng, màn hình đen hoặc GameGuardian tự động biến mất sau vài giây chạy script.
- **Nguyên nhân:**
  1. Vòng lặp `while true` không có thời gian nghỉ, chiếm dụng 100% tài nguyên CPU.
  2. Gọi `gg.getResults(100000)` kéo hàng trăm nghìn phần tử vào bộ nhớ RAM của Lua khiến máy ảo bị Out-Of-Memory.
- **Cách sửa chuẩn:**
  1. Luôn thêm `gg.sleep(100)` vào vòng lặp `while true`.
  2. Giới hạn `gg.getResults(100)` đến tối đa `gg.getResults(500)`.

### 2.3. Lỗi Bộ Nhớ: Tìm Thấy 0 Kết Quả (Count = 0)
- **Hiện tượng:** Dù nhập đúng số tiền/chỉ số đang hiện trên màn hình nhưng GG luôn báo 0 kết quả.
- **Nguyên nhân:**
  1. Chọn sai vùng nhớ (`gg.setRanges`): Game chạy trên Java Heap (như Mindustry) nhưng chỉ quét vùng Anonymous; hoặc ngược lại.
  2. Chọn sai kiểu dữ liệu: Giá trị thực tế là `TYPE_FLOAT` nhưng lại quét `TYPE_DWORD`.
  3. Quên gọi `gg.clearResults()` trước khi search, khiến lệnh tìm kiếm mới bị hiểu nhầm là lệnh refine trên tập kết quả cũ.
- **Cách sửa chuẩn:**
  ```lua
  gg.clearResults()
  -- Mở rộng vùng nhớ bao phủ cả Java Heap và Anonymous nếu chưa chắc chắn:
  gg.setRanges(gg.REGION_ANONYMOUS | gg.REGION_JAVA_HEAP | gg.REGION_C_ALLOC)
  gg.searchNumber(val, gg.TYPE_AUTO) -- Hoặc TYPE_FLOAT nếu là chỉ số thập phân
  ```

### 2.4. Lỗi Logic Toggle: Bật Được Nhưng Khi Tắt Không Khôi Phục Hoặc Gây Lỗi Game
- **Hiện tượng:** Bật tính năng thành công, nhưng khi tắt thì nhân vật biến mất, game bị lỗi logic hoặc chỉ số bị nhảy loạn.
- **Nguyên nhân:** Khi bật, script không lưu lại bản sao giá trị bộ nhớ ban đầu; hoặc ghi đè một giá trị ngẫu nhiên khi tắt.
- **Cách sửa chuẩn:**
  Lưu mảng kết quả gốc bằng `backup = gg.getResults(count)` TRƯỚC KHI gọi `gg.editAll`, và khôi phục bằng `gg.setValues(backup)` khi tắt.

---

## 3. Quy Trình Tiếp Nhận & Sửa Lỗi

1. **Bước 1 — Xác định Game & File Script:** Định vị đúng `D:\project\GameGuardian\gameguardian-lua-script\script\<game_id>\<file_name>.lua`.
2. **Bước 2 — Định vị Dòng Lỗi & Ngữ Cảnh:**
   - Đọc kỹ dòng code bị báo lỗi và 15 dòng xung quanh.
   - Kiểm tra các biến đầu vào, giá trị `nil`, scope của biến (`local` vs global).
3. **Bước 3 — Sửa Mã Nguồn & Tái Cấu Trúc:**
   - Áp dụng các giải pháp phòng vệ (nil check, sleep, clearResults, setValues).
   - Đảm bảo giữ nguyên kiến trúc Event-Driven Overlay Listener (`gg.isVisible(true)`).
4. **Bước 4 — Bàn Giao:**
   - Cung cấp file script đã sửa hoàn chỉnh.
   - Giải thích rõ nguyên nhân gây lỗi và những điểm đã được cải tiến để tránh lặp lại.

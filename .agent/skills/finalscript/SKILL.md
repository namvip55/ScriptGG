# SKILL: FINALSCRIPT
  # Chốt và hoàn thiện GameGuardian Lua Script tự động hóa 100% dựa trên Runtime Evidence

  ## 1. Vai trò

  Bạn là Agent chuyên chuyển đổi các script thử nghiệm (kết quả Test Runtime) thành **GameGuardian Lua Script hoàn chỉnh (Final
  Script)**
  có khả năng tự động hóa 100% việc quét, lọc và chỉnh sửa bộ nhớ RAM dựa trên bằng chứng
  kiểm thử thực tế (Runtime Evidence) do người dùng cung cấp.

  Skill này sử dụng cho NHIỀU GAME, kết hợp:
  - Hồ sơ phân tích source từ `CRAWLDATA` (`SOURCE_CONFIRMED`).
  - Khung script giao diện từ `GENSCRIPT`.
  - Bằng chứng kiểm chứng runtime do người dùng thu thập/xuất ra từ GG (`RUNTIME_CONFIRMED`).
  - Quy chuẩn giao diện đẹp mắt, có màu sắc BBCode từ `docs/synthesis/lua-scripting-knowledge-synthesis.md`.

  ## 2. Đường dẫn dự án cố định

  - Source game: `D:\project\GameGuardian\srcgame`
  - Phân tích source & Runtime Evidence: `D:\project\GameGuardian\analysis`
  - Script đầu ra: `D:\project\GameGuardian\gameguardian-lua-script\script`

  ### 2.1. Phân tách theo game

  `D:\project\GameGuardian\gameguardian-lua-script\script\<game_id>\`
  `D:\project\GameGuardian\analysis\<game_id>\runtime-validation.md`

  ## 3. Đầu vào bắt buộc

  1. **`game_id`** và tên game.
  2. **Khung Script Lua hiện tại** (đã sinh từ `GENSCRIPT`).
  3. **Bằng chứng Runtime Evidence** (copy từ hộp thoại Alert của GENSCRIPT):
     - Game Package & Version
     - Kiểu tính năng kiểm thử
     - Vùng nhớ tùy chỉnh (`TYPE_DWORD`, `TYPE_FLOAT`, ...)
     - Giá trị tìm kiếm ban đầu → Refine → Địa chỉ → Số kết quả
     - Giá trị trước / sau chỉnh sửa
  4. Tài liệu tham khảo UI & API trong `docs/synthesis/`.

  ## 4. Quy trình thực hiện

  ### Bước 1 — Tiếp nhận & Phân tích Bằng chứng Runtime
  - Đọc cấu trúc chuỗi `RUNTIME_LOG` do `GENSCRIPT` xuất ra.
  - Kiểm tra vùng nhớ, kiểu dữ liệu, số kết quả, địa chỉ thực tế đã đủ tin cậy chưa.
  - Cập nhật nhật ký vào `analysis\<game_id>\runtime-validation.md`.

  ### Bước 2 — Chuyển đổi sang tự động hóa 100%
  - Thay thế theo mẫu từng tính năng:
    1. `gg.setRanges(<DIỄN ĐỐT NHỊ LỐ> / ADDRESS)` — thiết lập đúng vùng nhớ.
    2. `gg.clearResults()` — dọn dẹp.
    3. `gg.searchNumber(<GIÁ TRỮ> / TYPE)` — tự động tìm kiếm.
    4. `gg.editAll(<NEWVALUE> / TYPE)` — tự động sửa.
    5. Xử lý nil số lượng cho safety.
    6. `gg.clearResults()` — dọn dẹp cuối.

  ### Bước 3 — Áp dụng quy chuẩn UI đẹp mắt
  - Kế thừa quy chuẩn từ GENSCRIPT: BBCode màu sắc, Icon đồng bộ, Banner khung,
    Progress bar, 100% Tiếng Việt.
  - Đổi `[color=#FFD700]⚠️  CHỜ RUNTIME[/color]` → `[color=#00E676]● [ON][/color]`.

  ### Bước 4 — Kiểm tra an toàn
  - Kiểm tra nil số liệu `gg.getResultCount()` trướ khi sửa.
  - Báo lỗi bằng hộp thoại màu RED và ngừng script, không văng mất dữ liệu.

  ### Bước 5 — Xuất file
  - Lưu: `D:\project\GameGuardian\gameguardian-lua-script\script\<game_id>\<name>-final.lua`
  - Báo cáo chi tiết runtime đã chốt + hướng dẫn chạy.

  ## 5. Nguyên tắc

  Final script chứa 100% logic auto; không có placeholder, không giá trị phỏng đoán.
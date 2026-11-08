# Hồ sơ Phân tích Kỹ thuật Game: Manga Bá Cháy (MBC)
**Game ID:** `mbc`  
**Package Name:** `vn.vgp.manga.ba.chay`  
**Publisher:** VGP (Vietnam Game Publisher)  
**Engine:** Cocos2d-x (Lua runtime - `libcocos2dlua.so`)  
**Nền tảng:** Android (ARM64-v8a / ARMeabi-v7a)  

---

## 1. Tổng quan Dự án

Hồ sơ này ghi nhận toàn bộ kết quả phân tích cấu trúc mã nguồn, cơ chế mã hóa script, kiến trúc game, giao thức mạng và các trường bộ nhớ phục vụ công tác phát triển GameGuardian Lua Script.

### Thành tựu phân tích kỹ thuật:
1. **Giải mã toàn bộ mã nguồn Lua (1.112 tệp):**
   - Đã bẻ khóa cơ chế bảo vệ XXTEA của game.
   - Trích xuất chìa khóa giải mã từ binary `libcocos2dlua.so`: Key = `3c883f7813a3ee68`.
   - Toàn bộ 1.112 file Lua plain-text đã được giải mã và lưu trữ tại `D:\project\GameGuardian\srcgame\mbc\decompiled_lua\`.
2. **Khảo sát kiến trúc Client/Server:**
   - Trận đấu là mô hình Turn-based Card RPG. Kết quả trận đấu (`battlereport`, `battleresult`) được tính toán trên Server và truyền về Client qua Google Protobuf.
   - Client đảm nhiệm hiển thị animation, playback và các điều khiển trực quan (Tốc độ trận đấu, Nút bỏ qua animation, UI HUD).
3. **Tiềm năng khai thác GameGuardian:**
   - **Hack Tốc độ trận đấu (TimeScale / Battle Speed):** Kiểm soát `CCDirector:sharedDirector():getScheduler():setTimeScale()` từ bộ nhớ Client (`REGION_ANONYMOUS`). Vượt qua giới hạn VIP / Level kiểm soát tốc độ x3.
   - **Bỏ qua trận đấu (Battle Skip / Instant Finish Animation):** Kích hoạt luồng `battleScene.endfunction(self)` để kết thúc ngay lập tức hoạt ảnh và nhận bảng tổng kết.
   - **Quét chỉ số tướng & nhân vật (Visual / Local Memory):** Khảo sát cấu trúc `role_pb` và `generals_pb` (HP, Atk, Speed, Coins, Diamonds).

---

## 2. Mục lục Hồ sơ Phân tích

- [Danh mục mã nguồn (Source Inventory)](file:///d:/project/GameGuardian/analysis/mbc/source-inventory.md)
- [Kiến trúc hệ thống (Architecture)](file:///d:/project/GameGuardian/analysis/mbc/architecture.md)
- [Luồng dữ liệu (Data Flow)](file:///d:/project/GameGuardian/analysis/mbc/data-flow.md)
- [Bằng chứng kỹ thuật (Evidence Index)](file:///d:/project/GameGuardian/analysis/mbc/evidence-index.md)
- [Quy trình kiểm chứng Runtime (Runtime Validation)](file:///d:/project/GameGuardian/analysis/mbc/runtime-validation.md)
- **Hồ sơ chi tiết tính năng:**
  - [Phân tích Tốc độ trận đấu (Battle Speed & TimeScale)](file:///d:/project/GameGuardian/analysis/mbc/feature-analysis/battle-speed.md)
  - [Phân tích Bỏ qua trận đấu (Battle Skip / Instant Result)](file:///d:/project/GameGuardian/analysis/mbc/feature-analysis/battle-skip.md)
  - [Phân tích Chỉ số Tướng & Nhân vật (Player & General Stats)](file:///d:/project/GameGuardian/analysis/mbc/feature-analysis/player-role-stats.md)

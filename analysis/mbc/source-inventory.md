# Danh mục Mã Nguồn & Tài nguyên Game: Manga Bá Cháy (`mbc`)

## 1. Thông tin Tập tin Gốc

- **APK File:** `D:\project\GameGuardian\apk\MBC.apk` (Dung lượng: ~323 MB)
- **Thư mục trích xuất:** `D:\project\GameGuardian\srcgame\mbc\`
- **Thư mục mã nguồn Lua giải mã:** `D:\project\GameGuardian\srcgame\mbc\decompiled_lua\`
- **Công cụ giải mã tự động:** `D:\project\GameGuardian\tools\decrypt_mbc_lua.py`

---

## 2. Thư viện Thực thi (Native Libraries)

Nằm trong thư mục `srcgame/mbc/lib/` (hỗ trợ hai kiến trúc `arm64-v8a` và `armeabi-v7a`):

| Thư viện | Kích thước (v7a) | Chức năng chính | Ghi chú Reverse Engineering |
|---|---|---|---|
| `libcocos2dlua.so` | 30.0 MB | Core Cocos2d-x Engine, Lua VM, Decryption Loader | Chứa `goddess_lua_loader` và khóa XXTEA `3c883f7813a3ee68` |
| `libsecsdk.so` | 505 KB | Security SDK / Anti-tamper | Kiểm tra chữ ký và tính toàn vẹn |
| `libsigner.so` | 896 KB | Chữ ký dữ liệu & xác thực request mạng | Dùng cho giao thức kết nối server |
| `libBugly.so` / `libBugly_Native.so` | ~180 KB | Crash Reporting & Telemetry | Thu thập log lỗi |

---

## 3. Cấu trúc Tài nguyên & Mã nguồn Lua Giải mã

Sau khi giải mã bằng khóa `3c883f7813a3ee68`, tổng cộng **1.112 tệp Lua** đã được trích xuất:

### 3.1. Thư mục `decompiled_lua/scripts/` (Core Game Logic)
Chứa toàn bộ logic gameplay, UI Layer, trận đấu, sự kiện:
- [battleScene.lua](file:///d:/project/GameGuardian/srcgame/mbc/decompiled_lua/scripts/battleScene.lua): Quản lý sàn đấu, animation, điều khiển tốc độ (speed), nút bỏ qua (tiaoguo / skip), hiển thị kết quả. (3.084 dòng)
- [battlegeneral.lua](file:///d:/project/GameGuardian/srcgame/mbc/decompiled_lua/scripts/battlegeneral.lua): Quản lý thực thể tướng trên sân, animation đánh, hiệu ứng mất máu/hồi máu.
- [battlemochong.lua](file:///d:/project/GameGuardian/srcgame/mbc/decompiled_lua/scripts/battlemochong.lua): Quản lý ma sủng / pet trong trận đấu.
- [battleReportConvert.lua](file:///d:/project/GameGuardian/srcgame/mbc/decompiled_lua/scripts/battleReportConvert.lua): Chuyển đổi dữ liệu chiến báo Protobuf sang cấu trúc animation khung hình.
- [battleCallback.lua](file:///d:/project/GameGuardian/srcgame/mbc/decompiled_lua/scripts/battleCallback.lua): Callback các sự kiện sát thương, hiệu ứng buff/debuff.
- [main.lua](file:///d:/project/GameGuardian/srcgame/mbc/decompiled_lua/scripts/main.lua): Điểm khởi chạy Net thread, load module toàn cục và xử lý exception `__G_TRACKBACK__`.

### 3.2. Thư mục `decompiled_lua/pb/` (Protobuf Network Protocol)
Chứa các định dạng bản tin protobuf giao tiếp giữa Client và Server:
- [role_pb.lua](file:///d:/project/GameGuardian/srcgame/mbc/decompiled_lua/pb/role_pb.lua): Cấu trúc thông tin người chơi: `id`, `name`, `vip`, `level`, `coin`, `gold`, `stamina`, `energy`, `power`.
- [generals_pb.lua](file:///d:/project/GameGuardian/srcgame/mbc/decompiled_lua/pb/generals_pb.lua): Cấu trúc thông tin tướng: `cid`, `iid`, `level`, `atk`, `defense`, `hp`, `speed`, `critical`, `dodge`, `parry`, `resilience`, `hit`, `arp`.
- [battlereport_pb.lua](file:///d:/project/GameGuardian/srcgame/mbc/decompiled_lua/pb/battlereport_pb.lua) & [battleresult_pb.lua](file:///d:/project/GameGuardian/srcgame/mbc/decompiled_lua/pb/battleresult_pb.lua): Định dạng chiến báo và kết quả trận chiến gửi từ Server.
- [copyattack_pb.lua](file:///d:/project/GameGuardian/srcgame/mbc/decompiled_lua/pb/copyattack_pb.lua) & [copyattackresult_pb.lua](file:///d:/project/GameGuardian/srcgame/mbc/decompiled_lua/pb/copyattackresult_pb.lua): Yêu cầu vượt ải và kết quả ải.

### 3.3. Thư mục `decompiled_lua/common_lua/` (Engine Support & Utilities)
Chứa các tiện ích dùng chung:
- [functions.lua](file:///d:/project/GameGuardian/srcgame/mbc/decompiled_lua/common_lua/functions.lua): Các hàm tiện ích cốt lõi của Lua.
- [ui.lua](file:///d:/project/GameGuardian/srcgame/mbc/decompiled_lua/common_lua/ui.lua): Hệ thống quản lý giao diện, widget, popup, grayscale.
- [device.lua](file:///d:/project/GameGuardian/srcgame/mbc/decompiled_lua/common_lua/device.lua): Cầu nối gọi JNI Android / iOS.
- [containers.lua](file:///d:/project/GameGuardian/srcgame/mbc/decompiled_lua/common_lua/containers.lua): Cấu trúc mảng, từ điển mở rộng.

### 3.4. Thư mục `assets/config/1/` (Static Game Configs)
Chứa các bảng dữ liệu cấu hình JSON tĩnh:
- `athletics_copy.json`: Cấu hình các ải đấu (15 MB).
- `abyss_customs.json`: Cấu hình ải Vực thẳm / Abyss (1 MB).
- `activity_time.json`: Lịch trình sự kiện.
- `sanguo.sqlite`: SQLite database lưu trữ thông tin server list và phiên bản config.

# Chỉ mục Bằng chứng Kỹ thuật (Evidence Index): Manga Bá Cháy (`mbc`)

| STT | Khẳng định Kỹ thuật | Trạng thái Bằng chứng | Vị trí Tập tin & Dòng code |
|---|---|---|---|
| 1 | Game sử dụng engine Cocos2d-x (Lua runtime) | `SOURCE_CONFIRMED` | `srcgame/mbc/lib/armeabi-v7a/libcocos2dlua.so` |
| 2 | Toàn bộ script Lua bị mã hóa bằng XXTEA | `SOURCE_CONFIRMED` | `libcocos2dlua.so` tại hàm `goddess_lua_loader` (`0x8fbc08`) và `xxtea_decrypt` (`0x8fe43c`) |
| 3 | Chìa khóa giải mã XXTEA là `3c883f7813a3ee68` | `SOURCE_CONFIRMED` | Chuỗi nhị phân tại offset `0x1aa81a6` trong `libcocos2dlua.so` |
| 4 | Kích thước gốc tệp Lua được lưu trong 4 byte cuối (XXTEA `inc_len = 1`) | `SOURCE_CONFIRMED` | Disassembly hàm `0x8fe71a` kiểm tra `m = data[len - 1]` |
| 5 | Các mức tốc độ trận đấu mặc định là 1.2x, 1.7x, 2.0x | `SOURCE_CONFIRMED` | [battleScene.lua](file:///d:/project/GameGuardian/srcgame/mbc/decompiled_lua/scripts/battleScene.lua#L129) (`speedconfig = {1.2, 1.7, 2}`) |
| 6 | Tốc độ trận đấu điều khiển qua Cocos2d-x Scheduler | `SOURCE_CONFIRMED` | [battleScene.lua](file:///d:/project/GameGuardian/srcgame/mbc/decompiled_lua/scripts/battleScene.lua#L1619) (`CCDirector:sharedDirector():getScheduler():setTimeScale(...)`) |
| 7 | Tốc độ x3 bị khóa bởi VIP / Cấp độ người chơi | `SOURCE_CONFIRMED` | [battleScene.lua](file:///d:/project/GameGuardian/srcgame/mbc/decompiled_lua/scripts/battleScene.lua#L1590-L1612) (`battle_speed_limit`) |
| 8 | Bỏ qua trận đấu được thực thi bằng cách dừng mọi action và gọi thẳng `showResult` | `SOURCE_CONFIRMED` | [battleScene.lua](file:///d:/project/GameGuardian/srcgame/mbc/decompiled_lua/scripts/battleScene.lua#L2936-L2967) (`battleScene.endfunction`) |
| 9 | Kết quả trận đấu do Server tính toán và gửi về qua Protobuf | `SOURCE_CONFIRMED` | [battleScene.lua](file:///d:/project/GameGuardian/srcgame/mbc/decompiled_lua/scripts/battleScene.lua#L2005-L2018) và `pb/battlereport_pb.lua` |
| 10 | Tiền tệ và chỉ số tướng được định nghĩa qua Protobuf WireType int32 | `SOURCE_CONFIRMED` | [role_pb.lua](file:///d:/project/GameGuardian/srcgame/mbc/decompiled_lua/pb/role_pb.lua) và [generals_pb.lua](file:///d:/project/GameGuardian/srcgame/mbc/decompiled_lua/pb/generals_pb.lua) |

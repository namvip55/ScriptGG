# Luồng Dữ liệu Trận đấu & Hệ thống (Data Flow): Manga Bá Cháy (`mbc`)

## 1. Luồng Khởi tạo và Thực thi Trận đấu

```mermaid
sequenceDiagram
    participant User as Người chơi
    participant ClientUI as UI Client (Layer_main / Copy)
    participant Server as Game Server
    participant BScene as battleScene.lua
    participant Scheduler as Cocos2d Scheduler

    User->>ClientUI: Chọn ải và nhấn "Chiến đấu"
    ClientUI->>Server: Gửi gói copyattack_pb (Ải, Đội hình)
    Note over Server: Tính toán toàn bộ kết quả trận đấu,<br/>sát thương từng hiệp, thắng/thua
    Server-->>ClientUI: Trả về gói battleresult_pb + battlereport_pb
    ClientUI->>BScene: battleScene:init(result)
    Note over BScene: convertBattleReportToAnimationSub() tạo danh sách animation
    BScene->>Scheduler: setTimeScale(speedconfig[step])
    BScene->>User: Trình chiếu diễn hoạt trận đấu
    alt Người chơi bấm Tăng tốc (Speed Button)
        User->>BScene: Bấm Speed Button
        BScene->>Scheduler: setTimeScale(1.2 / 1.7 / 2.0)
    else Người chơi bấm Bỏ qua (Skip Button)
        User->>BScene: Bấm End Button (tiaoguo)
        BScene->>BScene: endfunction() -> Dừng actions
        BScene->>User: Hiển thị showResult() ngay lập tức
    end
```

---

## 2. Luồng Đồng bộ Chỉ số Nhân vật & Tướng

1. **Khởi động & Đăng nhập:**
   - Client gửi `userchannellogin_pb`.
   - Server phản hồi `responseuser_pb`, nạp toàn bộ cấu trúc `Role` và `Generals` vào bộ nhớ client (đối tượng toàn cục `GameScene.roleinfo` và `GameScene.generals`).
2. **Cập nhật Chỉ số khi Nâng cấp:**
   - Người chơi bấm nâng cấp trang bị / cường hóa tướng:
   - Client gửi `equipstrengthen_pb` hoặc `inheritrequest_pb`.
   - Server tính toán, trừ tiền trên Database, trả về `result_pb`.
   - Client nhận phản hồi và cập nhật lại `roleinfo.coin` và chỉ số `general.atk`, `general.hp`.

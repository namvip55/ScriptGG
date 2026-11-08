# Phân tích Tính năng: Chỉ số Nhân vật & Tướng (Player & General Stats)
**Game ID:** `mbc`  
**Trạng thái bằng chứng:** `SOURCE_CONFIRMED`  

---

## 1. Mô tả Tính năng

Nhân vật người chơi và các tướng sở hữu hệ thống thuộc tính chiến đấu và tài nguyên kinh tế. Cấu trúc dữ liệu được quy định chặt chẽ thông qua giao thức Google Protobuf.

---

## 2. Dẫn chứng Mã Nguồn & Cấu trúc Dữ liệu

### 2.1. Cấu trúc Nhân vật (`Role`)
Định nghĩa tại [role_pb.lua](file:///d:/project/GameGuardian/srcgame/mbc/decompiled_lua/pb/role_pb.lua):

| Tên trường Protobuf | Kiểu C++ / Wire Type | Ý nghĩa thực tế | Kiểu GG (`gg.TYPE_*`) | Rủi ro Server Validation |
|---|---|---|---|---|
| `id` | `int32` | ID tài khoản người chơi | `gg.TYPE_DWORD` | Chỉ đọc |
| `name` | `string` | Tên nhân vật | - | Chỉ đọc |
| `vip` | `int32` | Cấp độ VIP | `gg.TYPE_DWORD` | Server-Side (Client Visual) |
| `level` | `int32` | Cấp độ nhân vật | `gg.TYPE_DWORD` | Server-Side |
| `exp` / `nextexp` | `int32` | Điểm kinh nghiệm hiện tại / yêu cầu | `gg.TYPE_DWORD` | Server-Side |
| `coin` | `int32` | Tiền vàng (Vàng ingame) | `gg.TYPE_DWORD` | Server-Side (Bị từ chối khi mua) |
| `gold` | `int32` | Kim cương (Tiền nạp) | `gg.TYPE_DWORD` | Server-Side (Bị từ chối khi mua) |
| `stamina` / `maxstamina` | `int32` | Thể lực đi ải | `gg.TYPE_DWORD` | Server-Side |
| `energy` / `maxenergy` | `int32` | Hoạt lực hoạt động | `gg.TYPE_DWORD` | Server-Side |
| `power` | `int32` | Tổng lực chiến | `gg.TYPE_DWORD` | Server-Side |

### 2.2. Cấu trúc Thuộc tính Tướng (`General_Property`)
Định nghĩa tại [generals_pb.lua](file:///d:/project/GameGuardian/srcgame/mbc/decompiled_lua/pb/generals_pb.lua):

| Tên trường Protobuf | Số thứ tự Field | Kiểu dữ liệu | Ý nghĩa | Kiểu GG |
|---|---|---|---|---|
| `cid` | 1 | `int32` | Config ID (Loại tướng) | `gg.TYPE_DWORD` |
| `iid` | 2 | `int32` | Instance ID (Định danh tướng cụ thể) | `gg.TYPE_DWORD` |
| `level1` / `level2` | 3, 4 | `int32` | Cấp độ & Phẩm chất | `gg.TYPE_DWORD` |
| `exp` | 5 | `int32` | Kinh nghiệm tướng | `gg.TYPE_DWORD` |
| `atk` | 6 | `int32` | Công kích (Tấn công) | `gg.TYPE_DWORD` |
| `defense` | 7 | `int32` | Phòng thủ | `gg.TYPE_DWORD` |
| `hp` | 8 | `int32` | Lượng máu tối đa | `gg.TYPE_DWORD` |
| `speed` | 9 | `int32` | Tốc độ xuất chiêu | `gg.TYPE_DWORD` |
| `critical` | 10 | `int32` | Tỷ lệ bạo kích | `gg.TYPE_DWORD` |
| `dodge` | 11 | `int32` | Tỷ lệ né tránh | `gg.TYPE_DWORD` |
| `parry` | 12 | `int32` | Tỷ lệ đỡ đòn | `gg.TYPE_DWORD` |
| `resilience` | 13 | `int32` | Kháng bạo kích | `gg.TYPE_DWORD` |
| `hit` | 14 | `int32` | Độ chính xác | `gg.TYPE_DWORD` |
| `arp` | 15 | `int32` | Xuyên giáp | `gg.TYPE_DWORD` |
| `criticaldmg` | 16 | `int32` | Sát thương bạo kích | `gg.TYPE_DWORD` |
| `potential` | 17 | `int32` | Tiềm năng | `gg.TYPE_DWORD` |
| `power` | 20 | `int32` | Lực chiến tướng | `gg.TYPE_DWORD` |

---

## 3. Phân tích Bộ nhớ & Cảnh báo Tính hợp lệ

> [!WARNING]
> **Rủi ro Server-Side Validation:**
> - Toàn bộ các chỉ số `atk`, `hp`, `defense` của tướng được lưu trữ trên Server. Khi chiến đấu, Server dùng chỉ số trên Database để tính toán kết quả trận đấu (`battlereport_pb`).
> - Việc sửa `atk` hay `hp` trong bộ nhớ GameGuardian chỉ có tác dụng thay đổi số hiển thị trên giao diện thông tin tướng (Visual Change), hoàn toàn không làm tăng sát thương thật trong trận chiến.
> - Tiền vàng `coin` và kim cương `gold` cũng tương tự: việc sửa đổi sẽ làm hiển thị số ảo, nhưng khi nhấn mua trong Shop hoặc quay tướng, Server sẽ kiểm tra số dư thực tế và báo lỗi giao dịch không hợp lệ (`error_pb`).

---

## 4. Gợi ý Group Search cho Tính năng Hiển thị (Visual Mod)

Nếu muốn tạo script hiển thị chỉ số tướng phục vụ mục đích quay phim / chụp ảnh:
- Cú pháp Group Search trên GameGuardian:
  ```text
  atk;defense;hp:24
  ```
  Ví dụ với tướng có Công 1500, Thủ 800, Máu 12000:
  ```text
  1500D;800D;12000D:24
  ```
- Vùng nhớ quét: `gg.REGION_ANONYMOUS` (Lua Table / C++ Struct).

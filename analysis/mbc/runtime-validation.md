# Hướng dẫn Kiểm chứng Runtime: Manga Bá Cháy (`mbc`)

Tài liệu này cung cấp các kịch bản kiểm chứng thực nghiệm trên GameGuardian chạy trên thiết bị giả lập / máy thật Android.

---

## Kịch bản 1: Kiểm chứng Hack Tốc độ Trận đấu (TimeScale Mod)

### Mục tiêu
Xác nhận rằng việc thay đổi biến `timeScale` trong vùng nhớ `REGION_ANONYMOUS` làm tăng tốc toàn bộ trận đấu mà không làm văng game (crash) hay lệch đồng bộ chiến báo.

### Các bước thực hiện:
1. Mở game **Manga Bá Cháy**, đăng nhập vào một tài khoản thử nghiệm.
2. Bắt đầu một ải phó bản bất kỳ. Khi các tướng bắt đầu chạy ra sân đấu (tốc độ đang ở mặc định x1):
3. Mở GameGuardian:
   - Chọn tiến trình: `vn.vgp.manga.ba.chay`.
   - Cài đặt vùng nhớ: chỉ chọn `Ca: Anonymous` (`gg.REGION_ANONYMOUS`).
   - Tìm kiếm: `1.2` kiểu `Float`. Kết quả ban đầu có thể có vài nghìn địa chỉ.
4. Quay lại game, bấm nút Tốc độ để chuyển sang x2 (màn hình hiển thị "2X"):
   - Mở GameGuardian, lọc giá trị: `1.7` kiểu `Float`.
5. Tiếp tục chuyển về x1, lọc giá trị: `1.2`.
6. Danh sách kết quả sẽ rút gọn còn 1 đến 2 địa chỉ.
7. Thử nghiệm đổi giá trị thành `5.0`:
   - Quan sát: Toàn bộ tướng đánh cực nhanh, hiệu ứng chiêu lướt qua nhanh gấp 5 lần.
8. Thử nghiệm đổi giá trị thành `20.0` và đóng băng:
   - Trận đấu hoàn thành chỉ trong khoảng 3 giây, màn hình hiển thị bảng kết quả chiến thắng / chiến bại hoàn chỉnh.

### Kết quả mong đợi:
- Trận đấu kết thúc bình thường, phần thưởng kinh nghiệm và vật phẩm nhận đầy đủ từ server, không có cảnh báo gian lận.

---

## Kịch bản 2: Kiểm chứng Ranh giới Server-Side Validation của Tiền Tệ

### Mục tiêu
Chứng minh rằng sửa đổi `coin` và `gold` chỉ thay đổi hiển thị cục bộ (Visual), kiểm chứng nguyên tắc an toàn cho người dùng script.

### Các bước thực hiện:
1. Ghi nhận số Vàng hiện có (ví dụ: `158,200`).
2. Tìm kiếm trong GameGuardian kiểu `Dword` với vùng nhớ `Anonymous` hoặc `Java Heap`.
3. Điểm số tìm thấy: Sửa thành `999,999,999`.
4. Quan sát: Giao diện hiển thị 999 triệu vàng.
5. Thử bấm mua 1 món đồ trong shop trị giá 500,000 vàng:
   - Quan sát kết quả: Xuất hiện thông báo lỗi từ server "Số dư không đủ" hoặc giao diện tải lại và số vàng trở về `158,200`.

### Kết luận:
Tính năng hack tiền vàng/kim cương không khả thi do Server kiểm tra trực tiếp. Script chỉ nên tập trung vào các tính năng Client-Side như **Tốc độ trận đấu (TimeScale)**, **Hỗ trợ tự động thao tác (Auto Macro)**, và **Tối ưu hiển thị**.

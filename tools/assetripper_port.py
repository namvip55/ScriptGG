#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
=============================================================================
ASSET RIPPER PORT & SOURCE EXTRACTOR (2026)
Hệ thống cầu nối (Port) tự động hóa tách mã nguồn và tài nguyên game
từ thư mục APK vào thư mục srcgame phục vụ GameGuardian Reverse Engineering.
=============================================================================
"""

import os
import sys
import time
import json
import socket
import argparse
import subprocess
import urllib.request
import urllib.parse
import zipfile
from pathlib import Path

# Đảm bảo console Windows in tiếng Việt UTF-8 không lỗi charmap
if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
        sys.stderr.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

# Cấu hình mặc định
BASE_DIR = Path(__file__).resolve().parent.parent
TOOLS_DIR = BASE_DIR / "tools" / "AssetRipper"
EXE_PATH = TOOLS_DIR / "AssetRipper.GUI.Free.exe"
DEFAULT_PORT = 18765
APK_DIR = BASE_DIR / "apk"
SRCGAME_DIR = BASE_DIR / "srcgame"

def log(msg, prefix="[AssetRipper Port]"):
    print(f"{prefix} {msg}")

def check_port_in_use(port: int, host="127.0.0.1") -> bool:
    """Kiểm tra xem port đã có tiến trình nào lắng nghe chưa."""
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.settimeout(0.5)
        return s.connect_ex((host, port)) == 0

def detect_apk_engine(apk_path: Path) -> dict:
    """Khảo sát engine của APK trước khi nạp vào AssetRipper."""
    info = {
        "engine": "Unknown",
        "is_unity": False,
        "details": []
    }
    try:
        with zipfile.ZipFile(apk_path, "r") as z:
            names = z.namelist()
            for n in names:
                n_lower = n.lower()
                if "libunity.so" in n_lower or "libil2cpp.so" in n_lower or "assets/bin/data" in n_lower:
                    info["is_unity"] = True
                    info["engine"] = "Unity (IL2CPP / Mono)"
                    info["details"].append(n)
                elif "libcocos2d" in n_lower:
                    info["engine"] = "Cocos2d (Lua / C++)"
                    info["details"].append(n)
                elif "libunreal" in n_lower or "libue4" in n_lower:
                    info["engine"] = "Unreal Engine"
                    info["details"].append(n)
    except Exception as e:
        info["details"].append(f"Lỗi đọc APK: {e}")
    return info

def ensure_server_running(port: int = DEFAULT_PORT) -> subprocess.Popen | None:
    """Đảm bảo AssetRipper daemon đang chạy trên port chỉ định."""
    if not EXE_PATH.exists():
        log(f"LỖI: Không tìm thấy tệp thực thi AssetRipper tại: {EXE_PATH}")
        sys.exit(1)

    url = f"http://127.0.0.1:{port}/openapi.json"

    # Kiểm tra nếu server đã chạy sẵn
    if check_port_in_use(port):
        try:
            req = urllib.request.urlopen(url, timeout=2)
            if req.getcode() == 200:
                log(f"AssetRipper server đã đang chạy sẵn tại cổng {port}.")
                return None
        except Exception:
            log(f"Cảnh báo: Cổng {port} đang bị chiếm nhưng không phản hồi AssetRipper API.")

    # Khởi chạy server mới ở chế độ headless
    log(f"Đang khởi động AssetRipper daemon trên port {port} (headless mode)...")
    proc = subprocess.Popen(
        [str(EXE_PATH), "--headless", "--port", str(port)],
        cwd=str(BASE_DIR),
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL
    )

    # Chờ server sẵn sàng (tối đa 15 giây)
    max_wait = 15
    start_time = time.time()
    while time.time() - start_time < max_wait:
        try:
            req = urllib.request.urlopen(url, timeout=1)
            if req.getcode() == 200:
                log(f"AssetRipper server đã khởi động thành công trên cổng {port}!")
                return proc
        except Exception:
            time.sleep(0.5)

    log(f"LỖI: Quá thời gian chờ AssetRipper phản hồi tại http://127.0.0.1:{port}")
    if proc.poll() is not None:
        log(f"Tiến trình đã thoát sớm với mã lỗi: {proc.returncode}")
    sys.exit(1)

def send_api_request(port: int, endpoint: str, form_data: dict = None) -> tuple[int, str]:
    """Gửi HTTP request tới AssetRipper Web API."""
    url = f"http://127.0.0.1:{port}{endpoint}"
    data_bytes = None
    headers = {}

    if form_data:
        data_bytes = urllib.parse.urlencode(form_data).encode("utf-8")
        headers["Content-Type"] = "application/x-www-form-urlencoded"

    req = urllib.request.Request(url, data=data_bytes, headers=headers)
    try:
        with urllib.request.urlopen(req, timeout=300) as response:
            return response.getcode(), response.read().decode("utf-8", errors="ignore")
    except urllib.error.HTTPError as e:
        # Nhiều endpoint của AssetRipper trả về 302 Found sau khi nạp/xuất
        return e.code, e.read().decode("utf-8", errors="ignore")
    except Exception as e:
        return -1, str(e)

def extract_apk_to_srcgame(apk_path: Path, game_id: str, mode: str = "primary", port: int = DEFAULT_PORT):
    """Thực hiện quy trình trích xuất src từ APK qua Port AssetRipper."""
    if not apk_path.exists():
        log(f"LỖI: Không tìm thấy file APK tại: {apk_path}")
        return False

    out_dir = SRCGAME_DIR / game_id
    out_dir.mkdir(parents=True, exist_ok=True)

    log(f"--- BẮT ĐẦU TRÍCH XUẤT SOURCE TỪ APK ---")
    log(f"APK mục tiêu  : {apk_path.resolve()}")
    log(f"Game ID       : {game_id}")
    log(f"Thư mục xuất  : {out_dir.resolve()}")
    log(f"Chế độ xuất   : {'PrimaryContent (Mã nguồn C# & Assemblies)' if mode == 'primary' else 'UnityProject (Toàn bộ Dự án Unity)'}")

    # Khảo sát engine
    engine_info = detect_apk_engine(apk_path)
    log(f"Động cơ phát hiện: {engine_info['engine']}")
    if not engine_info["is_unity"]:
        log("LƯU Ý: File APK này không có dấu hiệu đặc trưng của Unity Engine.")
        log("Nếu APK dùng engine khác (ví dụ Cocos2d-x / Native C++), AssetRipper có thể không trích xuất được C# scripts.")

    # 1. Reset trạng thái AssetRipper
    log("Đang đặt lại phiên làm việc AssetRipper...")
    send_api_request(port, "/Reset", {})

    # 2. Nạp APK (/LoadFile)
    log("Đang nạp file APK vào AssetRipper (có thể mất 1-3 phút tùy dung lượng)...")
    code, resp = send_api_request(port, "/LoadFile", {"path": str(apk_path.resolve())})
    if code not in (200, 302):
        log(f"Cảnh báo nạp file: Mã phản hồi HTTP {code}")

    # 3. Xuất Source (/Export/PrimaryContent hoặc /Export/UnityProject)
    export_endpoint = "/Export/PrimaryContent" if mode == "primary" else "/Export/UnityProject"
    log(f"Đang tiến hành giải mã và xuất mã nguồn sang {out_dir.name}...")
    code, resp = send_api_request(port, export_endpoint, {"path": str(out_dir.resolve())})
    
    # 4. Thống kê kết quả
    extracted_files = list(out_dir.rglob("*"))
    file_count = sum(1 for f in extracted_files if f.is_file())
    csharp_files = sum(1 for f in extracted_files if f.suffix == ".cs")
    dll_files = sum(1 for f in extracted_files if f.suffix == ".dll")

    log(f"--- KẾT QUẢ TRÍCH XUẤT ---")
    log(f"Tổng số tệp trích xuất: {file_count}")
    log(f"Tệp mã nguồn C# (.cs): {csharp_files}")
    log(f"Tệp thư viện (.dll)   : {dll_files}")
    log(f"Đường dẫn source game : {out_dir.resolve()}")

    if file_count > 0:
        log("✅ Quá trình trích xuất hoàn tất thành công!")
        return True
    else:
        log("⚠️ AssetRipper không tìm thấy nội dung Unity để trích xuất.")
        if not engine_info["is_unity"]:
            log("TỰ ĐỘNG KÍCH HOẠT DỰ PHÒNG: Đây là APK Non-Unity (" + engine_info["engine"] + ").")
            log("Đang giải nén các tệp tài nguyên, script và thư viện từ APK vào srcgame...")
            try:
                with zipfile.ZipFile(apk_path, "r") as z:
                    for member in z.infolist():
                        # Trích xuất assets/, lib/, classes*.dex
                        if member.filename.startswith("assets/") or member.filename.startswith("lib/") or member.filename.startswith("classes"):
                            z.extract(member, out_dir)
                fallback_files = list(out_dir.rglob("*"))
                log(f"✅ Đã giải nén dự phòng thành công: {len(fallback_files)} tệp vào {out_dir.resolve()}")
                return True
            except Exception as e:
                log(f"Lỗi giải nén dự phòng: {e}")
        return False

def main():
    parser = argparse.ArgumentParser(description="AssetRipper Port & Source Extraction Pipeline")
    parser.add_argument("--apk", type=str, help="Đường dẫn đến file APK (nếu bỏ trống sẽ tự tìm trong thư mục apk/)")
    parser.add_argument("--game_id", type=str, help="ID của game (mặc định lấy theo tên file APK)")
    parser.add_argument("--port", type=int, default=DEFAULT_PORT, help=f"Cổng chạy AssetRipper Web Service (mặc định: {DEFAULT_PORT})")
    parser.add_argument("--mode", choices=["primary", "project"], default="primary", help="Chế độ xuất: primary (chỉ src/dlls) hoặc project (full Unity project)")
    parser.add_argument("--server-only", action="store_true", help="Chỉ khởi động AssetRipper Web Server trên port chỉ định để thao tác trên trình duyệt")
    parser.add_argument("--stop", action="store_true", help="Dừng tiến trình AssetRipper đang chạy trên port chỉ định")

    args = parser.parse_args()

    if args.stop:
        log(f"Đang tìm và đóng các tiến trình AssetRipper...")
        subprocess.run(["taskkill", "/F", "/IM", "AssetRipper.GUI.Free.exe"], capture_output=True)
        log("Đã đóng AssetRipper.")
        return

    # Khởi động server
    proc = ensure_server_running(args.port)

    if args.server_only:
        log(f"AssetRipper Web UI đang mở tại: http://127.0.0.1:{args.port}")
        log("Bạn có thể truy cập liên kết trên từ trình duyệt web để thao tác trực quan.")
        try:
            while True:
                time.sleep(1)
        except KeyboardInterrupt:
            log("Đang tắt server...")
            if proc:
                proc.terminate()
        return

    # Tìm file APK
    target_apk = None
    if args.apk:
        target_apk = Path(args.apk)
    else:
        apk_files = list(APK_DIR.glob("*.apk"))
        if not apk_files:
            log(f"Không tìm thấy file .apk nào trong thư mục: {APK_DIR}")
            log("Vui lòng sao chép file .apk vào thư mục 'apk/' hoặc chỉ định qua cờ --apk <đường_dẫn>")
            return
        target_apk = apk_files[0]
        log(f"Tự động chọn file APK đầu tiên tìm thấy: {target_apk.name}")

    # Xác định game_id
    game_id = args.game_id
    if not game_id:
        game_id = target_apk.stem.lower().replace(" ", "-").replace("_", "-")

    # Tiến hành trích xuất
    extract_apk_to_srcgame(target_apk, game_id, mode=args.mode, port=args.port)

if __name__ == "__main__":
    main()

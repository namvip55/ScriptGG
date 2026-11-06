# SKILL: GENSCRIPT
  # Sinh GameGuardian Lua Script đa game từ hồ sơ phân tích source & UI đẹp mắt có màu sắc
  # (Kèm chức năng Kiểm Thử Runtime & Xuất Bằng Chứng dành cho skill FINALSCRIPT)

  ## 1. Vai trò

  Bạn là Agent chuyên thiết kế và sinh GameGuardian Lua Script dựa trên:
  - Yêu cầu chức năng của người dùng.
  - Báo cáo phân tích source do skill `CRAWLDATA` tạo.
  - Dữ liệu runtime/GameGuardian đã được người dùng kiểm chứng.
  - Tài liệu kiến thức Lua/GameGuardian được cung cấp trong Project (đặc biệt là
    `docs/synthesis/lua-scripting-knowledge-synthesis.md` và `docs/synthesis/lua-scripting-knowledge.md`).

  Skill này phải dùng lại được cho NHIỀU GAME. Không hardcode Mindustry, Unity, Android Java, package name, engine, version, tên
  class hoặc cấu trúc memory của một game cụ thể.

  Nhiệm vụ:
  - Chọn đúng hồ sơ game.
  - Đọc báo cáo phân tích tương ứng.
  - Đánh giá độ đầy đủ của bằng chứng.
  - Thiết kế logic script & **giao diện đẹp mắt, chuyên nghiệp, có màu sắc (BBCode color tags)**.
  - Tích hợp **Danh Mục Test Runtime (Kiểm Thử từng tính năng A-Z)**: mỗi tính năng có hướng dẫn chi tiết thực hiện thủ công trong
  GameGuardian.
  - Tích hợp **Công Cụ Xuất Bằng Chứng (Export Runtime Evidence)** để người dùng gửi dữ liệu cho skill `FINALSCRIPT`.
  - Sinh Lua hoàn chỉnh trong đúng thư mục của game, tất cả giao diện script đều là Tiếng Việt.
  - Rà soát cú pháp, luồng menu, hiệu ứng loading/progress, màu sắc, xử lý lỗi và khả năng khôi phục.
  - Ghi rõ điều đã xác minh và điều cần kiểm thử.

  ## 2. Đường dẫn dự án cố định

  - Source game: `D:\project\GameGuardian\srcgame`
  - Phân tích source: `D:\project\GameGuardian\analysis`
  - Script đầu ra: `D:\project\GameGuardian\gameguardian-lua-script\script`

  Không tự ý thay đổi các thư mục gốc.

  ### 2.1. Quy tắc phân tách theo game

  Mỗi script phải được lưu vào thư mục riêng của game:

  `D:\project\GameGuardian\gameguardian-lua-script\script\<game_id>\`

  Ví dụ:

  ```text
  gameguardian-lua-script\script\
  |
  +-- mindustry\
  |   +-- player-tools.lua
  |   +-- resource-helper.lua
  |
  +-- game-a\
  |   +-- automation.lua
  |
  +-- game-b\
      +-- quality-of-life.lua

  Không lưu script của nhiều game lẫn vào cùng một thư mục nếu có thể tránh. Không ghi đè file trùng tên thuộc game khác.

  2.2. Xác định game_id

  - Dùng game_id trong yêu cầu hoặc báo cáo CRAWLDATA.
  - Đối chiếu với analysis\<game_id>\README.md.
  - Nếu không xác định chắc game, không chọn hồ sơ theo phỏng đoán.
  - Không lấy báo cáo feature của game A để viết script cho game B.
  - Ghi rõ game, phiên bản và source revision mà script dựa trên.

  3. Đầu vào phải kiểm tra

  Trước khi viết script, đọc các tài liệu phù hợp trong:

  D:\project\GameGuardian\analysis\<game_id>\

  Ưu tiên:
  1. README.md
  2. Báo cáo feature trong feature-analysis\
  3. runtime-validation.md
  4. data-flow.md
  5. architecture.md
  6. evidence-index.md
  7. source-inventory.md

  Đồng thời BẮT BUỘC đọc & tham khảo tài liệu kiến thức GameGuardian UI & API trong Project:
  - D:\project\GameGuardian\docs\synthesis\lua-scripting-knowledge-synthesis.md
  - D:\project\GameGuardian\docs\synthesis\lua-scripting-knowledge.md

  Sử dụng các file synthesis trên làm chuẩn tham khảo về:
  - Cấu trúc Welcome sequence & Progress Bar loading animation trong Toast.
  - Bố cục Main Menu Loop (mẫu while true với gg.choice).
  - Mã màu sắc BBCode ([color=...]), formatting ([b], [i], [size]) và icons/emojis.
  - API tìm kiếm, chỉnh sửa memory an toàn và kiểm tra bảo mật (Version Check / Target Check).

  Lưu ý: Không coi ví dụ trong tài liệu là bằng chứng rằng một giá trị bộ nhớ cụ thể hoạt động trên game hiện tại.

  Đầu vào tính năng gồm:
  - Game và game_id.
  - Chức năng cần thực hiện.
  - Kết quả mong muốn.
  - Điều kiện sử dụng.
  - Yêu cầu menu/automation/toggle/preset.
  - Phiên bản mục tiêu nếu biết.
  - Runtime evidence do người dùng cung cấp.

  Không yêu cầu lại thông tin đã có trong file hoặc hội thoại.

  4. Cổng xác minh dữ liệu

  Phân loại từng thông tin:

  - SOURCE_CONFIRMED: được xác nhận trực tiếp trong source.
  - RUNTIME_CONFIRMED: đã được kiểm tra trong runtime/GameGuardian và có bằng chứng.
  - INFERRED: suy luận có cơ sở nhưng chưa kiểm chứng runtime.
  - UNKNOWN: chưa có dữ liệu.
  - NOT_APPLICABLE: không áp dụng.

  Nguyên tắc:

  1. Source dùng để hiểu logic game, class, field, method, kiểu dữ liệu source và luồng cập nhật.
  2. Runtime evidence dùng để xác định kết quả tìm kiếm, kiểu dữ liệu thực tế, vùng nhớ, địa chỉ/offset/pointer nếu cần.
  3. Không biến giá trị mặc định trong source thành giá trị tìm kiếm GameGuardian.
  4. Không biến field/property thành địa chỉ memory.
  5. Không suy ra offset từ thứ tự khai báo field.
  6. Không tự bịa package name, version, memory region hoặc số lượng kết quả.
  7. Không dùng dữ liệu của game/version khác nếu chưa chứng minh tương thích.

  Chỉ triển khai memory edit cụ thể khi dữ liệu cần thiết đã được RUNTIME_CONFIRMED.

  Nếu thiếu runtime evidence, có thể:
  - Sinh menu và kiến trúc Lua.
  - Sinh các hàm xử lý độc lập với memory.
  - Tạo placeholder TODO_RUNTIME_CONFIRMATION.
  - Đưa quy trình kiểm chứng để người dùng cung cấp kết quả.
  - Không đưa placeholder giả dạng giá trị thật vào lệnh tìm kiếm/chỉnh sửa.

  5. Quy chuẩn Thiết kế Giao diện (UI) & Màu sắc (Coloring)

  Để đảm bảo mọi script được sinh ra đều có giao diện đẹp mắt, thu hút, dễ nhìn và chuyên nghiệp, bắt buộc áp dụng các quy chuẩn
  thiết kế UI sau:

  5.1. Thẻ Màu BBCode (BBCode Formatting)

  GameGuardian hỗ trợ các thẻ định dạng BBCode trong các hộp thoại (gg.alert, gg.choice, gg.multiChoice, gg.prompt). Sử dụng cú
  pháp:
  - Màu sắc: [color=#HEX_CODE]Văn bản[/color] (hoặc tên màu như [color=red], [color=yellow]).
  - Kiểu chữ: [b]In đậm[/b], [i]In nghiêng[/i], [u]Gạch chân[/u].
  - Cỡ chữ: [size=20]Tiêu đề lớn[/size].

  5.2. Bảng Màu Chuẩn (Color Palette)

  - Tiêu đề / Brand Accent: [color=#FFD700] (Vàng kim / Gold), [color=#00E5FF] (Xanh Cyan), [color=#B388FF] (Tím sáng).
  - Trạng thái Bật / Thành công (ON / Success): [color=#00E676] hoặc [color=#00FF00] (Xanh lá sáng).
  - Trạng thái Tắt / Thoát / Thất bại (OFF / Exit / Error): [color=#FF1744] hoặc [color=#FF4444] (Đỏ tươi).
  - Cảnh báo / Chưa xác minh (Warning / Caution): [color=#FFD700] (Vàng) hoặc [color=#FF9100] (Cam).
  - Tham số / Giá trị / Đơn vị (Highlight / Parameter): [color=#1DE9B6] (Xanh ngọc) hoặc [color=#FFFFFF] (Trắng nổi bật).
  - Ghi chú phụ / Subtitle / Footer (Muted Text): [color=#B0BEC5] (Xám bạc).

  5.3. Hệ thống Icons & Emojis Đồng bộ

  - Logo / Script Header: 👑, ⚡, 🚀, 🛡️ , 🎮, 🔥, ✨
  - Danh mục Menu:
    - Tiền tệ / Tài nguyên: 💰, 🪙 , 💎, 💳
    - Chỉ số / Nhân vật: ⚔️ , 🛡️ , ❤️ , ⚡, 🎯
    - Quy tắc / Gameplay: 🛠️ , 🏗️ , ⚙️ , 🌀, ⏱️ 
    - Công cụ Runtime / Hệ thống: 🔍, 📊, 💾, 🔄, ⚙️ 
    - Thoát / Hủy: 🚪, 🔙, ❌
  - Cờ trạng thái:
    - [color=#00E676]● [ĐÃ BẬT][/color] / [color=#00E676]● [ON][/color]
    - [color=#FF1744]○ [ĐÃ TẮT][/color] / [color=#FF1744]○ [OFF][/color]
    - [color=#FFD700]⚠️   [CHỜ RUNTIME][/color]

  5.4. Khung Viền & Bố cục Visual (Banners & Dividers)

  Tạo phân cách nghệ thuật bằng các ký tự viền trong hộp thoại gg.alert và tiêu đề Menu:
  - Khung hoa văn: ◈━━━━━━━━━━━━━━━━━━━━━━━◈
  - Viền nét đôi: ═════════════════════════════
  - Viền nét đơn: -----------------------------

  5.5. Trải nghiệm Luồng Giao diện (UX Flow)

  1. Khởi tạo & Progress Bar Animation:
     - Tắt menu bằng gg.setVisible(false).
     - Chạy hiệu ứng Toast Progress Bar (ví dụ: \n[color=#00E5FF][▓▓▓▓░░░░░░] 40% Đang nạp...[/color]).
     - Hiển thị Welcome Alert đẹp mắt với thông tin tác giả, phiên bản và hướng dẫn kích hoạt menu bằng biểu tượng GG.
  2. Menu Chính Loop (while true do ... end):
     - Sử dụng gg.choice với tiêu đề đẹp có màu sắc và banner.
     - Các option được đánh số thứ tự 1., 2., có icon tương ứng và cờ màu thể hiện trạng thái [ON]/[OFF].
     - Danh mục mới "🧪 Test Runtime": Hiển thị mỗi tính năng cần kiểm thử với thông tin ⚠️  CHỜ RUNTIME màu vàng.
     - Danh mục mới "📤 Xuất Bằng Chứng": Xuất toàn bộ dữ liệu test runtime sang hộp thoại Alert chuẩn format cho FINALSCRIPT.
  3. Menu Con & Hộp thoại Prompt (gg.prompt):
     - Nhãn tham số có màu sắc kèm giá trị mặc định rõ ràng.
     - Khi chọn Hủy (click ra ngoài/cancel), hiển thị Toast thông báo đã hủy thao tác nhẹ nhàng, không gây crash script.
  4. Thông báo Toast & Alert phản hồi:
     - Mọi thao tác đều gửi Toast/Alert ngắn gọn có icon + màu sắc phản hồi kết quả (Thành công ✅, Cảnh báo ⚠️ , Thất bại ❌).

  5.6. Mẫu Code UI Chuẩn (UI Code Template)

  -- Banner & Tiêu đề đẹp
  local SCRIPT_NAME = "Mindustry VIP Helper"
  local VERSION = "1.0.0"
  local SCRIPT_TITLE = "[color=#FFD700][b]👑 " .. SCRIPT_NAME .. "[/b][/color]"
  local SCRIPT_TAG = "[color=#00E5FF][" .. SCRIPT_NAME .. "][/color]"

  -- Trạng thái Feature
  local state = {
      godMode = false,
      infiniteRes = false
  }

  -- Tiện ích Toast có màu & Tag
  local function notify(msg)
      gg.toast(SCRIPT_TAG .. " " .. msg)
  end

  -- Tiện ích Alert có Banner khung đẹp
  local function alert(title, msg)
      local banner = "[color=#00E5FF]◈━━━━━━━━━━━━━━━━━━━━━━━◈[/color]\n"
          .. "  " .. SCRIPT_TITLE .. " [color=#B0BEC5]v" .. VERSION .. "[/color]\n"
          .. "[color=#00E5FF]◈━━━━━━━━━━━━━━━━━━━━━━━◈[/color]\n\n"
      gg.alert(banner .. "[color=#FFD700][b]" .. title .. "[/b][/color]\n\n" .. msg)
  end

  -- Hiệu ứng Loading Progress Bar
  local function showWelcome()
      gg.setVisible(false)
      notify("🚀 Đang khởi tạo script...")
      gg.sleep(300)

      local steps = {
          "\n[color=#00E5FF]□□□□□□□□□□  0% Khởi động hệ thống...[/color]",
          "\n[color=#00E5FF]■■■■□□□□□□ 40% Kiểm tra tiến trình game...[/color]",
          "\n[color=#00E5FF]■■■■■■■□□□ 70% Nạp cấu hình & menu...[/color]",
          "\n[color=#00E676]■■■■■■■■■■ 100% Hoàn tất![/color]"
      }
      for _, s in ipairs(steps) do
          gg.toast(s)
          gg.sleep(250)
      end

      alert("CHÀO MỪNG", "Kích hoạt script thành công!\n[color=#1DE9B6]👉 Nhấn vào biểu tượng GG để bật Menu chức năng.[/color]")
  end

  -- ===========================================================================
  -- MỤC: TEST RUNTIME & EXPORT EVIDENCE (Kiểm Thử & Xuất Bằng Chứng)
  -- ===========================================================================

  -- Danh sách các tính năng cần test runtime (sẽ sinh thay thế theo specific game)
  local featuresForTesting = {
      {name = "🛡 God Mode (Mở khóa god)", desc = "Mở khóa ảnh nền, vô hạn máu / thắng", runtimeState = false},
      {name = "💰 Infinite Resources (Tài nguyên vô hạn)", desc = "Vô hạn tiền, tài nguyên chỉ số", runtimeState = false},
      {name = "⚔ Damage Multiplier (Số sát thương)", desc = "Lên chỉ số sát thương nhân đôi", runtimeState = false},
      {name = "🛠 Build Speed Multiplier (Tốc độ xây dựng)", desc = "Quy đổi tốc độ xây dựng nhanh hơn", runtimeState = false}
  }

  -- Hàm xuất bằng chứng runtime thành chuỗi text gửi cho FINALSCRIPT
  local function exportRuntimeEvidence(featureIndex)
      if not featureIndex or featureIndex < 1 or featureIndex > #featuresForTesting then
          alert("[color=#FFD700][b]📤 Xuất Bằng Chứng ĐANG CHUYỂN ĐỘNG...[/b][/color]\n\nHãy sao chép đoạn text dưới đây và gửi lại
  cho agent để tạo script Final Automation 100%:\n\n")
          return
      end

      local f = featuresForTesting[featureIndex]
      local target = gg.getTargetInfo()
      local pkg = target and target.packageName or "Chưa rõ"
      local ver = target and target.versionName or "Chưa rõ"

      -- Chuỗi text chuẩn format sẵn sàng copy đi
      local logText = string.format(
          "================ RUNTIME EVIDENCE LOG ================\n"
          .. "Game Package: %s (v%s)\n"
          .. "Tính năng Tested: [%s]\n"
          .. "------------------\n"
          .. "Step 1: ✅ Kiểm tra tiến trình game chạy bình thường.\n"
          .. "Step 2: ✅ Chạy đến bước cần test.\n"
          .. "Step 3: Quét giá trị ban đầu bằng GG: gg.searchNumber(\"Giá trị mặc định\", %s)\n"
          .. "Step 4: Thay đổi giá trị trong game để thấy dữ liệu change.\n"
          .. "Step 5: Lọc refine: gg.refineNumber(\"Giá trị after\", %s)\n"
          .. "Step 6: Sao chép địa chỉ quét thấy được.\n"
          .. "Step 7: Thay đổi địa chỉ bằng gg.editAll(newValue, %s)\n"
          .. "Step 8: Kiểm tra kiểu dữ liệu thực tế: %s\n"
          .. "Step 9: Số kết quả hiện tại: %d\n"
          .. "Step 10: Kiểm tra lại bằng chứng sau khi chỉnh sửa.\n"
          .. "======================================================\n",
          pkg, ver, f.desc,
          "-- Dưới đây để tùy chỉnh: TYPE_DWORD / TYPE_FLOAT / TYPE_DOUBLE / TYPE_BYTE",
          "-- Dưới đây để tùy chỉnh: TYPE_DWORD / TYPE_FLOAT / TYPE_DOUBLE / TYPE_BYTE",
          "-- Dưới đây để tùy chỉnh: TYPE_DWORD / TYPE_FLOAT / TYPE_DOUBLE / TYPE_BYTE",
          "-- Kiểu dữ liệu thực tế sau thử: DWORD / FLOAT / DOUBLE / BYTE",
          "-- Số lượng kết quả dọn lại: 1 / 3 / 12 / 0",
          f.desc,
          "-- Ví dụ: TYPE_DWORD -> Dword",
          "-- Ví dụ: TYPE_FLOAT -> Float",
          "-- Ví dụ: TYPE_DOUBLE -> Double",
          "-- Ví dụ: TYPE_BYTE -> Byte",
          "-- Ví dụ: Số kết quả: 1 địa chỉ vẫn giữ nguyên",
          "-- Ví dụ: Số kết quả: 3 địa chỉ",
          "-- Ví dụ: Số kết quả: 0 địa chỉ",
          f.name
      )

      -- Hiển thị Alert màu vàng cảnh báo & text sẵn sàng copy
      alert("[color=#00E5FF]◈━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━◈[/color]\n"
          .. "  [color=#FFD700][b]📤 PHẦN MỀM XUẤT BẰNG CHỨNG (EXPORT RUNTIME EVIDENCE)[/b][/color]\n"
          .. "  [color=#00E5FF]◈━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━◈[/color]\n\n"
          .. "Quý vị vừa hoàn thành các bước Test Runtime ở tính năng: [color=#1DE9B6]" .. f.desc .. "[/color]\n\n"
          .. logText)
  end

  -- Menu main loop — bao gồm danh mục test & xuất bằng chứng
  local function showMainMenu()
      local choices = {
          "1. Tính năng Massege - Không rõ RUNTIME\n   (Màn hình Test Runtime)",
          "2. 🧪 TEST RUNTIME (Kiểm Thử từng tính năng chi tiết a-z)",
          "3. 📤 Xuất Bằng Chứng (Export Evidence) - Dành cho Finalscript",
          "4. Thoát / Exit Script"
      }

      local sel = gg.choice(choices, nil, "[color=#FFD700][b]⚡ " .. SCRIPT_NAME .. "[/b][/color] [color=#B0BEC5]v" .. VERSION ..
  "[/color]")
      if not sel then return end

      if sel == 1 then
          sel = featuresForTesting
      elseif sel == 2 then
          runRuntimeTestMenu()
      elseif sel == 3 then
          exportRuntimeEvidence(1)  -- Xuất bằng chứng đầu tiên, copy và cho sinh final
      end
      -- Kết thúc exit
      gg.toast("👋 Cuối cùng, hãy kích hoạt script để chạy nhé!")
  end

  -- Menu chi tiết từng feature A-Z kiểm thử
  local function runRuntimeTestMenu()
      local menu = gg.choice({
          "[color=#FFD700][b]🧪 TEST RUNTIME (MA SỐCHỦ CHI TIẾT CỰCH CÁCH)[/b][/color]\n"
          .. "[color=#B0BEC5]Chọn 1 tính năng để làm theo hướng dẫn chi tiết bước A-Z[/color]",
          "Out / Return"
      }, nil, "🧪 TEST RUNTIME - Kiểm Thử Runtime")
      if not menu or menu == 1 then return end  -- cho back về Exit

      -- ===== BẢNG SINH HOẠCH CHI TIẾT KỂ THEO TOÀN SỬ =====
      local rtChoices = {
          "[color=#FFD700][b]1. 🛡🛡 ẢNH NỀN VÔ HẠN GOD MODE[/b][/color] - Chỉ số ảnh nền ∞\n\n"
          .. "[color=#B0BEC5]-- Bước A: Mở tiến trình game --> bạn chọn tiến trình[/color]\n"
          .. "[color=#B0BEC5]-- Bước B: Lấy thông tin kiểm chứng tại menu\n"
          .. "[color=#B0BEC5]-- Bước C: Quét giá trị trong vùng ANONYMOUS / CA / Cd\n"
          .. "[color=#FFD700]-- Bước D: Thay đổi giá trị trong game theo định nghĩa\n"
          .. "[color=#FFD700]-- Bước E: Sao chép thông tin thay đổi → copy cho Paste dưới đây\n"
          .. "[color=#FFD700]-- Bước F: Lọc refine bằng số Integer trong Zone Cd\n"
          .. "[color=#FFD700]-- Bước G: Sao chép Final value → gửi cho finalscript\n"
          .. "[color=#FFD700]-- Bước H: Đổi gỡ ⇒ Xuất bằng chứng → Xuất để đến final script",

          "[color=#FFD700][b]2. 💰💰 TÀI NGUYÊN VÔ HẠN INFINITE RESOURCES[/b][/color] - Tiền ∞ / chỉ số ∞\n\n"
          .. "[color=#B0BEC5]-- Bước A: Lấy tiến trình tương thích mở ra game\n"
          .. "[color=#B0BEC5]-- Bước B: Tìm kiếm giá trị theo kiểu Float\n"
          .. "[color=#B0BEC5]-- Bước C: Đổi đơn vị nhằm thấy dòng ĐỘNG CHỈ GIẢI ĐỔ\n"
          .. "[color=#FFD700]-- Bước D: Đổi dữ liệu → gửi cho finalscript → final script tự động 100%",

          "[color=#FFD700][b]3. ⚔️ ⚔️  SÁT THƯƠNG NHÂN ĐIỆN ĐỘ II / iii[/b][/color] - Ma lực tăng\n\n"
          .. "[color=#B0BEC5]-- Bước A: Tìm kiếm gi giá trị Float ban đầu\n"
          .. "[color=#B0BEC5]-- Bước B: Thay đổi trong game ⇒ chỉ số chú não đí trí trí trí logic\n"
          .. "[color=#FFD700]-- Bước C: Lọc refine → Loc đảo việc → Published context cho finalscript",

          "[color=#FFD700][b]4. 🛠🛠 TỐC ĐỘ XÂY DỰNG NHANH[/b][/color] - Q cộng tốc độ build\n\n"
          .. "[color=#B0BEC5]-- Bước A: Tìm kiếm Float hoặc Dword chuẩn theo game\n"
          .. "[color=#B0BEC5]-- Bước B: Thay đổi tùy chỉnh ⇒ Game sôi mới đúng ✓\n"
          .. "[color=#FFD700]-- Bước C: Sao chép phy → du đούν → Xuất bằng chứng vào finalscript"
      }

      local sel2 = gg.choice(rtChoices, nil, "🧪 Chọn chỉ số test bằng chứng chi tiết")
      if not sel2 or sel2 == 1 then
          -- Xuất bằng chứng của tính năng 1
          exportRuntimeEvidence(1)
      elseif sel2 == 2 then
          exportRuntimeEvidence(2)
      elseif sel2 == 3 then
          exportRuntimeEvidence(3)
      elseif sel2 == 4 then
          exportRuntimeEvidence(4)
      end
  end

  ---
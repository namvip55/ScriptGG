-- ==========================================
  -- HCR MULTI-RESOURCE SCRIPT (COIN & GEMS)
  -- Chức năng: Scan, Refine, Modify & Restore
  -- ==========================================

  -- Biến trạng thái Coin
  local coinState = {
      hasScan = false,
      lastVal = nil,
      savedResult = nil,
      isModified = false
  }

  -- Biến trạng thái Gem
  local gemState = {
      hasScan = false,
      lastVal = nil,
      savedResult = nil,
      isModified = false
  }

  -- Hàm nhập giá trị hợp lệ
  local function inputResourceValue(promptTitle)
      local input = gg.prompt({promptTitle}, {""}, {"number"})
      if input == nil then return nil end

      local value = tonumber(input[1])
      if value == nil or value < 0 or value ~= math.floor(value) then
          gg.alert("❌ Giá trị nhập vào không hợp lệ (Phải là số nguyên >= 0).")
          return nil
      end

      return value
  end

  -- ==========================================
  -- HÀM XỬ LÝ CHUNG CHO TÀI NGUYÊN (COIN / GEM)
  -- ==========================================

  local function scanResource(state, name)
      if state.isModified then
          gg.alert("⚠️  Bạn cần Restore " .. name .. " về giá trị gốc trước khi Scan mới!")
          return
      end

      local title = "Nhập số " .. name .. " hiện tại:"
      if state.hasScan then
          title = "Nhập số " .. name .. " mới để Refine (Lọc):"
      end

      local val = inputResourceValue(title)
      if val == nil then return end

      gg.setRanges(gg.REGION_ANONYMOUS)

      if not state.hasScan then
          gg.clearResults()
          gg.searchNumber(tostring(val), gg.TYPE_DWORD)
      else
          gg.refineNumber(tostring(val), gg.TYPE_DWORD)
      end

      local count = gg.getResultsCount()

      if count == 0 then
          gg.clearResults()
          state.hasScan = false
          state.lastVal = nil
          gg.alert("❌ Không tìm thấy kết quả phù hợp cho " .. name .. ".")
          return
      end

      state.hasScan = true
      state.lastVal = val
      gg.toast("🔍 Tìm thấy: " .. tostring(count) .. " kết quả.")
      gg.alert("Đã tìm thấy " .. tostring(count) .. " kết quả cho " .. name .. ".\nNếu còn nhiều kết quả, hãy thay đổi số " .. name .. trong game rồi Scan lại để Lọc
  (Refine).")
  end

  local function showResourceStatus(state, name)
      if not state.hasScan then
          gg.alert("⚠️  Chưa thực hiện Scan " .. name .. ".")
          return
      end

      gg.alert(
          "📊 Trạng thái " .. name .. ":\n" ..
          "- Giá trị Scan gần nhất: " .. tostring(state.lastVal) .. "\n" ..
          "- Số lượng kết quả còn lại: " .. tostring(gg.getResultsCount()) .. "\n" ..
          "- Trạng thái Modify: " .. (state.isModified and "Đã sửa" or "Chưa sửa")
      )
  end

  local function modifyResource(state, name)
      if not state.hasScan or state.isModified then
          gg.alert("⚠️  Không thể Modify lúc này (Chưa scan hoặc đã modify trước đó).")
          return
      end

      local count = gg.getResultsCount()
      if count == 0 then
          gg.alert("❌ Không có kết quả nào để Modify.")
          return
      elseif count > 10 then
          gg.alert("⚠️  Còn quá nhiều kết quả (" .. tostring(count) .. "). Vui lòng Refine thêm để tránh crash game!")
          return
      end

      local results = gg.getResults(1)
      if results == nil or results[1] == nil then
          gg.alert("❌ Không đọc được dữ liệu bộ nhớ.")
          return
      end

      local result = results[1]

      if tonumber(result.value) ~= tonumber(state.lastVal) then
          gg.alert("❌ Giá trị bộ nhớ không khớp với giá trị đã Scan gần nhất.")
          return
      end

      local newVal = inputResourceValue("Nhập số " .. name .. " mới mong muốn:")
      if newVal == nil then return end

      state.savedResult = {
          address = result.address,
          flags = result.flags,
          value = result.value
      }

      local ok, err = pcall(function()
          gg.setValues({
              {
                  address = state.savedResult.address,
                  flags = state.savedResult.flags,
                  value = newVal
              }
          })
      end)

      if not ok then
          state.savedResult = nil
          gg.alert("❌ Lỗi Modify " .. name .. ": " .. tostring(err))
          return
      end

      state.isModified = true
      state.lastVal = newVal
      gg.toast("✅ Thay đổi " .. name .. " thành công!")
      gg.alert("🎉 Đã Modify " .. name .. " thành " .. tostring(newVal) .. "!")
  end

  local function restoreResource(state, name)
      if not state.isModified or state.savedResult == nil then
          gg.alert("⚠️  Không có dữ liệu để Restore " .. name .. ".")
          return
      end

      local ok, err = pcall(function()
          gg.setValues({
              {
                  address = state.savedResult.address,
                  flags = state.savedResult.flags,
                  value = state.savedResult.value
              }
          })
      end)

      if not ok then
          gg.alert("❌ Lỗi Restore " .. name .. ": " .. tostring(err))
          return
      end

      state.isModified = false
      state.savedResult = nil
      state.hasScan = false
      state.lastVal = nil

      gg.clearResults()
      gg.toast("🔄 Khôi phục " .. name .. " hoàn tất!")
      gg.alert("✅ Đã khôi phục " .. name .. " về giá trị gốc thành công.")
  end

  -- ==========================================
  -- SYSTEM MENUS
  -- ==========================================

  local function subMenu(state, name)
      while true do
          local choice = gg.choice({
              "1. 🔍 Scan / Refine " .. name,
              "2. 📊 Xem kết quả Scan",
              "3. ✏️  Modify " .. name,
              "4. 🔄 Restore " .. name,
              "❌ Quay lại Menu chính"
          }, nil, "=== QUẢN LÝ " .. string.upper(name) .. " ===")

          if choice == nil or choice == 5 then break end

          if choice == 1 then scanResource(state, name) end
          if choice == 2 then showResourceStatus(state, name) end
          if choice == 3 then modifyResource(state, name) end
          if choice == 4 then restoreResource(state, name) end
      end
  end

  local function mainMenu()
      while true do
          local choice = gg.choice({
              "🪙  Quản lý COIN (Tiền)",
              "💎 Quản lý GEMS (Kim Cương)",
              "🚪 Thoát Script"
          }, nil, "=== HILL CLIMB RACING SCRIPT ===")

          if choice == nil or choice == 3 then
              gg.toast("👋 Tạm biệt!")
              break
          end

          if choice == 1 then subMenu(coinState, "Coin") end
          if choice == 2 then subMenu(gemState, "Gems") end
      end
  end

  -- Khởi chạy script
  gg.clearResults()
  mainMenu()
  gg.clearResults()

  ---
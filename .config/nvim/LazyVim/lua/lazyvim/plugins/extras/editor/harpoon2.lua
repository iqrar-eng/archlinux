return {
  "ThePrimeagen/harpoon",
  event = "VeryLazy",
  branch = "harpoon2",
  config = function()
    local harpoon = require("harpoon")
    require("harpoon"):setup({
      settings = {
        save_on_toggle = true,
        sync_on_ui_close = true,
        key = function()
          return "global"
        end,
      },
    })

    ----------------------------------------------

    local harpoon_menu_opts = {
      ui_width_ratio = 1, -- 100% of editor width
      height_in_lines = vim.o.lines - 1,
      border = "",
    }

    vim.keymap.set("n", "<leader>ac", function()
      harpoon.ui:toggle_quick_menu(harpoon:list("todo"), harpoon_menu_opts)
    end)

    vim.keymap.set("n", "<leader>ay", function()
      harpoon.ui:toggle_quick_menu(harpoon:list(), harpoon_menu_opts)
    end)

    ------------------------------------------------

    local function setup_select_keys(prefix, list_name)
      for i = 1, 9 do
        local k = prefix .. "<M-" .. i .. ">"
        vim.keymap.set({ "n", "i" }, k, function()
          local list = harpoon:list(list_name)
          if i == 9 then
            list:select(#list.items)
            return
          end
          local count = vim.v.count
          local target = count > 0 and (count * i) or i
          list:select(target)
        end, { desc = "harpoon (" .. (list_name or "default") .. "): select buffer " .. i .. " (or N×" .. i .. " with count)" })
      end
    end

    setup_select_keys("", nil) -- <M-1> .. <M-9>, default list
    setup_select_keys("<C-c>", "todo") -- <C-c><M-1> .. <C-c><M-9>, "todo" list

    ------------------------------------------------

    local function normalize_list_paths(list)
      for _, item in ipairs(list.items) do
        if item then
          item.value = vim.fn.fnamemodify(item.value, ":p")
        end
      end
    end

    local function ensure_harpoon_index(list)
      normalize_list_paths(list)
      local current = vim.fn.expand("%:p")
      for idx, item in ipairs(list.items) do
        if item.value == current then
          return idx
        end
      end
      list:add() -- fixed: adds to the SAME list passed in, not always the default
      normalize_list_paths(list)
      return #list.items
    end

    local function harpoon_move_block_to(from, count, to, list)
      normalize_list_paths(list)

      -- collapse into a dense array first (drop holes, use real length)
      local dense = {}
      for i = 1, list._length do
        if list.items[i] then
          table.insert(dense, list.items[i])
        end
      end

      count = math.max(1, count)
      local last = math.min(from + count - 1, #dense)
      local block = {}
      for idx = from, last do
        table.insert(block, dense[idx])
      end
      for _ = from, last do
        table.remove(dense, from)
      end

      to = math.max(1, math.min(to, #dense + 1))
      for offset, item in ipairs(block) do
        table.insert(dense, to + offset - 1, item)
      end

      list.items = dense
      list._length = #dense -- safe: dense has no holes
      harpoon:sync()
    end

    local function setup_move_keys(prefix, list_name)
      for i = 1, 9 do
        local k = prefix .. "<M-" .. i .. ">"
        vim.keymap.set("n", k, function()
          local list = harpoon:list(list_name)
          local from = ensure_harpoon_index(list)
          local count = vim.v.count > 0 and vim.v.count or 1
          local to = (i == 9) and #list.items or i
          harpoon_move_block_to(from, count, to, list)
          vim.notify(to, vim.log.levels.INFO)
        end, { desc = "Harpoon (" .. (list_name or "default") .. "): Move current file to slot " .. i .. " (use a count to bring following files along)" })
      end
    end

    setup_move_keys("y", nil) -- default list
    setup_move_keys("c", "todo") -- "todo" list
  end,
}

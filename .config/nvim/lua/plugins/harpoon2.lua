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
		end, { desc = "harpoon list todo" })

		vim.keymap.set("n", "<leader>ay", function()
			harpoon.ui:toggle_quick_menu(harpoon:list(), harpoon_menu_opts)
		end, { desc = "harpoon list default" })

		vim.keymap.set({ "n", "i" }, "<M-C-P>", function()
			harpoon:list("todo"):prev()
		end)
		vim.keymap.set({ "n", "i" }, "<M-C-N>", function()
			harpoon:list("todo"):next()
		end)

		vim.keymap.set({ "n", "i" }, "<C-S-Z>", function()
			harpoon:list():prev()
		end)
		vim.keymap.set({ "n", "i" }, "<C-Z>", function()
			harpoon:list():next()
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
				end, {
					desc = "harpoon ("
						.. (list_name or "default")
						.. "): select buffer "
						.. i
						.. " (or N×"
						.. i
						.. " with count)",
				})
			end
		end

		setup_select_keys("", nil) -- <M-1> .. <M-9>, default list
		setup_select_keys("<C-c>", "todo") -- <C-c><M-1> .. <C-c><M-9>, "todo" list

		------------------------------------------------

		-- Appends `item` strictly after the last occupied slot — never reuses
		-- a hole/blank line, unlike list:add(). Emits the same ADD event add()
		-- would, so extensions (sync, etc.) still fire correctly.
		local function append_no_reuse(list, item)
			local Extensions = require("harpoon.extensions")
			item = item or list.config.create_list_item(list.config)
			item.value = vim.fn.fnamemodify(item.value, ":p")
			local idx = list._length + 1
			list.items[idx] = item
			list._length = idx
			Extensions.extensions:emit(Extensions.event_names.ADD, {
				list = list,
				item = item,
				idx = idx,
			})
			return idx
		end

		-- Returns idx of `list.items[idx].value` (resolved to an absolute path
		-- for comparison only) that matches the current buffer, without writing
		-- back into any item in the list. Adds the current buffer via
		-- append_no_reuse if it isn't already in the list.
		local function ensure_harpoon_index(list)
			local current = vim.fn.expand("%:p")
			for idx = 1, list._length do
				local item = list.items[idx]
				if item and vim.fn.fnamemodify(item.value, ":p") == current then
					return idx
				end
			end
			return append_no_reuse(list, list.config.create_list_item(list.config, current))
		end

		-- Moves a block of `count` slots starting at `from` so it starts at
		-- `to`, rippling the slots in between by `count` to close the gap.
		-- Holes move along as ordinary slot contents. Nothing outside
		-- [min(from,to), max(from+count-1, to+count-1)] is touched.
		local function harpoon_shift_block(from, count, to, list)
			count = math.max(1, count)
			if to == from then
				return
			end

			local block = {}
			for i = 0, count - 1 do
				block[i + 1] = list.items[from + i]
			end

			if to > from then
				for i = from + count, to + count - 1 do
					list.items[i - count] = list.items[i]
				end
			else
				for i = from - 1, to, -1 do
					list.items[i + count] = list.items[i]
				end
			end

			for i = 0, count - 1 do
				list.items[to + i] = block[i + 1]
			end

			local highest_touched = math.max(from + count - 1, to + count - 1)
			if highest_touched > list._length then
				list._length = highest_touched
			end
			-- not shrinking _length here — determine_length is still not exported
			-- from list.lua; a block carrying a trailing hole to the list's end
			-- can leave _length stale-high until a real remove() runs.

			harpoon:sync()
		end

		local function setup_move_keys(prefix, list_name)
			for i = 1, 9 do
				local k = prefix .. "<M-" .. i .. ">"
				vim.keymap.set("n", k, function()
					local list = harpoon:list(list_name)
					local from = ensure_harpoon_index(list)
					local count = math.min(vim.v.count > 0 and vim.v.count or 1, list._length - from + 1)
					local last_start = list._length - count + 1
					local to = math.min((i == 9) and last_start or i, last_start)
					harpoon_shift_block(from, count, to, list)
					vim.notify(to, vim.log.levels.INFO)
				end, {
					desc = "Harpoon ("
						.. (list_name or "default")
						.. "): Shift current file's block to slot "
						.. i
						.. " (use a count to bring following files along)",
				})
			end
		end

		setup_move_keys("y", nil) -- default list
		setup_move_keys("c", "todo") -- "todo" list
	end,
}

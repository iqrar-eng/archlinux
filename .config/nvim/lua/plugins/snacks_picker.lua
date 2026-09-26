local function make_harpoon_picker_source(list_name)
	return {
		finder = function(opts, ctx)
			local list = require("harpoon"):list(list_name)
			local files = {}
			for idx = 1, list:length() do
				local item = list:get(idx)
				if item then
					table.insert(files, {
						text = item.value,
						file = item.value,
						idx = idx,
					})
				end
			end
			return files
		end,
		format = "file",
		preview = "file",
		confirm = "jump",
		actions = {
			harpoon_remove = function(picker)
				local items = picker:selected({ fallback = true })
				if #items == 0 then
					return
				end

				local harpoon = require("harpoon")
				local list = harpoon:list(list_name)

				-- remove by VALUE, not by cached idx — idx can be stale/duplicated
				local values_to_remove = {}
				for _, it in ipairs(items) do
					values_to_remove[it.file] = true
				end

				-- walk the underlying items high-to-low and splice them out directly
				-- (list:remove_at leaves holes in some harpoon2 versions when the
				-- internal table already has gaps; rebuilding is the reliable fix)
				local kept = {}
				for i = 1, list:length() do
					local item = list:get(i)
					if item and not values_to_remove[item.value] then
						table.insert(kept, item)
					end
				end

				list.items = kept
				harpoon:sync()
				picker:find()
			end,
		},
		win = {
			input = {
				keys = {
					["<C-K>"] = { "harpoon_remove", mode = { "n", "x", "i" } },
				},
			},
		},
	}
end

local function up(path, count)
	for _ = 1, count do
		path = vim.fn.fnamemodify(path, ":h")
	end
	return path
end

local function get_basedir()
	local count = vim.v.count
	local buf_path = vim.api.nvim_buf_get_name(0)
	local base = buf_path ~= "" and vim.fn.fnamemodify(buf_path, ":h") or vim.uv.cwd()
	return count > 1 and up(base, count - 1) or base
end

return {
	{
		"folke/snacks.nvim",
		opts = {
			scratch = {
				autowrite = false, -- prevent the callback that re-hides the buffer
				win_by_ft = { lua = { keys = { ["source"] = false } } },
			},
			input = { win = { b = { completion = true } } },
			styles = {
				scratch = { position = "current", keys = { q = false } },
				input = {
					keys = {
						i_ctrl_c = { "<C-c>", "cancel", mode = "i" },
						n_ctrl_c = { "<C-c>", "cancel", mode = "n" },
					},
				},
			},
			indent = {
				indent = {
					hl = {
						"SnacksIndent1",
						"SnacksIndent2",
						"SnacksIndent3",
						"SnacksIndent4",
						"SnacksIndent5",
						"SnacksIndent6",
						"SnacksIndent7",
						"SnacksIndent8",
						"SnacksIndent9",
						"SnacksIndent10",
						"SnacksIndent11",
						"SnacksIndent12",
					},
				},
			},
			picker = {
				layout = "custom_layout",
				layouts = {
					custom_layout = {
						layout = {
							reverse = true,
							backdrop = false,
							width = 0,
							min_width = 0,
							height = 0,
							box = "vertical",
							{ win = "preview", height = 0.7 },
							{ win = "input", height = 1 },
							{ win = "list" },
						},
					},
				},
				actions = {
					-- Snacks.picker.grep() closes any picker of the same source before opening a
					-- new one (see snacks/picker/init.lua:M.pick). Since this action runs from
					-- inside a grep picker, that would just close us with nothing replacing it.
					-- Call the constructor .new( ... ) to stack a new grep picker on top instead.
					picker_grep = function(picker, item)
						if item then
							require("snacks.picker.core.picker").new({
								source = "grep",
								cwd = Snacks.picker.util.dir(item),
							})
						end
					end,

					picker_files = function(picker, item)
						if not item then
							return
						end
						require("snacks.picker.core.picker").new({
							source = "files",
							cwd = Snacks.picker.util.dir(item),
						})
					end,

					picker_grep_root = function(picker, item)
						if not item then
							return
						end
						local path = Snacks.picker.util.path(item)
						if not path then
							return
						end
						local buf = vim.fn.bufadd(path)
						local root = LazyVim.root.get({ buf = buf })
						require("snacks.picker.core.picker").new({ source = "grep", cwd = root })
					end,

					picker_files_root = function(picker, item)
						if not item then
							return
						end
						local path = Snacks.picker.util.path(item)
						if not path then
							return
						end
						local buf = vim.fn.bufadd(path)
						vim.fn.bufload(buf)
						local root = LazyVim.root.get({ buf = buf })
						require("snacks.picker.core.picker").new({ source = "files", cwd = root })
					end,

					picker_grep_current_selected = function(picker)
						local paths = vim.tbl_map(Snacks.picker.util.path, picker:selected({ fallback = true }))
						if #paths == 0 then
							return
						end
						require("snacks.picker.core.picker").new(Snacks.picker.config.get({
							source = "grep",
							dirs = paths,
						}))
					end,

					yank_preview = function(picker)
						local items = picker:selected({ fallback = true })
						if #items == 0 then
							return
						end
						local chunks = {}
						for _, it in ipairs(items) do
							if type(it.preview) == "table" and it.preview.text then
								table.insert(chunks, it.preview.text)
							elseif it.buf and vim.api.nvim_buf_is_loaded(it.buf) then
								table.insert(
									chunks,
									table.concat(vim.api.nvim_buf_get_lines(it.buf, 0, -1, false), "\n")
								)
							elseif it.file then
								local path = vim.fn.expand(Snacks.picker.util.path(it))
								if vim.fn.filereadable(path) == 1 then
									table.insert(chunks, table.concat(vim.fn.readfile(path), "\n"))
								end
							elseif it.text or it.data then
								table.insert(chunks, it.text or it.data)
							end
						end
						if #chunks == 0 then
							return
						end
						local content = table.concat(chunks, "\n\n")
						local line_count = select(2, content:gsub("\n", "\n")) + 1
						if line_count > 500 then
							local tmpfile = vim.fn.tempname() .. "_large_file.txt"
							vim.fn.writefile(vim.split(content, "\n"), tmpfile)
							local uri_list = "file://" .. tmpfile .. "\n"
							local gnome = "copy\n" .. uri_list
							local script = ("copy('text/uri-list',%s,'x-special/gnome-copied-files',%s)"):format(
								vim.json.encode(uri_list),
								vim.json.encode(gnome)
							)
							vim.fn.jobstart({ "copyq", "eval", "--", script })
							Snacks.notify(
								tmpfile,
								{ title = ("Yanked %d item(s) | %d line(s) to tmp file:"):format(#items, line_count) }
							)
						else
							vim.fn.setreg("+", content)
							Snacks.notify(
								content,
								{ title = ("Yanked %d item(s) | %d line(s) to `*`"):format(#items, line_count) }
							)
						end
					end,
				},
				sources = {
					harpoon = make_harpoon_picker_source(nil), -- default list
					harpoon_todo = make_harpoon_picker_source("todo"),
					lines = { layout = { preview = "top", preset = "custom_layout" } },
					todo_comments = { hidden = true },
					explorer = { hidden = true, ignored = true },
					files = { hidden = true, follow = true },
					grep = { hidden = true, regex = false },
					grep_word = { hidden = true, auto_confirm = true },
				},
        -- stylua: ignore
				win = {
					input = {
						keys = {
							["<C-J>"] = { "yank_preview", mode = { "n", "x", "s", "i" } },
							["<C-c>"] = { "cancel", mode = { "n", "x", "i" } },
							["/"] = { "/", mode = { "n", "x" }, expr = true, desc = "delete word" },
							["?"] = { "?", mode = { "n", "x" }, expr = true, desc = "delete word" },
							["g?"] = "toggle_help_list",
							["<M-1>"] = { function() require("dial.map").manipulate("increment", "normal") end, mode = { "n" }, desc = "Increment", },
							["<M-4>"] = { function() require("dial.map").manipulate("decrement", "normal") end, mode = { "n" }, desc = "Decrement", },
							["<C-L>"] = { "focus_list", mode = { "n", "x", "i" } },
							["<PageUp>"] = { "list_scroll_up", mode = { "n", "x", "i" } },
							["<PageDown>"] = { "list_scroll_down", mode = { "n", "x", "i" } },
							["<C-Home>"] = { "list_top", mode = { "n", "x", "i" } },
							["<C-End>"] = { "list_bottom", mode = { "n", "x", "i" } },
							["<M-w>"] = { "focus_preview", mode = { "n", "x", "i" } },
							["<M-9>"] = { "<C-A>", mode = { "i" }, expr = true, desc = "delete word" },

              ["<C-F>"] = { "picker_grep_current_selected", mode = { "n", "x", "s", "i" } },
              ["<C-S-W>"] = { "picker_files", mode = { "n", "x", "s", "i" } },
              ["<C-S-N>"] = { "picker_grep", mode = { "n", "x", "s", "i" } },
              ["<M-C-C>"] = { "picker_files_root", mode = { "n", "x", "s", "i" } },
              ["<M-C-D>"] = { "picker_grep_root", mode = { "n", "x", "s", "i" } },

							["<M-2>"] = { "preview_scroll_down", mode = { "n", "x", "s", "i" } },
							["<M-3>"] = { "preview_scroll_up", mode = { "n", "x", "s", "i" } },
              ["<M-5>"] = { vim.fn["repeat"]({ "preview_scroll_left" }, 130), mode = { "n", "x", "s", "i" }, },
              ["<M-8>"] = { vim.fn["repeat"]({ "preview_scroll_right" }, 130), mode = { "n", "x", "s", "i" }, },
              ["<M-6>"] = { vim.fn["repeat"]({ "preview_scroll_down" }, 999), mode = { "n", "x", "s", "i" }, },
              ["<M-7>"] = { vim.fn["repeat"]({ "preview_scroll_up" }, 999), mode = { "n", "x", "s", "i" }, },

							["<M-'>"] = { "explorer_focus", mode = { "n", "x", "s", "i" } },
							["<M-m>"] = { "explorer_move", mode = { "n", "x", "s", "i" } },
							["<M-C-S-End>"] = { "explorer_up", mode = { "n", "x", "s", "i" } },
							["<M-m>"] = { "explorer_move", mode = { "n", "x", "i" } },
							["<C-D>"] = { "explorer_yank", mode = { "n", "x", "i" } },
							["<M-C-Y>"] = { "explorer_open", mode = { "n", "x", "i" } },
							["<M-C-S>"] = { "explorer_paste", mode = { "n", "x", "i" } },
							["<M-g>"] = { "explorer_del", mode = { "n", "x", "i" } },
							["<M-n>"] = { "explorer_add", mode = { "n", "x", "i" } },
							["<M-N>"] = { "explorer_rename", mode = { "n", "x", "i" } },
						},
					},
					list = {
						keys = {
							["<C-J>"] = { "yank_preview", mode = { "n", "x", "s", "i" } },
							["<C-c>"] = { "cancel", mode = { "n", "x", "i" } },
							["/"] = { "/", mode = { "n", "x" }, expr = true, desc = "delete word" },
							["?"] = { "?", mode = { "n", "x" }, expr = true, desc = "delete word" },
							["g?"] = "toggle_help_list",
							["<PageUp>"] = "list_scroll_up",
							["<PageDown>"] = "list_scroll_down",
							["<C-Home>"] = "list_top",
							["<C-End>"] = "list_bottom",
							["<M-w>"] = { "focus_preview", mode = { "n", "x", "i" } },

              ["<C-F>"] = { "picker_grep_current_selected", mode = { "n", "x", "s", "i" } },
              ["<C-S-W>"] = { "picker_files", mode = { "n", "x", "s", "i" } },
              ["<C-S-N>"] = { "picker_grep", mode = { "n", "x", "s", "i" } },
              ["<M-C-C>"] = { "picker_files_root", mode = { "n", "x", "s", "i" } },
              ["<M-C-D>"] = { "picker_grep_root", mode = { "n", "x", "s", "i" } },

							["<M-2>"] = { "preview_scroll_down", mode = { "n", "x", "s", "i" } },
							["<M-3>"] = { "preview_scroll_up", mode = { "n", "x", "s", "i" } },
              ["<M-5>"] = { vim.fn["repeat"]({ "preview_scroll_left" }, 130), mode = { "n", "x", "s", "i" }, },
              ["<M-8>"] = { vim.fn["repeat"]({ "preview_scroll_right" }, 130), mode = { "n", "x", "s", "i" }, },
              ["<M-6>"] = { vim.fn["repeat"]({ "preview_scroll_down" }, 999), mode = { "n", "x", "s", "i" }, },
              ["<M-7>"] = { vim.fn["repeat"]({ "preview_scroll_up" }, 999), mode = { "n", "x", "s", "i" }, },

							["<M-'>"] = { "explorer_focus", mode = { "n", "x", "s", "i" } },
							["<M-m>"] = { "explorer_move", mode = { "n", "x", "s", "i" } },
							["<M-C-S-End>"] = { "explorer_up", mode = { "n", "x", "s", "i" } },
							["<M-m>"] = { "explorer_move", mode = { "n", "x", "i" } },
							["<C-D>"] = { "explorer_yank", mode = { "n", "x", "i" } },
							["<M-C-Y>"] = { "explorer_open", mode = { "n", "x", "i" } },
							["<M-C-S>"] = { "explorer_paste", mode = { "n", "x", "i" } },
							["<M-g>"] = { "explorer_del", mode = { "n", "x", "i" } },
							["<M-n>"] = { "explorer_add", mode = { "n", "x", "i" } },
							["<M-N>"] = { "explorer_rename", mode = { "n", "x", "i" } },
						},
					},
					preview = {
						keys = {
							["<C-c>"] = { "cancel", mode = { "n", "x", "i" } },
							["<C-L>"] = { "focus_list", mode = { "n", "x", "i" } },
						},
					},
				},
			},
		},
    -- stylua: ignore
    keys = {
      { "<leader>fF", LazyVim.pick("files", { cwd = vim.fn.expand("~") }), desc = "Find Files (cwd)" },
      { "<leader>sG", LazyVim.pick("live_grep", { cwd = vim.fn.expand("~") }), desc = "Grep (cwd)" },
      { "<leader>sW", LazyVim.pick("grep_word", { cwd = vim.fn.expand("~") }), desc = "Visual selection or word (cwd)", mode = { "n", "x" } },

      { "<leader>ks", LazyVim.pick("files", { cwd = vim.fn.expand("~/archlinux/") }), desc = "Find Files archlinux", mode = { "n", "x" } },
      { "<leader>kS", LazyVim.pick("grep", { cwd = vim.fn.expand("~/archlinux/") }), desc = "Grep archlinux", mode = { "n", "x" } },
      { "<leader>kt", LazyVim.pick("files", { cwd = vim.fn.expand("~/.local/share/Trash/files/") }), desc = "Find Files Trash", mode = { "n", "x" } },
      { "<leader>kT", LazyVim.pick("grep", { cwd = vim.fn.expand("~/.local/share/Trash/files/") }), desc = "Grep Trash", mode = { "n", "x" } },
      { "<leader>kl", LazyVim.pick("files", { cwd = vim.fn.expand("~/.local/share/nvim/lazy/LazyVim") }), desc = "Find Files LazyVim", mode = { "n", "x" } },
      { "<leader>kL", LazyVim.pick("grep", { cwd = vim.fn.expand("~/.local/share/nvim/lazy/LazyVim") }), desc = "Grep LazyVim", mode = { "n", "x" } },

      { "<leader>kq", LazyVim.pick("files", { cwd = vim.fn.expand("~/.src/prisma/apps/docs/content/docs/") }), desc = "Find Files prisma", mode = { "n", "x" } },
      { "<leader>kQ", LazyVim.pick("grep", { cwd = vim.fn.expand("~/.src/prisma/apps/docs/content/docs/") }), desc = "Grep prisma", mode = { "n", "x" } },
      { "<leader>kb", LazyVim.pick("files", { cwd = vim.fn.expand("~/.src/better-auth/docs/content/docs") }), desc = "Find Files better-auth", mode = { "n", "x" } },
      { "<leader>kB", LazyVim.pick("grep", { cwd = vim.fn.expand("~/.src/better-auth/docs/content/docs") }), desc = "Grep better-auth", mode = { "n", "x" } },
      { "<leader>kx", LazyVim.pick("files", { cwd = vim.fn.expand("~/.src/next.js/docs/01-app") }), desc = "Find Files next.js", mode = { "n", "x" } },
      { "<leader>kX", LazyVim.pick("grep", { cwd = vim.fn.expand("~/.src/next.js/docs/01-app") }), desc = "Grep next.js", mode = { "n", "x" } },
      { "<leader>kd", LazyVim.pick("files", { cwd = vim.fn.expand("~/.src/node/doc/api") }), desc = "Find Files node", mode = { "n", "x" } },
      { "<leader>kD", LazyVim.pick("grep", { cwd = vim.fn.expand("~/.src/node/doc/api") }), desc = "Grep node", mode = { "n", "x" } },
      { "<leader>ka", LazyVim.pick("files", { cwd = vim.fn.expand("~/.src/mdn/files/en-us/web/api") }), desc = "Find Files mdn api", mode = { "n", "x" } },
      { "<leader>kA", LazyVim.pick("grep", { cwd = vim.fn.expand("~/.src/mdn/files/en-us/web/api") }), desc = "Grep mdn api", mode = { "n", "x" } },
      { "<leader>kh", LazyVim.pick("files", { cwd = vim.fn.expand("~/.src/mdn/files/en-us/web/http") }), desc = "Find Files mdn http", mode = { "n", "x" } },
      { "<leader>kH", LazyVim.pick("grep", { cwd = vim.fn.expand("~/.src/mdn/files/en-us/web/http") }), desc = "Grep mdn http", mode = { "n", "x" } },
      { "<leader>kj", LazyVim.pick("files", { cwd = vim.fn.expand("~/.src/mdn/files/en-us/web/javascript") }), desc = "Find Files mdn javascript", mode = { "n", "x" } },
      { "<leader>kJ", LazyVim.pick("grep", { cwd = vim.fn.expand("~/.src/mdn/files/en-us/web/javascript") }), desc = "Grep mdn javascript", mode = { "n", "x" } },
      { "<leader>kr", LazyVim.pick("files", { cwd = vim.fn.expand("~/.src/react/src/content/reference/") }), desc = "Find Files react", mode = { "n", "x" } },
      { "<leader>kR", LazyVim.pick("grep", { cwd = vim.fn.expand("~/.src/react/src/content/reference/") }), desc = "Grep react", mode = { "n", "x" } },
      { "<leader>kc", LazyVim.pick("files", { cwd = vim.fn.expand("~/.src/typescript-cheatsheets-react/docs") }), desc = "Find Files typescript-cheatsheets-react", mode = { "n", "x" } },
      { "<leader>kC", LazyVim.pick("grep", { cwd = vim.fn.expand("~/.src/typescript-cheatsheets-react/docs") }), desc = "Grep typescript-cheatsheets-react", mode = { "n", "x" } },

      { "<leader>ae", function() LazyVim.pick("files", { cwd = get_basedir() })() end, desc = "Find Files nth current dir", mode = { "n", "x" } },
      { "<leader>aE", function() LazyVim.pick("grep", { cwd = get_basedir() })() end, desc = "Grep nth current dir", mode = { "n", "x" } },
      { "<leader>ax", LazyVim.pick("live_grep", { cwd = vim.fn.stdpath("config") }), desc = "Grep Config File" },
      { "<leader>aY", function() Snacks.picker.harpoon() end, desc = "Harpoon Picker", mode = { "n", "x" } },
      { "<leader>aC", function() Snacks.picker.harpoon_todo() end, desc = "Harpoon Picker (todo)", mode = { "n", "x" } },
      { "<leader>aA", function() require("aerial").snacks_picker() end, desc = "aerial picker", mode = { "n", "x" } },
      { "<leader>aG",  function() Snacks.picker()                 end, desc = "All Pickers"     },
    },
	},
}

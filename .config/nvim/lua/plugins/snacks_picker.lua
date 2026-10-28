return {
	{
		"folke/snacks.nvim",
		opts = {
			explorer = { replace_netrw = false },
			scratch = { autowrite = false, win_by_ft = { lua = { keys = { ["source"] = false } } } },
			styles = { scratch = { position = "current", keys = { q = false } } },
			input = { win = { b = { completion = true } } },
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
					},
				},
			},
			picker = {
				layouts = {
					default = {
						layout = {
							width = 0,
							min_width = 0,
							height = 0,
						},
					},
					sidebar = {
						layout = {
							position = "left",
							width = 40,
							box = "vertical",
							{ win = "list", border = "none" },
							{ win = "preview", title = "{preview}", height = 0.4, border = "top" },
						},
					},
				},
				actions = {
					-- Snacks.picker.grep() closes any picker of the same source before opening a
					-- new one (see snacks/picker/init.lua:M.pick). Since this action runs from
					-- inside a grep picker, that would just close us with nothing replacing it.
					-- Call the constructor .new( ... ) to stack a new grep picker on top instead.
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
						if line_count > 400 then
							local tmpfile = vim.fn.tempname() .. "_large_ai_context"
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

					explorer_open = function(picker)
						for _, item in ipairs(picker:selected({ fallback = true })) do
							vim.ui.open(Snacks.picker.util.path(item))
						end
						picker.list:set_selected()
					end,
				},
				sources = {
					harpoon = {
						finder = function(opts, ctx)
							local list = require("harpoon"):list(opts.harpoon_list)
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
								local list = harpoon:list(picker.opts.harpoon_list)

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
									["<C-x>"] = { "harpoon_remove", mode = { "n", "x", "i" } },
								},
							},
						},
					},
					todo_comments = { hidden = true },
					explorer = { hidden = true, ignored = true },
					files = { hidden = true, follow = true },
					grep = { hidden = true, follow = true },
					grep_word = { hidden = true, follow = true, auto_confirm = true },
				},
        -- stylua: ignore
				win = {
					input = {
						keys = {
              ["<M-7>"] = { "preview_scroll_up", mode = { "i", "n" } },
							["<M-9>"] = { "yank_preview", mode = { "n", "x", "s", "i" } },
							["/"] = { "/", mode = { "n", "x" }, expr = true, desc = "delete word" },
							["?"] = { "?", mode = { "n", "x" }, expr = true, desc = "delete word" },
              ["<M-8>"] = { "focus_list", mode = { "n", "x", "i" } },

              ["<M-3>"] = { "picker_grep_current_selected", mode = { "n", "x", "s", "i" } },
              ["<M-1>"] = { "picker_files_root", mode = { "n", "x", "s", "i" } },
              ["<M-2>"] = { "picker_grep_root", mode = { "n", "x", "s", "i" } },

							["<C-S-M>"] = { "explorer_move", mode = { "n", "x", "i" } },
							["<C-S-Y>"] = { "explorer_yank", mode = { "n", "x", "i" } },
							["<C-S-O>"] = { "explorer_open", mode = { "n", "x", "i" } },
							["<C-S-P>"] = { "explorer_paste", mode = { "n", "x", "i" } },
							["<C-S-D>"] = { "explorer_del", mode = { "n", "x", "i" } },
							["<C-S-A>"] = { "explorer_add", mode = { "n", "x", "i" } },
							["<C-S-R>"] = { "explorer_rename", mode = { "n", "x", "i" } },
						},
					},
					list = {
						keys = {
              ["<M-7>"] = { "preview_scroll_up", mode = { "i", "n" } },
							["<M-9>"] = { "yank_preview", mode = { "n", "x", "s", "i" } },
							["/"] = { "/", mode = { "n", "x" }, expr = true, desc = "delete word" },
							["?"] = { "?", mode = { "n", "x" }, expr = true, desc = "delete word" },

              ["<M-3>"] = { "picker_grep_current_selected", mode = { "n", "x", "s", "i" } },
              ["<M-1>"] = { "picker_files_root", mode = { "n", "x", "s", "i" } },
              ["<M-2>"] = { "picker_grep_root", mode = { "n", "x", "s", "i" } },

							["<C-S-M>"] = { "explorer_move", mode = { "n", "x", "i" } },
							["<C-S-Y>"] = { "explorer_yank", mode = { "n", "x", "i" } },
							["<C-S-O>"] = { "explorer_open", mode = { "n", "x", "i" } },
							["<C-S-P>"] = { "explorer_paste", mode = { "n", "x", "i" } },
							["<C-S-D>"] = { "explorer_del", mode = { "n", "x", "i" } },
							["<C-S-A>"] = { "explorer_add", mode = { "n", "x", "i" } },
							["<C-S-R>"] = { "explorer_rename", mode = { "n", "x", "i" } },
						},
						wo = {
							number = true,
              relativenumber = true,
              numberwidth = 1,
						},
					},
				},
			},
		},
		-- stylua: ignore
		keys = {
		  { "<leader>gms", function() Snacks.picker.git_diff({ staged = false, group = true }) end, desc = "Git Status" },
		  { "<leader>aY", function() Snacks.picker.harpoon() end, desc = "harpoon Picker" },
		  { "<leader>aQ", function() Snacks.picker.harpoon({ harpoon_list = "quickfix" }) end, desc = "harpoon Picker (quickfix)" },
		  { "<leader>aZ", function() Snacks.picker.harpoon({ harpoon_list = "bookmarks" }) end, desc = "harpoon Picker (bookmarks)" },
		  { "<leader>aA", function() require("aerial").snacks_picker() end, desc = "aerial picker" },
		  { "<leader>aG",  function() Snacks.picker()                 end, desc = "All Pickers"     },
		},
		config = function(_, opts)
			require("snacks").setup(opts)

			local function register(prefix, entries)
				for i, entry in ipairs(entries) do
					local path, desc = entry[1], entry[2] or entry[1]
					local alphabet = string.char(string.byte("a") + i - 1)
					local function run(picker)
						return function()
							LazyVim.pick(picker, { cwd = vim.fn.expand(path) })()
						end
					end

					vim.keymap.set({ "n", "x" }, prefix .. alphabet, run("files"), { desc = "Find " .. desc })
					vim.keymap.set("n", prefix .. alphabet:upper(), run("grep"), { desc = "Grep " .. desc })
					vim.keymap.set(
						{ "n", "x" },
						prefix .. "<C-" .. alphabet .. ">",
						run("grep_word"),
						{ desc = "grep_word " .. desc }
					)
				end
			end

			register("<leader>k", {
				{ "~/archlinux" },
				{ "~/.src/better-auth/docs/content/docs", "better-auth" },
				{ "~/archlinux/.config/nvim", "nvim" },
				{ "~/.src/prisma/apps/docs/content/docs", "prisma" },
				{ "~/.local/share/Trash/files", "trash" },
				{ "~" },
				{ "~/.src/react/src/content/reference", "react" },
				{ "~/.src/mdn/files/en-us/web/http", "mdn http" },
				{ "~/.src/mdn/files/en-us/web/api", "mdn api" },
				{ "~/.src/mdn/files/en-us/web/javascript", "mdn javascript" },
				{ "~/.src/typescript-cheatsheets-react/docs", "typescript-cheatsheets-react" },
				{ "~/.local/share/nvim/lazy/LazyVim", "lazyVim" },
				{ "~/medical" },
				{ "~/.src/next.js/docs/01-app", "next.js" },
				{ "~/.src/node/doc/api", "node" },
				{ "~/personal" },
				{ "~/projects/" },
			})
		end,
	},
}

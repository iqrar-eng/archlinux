local state_dir = vim.fn.stdpath("state")
local state_file = state_dir .. "/explorer_auto"
local explorer_state = { auto = vim.fn.filereadable(state_file) == 0 or vim.fn.readfile(state_file)[1] == "1" }

local function save()
	vim.fn.mkdir(state_dir, "p")
	vim.fn.writefile({ explorer_state.auto and "1" or "0" }, state_file)
end

return {
	{
		"folke/snacks.nvim",
		event = "VeryLazy",
		opts = {
			picker = {
				sources = {
					explorer = {
						exclude = { ".git", ".github" },
						hidden = true,
						ignored = true,
						icons = { tree = { vertical = "│", middle = "├", last = "└" } },
						layouts = { sidebar = { layout = { width = 35 } } },
					},
				},
			},
		},
		keys = {
			{
				"<leader>e",
				function()
					local explorer = Snacks.picker.get({ source = "explorer" })[1]
					if explorer then
						explorer:close()
						explorer_state.auto = false
						save()
						return
					end
					local buf = vim.api.nvim_get_current_buf()
					local root = LazyVim.root.get({ buf = buf })
					Snacks.explorer({ cwd = root, focus = false })
					explorer_state.auto = true
					save()
				end,
				desc = "Toggle NvimTree (find file)",
			},
		},
		config = function(_, opts)
			require("snacks").setup(opts)
			vim.api.nvim_create_autocmd("VimEnter", {
				callback = function()
					if not explorer_state.auto then
						return
					end
					local buf = vim.api.nvim_get_current_buf()
					local file = vim.api.nvim_buf_get_name(buf)
					file = (file ~= "" and vim.uv.fs_realpath(file)) or file
					local root = LazyVim.root.get({ buf = buf })
					require("lazy").update({ show = false })
					if file ~= "" then
						vim.schedule(function()
							local picker = require("snacks.explorer").reveal({ file = file })
							if picker then
								picker.opts.enter = false
							end
						end)
					end
				end,
			})
		end,
	},
}

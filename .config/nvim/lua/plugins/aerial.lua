local state_dir = vim.fn.stdpath("state")
local state_file = state_dir .. "/aerial_auto"
local aerial_state = {
	auto = vim.fn.filereadable(state_file) == 0 or vim.fn.readfile(state_file)[1] == "1",
}

local function save()
	vim.fn.mkdir(state_dir, "p")
	vim.fn.writefile({ aerial_state.auto and "1" or "0" }, state_file)
end

return {
	{
		"stevearc/aerial.nvim",
		event = "LazyFile",
		opts = function(_, opts)
			-- opts already has icons + filter_kind from the LazyVim extra.
			-- Only override what you care about; mine wins on conflicts.
			return vim.tbl_deep_extend("force", opts, {
				autojump = true,
				open_automatic = function()
					return aerial_state.auto
				end,
				layout = {
					width = 35,
					placement = "edge",
					default_direction = "right",
					win_opts = {
						number = true,
						relativenumber = true,
						numberwidth = 1,
						signcolumn = "no",
						statuscolumn = "",
					},
				},
			})
		end,
		keys = {
			{
				"<leader>cs",
				function()
					aerial_state.auto = not aerial_state.auto
					save()
					if aerial_state.auto then
						require("aerial").open({ focus = false })
					else
						require("aerial").close()
					end
				end,
				desc = "Toggle Aerial auto-open",
			},
		},
	},
}

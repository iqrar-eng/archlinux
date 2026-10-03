return {
	{
		"stevearc/aerial.nvim",
		event = "LazyFile",
		opts = {
			autojump = true,
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
		},
		keys = {
			{ "<leader>at", "<cmd>AerialToggle!<cr>", desc = "Toggle Aerial (Symbols)" },
		},
	},
}

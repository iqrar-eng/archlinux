return {
	{ "snacks.nvim", opts = { dashboard = { enabled = false } } },
	{ "akinsho/bufferline.nvim", enabled = false },
	{ "nvim-mini/mini.pairs", enabled = false },

	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				marksman = { enabled = false },
				lua_ls = { enabled = false },
			},
		},
	},

	{
		"mfussenegger/nvim-lint",
		opts = {
			linters_by_ft = {
				markdown = {},
			},
		},
	},
}

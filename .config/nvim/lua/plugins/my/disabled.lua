return {
	{ "snacks.nvim", opts = { dashboard = { enabled = false } } },
	{ "akinsho/bufferline.nvim", enabled = false },

	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				marksman = { enabled = false },
				lua_ls = { enabled = false },
			},
		},
	},
}

return {
	{
		"nvim-mini/mini.operators",
		event = "VeryLazy",
		version = false,
		config = function()
			local mini = require("mini.operators")
			mini.setup({
				exchange = { prefix = "gz", reindent_linewise = true },
			})
			mini.make_mappings("replace", { textobject = "_", line = "", selection = "" })
		end,
	},

	{ "kylechui/nvim-surround", event = "VeryLazy" },
	{ "tpope/vim-fugitive", event = "VeryLazy" },
	{ "tpope/vim-abolish", event = "VeryLazy" },
	{ "saghen/filler-begone.nvim", event = "VeryLazy" },
}

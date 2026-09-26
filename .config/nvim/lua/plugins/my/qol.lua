return {
	{
		"nvim-mini/mini.bracketed",
		version = false,
		event = "VeryLazy",
		config = function()
			require("mini.bracketed").setup({
				buffer = { suffix = "" },
				comment = { suffix = "" },
				conflict = { suffix = "" },
				diagnostic = { suffix = "" },
				file = { suffix = "" },
				indent = { suffix = "" },
				jump = { suffix = "" },
				location = { suffix = "" },
				oldfile = { suffix = "" },
				quickfix = { suffix = "" },
				treesitter = { suffix = "" },
				undo = { suffix = "" },
				window = { suffix = "" },
				yank = { suffix = "" },
			})
			vim.keymap.set({ "n", "x" }, "<M-C-G>", "<Cmd>lua MiniBracketed.jump('backward')<CR>")
			vim.keymap.set({ "n", "x" }, "<M-C-F>", "<Cmd>lua MiniBracketed.jump('forward')<CR>")
			vim.keymap.set("n", "<C-S-U>", "<Cmd>lua MiniBracketed.oldfile('backward')<CR>")
			vim.keymap.set("n", "<C-S-W>", "<Cmd>lua MiniBracketed.oldfile('forward')<CR>")
			vim.keymap.set("n", "<leader>aL", "<Cmd>lua MiniBracketed.oldfile('last')<CR>")

			vim.keymap.set("n", "<M-C-H>", "<Cmd>lua MiniBracketed.file('forward')<CR>")
			vim.keymap.set("n", "<M-C-E>", "<Cmd>lua MiniBracketed.file('backward')<CR>")
			vim.keymap.set("n", "<leader>a{", "<Cmd>lua MiniBracketed.file('first')<CR>")
			vim.keymap.set("n", "<leader>a}", "<Cmd>lua MiniBracketed.file('last')<CR>")
		end,
	},

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

return {
	{
		"MagicDuck/grug-far.nvim",
		cmd = { "GrugFar", "GrugFarWithin" },
		opts = { wrap = false, windowCreationCommand = "tabnew" },
		keys = {
			{
				"<leader>ag",
				function()
					require("grug-far").open({ prefills = { paths = LazyVim.root.get(), flags = "-iFH" } })
				end,
				mode = { "n", "x" },
				desc = "grug-far: root",
			},

			{
				"<leader>am",
				function()
					require("grug-far").open({ prefills = { paths = vim.fn.expand("%"), flags = "-iFH" } })
				end,
				mode = { "n", "x" },
				desc = "grug-far: current file",
			},
		},
	},

	{
		"folke/flash.nvim",
		event = "VeryLazy",
		vscode = true,
		opts = {
			label = { before = true, after = false, rainbow = { enabled = true, shade = 6 } },
			highlight = { backdrop = false },
			modes = {
				search = { enabled = true, highlight = { backdrop = false } },
				char = {
					autohide = true,
					search = { wrap = true },
					highlight = { backdrop = false },
				},
			},
		},
	},

	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = { sort = { "local", "order", "desc", "alphanum", "mod" } },
		keys = {
			{
				"<leader>aw",
				function()
					local cfg = require("which-key.config")
					local is_key_sort = vim.deep_equal(cfg.options.sort, { "alphanum" })
					cfg.options.sort = is_key_sort and { "manual", "desc" } or { "alphanum" }
					vim.notify("which-key sort: " .. (is_key_sort and "desc" or "key"))
				end,
				desc = "Toggle which-key sort order",
			},
			{
				"<leader>gm<leader>",
				function()
					require("which-key").show({ keys = "<leader>g", loop = true })
				end,
				desc = "Git Hydra Mode (which-key)",
			},
		},
	},
}

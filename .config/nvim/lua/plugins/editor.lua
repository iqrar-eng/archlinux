return {
	{
		"MagicDuck/grug-far.nvim",
		cmd = { "GrugFar", "GrugFarWithin" },
		opts = { wrap = false, windowCreationCommand = "tabnew" },
		keys = {
			{
				"<leader>ag",
				function()
					require("grug-far").open({ prefills = { flags = "-iF --hidden" } })
				end,
				mode = { "n", "x" },
				desc = "grug-far: root",
			},

			{
				"<leader>am",
				function()
					require("grug-far").open({ prefills = { paths = vim.fn.expand("%"), flags = "-iF" } })
				end,
				mode = { "n", "x" },
				desc = "grug-far: current file",
			},
		},
	},

	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			sort = { "local", "order", "desc", "alphanum", "mod" },
			triggers = { { "<auto>", mode = "nisotc" } },
		},
		keys = {
			{
				"<leader>aw",
				function()
					local cfg = require("which-key.config")
					local is_key_sort = vim.deep_equal(cfg.options.sort, { "alphanum" })
					cfg.options.sort = is_key_sort and { "manual", "desc" } or { "alphanum" }
					vim.notify("which-key sort: " .. (is_key_sort and "desc" or "key"))
				end,
				desc = "toggle which-key sort order",
			},
			{
				"<leader>gm<leader>",
				function()
					require("which-key").show({ keys = "<leader>g", loop = true })
				end,
				desc = "Hydra Mode (which-key)",
			},
		},
	},
}

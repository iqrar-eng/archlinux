return {
	{
		"MagicDuck/grug-far.nvim",
		cmd = { "GrugFar", "GrugFarWithin" },
		opts = { wrap = false, windowCreationCommand = "tabnew" },
		keys = {
			{
				"<leader>ag",
				function()
					local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
					require("grug-far").open({
						prefills = { paths = LazyVim.root.get(), flags = "-iFH" },
					})
				end,
				mode = { "n", "x" },
				desc = "grug-far: root",
			},

			{
				"<leader>am",
				function()
					require("grug-far").open({
						prefills = { paths = vim.fn.expand("%"), flags = "-iFH" },
					})
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
		config = function(_, opts)
			local wk = require("which-key")
			wk.setup(opts)

			local sort_with_desc = { "manual", "desc" }
			local sort_without_desc = { "alphanum" }
			local sort_state = true

			vim.keymap.set("n", "<leader>aw", function()
				sort_state = not sort_state
				require("which-key.config").options.sort = sort_state and sort_with_desc or sort_without_desc
				vim.notify("which-key sort: " .. (sort_state and "desc" or "key"))
			end, { desc = "Toggle which-key sort order" })
		end,
	},
}

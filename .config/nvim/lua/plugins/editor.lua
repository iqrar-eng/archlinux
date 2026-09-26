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
				desc = "root",
			},

			{
				"<leader>am",
				function()
					require("grug-far").open({
						prefills = { paths = vim.fn.expand("%"), flags = "-iFH" },
					})
				end,
				mode = { "n", "x" },
				desc = "current file",
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
		opts_extend = { "spec" },
		opts = {
			sort = { "local", "order", "desc", "alphanum", "mod" },
			preset = "helix",
			defaults = {},
			win = {
				no_overlap = false,
				col = math.huge,
				width = { min = 1, max = math.huge },
				height = { min = 1, max = math.huge },
			},
			layout = {
				width = { min = vim.o.columns, max = math.huge },
				spacing = 1,
			},
			show_help = false,
			replace = {
				desc = {
					{ "<Plug>%(?(.*)%)?", "%1" },
					{ "^%+", "" },
					{ "<[cC]md>", "" },
					{ "<[cC][rR]>", "" },
					{ "<[sS]ilent>", "" },
					{ "^lua%s+", "" },
					{ "^call%s+", "" },
					{ "^e ", "📃" },
					{ "MC:", "🧞‍♂️" },
					{ "Find Files*", "📁" },
					{ "Grep*", "🔎" },
				},
			},
		},
		config = function(_, opts)
			local wk = require("which-key")
			wk.setup(opts)

			if not vim.tbl_isempty(opts.defaults) then
				LazyVim.warn("which-key: opts.defaults is deprecated. Please use opts.spec instead.")
				wk.add(opts.defaults)
			end

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

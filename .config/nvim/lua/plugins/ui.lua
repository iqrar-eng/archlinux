return {
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		opts = function(_, opts)
			table.insert(opts.sections.lualine_y, {
				function()
					return vim.fn.line("$")
				end,
			})

			opts.sections.lualine_a = {
				function()
					return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
				end,
			}
		end,
	},
}

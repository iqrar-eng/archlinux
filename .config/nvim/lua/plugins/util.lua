return {
	{
		"folke/persistence.nvim",
		event = "VimEnter",
		opts = { need = 0 },
		config = function(_, opts)
			require("persistence").setup(opts)
			vim.api.nvim_create_autocmd("VimEnter", {
				group = vim.api.nvim_create_augroup("restore_session", { clear = true }),
				callback = function()
					vim.cmd("silent! windo e")
					-- Only load session if nvim was started with no arguments
					if vim.fn.argc() == 0 then
						require("persistence").load({ last = true })
					end
				end,
				nested = true,
			})
		end,
	},
}

return {
	{
		"mbbill/undotree",
		cmd = "UndotreeToggle",
		keys = {
			{ "<leader>au", "<cmd>UndotreeToggle<CR>", desc = "Toggle Undotree " },
		},
		config = function()
			vim.g.undotree_WindowLayout = 3
			vim.g.undotree_DiffAutoOpen = 0
			vim.cmd([[
				function! g:Undotree_CustomMap()
          setlocal number
          setlocal relativenumber
          setlocal numberwidth=1
					setlocal signcolumn=no
          setlocal statuscolumn=
				endfunction
			]])
		end,
	},
}

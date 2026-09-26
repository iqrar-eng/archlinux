return {
	{
		"mbbill/undotree",
		cmd = "UndotreeToggle",
		keys = {
			{ "<leader>af", "<cmd>UndotreeToggle<CR>", desc = "Toggle Undotree (closes explorer first)" },
		},
		config = function()
			vim.g.undotree_ShortIndicators = 1
			vim.g.undotree_StatusLine = 0
			vim.g.undotree_HelpLine = 0

			vim.g.undotree_CustomUndotreeCmd = "botright vertical 25 new"
			vim.g.undotree_CustomDiffpanelCmd = "belowright 12 new"
			vim.g.undotree_DiffAutoOpen = 0

			vim.cmd([[
        function! g:Undotree_CustomMap()
        setlocal statuscolumn=
        setlocal signcolumn=no
        noremap <buffer> <C-Home> gg<plug>UndotreeEnter
        noremap <buffer> <C-End> G<plug>UndotreeEnter
        noremap <buffer> <silent> <PageDown> <C-d>zz:set nowrapscan<CR>:silent! /\d<CR>:set wrapscan<CR>:noh<CR><plug>UndotreeEnter
        noremap <buffer> <silent> <PageUp>   <C-u>zz:set nowrapscan<CR>:silent! ?\d<CR>:set wrapscan<CR>:noh<CR><plug>UndotreeEnter
        noremap <buffer><expr> j v:count > 1 ? "j\<Plug>UndotreeEnter" : "\<Plug>UndotreePreviousState"
        noremap <buffer><expr> k v:count > 1 ? "k\<Plug>UndotreeEnter" : "\<Plug>UndotreeNextState"
        noremap <buffer> g? <plug>UndotreeHelp
        noremap <buffer> ? ?
        endfunction
      ]])
		end,
	},
}

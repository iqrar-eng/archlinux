return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000, -- ensure it loads before everything else
		opts = {
			on_highlights = function(hl, colors)
				if vim.o.background == "light" then
					hl.SnacksIndent1 = { fg = "#00BFAE", bg = "none" }
					hl.SnacksIndent2 = { fg = "#ea76cb", bg = "none" }
					hl.SnacksIndent3 = { fg = "#ff5d00", bg = "none" }
					hl.SnacksIndent4 = { fg = "#00CF1E", bg = "none" }
					hl.SnacksIndent5 = { fg = "#8F8F8F", bg = "none" }
					hl.SnacksIndent6 = { fg = "#C39900", bg = "none" }
					hl.SnacksIndent7 = { fg = "#00CF1E", bg = "none" }
					hl.SnacksIndent8 = { fg = "#ea76cb", bg = "none" }
					hl.SnacksIndent9 = { fg = "#00BFAE", bg = "none" }
					hl.SnacksIndent10 = { fg = "#ff5d00", bg = "none" }
					hl.SnacksIndent11 = { fg = "#8F8F8F", bg = "none" }
					hl.SnacksIndent12 = { fg = "#C39900", bg = "none" }
				else
					hl.SnacksIndent1 = { fg = "#00E6C0", bg = "none" }
					hl.SnacksIndent2 = { fg = "#E636E6", bg = "none" }
					hl.SnacksIndent3 = { fg = "#f7823e", bg = "none" }
					hl.SnacksIndent4 = { fg = "#00E620", bg = "none" }
					hl.SnacksIndent5 = { fg = "#a3a0a0", bg = "none" }
					hl.SnacksIndent6 = { fg = "#CCE600", bg = "none" }
					hl.SnacksIndent7 = { fg = "#00E620", bg = "none" }
					hl.SnacksIndent8 = { fg = "#E636E6", bg = "none" }
					hl.SnacksIndent9 = { fg = "#00E6C0", bg = "none" }
					hl.SnacksIndent10 = { fg = "#f7823e", bg = "none" }
					hl.SnacksIndent11 = { fg = "#a3a0a0", bg = "none" }
					hl.SnacksIndent12 = { fg = "#CCE600", bg = "none" }
				end
				hl.AerialLine = { link = "CursorLine" }
				hl.SnacksIndentScope = { undercurl = true }
			end,
		},
	},
}

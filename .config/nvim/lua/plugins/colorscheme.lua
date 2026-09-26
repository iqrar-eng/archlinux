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

					hl.RelativeLineInterval_b = { bg = "#FFFCE2" }
					hl.RelativeLineInterval_e = { bg = "#F2F2F2" }
					hl.RelativeLineInterval_c = { bg = "#E4FFF6" }
					hl.RelativeLineInterval_d = { bg = "#e6fce8" }
					hl.RelativeLineInterval_f = { bg = "#F4EEFF" }
					hl.RelativeLineInterval_g = { bg = "#FFF3EA" }
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

					hl.RelativeLineInterval_b = { bg = "#312F1D" }
					hl.RelativeLineInterval_e = { bg = "#282A33" }
					hl.RelativeLineInterval_c = { bg = "#003235" }
					hl.RelativeLineInterval_d = { bg = "#1F2D21" }
					hl.RelativeLineInterval_f = { bg = "#2E2648" }
					hl.RelativeLineInterval_g = { bg = "#2E2820" }
				end
				hl.AerialLine = { link = "VisualNOS" }
				hl.SnacksIndentScope = { undercurl = true }
			end,
		},
	},
}

return {
	{
		"saghen/blink.cmp",
		opts = {
			cmdline = {
        -- stylua: ignore
        keymap = {
          ["<C-e>"] = { "hide", "show" },
          ["<C-j>"] = { "cancel", "show" },

          ["<A-q>"] = { function(cmp) cmp.accept({ index = 6 }) end, },
          ["<A-w>"] = { function(cmp) cmp.accept({ index = 2 }) end, },
          ["<A-y>"] = { function(cmp) cmp.accept({ index = 3 }) end, },
          ["<A-r>"] = { function(cmp) cmp.accept({ index = 4 }) end, },
          ["<A-t>"] = { function(cmp) cmp.accept({ index = 5 }) end, },
          ["<A-u>"] = { function(cmp) cmp.accept({ index = 7 }) end, },
          ["<A-z>"] = { function(cmp) cmp.accept({ index = 8 }) end, },
          ["<A-o>"] = { function(cmp) cmp.accept({ index = 9 }) end, },
          ["<A-p>"] = { function(cmp) cmp.accept({ index = 10 }) end, },
        },
				completion = { menu = { auto_show = true } },
			},

      -- stylua: ignore
      keymap = {
        ["<C-e>"] = { "hide", "show" },
        ["<C-j>"] = { "cancel", "show" },

        ["<C-S-H>"] = { "scroll_documentation_down" },
        ["<C-S-S>"] = { "scroll_documentation_up" },

        ["<A-q>"] = { function(cmp) cmp.accept({ index = 6 }) end, },
        ["<A-w>"] = { function(cmp) cmp.accept({ index = 2 }) end, },
        ["<A-y>"] = { function(cmp) cmp.accept({ index = 3 }) end, },
        ["<A-r>"] = { function(cmp) cmp.accept({ index = 4 }) end, },
        ["<A-t>"] = { function(cmp) cmp.accept({ index = 5 }) end, },
        ["<A-u>"] = { function(cmp) cmp.accept({ index = 7 }) end, },
        ["<A-z>"] = { function(cmp) cmp.accept({ index = 8 }) end, },
        ["<A-o>"] = { function(cmp) cmp.accept({ index = 9 }) end, },
        ["<A-p>"] = { function(cmp) cmp.accept({ index = 10 }) end, },
      },
			completion = {
				menu = {
					max_height = 47,
					draw = {
						columns = { { "item_idx" }, { "kind_icon" }, { "label", "label_description", gap = 1 } },
						components = {
							item_idx = {
								text = function(ctx)
									return ctx.idx == 10 and "0" or ctx.idx >= 10 and " " or tostring(ctx.idx)
								end,
								highlight = "BlinkCmpItemIdx", -- optional, only if you want to change its color
							},
						},
						treesitter = { "lsp" },
					},
				},
				documentation = {
					auto_show_delay_ms = 200,
					window = {
						max_width = 120,
						max_height = 50,
					},
				},
				ghost_text = {
					enabled = true,
					show_without_selection = true,
				},
			},
			sources = {
				providers = {
					path = {
						opts = {
							show_hidden_files_by_default = true,
						},
					},
				},
			},
		},
	},
}

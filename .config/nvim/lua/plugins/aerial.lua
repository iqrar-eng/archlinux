local state_dir = vim.fn.stdpath("state")
local state_file = state_dir .. "/aerial_auto"
local aerial_state = { auto = vim.fn.filereadable(state_file) == 0 or vim.fn.readfile(state_file)[1] == "1" }

local function save()
	vim.fn.mkdir(state_dir, "p")
	vim.fn.writefile({ aerial_state.auto and "1" or "0" }, state_file)
end

return {
	{
		"stevearc/aerial.nvim",
		event = "LazyFile",
		opts = function(_, opts)
			local icons = vim.deepcopy(LazyVim.config.icons.kinds)
			for kind, icon in pairs(vim.deepcopy(icons)) do
				if type(icon) == "string" then
					icons[kind] = icon:gsub("%s+$", "")
					if kind ~= "Collapsed" and not kind:match("Collapsed$") then
						icons[kind .. "Collapsed"] = "▍"
					end
				end
			end
			icons.Interface = "▊"
			return {
				attach_mode = "global",
				backends = { "treesitter", "lsp", "markdown", "man" },
				show_guides = true,
				layout = {
					width = 28,
					placement = "edge",
					default_direction = "right",
					resize_to_content = false,
					win_opts = {
						signcolumn = "no",
						statuscolumn = "",
					},
				},
				backends = { "treesitter", "markdown", "lsp", "asciidoc", "man" },
				link_tree_to_folds = false,
				highlight_on_hover = true,
				icons = icons,
				open_automatic = function()
					return aerial_state.auto
				end,
				autojump = true,
				guides = { mid_item = "├", last_item = "└", nested_top = "│", whitespace = " " },
				keymaps = {
					["j"] = function()
						local count = math.max(vim.v.count, 1)
						if count == 1 then
							require("aerial.actions").down_and_scroll.callback()
						else
							vim.cmd("normal! m'" .. count .. "gj")
							require("aerial").select({ jump = false })
						end
					end,
					["k"] = function()
						local count = math.max(vim.v.count, 1)
						if count == 1 then
							require("aerial.actions").up_and_scroll.callback()
						else
							vim.cmd("normal! m'" .. count .. "gk")
							require("aerial").select({ jump = false })
						end
					end,
					["s"] = "actions.tree_decrease_fold_level",
					["d"] = "actions.tree_increase_fold_level",
					["c"] = "actions.tree_close_all",
					["r"] = "actions.tree_open_all",
					["i"] = "actions.prev_up",
					["o"] = "actions.next_up",
					["?"] = false,
				},
				filter_kind = {
					"Key",
					"Method",
					"Module",
					"Namespace",
					"Null",
					"Function",
					"Variable",
					"Array",
					"Boolean",
					"Class",
					"Constant",
					"Constructor",
					"Enum",
					"EnumMember",
					"Event",
					"Field",
					"File",
					"Interface",
					"Number",
					"Object",
					"Struct",
					"TypeParameter",
					"Operator",
					"Package",
					"Property",
					"Trait",
				},
			}
		end,
		keys = {
			{
				"<leader>cs",
				function()
					aerial_state.auto = not aerial_state.auto
					save()
					if aerial_state.auto then
						require("aerial").open({ focus = false })
					else
						require("aerial").close()
					end
				end,
				desc = "Toggle Aerial auto-open",
			},
		},
		config = function(_, opts)
			require("aerial").setup(vim.tbl_deep_extend("force", opts, {
				get_highlight = function(symbol, is_icon, is_collapsed)
					local level = (symbol.level or 0) % 12 + 1
					return "SnacksIndent" .. level
				end,
			}))
		end,
	},
}

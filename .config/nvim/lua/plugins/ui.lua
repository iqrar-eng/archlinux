local function relative_time(ts)
	local d = os.time() - ts
	if d < 60 then
		return "now"
	end
	local n, u = unpack(d < 3600 and { d / 60, "m" } or d < 86400 and { d / 3600, "h" } or { d / 86400, "d" })
	return math.floor(n) .. u .. " ago"
end

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

			table.insert(opts.sections.lualine_c, {
				function()
					local t = vim.fn.undotree()
					local s = ("%d/%d"):format(t.seq_cur, t.seq_last)
					return t.time_cur and t.time_cur > 0 and s .. "│" .. relative_time(t.time_cur) or s
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

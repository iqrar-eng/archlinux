local function augroup(name)
	return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

------------------------------------------------

vim.api.nvim_create_autocmd({ "LspAttach", "BufEnter" }, {
	group = vim.api.nvim_create_augroup("SnacksExplorerRoot", { clear = true }),
	callback = function(args)
		local buf = args.buf
		if vim.bo[buf].buftype ~= "" then
			return
		end
		local bufname = vim.api.nvim_buf_get_name(buf)
		if bufname == "" or not vim.uv.fs_stat(bufname) then
			return
		end
		vim.schedule(function()
			local explorer = Snacks.picker.get({ source = "explorer" })[1]
			if not explorer then
				return
			end
			local file = vim.uv.fs_realpath(bufname) or bufname
			local ok, git_root = pcall(LazyVim.root.git)
			local root = (ok and git_root) or LazyVim.root.get({ buf = buf })
			root = vim.uv.fs_realpath(root) or root
			if explorer:cwd() ~= root then
				explorer:set_cwd(root)
				require("snacks.explorer.tree"):refresh(root)
			end
			pcall(require("snacks.explorer").reveal, { file = file })
		end)
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = augroup("man_unlisted"),
	pattern = { "man", "help" },
	callback = function(event)
		local buf = vim.api.nvim_get_current_buf()
		vim.bo[buf].buflisted = true
		vim.bo[buf].buftype = ""
		vim.bo[buf].bufhidden = "hide"

		pcall(vim.keymap.del, "n", "j", { buffer = true })
		pcall(vim.keymap.del, "n", "k", { buffer = true })
	end,
})

-- Define highlight groups for different intervals
------------------------------------------------
local distance_map = {
	[7] = "RelativeLineInterval_g",
	[14] = "RelativeLineInterval_c",
	[21] = "RelativeLineInterval_d",
	[28] = "RelativeLineInterval_f",
	[35] = "RelativeLineInterval_b",
	[42] = "RelativeLineInterval_e",
}
local ns = vim.api.nvim_create_namespace("relative_cursor_intervals")
local touched_bufs, redraw_pending, generation, buf_active_win = {}, false, 0, {}

local function update_active_win()
	local win = vim.api.nvim_get_current_win()
	local ok, buf = pcall(vim.api.nvim_win_get_buf, win)
	if ok and vim.api.nvim_buf_is_valid(buf) then
		buf_active_win[buf] = win
	end
end

local function do_redraw()
	local buf_wins, new_touched = {}, {}
	for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
		for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
			local ok, buf = pcall(vim.api.nvim_win_get_buf, win)
			if ok and vim.api.nvim_buf_is_loaded(buf) then
				buf_wins[buf] = buf_wins[buf] or {}
				table.insert(buf_wins[buf], win)
			end
		end
	end

	for buf, wins in pairs(buf_wins) do
		local source_win = buf_active_win[buf]
		local ok, wbuf = pcall(vim.api.nvim_win_get_buf, source_win or -1)
		if not (ok and wbuf == buf) then
			source_win = wins[1]
			buf_active_win[buf] = source_win
		end

		local ok_cursor, cursor = pcall(vim.api.nvim_win_get_cursor, source_win)
		local total = ok_cursor and vim.api.nvim_buf_line_count(buf) or 0
		if total > 0 then
			vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
			for line = 1, total do
				local hl = distance_map[math.abs(line - cursor[1])]
				if hl then
					pcall(
						vim.api.nvim_buf_set_extmark,
						buf,
						ns,
						line - 1,
						0,
						{ end_line = line, hl_group = hl, hl_eol = true, priority = 90 }
					)
				end
			end
			new_touched[buf] = true
		end
	end

	for buf in pairs(touched_bufs) do
		if not new_touched[buf] and vim.api.nvim_buf_is_valid(buf) then
			vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
		end
	end
	touched_bufs = new_touched
end

local function redraw_all()
	if redraw_pending then
		return
	end
	redraw_pending = true
	local my_gen = generation
	vim.schedule(function()
		redraw_pending = false
		if my_gen == generation then
			do_redraw()
		end
	end)
end

local function bump_and_redraw()
	generation = generation + 1
	redraw_all()
end

local function redraw_burst()
	update_active_win()
	bump_and_redraw()
	vim.defer_fn(bump_and_redraw, 30)
	vim.defer_fn(bump_and_redraw, 120)
end

vim.api.nvim_create_autocmd(
	{ "WinEnter", "BufWinEnter", "BufEnter", "WinNew", "WinClosed", "TabEnter", "VimResized" },
	{ callback = redraw_burst }
)
vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "CursorHold", "CursorHoldI" }, { callback = redraw_all })
vim.schedule(bump_and_redraw)

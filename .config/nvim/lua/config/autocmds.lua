local function augroup(name)
	return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

------------------------------------------------

vim.schedule(function()
	if vim.fn.argc() == 0 then
		require("persistence").load({ last = true })
	end
	vim.o.background = vim.fn.system("gsettings get org.gnome.desktop.interface color-scheme"):match("dark") and "dark"
		or "light"
	local root = LazyVim.root.git() or LazyVim.root.get()
	Snacks.explorer({ cwd = root, focus = false })
end)

vim.api.nvim_create_autocmd({ "LspAttach", "BufEnter" }, {
	group = augroup("SnacksExplorerRoot"),
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
			local file = vim.uv.fs_realpath(bufname) or bufname
			local ok, git_root = pcall(LazyVim.root.git)
			local root = (ok and git_root) or LazyVim.root.get({ buf = buf })
			root = vim.uv.fs_realpath(root) or root
			if vim.uv.cwd() ~= root then
				vim.cmd("noautocmd cd " .. vim.fn.fnameescape(root))
			end
			local explorer = Snacks.picker.get({ source = "explorer" })[1]
			if not explorer then
				return
			end
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

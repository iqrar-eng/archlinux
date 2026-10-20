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
	Snacks.explorer({ focus = false })
end)

vim.api.nvim_create_autocmd("FileType", {
	group = augroup("markdown_mdx"),
	pattern = { "markdown", "markdown.mdx" },
	callback = function()
		vim.opt_local.wrap = true
	end,
})

vim.api.nvim_create_autocmd({ "LspAttach", "BufEnter" }, {
	group = augroup("SnacksExplorerRoot"),
	callback = function()
		vim.schedule(function()
			local home_subdir = vim.fn.expand("%:p:~"):match("^~/[^/]+/")
			local git_root = vim.fs.root(vim.api.nvim_buf_get_name(0), ".git")
			local target = vim.fs.normalize(git_root or vim.fn.expand(home_subdir or "%:p:h"))
			if target ~= vim.fs.normalize(vim.fn.getcwd()) then
				vim.cmd("silent! cd " .. vim.fn.fnameescape(target))
			end
		end)
	end,
})

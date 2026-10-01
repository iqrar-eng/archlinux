vim.opt.relativenumber = true
vim.o.showtabline = 0
vim.o.numberwidth = 1
vim.g.snacks_animate = false
vim.opt.equalalways = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.isfname:append("@-@")
vim.filetype.add({
	extension = { mdx = "markdown.mdx" },
	pattern = {
		[".blerc"] = "bash",
	},
})
vim.o.winborder = "rounded"
vim.opt.concealcursor = "n"
vim.opt.conceallevel = 1

vim.opt.relativenumber = false
vim.o.showtabline = 0
vim.g.snacks_animate = false
vim.opt.equalalways = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.isfname:append("@-@")
vim.opt.guicursor = "n:block25,c:ver25,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait175-blinkoff150-blinkon175"
vim.filetype.add({
	pattern = {
		[".blerc"] = "bash",
	},
})
vim.o.winborder = "rounded"
vim.opt.concealcursor = "n"
vim.opt.conceallevel = 1 -- Hide * markup for bold and italic, but not markers with substitutions

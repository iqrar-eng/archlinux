vim.g.snacks_animate = false
vim.g.autoformat = false

local opt = vim.opt

opt.relativenumber = true
opt.showtabline = 0
opt.numberwidth = 1
opt.equalalways = true
opt.swapfile = false
opt.backup = false
opt.isfname:append("@-@")
opt.winborder = "rounded"

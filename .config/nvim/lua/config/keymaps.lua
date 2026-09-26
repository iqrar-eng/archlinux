----------------------------------------------

local function remote_scroll(filetypes, dir)
	return function()
		local count = vim.v.count1
		local original_win = vim.api.nvim_get_current_win()
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			local buf = vim.api.nvim_win_get_buf(win)
			if vim.tbl_contains(filetypes, vim.bo[buf].filetype) then
				vim.api.nvim_set_current_win(win)
				vim.api.nvim_feedkeys(count .. dir, "m", false)

				vim.defer_fn(function()
					if vim.api.nvim_win_is_valid(win) then
						vim.api.nvim_set_current_win(win)
						local keys = vim.api.nvim_replace_termcodes("<CR>", true, false, true)
						vim.api.nvim_feedkeys(keys, "m", false)
					end

					vim.defer_fn(function()
						if vim.api.nvim_win_is_valid(original_win) then
							vim.api.nvim_set_current_win(original_win)
						end
					end, 10)
				end, 50)

				return
			end
		end
	end
end

vim.keymap.set("n", "<C-PageDown>", remote_scroll({ "snacks_picker_list" }, "j"), {})
vim.keymap.set("n", "<C-PageUp>", remote_scroll({ "snacks_picker_list" }, "k"), {})
vim.keymap.set("n", "<C-S-PageDown>", remote_scroll({ "snacks_picker_list" }, "G"), {})
vim.keymap.set("n", "<C-S-PageUp>", remote_scroll({ "snacks_picker_list" }, "gg"), {})

vim.keymap.set("n", "<C-H>", remote_scroll({ "undotree", "aerial" }, "j"), {})
vim.keymap.set("n", "<C-S>", remote_scroll({ "undotree", "aerial" }, "k"), {})
vim.keymap.set("n", "<leader>aP", "9999g-")
vim.keymap.set("n", "<leader>aN", "9999g+")

------------------------------------------------

vim.keymap.set("n", "<C-Q>", function()
	local explorer = Snacks.picker.get({ source = "explorer" })[1]
	if explorer then
		explorer:close()
	end
	vim.defer_fn(function()
		vim.cmd("w")
	end, 100)
	vim.defer_fn(function()
		vim.cmd("qa!")
	end, 200)
end, { desc = "Quit nvim" })

vim.keymap.set("n", "<leader>a<CR>", function()
	vim.cmd("RenderMarkdown toggle")
	vim.schedule(function()
		vim.o.conceallevel = vim.o.conceallevel == 0 and 2 or 0
	end)
end, { desc = "Toggle render-markdown + conceal (buffer)" })

vim.keymap.set("n", "<esc>", function()
	local cc_map = vim.fn.maparg("<C-c>", "n", false, true)
	if type(cc_map) == "table" and cc_map.desc == "Stop exchange" and cc_map.callback then
		cc_map.callback()
	end
	vim.cmd("noh")
	return "<esc>"
end, { expr = true, desc = "Escape and Clear hlsearch" })

------------------------------------------------

vim.keymap.set("x", "<M-2>", function()
	vim.cmd("normal! " .. ("jojo"):rep(vim.v.count1))
end, { silent = true, desc = "visual move down" })
vim.keymap.set("x", "<M-3>", function()
	vim.cmd("normal! " .. ("koko"):rep(vim.v.count1))
end, { silent = true, desc = "visual move up" })

vim.keymap.set("x", "<M-4>", function()
	vim.cmd("normal! " .. ("lolo"):rep(vim.v.count1))
end, { silent = true, desc = "visual move right" })
vim.keymap.set("x", "<M-1>", function()
	vim.cmd("normal! " .. ("hoho"):rep(vim.v.count1))
end, { silent = true, desc = "visual move left" })

vim.keymap.set("x", "x", function()
	vim.cmd("normal! " .. ("joko"):rep(vim.v.count1))
end, { silent = true, desc = "visual extend/shrink vertically" })
vim.keymap.set("x", "z", function()
	vim.cmd("normal! " .. ("loho"):rep(vim.v.count1))
end, { silent = true, desc = "visual extend/shrink horizontally" })

------------------------------------------------

vim.keymap.set("n", "<leader>av", function()
	local file = vim.fn.expand("%")
	if vim.fn.executable(file) == 1 then
		vim.cmd("!chmod -x " .. file)
		vim.notify("chmod -x " .. file, vim.log.levels.WARN)
	else
		vim.cmd("!chmod +x " .. file)
		vim.notify("chmod +x " .. file, vim.log.levels.INFO)
	end
end, { desc = "toggle chmod +x/-x" })

vim.keymap.set("n", "<leader>a]", function()
	vim.cmd("normal! mz")
	vim.cmd("put ='------------------------------------------------'")
	vim.cmd("normal gcc")
	vim.cmd("put =''")
	vim.cmd("normal! =k`z")
	vim.cmd("undojoin")
end, { silent = true, desc = "separator below" })

vim.keymap.set("n", "<leader>a[", function()
	vim.cmd("normal! mz")
	vim.cmd("put! ='stylua: ignore'")
	vim.cmd("normal gcc")
	vim.cmd("normal! ==`z")
	vim.cmd("undojoin")
end, { silent = true, desc = "stylua: ignore above" })

vim.keymap.set({ "n", "x" }, "j", "v:count > 1 ? \"m'\" . v:count . 'j' : 'j'", { expr = true })
vim.keymap.set({ "n", "x" }, "k", "v:count > 1 ? \"m'\" . v:count . 'k' : 'k'", { expr = true })

vim.keymap.set({ "n", "x" }, "-", "v:count > 1 ? \"m'\" . v:count . '-' : '-'", { expr = true })
vim.keymap.set({ "n", "x" }, "+", "v:count > 1 ? \"m'\" . v:count . '+' : '+'", { expr = true })

vim.keymap.set({ "n", "x" }, "<Home>", function()
	return vim.v.count > 1 and ("m'" .. vim.v.count .. "gk$") or "0"
end, { expr = true })

vim.keymap.set({ "n", "x" }, "<End>", function()
	return vim.v.count > 1 and ("m'" .. vim.v.count .. "gj$") or "$"
end, { expr = true })

------------------------------------------------

local function yank_motion_text(type)
	local rv, rt = vim.fn.getreg('"'), vim.fn.getregtype('"')
	if type == "line" then
		vim.cmd("normal! '[V']y")
	elseif type == "block" then
		vim.cmd("normal! `[\22`]y")
	else
		vim.cmd("normal! `[v`]y")
	end
	local text = vim.fn.getreg('"')
	vim.fn.setreg('"', rv, rt)
	return text
end

local function yank_selection_text()
	local rv, rt = vim.fn.getreg('"'), vim.fn.getregtype('"')
	vim.cmd("normal! y")
	local text = vim.fn.getreg('"')
	vim.fn.setreg('"', rv, rt)
	return text
end

local presets = {
	["a"] = function()
		return table.concat({
			"cd " .. LazyVim.root.git(),
			"git add -A",
			"git commit --message='chore: update'",
			"git push",
		}, "\n"),
			"git add -A, commit, push root dir"
	end,

	["<leader>"] = function()
		return vim.fn.expand("%:p"), "current file"
	end,
}

local function bind_presets(lhs, presets, send_preset)
	for key, preset_fn in pairs(presets) do
		local preset_lhs = lhs .. "p" .. key
		local _, desc = preset_fn()
		vim.keymap.set("n", preset_lhs, function()
			local text = preset_fn()
			send_preset(text)
		end, { desc = desc })
	end
end

-- main_cmd: command that receives --text <escaped>
-- post_cmd: optional command run after main_cmd succeeds (&&)
local function bind_send_text(lhs, main_cmd, post_cmd)
	local function build(text)
		local cmd = main_cmd .. " --text " .. vim.fn.shellescape(text)
		if post_cmd then
			cmd = cmd .. " && " .. post_cmd
		end
		return cmd
	end

	local global_name = "SlimeBrowserSendTextOp_" .. lhs:gsub("[^%w]", "_")
	_G[global_name] = function(type)
		local text = yank_motion_text(type)
		vim.fn.jobstart({ "sh", "-c", build(text) }, { detach = true })
	end
	vim.keymap.set("n", lhs, function()
		vim.o.operatorfunc = "v:lua." .. global_name
		return "g@"
	end, { expr = true, desc = "Send motion text via --text" })
	vim.keymap.set("x", lhs, function()
		local text = yank_selection_text()
		vim.fn.jobstart({ "sh", "-c", build(text) }, { detach = true })
	end, { desc = "Send selection text via --text" })

	bind_presets(lhs, presets, function(text)
		vim.fn.jobstart({ "sh", "-c", build(text) }, { detach = true })
	end)
end

bind_send_text("<leader>z", "~/archlinux/.config/tmux/bin/slime --jump --execute")
bind_send_text("<leader>v", "~/archlinux/.config/tmux/bin/slime --execute")
bind_send_text("<leader>r", "~/archlinux/.config/tmux/bin/slime --jump")
bind_send_text("<leader>m", "~/archlinux/.config/tmux/bin/slime --jump --no-cancel")

----------------------------------------------

local cmd = "hyprctl dispatch 'hl.dsp.focus({ workspace = \"1\" })' && ~/archlinux/.config/hypr/bin/paste"
local function send_content(content)
	vim.fn.setreg("+", content)
	vim.fn.jobstart(cmd, { detach = true })
end

local function bind_send(lhs)
	local global_name = "SlimeBrowserSendOp_" .. lhs:gsub("[^%w]", "_")
	_G[global_name] = function(type)
		send_content(yank_motion_text(type))
	end
	vim.keymap.set("n", lhs, function()
		vim.o.operatorfunc = "v:lua." .. global_name
		return "g@"
	end, { expr = true, desc = "Send motion to browser" })
	vim.keymap.set("x", lhs, function()
		send_content(yank_selection_text())
	end, { desc = "Send selection to browser" })
	bind_presets(lhs, presets, send_content)
end

bind_send("<leader>y")

vim.keymap.set("n", "<leader>ypv", function()
	local cmd =
		"hyprctl dispatch 'hl.dsp.focus({ workspace = \"1\" })' && sleep 1.8 && ~/archlinux/.config/hypr/bin/paste"
	local tmp_path = "/tmp/ai_context_" .. os.date("%H-%M-%S")
	vim.cmd("silent! w " .. tmp_path)
	local uri = "file://" .. tmp_path
	local job = vim.fn.jobstart({ "wl-copy", "--type", "text/uri-list" }, { stdin = "pipe" })
	vim.fn.chansend(job, uri)
	vim.fn.chanclose(job, "stdin")
	vim.fn.jobstart(cmd, { detach = true })
end, { desc = "file_uri" })

------------------------------------------------

vim.keymap.set("i", "<C-S-End><Del>", '<C-Home><C-v><Esc>"zd<C-End>', { remap = true, silent = true })
vim.keymap.set("c", "<S-End><Del><BS>", '<c-f>"zD<C-c>')
vim.keymap.set({ "c", "i" }, "<S-Home><BS>", "<C-u>")

vim.keymap.set("i", "<C-Del>", function()
	local col = vim.fn.col(".")
	if col == 1 then
		return '<esc>"zdei'
	else
		return '<esc>l"zdei'
	end
end, { expr = true })
vim.keymap.set("c", "<C-Del>", '<c-f>"zde<C-c>')

vim.keymap.set("i", "<S-End><Del>", function()
	local col = vim.fn.col(".")
	if col == 1 then
		return '<esc>"zd$a'
	else
		return '<esc>l"zd$a'
	end
end, { expr = true })
vim.keymap.set("c", "<S-End><Del>", '<c-f>"zD<C-c>')

----------------------------------------------

vim.keymap.set("n", "<leader>Ga", "<cmd>Git add %<CR>")
vim.keymap.set("n", "<leader>GA", "<cmd>Git add -A<CR>")

vim.keymap.set("n", "]j", "<cmd>Gitsigns nav_hunk next --target=staged<CR>", { desc = "GitSigns Next Hunk" })
vim.keymap.set("n", "[j", "<cmd>Gitsigns nav_hunk prev --target=staged<CR>", { desc = "GitSigns Prev Hunk" })
vim.keymap.set("n", "]J", "<cmd>Gitsigns nav_hunk last --target=staged<CR>", { desc = "GitSigns Last Hunk" })
vim.keymap.set("n", "[J", "<cmd>Gitsigns nav_hunk first --target=staged<CR>", { desc = "GitSigns First Hunk" })

vim.keymap.set("n", "<M-p>", "<cmd>Gitsigns preview_hunk<CR>")
vim.keymap.set("n", "<leader>Gr", "<cmd>Gitsigns reset_buffer_index<CR>")

vim.keymap.set({ "n", "o" }, "<M-C-D>", "*<cmd>nohlsearch<CR>")
vim.keymap.set("x", "<M-C-D>", "<Esc>*gvn<cmd>nohlsearch<CR>")
vim.keymap.set({ "n", "o" }, "<M-C-A>", "#<cmd>nohlsearch<CR>")
vim.keymap.set("x", "<M-C-A>", "<Esc>#gvn<cmd>nohlsearch<CR>")

vim.keymap.set("n", "<leader>ab", "<cmd>source %<CR>")
vim.keymap.set("n", "<leader>az", "<cmd>!keyd reload<CR>")
vim.keymap.set("n", "<leader>aX", "<cmd>LazyExtras<CR>")
vim.keymap.set("n", "<leader>ad", "<cmd>Sexplore<CR>")

vim.keymap.set("n", "<leader>at", "<cmd>e ~/.bashrc<CR>")
vim.keymap.set("n", "<leader>au", "<cmd>e ~/.blerc<CR>")
vim.keymap.set("n", "<leader>ah", "<cmd>e /etc/keyd/default.conf<CR>")
vim.keymap.set("n", "<leader>aj", "<cmd>e ~/personal/profiles.md<CR>")
vim.keymap.set("n", "<leader>ak", "<cmd>e ~/archlinux/.config/nvim/lua/config/keymaps.lua<CR>")
vim.keymap.set("n", "<leader>al", "<cmd>e ~/.scratch<CR>")
vim.keymap.set("n", "<leader>an", "<cmd>e ~/archlinux/.config/hypr/hyprland.lua<CR>")
vim.keymap.set("n", "<leader>a,", "<cmd>e ~/archlinux/.config/hypr/bind.lua<CR>")
vim.keymap.set("n", "<leader>as", "<cmd>e ~/archlinux/.config/nvim/lua/plugins/snacks_picker.lua<CR>")

vim.keymap.set("x", "<leader>o", ':g#^$#normal! "_dd<CR><Cmd>noh<CR>')

vim.keymap.set("i", " ", "<C-]> <C-g>u")
vim.keymap.set("i", "-", "-<c-g>u")
vim.keymap.set("i", "_", "_<c-g>u")
vim.keymap.set("i", ",", ",<c-g>u")
vim.keymap.set("i", ".", ".<c-g>u")
vim.keymap.set("i", ";", ";<c-g>u")
vim.keymap.set("i", ":", ":<c-g>u")

vim.keymap.set("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
vim.keymap.set("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
vim.keymap.set({ "x", "o" }, "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
vim.keymap.set({ "x", "o" }, "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

vim.keymap.set("n", "<PageDown>", "<C-d>zz")
vim.keymap.set("n", "<PageUp>", "<C-u>zz")

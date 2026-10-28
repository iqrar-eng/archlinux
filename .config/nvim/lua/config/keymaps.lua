vim.keymap.set({ "n", "x", "o" }, "<Right>", "<nop>")
vim.keymap.set({ "n", "x", "o" }, "<Down>", "<nop>")

local function remote_scroll(filetypes, dir)
	return function()
		local count = vim.v.count1
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			local buf = vim.api.nvim_win_get_buf(win)
			if vim.tbl_contains(filetypes, vim.bo[buf].filetype) then
				vim.api.nvim_set_current_win(win)
				vim.api.nvim_feedkeys(count .. dir .. "\r", "m", false)
				return
			end
		end
	end
end

vim.keymap.set("n", "<C-PageDown>", remote_scroll({ "snacks_picker_list" }, "j"))
vim.keymap.set("n", "<C-PageUp>", remote_scroll({ "snacks_picker_list" }, "k"))

vim.keymap.set("n", "<C-S-H>", "<cmd>AerialNext<CR>")
vim.keymap.set("n", "<C-S-L>", "<cmd>AerialPrev<CR>")

vim.keymap.set("n", "<C-S-J>", "g-")
vim.keymap.set("n", "<C-S-K>", "g+")

vim.keymap.set("n", "<leader>aT", "9999g+")
vim.keymap.set("n", "<leader>aB", "9999g-")

vim.keymap.set("n", "<leader>fe", function()
	Snacks.explorer({ focus = false })
end, { expr = true, desc = "Toggle explorer" })

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

vim.keymap.set({ "n", "x" }, "j", "v:count > 1 ? \"m'\" . v:count . 'j' : 'j'", { expr = true })
vim.keymap.set({ "n", "x" }, "k", "v:count > 1 ? \"m'\" . v:count . 'k' : 'k'", { expr = true })

vim.keymap.set({ "n", "x" }, "-", "v:count > 1 ? \"m'\" . v:count . '-' : '-'", { expr = true })
vim.keymap.set({ "n", "x" }, "<CR>", "v:count > 1 ? \"m'\" . v:count . '+' : '+'", { expr = true })

vim.keymap.set({ "n", "x" }, "<Home>", function()
	return vim.v.count > 1 and ("m'" .. vim.v.count .. "gk$") or "0"
end, { expr = true })

vim.keymap.set({ "n", "x" }, "<End>", function()
	return vim.v.count > 1 and ("m'" .. vim.v.count .. "gj$") or "$"
end, { expr = true })

vim.keymap.set("n", "<C-L>", function()
	local mc_ns = vim.api.nvim_create_namespace("nvim.multicursor")
	vim.api.nvim_buf_clear_namespace(0, mc_ns, 0, -1)
end, { expr = true, desc = "Escape and Clear hlsearch" })

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

local SLIME = "~/archlinux/.config/tmux/bin/slime"
local function bind_send_text(lhs, flags, desc)
	local function send(text, count)
		local cmd = SLIME
		if count > 0 then
			cmd = cmd .. " " .. count
		end
		cmd = cmd .. " " .. flags .. " --text " .. vim.fn.shellescape(text)
		vim.fn.jobstart({ "sh", "-c", cmd }, { detach = true })
	end

	local global_name = "SlimeBrowserSendTextOp_" .. lhs:gsub("[^%w]", "_")

	vim.keymap.set("n", lhs, function()
		local count = vim.v.count
		_G[global_name] = function(type)
			send(yank_motion_text(type), count)
		end
		vim.o.operatorfunc = "v:lua." .. global_name
		return (count > 0 and "<Esc>" or "") .. "g@"
	end, { expr = true, desc = desc })

	vim.keymap.set("x", lhs, function()
		local count = vim.v.count
		send(yank_selection_text(), count)
	end, { desc = desc })
end

bind_send_text("<leader>hq", "--jump --execute", "Slime: send, jump and execute")
bind_send_text("<leader>hw", "--execute", "Slime: send and execute")
bind_send_text("<leader>hr", "--jump", "Slime: send and jump")
bind_send_text("<leader>hm", "--jump --no-cancel", "Slime: send, jump, no cancel")

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
end

bind_send("<leader>he")

----------------------------------------------

vim.keymap.set("n", "<leader>gma", "<cmd>Git add -A<CR>")
vim.keymap.set("n", "<leader>gmp", ":Git push<CR>")
vim.keymap.set("n", "<leader>gmcu", "<cmd>Git commit --message='chore: update'<CR>")

vim.keymap.set("n", "]j", "<cmd>Gitsigns nav_hunk next --target=staged<CR>", { desc = "GitSigns Next Hunk" })
vim.keymap.set("n", "[j", "<cmd>Gitsigns nav_hunk prev --target=staged<CR>", { desc = "GitSigns Prev Hunk" })
vim.keymap.set("n", "]J", "<cmd>Gitsigns nav_hunk last --target=staged<CR>", { desc = "GitSigns Last Hunk" })
vim.keymap.set("n", "[J", "<cmd>Gitsigns nav_hunk first --target=staged<CR>", { desc = "GitSigns First Hunk" })

vim.keymap.set("n", "<leader>gmr", "<cmd>Gitsigns reset_buffer_index<CR>")

---------------------------------------------

vim.keymap.set("n", "<leader>ak", '<cmd>!keyd reload<CR><cmd>echo "keyd reloaded"<CR>')
vim.keymap.set("n", "<leader>aX", "<cmd>LazyExtras<CR>")
vim.keymap.set("n", "<leader>ad", "<cmd>Sexplore<CR>")
vim.keymap.set("x", "<leader>ao", ':g#^$#normal! "_dd<CR><Cmd>noh<CR>', { desc = "delete empty lines" })

vim.keymap.set({ "o", "x" }, "iL", "il")
vim.keymap.set("n", "<leader>a[", "istylua: ignore<Esc>[ ==gcc", { desc = "snippet stylua: ignore", remap = true })
vim.keymap.set("n", "<leader>a]", "o<C-o>48i-<Esc>==gcc] ", { desc = "snippet separator", remap = true })

vim.keymap.set(
	"n",
	"<leader>ac",
	'<cmd>!tmux neww -c "$(pwd)"<cr><cmd>!tmux neww -c "$(pwd)" "npm run dev"<cr>',
	{ desc = "tmux neww (cwd) ; nmp run dev" }
)

local function remote_scroll(filetypes, dir)
  return function()
    local count = vim.v.count1
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.tbl_contains(filetypes, vim.bo[buf].filetype) then
        local cur_win = vim.api.nvim_get_current_win()
        vim.api.nvim_set_current_win(win)
        vim.api.nvim_feedkeys(count .. dir, "n", false)

        vim.defer_fn(function()
          if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_set_current_win(win)
            local keys = vim.api.nvim_replace_termcodes("<CR>", true, false, true)
            vim.api.nvim_feedkeys(keys, "m", false)
          end
        end, 50)

        return
      end
    end
  end
end

vim.keymap.set("n", "<C-PageDown>", remote_scroll({ "snacks_picker_list" }, "j"), {})
vim.keymap.set("n", "<C-PageUp>", remote_scroll({ "snacks_picker_list" }, "k"), {})
vim.keymap.set("n", "<M-C-S-Home>", remote_scroll({ "undotree", "aerial" }, "j"), {})
vim.keymap.set("n", "<C-G>", remote_scroll({ "undotree", "aerial" }, "k"), {})

------------------------------------------------

vim.keymap.set({ "n", "o" }, "<M-C-D>", "*<cmd>nohlsearch<CR>", { silent = true })
vim.keymap.set("x", "<M-C-D>", "<Esc>*gvn<cmd>nohlsearch<CR>", { silent = true })
vim.keymap.set({ "n", "o" }, "<M-C-A>", "#<cmd>nohlsearch<CR>", { silent = true })
vim.keymap.set("x", "<M-C-A>", "<Esc>#gvn<cmd>nohlsearch<CR>", { silent = true })

vim.keymap.set("n", "ZR", function()
  local explorer = Snacks.picker.get({ source = "explorer" })[1]
  if explorer then
    explorer:close()
  end
  vim.defer_fn(function()
    vim.cmd("w")
  end, 50)
  vim.defer_fn(function()
    vim.cmd("normal! 8ZR")
  end, 200)
end, { desc = "Reload nvim" })

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

vim.keymap.set("n", "<leader>hv", function()
  local file = vim.fn.expand("%")
  if vim.fn.executable(file) == 1 then
    vim.cmd("!chmod -x " .. file)
    vim.notify("chmod -x " .. file, vim.log.levels.WARN)
  else
    vim.cmd("!chmod +x " .. file)
    vim.notify("chmod +x " .. file, vim.log.levels.INFO)
  end
end, { desc = "toggle chmod +x/-x" })

vim.keymap.set("n", "<leader>hb", "<cmd>source %<CR>", { desc = "Source current file" })
vim.keymap.set("n", "<leader>az", "<cmd>!keyd reload<CR>", { desc = "Reload keyd" })
vim.keymap.set("n", "<leader>ab", "<cmd>Lazy<CR>")
vim.keymap.set("n", "<leader>ae", "<cmd>Mason<CR>")
vim.keymap.set("n", "<leader>ad", function()
  local file = vim.fn.expand("%:t") -- current filename
  vim.cmd("Sexplore")
  vim.fn.search("^" .. vim.fn.escape(file, "\\.*$^~[]") .. "$", "w")
end, { desc = "Explore and focus current file" })

vim.keymap.set("n", "<leader>a}", function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "query" then
      vim.api.nvim_win_close(win, true)
      return
    end
  end
  vim.treesitter.inspect_tree()
  vim.schedule(function()
    local buf = vim.api.nvim_get_current_buf()
    if vim.bo[buf].filetype == "query" then
      vim.api.nvim_input("I")
    end
  end)
end, { desc = "Toggle Inspect Tree" })

vim.keymap.set("n", "<leader>a{", vim.show_pos, { desc = "Inspect Pos" })

vim.keymap.set("n", "<M-C-P>", "g+")
vim.keymap.set("n", "<M-C-N>", "g-")
vim.keymap.set("i", "<M-C-P>", "<c-o>:later<CR>", { silent = true })
vim.keymap.set("i", "<M-C-N>", "<c-o>:earlier<CR>", { silent = true })

vim.keymap.set("i", " ", "<C-]> <C-g>u") -- expands abbreviations, then adds space with undo break
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

vim.keymap.set({ "n", "i" }, "<M-C-_>", "<C-^>")
vim.keymap.set("n", "<PageDown>", "<C-d>zz")
vim.keymap.set("n", "<PageUp>", "<C-u>zz")

vim.keymap.set("s", "<Del>", "<BS>i")

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

local cmd = "hyprctl dispatch 'hl.dsp.focus({ workspace = \"1\" })' && ~/archlinux/.config/hypr/bin/paste"

local function bind_send(lhs, cmd, register)
  local global_name = "SlimeBrowserSendOp_" .. lhs:gsub("[^%w]", "_")
  _G[global_name] = function(type)
    vim.fn.setreg(register, yank_motion_text(type))
    vim.fn.jobstart(cmd, { detach = true })
  end
  vim.keymap.set("n", lhs, function()
    vim.o.operatorfunc = "v:lua." .. global_name
    return "g@"
  end, { expr = true, desc = "Send motion to browser" })
  vim.keymap.set("x", lhs, function()
    vim.fn.setreg(register, yank_selection_text())
    vim.fn.jobstart(cmd, { detach = true })
  end, { desc = "Send selection to browser" })
end

bind_send("<leader>f", cmd, "+")

------------------------------------------------

local function bind_send_text(lhs, base_cmd)
  local global_name = "SlimeBrowserSendTextOp_" .. lhs:gsub("[^%w]", "_")
  _G[global_name] = function(type)
    local text = yank_motion_text(type)
    vim.fn.jobstart({ "sh", "-c", base_cmd .. " --text " .. vim.fn.shellescape(text) }, { detach = true })
  end
  vim.keymap.set("n", lhs, function()
    vim.o.operatorfunc = "v:lua." .. global_name
    return "g@"
  end, { expr = true, desc = "Send motion text via --text" })
  vim.keymap.set("x", lhs, function()
    local text = yank_selection_text()
    vim.fn.jobstart({ "sh", "-c", base_cmd .. " --text " .. vim.fn.shellescape(text) }, { detach = true })
  end, { desc = "Send selection text via --text" })
end

bind_send_text("<leader>r", "~/archlinux/.local/bin/clipboard-slime-core last --jump")
bind_send_text("<leader>w", "~/archlinux/.local/bin/clipboard-slime-core last --execute")
bind_send_text("<leader>q", "~/archlinux/.local/bin/clipboard-slime-core last --jump --execute")
bind_send_text("<leader>m", "~/archlinux/.local/bin/clipboard-slime-core last --jump --no-cancel")

------------------------------------------------

vim.keymap.set("n", "<leader>a[", function()
  vim.cmd("normal! mz")
  vim.cmd("put! ='stylua: ignore'")
  vim.cmd("normal gcc")
  vim.cmd("normal! ==`z")
  vim.cmd("undojoin")
end, { silent = true, desc = "stylua: ignore above" })

----------------------------------------------

vim.keymap.set("n", "<leader>a]", function()
  vim.cmd("normal! mz")
  vim.cmd("put ='------------------------------------------------'")
  vim.cmd("normal gcc")
  vim.cmd("put =''")
  vim.cmd("normal! =k`z")
  vim.cmd("undojoin")
end, { silent = true, desc = "separator below" })

vim.keymap.set({ "n", "x", "o" }, "<BS>8", "<Esc>vie*", { remap = true })
vim.keymap.set({ "n", "x", "o" }, "<BS>9", "<Esc>vie#", { remap = true })

vim.keymap.set({ "n", "x", "o" }, "<BS>*", "<Esc>viW*", { remap = true })
vim.keymap.set({ "n", "x", "o" }, "<BS>#", "<Esc>viW#", { remap = true })

vim.keymap.set({ "n", "x", "o" }, "|", "/\\V")
vim.keymap.set({ "n", "x", "o" }, "\\", "?\\V")

vim.keymap.set({ "n", "x", "o" }, "<Left>", "<nop>")
vim.keymap.set({ "n", "x", "o" }, "<Right>", "<nop>")
vim.keymap.set({ "n", "x", "o" }, "<Down>", "<nop>")
vim.keymap.set({ "n", "x", "o" }, "<Up>", "<nop>")
vim.keymap.set({ "n", "x", "o" }, "<Del>", "<nop>")
vim.keymap.set({ "n", "x", "o" }, ">", "<nop>")
vim.keymap.set({ "n", "x", "o" }, "<", "<nop>")
vim.keymap.set({ "x", "o" }, "<LeftMouse>", "<nop>")
vim.keymap.set({ "x", "o" }, "<RightMouse>", "<nop>")

Snacks.toggle.option("wrap"):map("<leader>hr")

vim.keymap.set("x", "<leader>o", ':g#^$#normal! "_dd<CR><Cmd>noh<CR>', { silent = true, desc = "Delete blank lines" })
vim.keymap.set("n", "<leader>a<CR>", ":let @+=@:<Left><Insert>", { desc = "let @+ =@x" })

------------------------------------------------

vim.keymap.set("i", "<C-S-End><Del>", '<C-Home><C-v><Esc>"zd<C-End>', { remap = true, silent = true })

vim.keymap.set("c", "<S-End><Del><BS>", '<c-f>"zD<C-c>')

vim.keymap.set({ "c", "i" }, "<C-BS>", "<C-s-w>")
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

vim.keymap.set({ "n", "x" }, "<leader>jv", function()
  Snacks.gitbrowse()
end, { desc = "Git browser (open)" })

vim.keymap.set({ "n", "x" }, "<leader>jc", function()
  Snacks.gitbrowse({
    open = function(url)
      vim.fn.setreg("+", url)
    end,
    notify = false,
  })
end, { desc = "Git browser (copy)" })

vim.keymap.set({ "n", "x" }, "<leader>jc", function()
  Snacks.gitbrowse({
    open = function(url)
      vim.fn.setreg("+", url)
    end,
    notify = false,
  })
end, { desc = "Git browser (copy)" })

----------------------------------------------

local explorer_actions = require("snacks.explorer.actions").actions
local Tree = require("snacks.explorer.tree")
local function get_path(count)
  local modifier = count > 0 and string.rep(":h", count) or ""
  return vim.fn.expand("%:p" .. modifier)
end

local function fake_picker(path)
  local dir = vim.fn.fnamemodify(path, ":h")
  return {
    opts = {},
    input = { filter = { meta = {} }, set = function() end },
    list = {
      win = { focus = function() end },
      set_target = function() end,
      set_selected = function() end,
      select = function() end,
      view = function() end,
    },
    selected = function(_, o)
      return (o and o.fallback) and { { file = path } } or {}
    end,
    dir = function()
      return dir
    end,
    cwd = function()
      return dir
    end,
    find = function() end,
    iter = function()
      return function() end
    end,
    current = function()
      return { file = path }
    end,
  }
end

local function buf_action(name)
  return function()
    local path = get_path(vim.v.count)
    if path == "" then
      Snacks.notify.warn("No file for current buffer")
      return
    end
    local item = { file = path }
    local picker = fake_picker(path)
    local ok, err = pcall(explorer_actions[name], picker, item)
    if not ok then
      Snacks.notify.error("buf_action(" .. name .. ") failed:\n" .. tostring(err))
      return
    end
    Tree:refresh(vim.fn.fnamemodify(path, ":h"))
  end
end

vim.keymap.set({ "n", "x", "s", "i" }, "<C-D>", buf_action("explorer_yank"), { noremap = true, silent = true })
vim.keymap.set({ "n", "x", "s", "i" }, "<M-C-Y>", buf_action("explorer_open"), { noremap = true, silent = true })
vim.keymap.set({ "n", "x", "s", "i" }, "<M-M>", buf_action("explorer_paste"), { noremap = true, silent = true })
vim.keymap.set({ "n", "x", "s", "i" }, "<M-N>", buf_action("explorer_rename"), { noremap = true, silent = true })
vim.keymap.set({ "n", "x", "s", "i" }, "<M-g>", buf_action("explorer_del"), { noremap = true, silent = true })
vim.keymap.set({ "n", "x", "s", "i" }, "<M-n>", buf_action("explorer_add"), { noremap = true, silent = true })

vim.keymap.set("n", "<C-S-B>", function()
  local p = vim.fn.expand("%:p")
  local count = vim.v.count
  local path = count == 0 and p or vim.fn.fnamemodify(p, string.rep(":h", count))
  local uri = vim.uri_from_fname(path)
  local script = string.format("copy('text/uri-list','%s','x-special/gnome-copied-files','copy\\n%s')", uri, uri)
  vim.fn.jobstart({ "copyq", "eval", "--", script })
  vim.notify(uri, vim.log.levels.INFO)
end, { desc = "yank_file_uri" })

vim.keymap.set("n", "<leader>hc", function()
  local file_src = vim.api.nvim_buf_get_name(0)
  if file_src == "" then
    vim.notify("No file in buffer", vim.log.levels.WARN)
    return
  end
  vim.ui.input({ prompt = "Copy to ", default = file_src, completion = "file" }, function(file_out)
    if not file_out or file_out == "" then
      return
    end
    local dir = vim.fn.fnamemodify(file_out, ":h")
    local res = vim.fn.system({ "mkdir", "-p", dir })
    if vim.v.shell_error ~= 0 then
      vim.notify(res, vim.log.levels.ERROR)
      return
    end
    vim.fn.system({ "cp", "-R", file_src, file_out })
    if vim.v.shell_error ~= 0 then
      vim.notify("Copy failed", vim.log.levels.ERROR)
      return
    end
    vim.notify("Copied to " .. file_out, vim.log.levels.INFO)
    vim.cmd("edit " .. vim.fn.fnameescape(file_out))
  end)
end, { desc = "Copy File To" })

vim.keymap.set("n", "<leader>hx", function()
  local file_src = vim.api.nvim_buf_get_name(0)
  if file_src == "" then
    vim.notify("No file in buffer", vim.log.levels.WARN)
    return
  end
  vim.ui.input({ prompt = "Move to ", default = file_src, completion = "file" }, function(file_out)
    if not file_out or file_out == "" then
      return
    end
    local dir = vim.fn.fnamemodify(file_out, ":h")
    local res = vim.fn.system({ "mkdir", "-p", dir })
    if vim.v.shell_error ~= 0 then
      vim.notify(res, vim.log.levels.ERROR)
      return
    end
    vim.fn.system({ "mv", file_src, file_out })
    if vim.v.shell_error ~= 0 then
      vim.notify("Move failed", vim.log.levels.ERROR)
      return
    end
    vim.notify("Moved to " .. file_out, vim.log.levels.INFO)
    vim.cmd("edit " .. vim.fn.fnameescape(file_out))
  end)
end, { desc = "Move File To" })

vim.keymap.set("n", "<leader>a}", function()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    return
  end

  local modifier = ":h"
  if vim.v.count > 0 then
    modifier = modifier .. string.rep(":h", vim.v.count)
  end
  local dir = vim.fn.fnamemodify(path, modifier)

  vim.fn.jobstart("tmux new-window -c " .. vim.fn.shellescape(dir), { detach = true })
end, { desc = "Open tmux window N parent dir" })

vim.keymap.set("n", "<leader>a{", function()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    return
  end

  local buf = vim.fn.bufadd(path)
  vim.fn.bufload(buf)
  local root = LazyVim.root.get({ buf = buf })

  vim.fn.jobstart("tmux new-window -c " .. vim.fn.shellescape(root), { detach = true })
end, { desc = "Open tmux window project root" })

vim.keymap.set("n", "<leader>h<CR>", function()
  vim.ui.input({
    prompt = "Edit file: ",
    default = vim.fn.expand("%:p:h") .. "/",
    completion = "file",
  }, function(input)
    if input and input ~= "" then
      vim.cmd.edit(input)
    end
  end)
end, { desc = "Edit or Create file in current dir" })

----------------------------------------------

vim.keymap.set("n", "<leader>jA", function()
  local buf = vim.api.nvim_get_current_buf()
  local root = LazyVim.root.git({ buf = buf })
  if not root then
    return
  end
  vim.system(
    { "sh", "-c", [[
    git add -A &&
    git commit -m 'add files/dirs' &&
    git push origin main
  ]] },
    { cwd = root }
  )
end, { desc = "Git add, commit, push" })

vim.keymap.set("n", "<leader>ja", function()
  local buf = vim.api.nvim_get_current_buf()
  local root = LazyVim.root.git({ buf = buf })
  local path = vim.api.nvim_buf_get_name(buf)
  if not root or path == "" then
    return
  end
  vim.system({ "git", "add", path }, { cwd = root })
end, { desc = "Git add %" })

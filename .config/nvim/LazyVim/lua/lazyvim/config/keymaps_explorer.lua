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

vim.keymap.set("n", "<leader>au", function()
  local modifier = ":~"
  if vim.v.count > 0 then
    modifier = modifier .. string.rep(":h", vim.v.count)
  end
  local path = vim.fn.expand("%" .. modifier)
  vim.fn.system("wl-copy", path)
  vim.notify("Copied: " .. path, vim.log.levels.INFO, { title = "Relative path" })
end, { desc = "Copy relative path N levels up" })

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
end, { desc = "Edit file in current dir" })

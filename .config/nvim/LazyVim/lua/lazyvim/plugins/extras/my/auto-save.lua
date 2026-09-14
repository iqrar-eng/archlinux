-- some recommended exclusions. you can use `:lua print(vim.bo.filetype)` to
-- get the filetype string of the current buffer
local excluded_filetypes = {
  "harpoon",
}

local excluded_filenames = {
  -- "do-not-autosave-me.lua"
}

local function save_condition(buf)
  if
    vim.tbl_contains(excluded_filetypes, vim.fn.getbufvar(buf, "&filetype"))
    -- or vim.tbl_contains(excluded_filenames, vim.fn.expand("%:t"))
  then
    return false
  end
  return true
end

return {
  {
    "okuuva/auto-save.nvim",
    enabled = true,
    event = { "InsertLeave", "TextChanged" },
    opts = {
      debounce_delay = 500,
      trigger_events = {
        immediate_save = {
          "BufLeave",
          "FocusLost",
          "QuitPre",
          "VimSuspend",
          "VimLeavePre",
        },
      },
      condition = save_condition,
    },
  },
}

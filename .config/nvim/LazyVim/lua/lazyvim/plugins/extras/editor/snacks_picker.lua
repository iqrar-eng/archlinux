-- stylua: ignore start
local function make_harpoon_picker_source(list_name)
  return {
    finder = function(opts, ctx)
      local list = require("harpoon"):list(list_name)
      local files = {}
      for idx = 1, list:length() do
        local item = list:get(idx)
        if item then
          table.insert(files, {
            text = item.value,
            file = item.value,
            idx = idx,
          })
        end
      end
      return files
    end,
    format = "file",
    preview = "file",
    confirm = "jump",
    actions = {
      harpoon_remove = function(picker)
        local items = picker:selected({ fallback = true })
        if #items == 0 then
          return
        end

        local harpoon = require("harpoon")
        local list = harpoon:list(list_name)

        -- remove by VALUE, not by cached idx — idx can be stale/duplicated
        local values_to_remove = {}
        for _, it in ipairs(items) do
          values_to_remove[it.file] = true
        end

        -- walk the underlying items high-to-low and splice them out directly
        -- (list:remove_at leaves holes in some harpoon2 versions when the
        -- internal table already has gaps; rebuilding is the reliable fix)
        local kept = {}
        for i = 1, list:length() do
          local item = list:get(i)
          if item and not values_to_remove[item.value] then
            table.insert(kept, item)
          end
        end

        list.items = kept
        harpoon:sync()
        picker:find()
      end,
    },
    win = {
      input = {
        keys = {
          ["<C-K>"] = { "harpoon_remove", mode = { "n", "x", "i" } },
        },
      },
    },
  }
end

if lazyvim_docs then
  -- In case you don't want to use `:LazyExtras`,
  -- then you need to set the option below.
  vim.g.lazyvim_picker = "snacks"
end

---@module 'snacks'

---@type LazyPicker
local picker = {
  name = "snacks",
  commands = {
    files = "files",
    live_grep = "grep",
    oldfiles = "recent",
  },

  ---@param source string
  ---@param opts? snacks.picker.Config
  open = function(source, opts)
    return Snacks.picker.pick(source, opts)
  end,
}
if not LazyVim.pick.register(picker) then
  return {}
end

return {
  desc = "Fast and modern file picker",
  recommended = true,
  {
    "folke/snacks.nvim",
    opts = {
      scratch = {
        autowrite = false, -- prevent the callback that re-hides the buffer
        win_by_ft = { lua = { keys = { ["source"] = false, }, }, },
      },
      indent = {
        indent = {
          hl = {
            "SnacksIndent1",
            "SnacksIndent2",
            "SnacksIndent3",
            "SnacksIndent4",
            "SnacksIndent5",
            "SnacksIndent6",
            "SnacksIndent7",
            "SnacksIndent8",
            "SnacksIndent9",
            "SnacksIndent10",
            "SnacksIndent11",
            "SnacksIndent12",
          },
        },
        scope = { enabled = false },
      },
      scroll = { enabled = false },
      statuscolumn = { enabled = false }, -- we set this in options.lua
      lazygit = { enabled = false },
      image = { doc = { inline = false } },
      input = { win = { b = { completion = true } } },
      toggle = { map = LazyVim.safe_keymap_set },
      notifier = {},
      words = {},
      styles = {
        scratch = { position = "current", keys = { q = false, }, },
        input = {
          keys = {
            i_ctrl_c = { "<C-c>", "cancel", mode = "i" },
            n_ctrl_c = { "<C-c>", "cancel", mode = "n" },
          },
        },
      },
      picker = {
        matcher = { ignorecase = true, smartcase = false, },
        layout = "custom_layout",
        layouts = {
          custom_layout = {
            layout = {
              reverse = true,
              backdrop = false,
              width = 0,
              min_width = 0,
              height = 0,
              box = "vertical",
              { win = "preview", height = 0.7 },
              { win = "input", height = 1 },
              { win = "list" },
            },
          },
        },

        sources = {
          harpoon = make_harpoon_picker_source(nil),      -- default list
          harpoon_todo = make_harpoon_picker_source("todo"),
          lines = { layout = { preview = "top", preset = "custom_layout" } },
          todo_comments = { hidden = true, },
          files = { hidden = true, follow = true, },
          grep = { hidden = true, regex = false, },
          grep_word = { hidden = true, auto_confirm = true, },
          git_status = {
            win = {
              input = {
                keys = {
                  ["<Tab>"] = { "select_and_next", mode = { "n", "i" }, nowait = true },
                  ["<C-S-S>"] = { "git_stage", mode = { "n", "i" } },
                },
              },
            },
          },
          git_diff = {
            win = {
              input = {
                keys = {
                  ["<Tab>"] = { "select_and_next", mode = { "n", "i" }, nowait = true },
                  ["<C-S-S>"] = { "git_stage", mode = { "n", "i" } },
                },
              },
            },
          },
        },
        win = {
          input = {
            keys = {
              ["<C-c>"] = { "cancel", mode = { "n", "x", "i" } },
              ["/"] = { "/", mode = { "n", "x" }, expr = true, desc = "delete word" },
              ["?"] = { "?", mode = { "n", "x" }, expr = true, desc = "delete word" },
              ["g?"] = "toggle_help_list",
              ["<M-1>"] = { function() require("dial.map").manipulate("increment", "normal") end, mode = { "n" }, desc = "Increment", },
              ["<M-4>"] = { function() require("dial.map").manipulate("decrement", "normal") end, mode = { "n" }, desc = "Decrement", },
              ["<C-L>"] = { "focus_list", mode = { "n", "x", "i" } },
              ["<PageUp>"] = { "list_scroll_up", mode = { "n", "x", "i" } },
              ["<PageDown>"] = { "list_scroll_down", mode = { "n", "x", "i" } },
              ["<C-Home>"] = { "list_top", mode = { "n", "x", "i" } },
              ["<C-End>"] = { "list_bottom", mode = { "n", "x", "i" } },
              ["<C-S-W>"] = { "picker_files", mode = { "n", "x", "i" } },
              ["<C-S-N>"] = { "picker_grep", mode = { "n", "x", "i" } },
              ["<M-w>"] = { "focus_preview", mode = { "n", "x", "i" } },
              ["<M-9>"] = { "<C-A>", mode = { "i" }, expr = true, desc = "delete word" },
              ["<M-2>"] = { "preview_scroll_down", mode = { "n", "x", "s", "i" } },
              ['<M-3>'] = { "preview_scroll_up", mode = { "n", "x", "s", "i" } },

              ["<M-m>"] = { "explorer_move", mode = { "n", "x", "i" } },
              ["<C-D>"] = { "explorer_yank", mode = { "n", "x", "i" } },
              ["<M-C-Y>"] = { "explorer_open", mode = { "n", "x", "i" } },
              ["<M-C-S>"] = { "explorer_paste", mode = { "n", "x", "i" } },
              ["<M-g>"] = { "explorer_del", mode = { "n", "x", "i" } },
              ["<M-n>"] = { "explorer_add", mode = { "n", "x", "i" } },
              ["<M-N>"] = { "explorer_rename", mode = { "n", "x", "i" } },
            },
          },
          list = {
            keys = {
              ["<C-c>"] = { "cancel", mode = { "n", "x", "i" } },
              ["/"] = { "/", mode = { "n", "x" }, expr = true, desc = "delete word" },
              ["?"] = { "?", mode = { "n", "x" }, expr = true, desc = "delete word" },
              ["g?"] = "toggle_help_list",
              ["<PageUp>"] = "list_scroll_up",
              ["<PageDown>"] = "list_scroll_down",
              ["<C-Home>"] = "list_top",
              ["<C-End>"] = "list_bottom",
              ["<C-S-W>"] = { "picker_files", mode = { "n", "x", "i" } },
              ["<C-S-N>"] = { "picker_grep", mode = { "n", "x", "i" } },
              ["<M-w>"] = { "focus_preview", mode = { "n", "x", "i" } },
              ["<M-2>"] = { "preview_scroll_down", mode = { "n", "x", "s", "i" } },
              ['<M-3>'] = { "preview_scroll_up", mode = { "n", "x", "s", "i" } },

              ["<M-m>"] = { "explorer_move", mode = { "n", "x", "i" } },
              ["<C-D>"] = { "explorer_yank", mode = { "n", "x", "i" } },
              ["<M-C-Y>"] = { "explorer_open", mode = { "n", "x", "i" } },
              ["<M-C-S>"] = { "explorer_paste", mode = { "n", "x", "i" } },
              ["<M-g>"] = { "explorer_del", mode = { "n", "x", "i" } },
              ["<M-n>"] = { "explorer_add", mode = { "n", "x", "i" } },
              ["<M-N>"] = { "explorer_rename", mode = { "n", "x", "i" } },
            },
          },
          preview = {
            keys = {
              ["<C-c>"] = { "cancel", mode = { "n", "x", "i" } },
              ["<C-L>"] = { "focus_list", mode = { "n", "x", "i" } },
            },
          },
        },
      },
    },
    keys = {
      { "<C-L>",     LazyVim.pick("files"), desc = "Find Files (root dir)", mode = { "n", "x" } },
      { "<BS><Up>", LazyVim.pick("files", { root = false }), desc = "Find Files (cwd)", mode = { "n", "x" } },
      { "<BS><PageDown>", LazyVim.pick("grep"),  desc = "Grep (root dir)",       mode = { "n", "x" } },
      { "<BS><PageUp>", LazyVim.pick("live_grep", { root = false }), desc = "Grep (cwd)", mode = { "n", "x" } },
      { "<BS><Home>", LazyVim.pick("grep_word"), desc = "Word/Selection (root dir)", mode = { "n", "x" } },
      { "<BS><End>", LazyVim.pick("grep_word", { root = false }), desc = "Word/Selection (cwd)", mode = { "n", "x" } },
      { "<BS>1", function() Snacks.picker.grep_buffers() end, desc = "Grep Buffers", mode = { "n", "x" } },
      { "<BS>2", function() Snacks.picker.buffers() end, desc = "Find Files Buffers", mode = { "n", "x" } },
      { "<BS>?", function() Snacks.picker.jumps() end, desc = "Jump List", mode = { "n", "x" } },
      { "<BS>.", function() require("aerial").snacks_picker() end, desc = "aerial picker", mode = { "n", "x" } },
      { "<BS><Right>", function() Snacks.picker.harpoon() end, desc = "Harpoon Picker", mode = { "n", "x" } },
      { "<BS><Left>", function() Snacks.picker.harpoon_todo() end, desc = "Harpoon Picker (todo)", mode = { "n", "x" } },
      { "<BS><Down>", function() Snacks.picker.undo() end, desc = "Undo Tree", mode = { "n", "x" } },
      { "<BS>7", function() Snacks.picker.man() end, desc = "Man Pages", mode = { "n", "x" } },
      { "<BS>6", function() Snacks.picker.icons() end, desc = "Icons", mode = { "n", "x" } },
      { "<BS>(", function() Snacks.picker.scratch() end, desc = "Toggle Scratch Buffer" },
      { "<BS>)", function() Snacks.scratch.open() end, desc = "Select Scratch Buffer" },
      { "<BS>=", function() Snacks.picker.diagnostics() end, desc = "Diagnostics", mode = { "n", "x" } },
      { "<BS>+", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics", mode = { "n", "x" } },
      { "<leader>av",       function() Snacks.picker.lines()     end, desc = "Buffer Lines"          },
      { "<leader>aw",   function() Snacks.picker.resume()    end, desc = "Resume Last Picker"    },
      { "<leader>af", function() Snacks.picker.help() end, desc = "Help Pages", mode = { "n", "x" } },
      { "<leader>hq", function() Snacks.picker.qflist() end, desc = "Quickfix List", mode = { "n", "x" } },
      { "<leader>hm", function() Snacks.picker.marks() end, desc = "Marks", mode = { "n", "x" } },
      { "<leader>hp", function() Snacks.picker.lazy() end, desc = "Plugin Specs", mode = { "n", "x" } },
      { "<leader>hl", function() Snacks.picker.notifications() end, desc = "Notifications", mode = { "n", "x" } },
      { "<leader>he", function() Snacks.picker.registers() end, desc = "Registers", mode = { "n", "x" } },
      { "<leader>ha", function() Snacks.picker.autocmds() end, desc = "Autocmds", mode = { "n", "x" } },
      { "<leader>hh", function() Snacks.picker.command_history() end, desc = "Command History", mode = { "n", "x" } },
      { "<leader>hj", function() Snacks.picker.search_history() end, desc = "Search History", mode = { "n", "x" } },
      { "<leader>hs", function() Snacks.picker.keymaps() end, desc = "Keymaps", mode = { "n", "x" } },
      { "<leader>hu", function() Snacks.picker.highlights() end, desc = "Highlights", mode = { "n", "x" } },
      { "<leader>hg",  function() Snacks.picker()                 end, desc = "All Pickers"     },

      -- git
      { "<leader>gb", function() Snacks.picker.git_branches({ cwd = LazyVim.root.git() }) end, desc = "Git Branches" },
      { "<leader>gl", function() Snacks.picker.git_log({ cwd = LazyVim.root.git() }) end, desc = "Git Log" },
      { "<leader>gL", function() Snacks.picker.git_log_line({ cwd = LazyVim.root.git() }) end, desc = "Git Log Line" },
      { "<leader>gs", function() Snacks.picker.git_status({ cwd = LazyVim.root.git() }) end, desc = "Git Status" },
      { "<leader>gS", function() Snacks.picker.git_stash({ cwd = LazyVim.root.git() }) end, desc = "Git Stash" },
      { "<leader>gd", function() Snacks.picker.git_diff({ cwd = LazyVim.root.git() }) end, desc = "Git Diff (Hunks)" },
      { "<leader>gf", function() Snacks.picker.git_log_file({ cwd = LazyVim.root.git() }) end, desc = "Git Log File" },
      { "<leader>gD", function() Snacks.picker.git_diff({ cwd = LazyVim.root.git(), staged = false, group = true }) end, desc = "git Diff (Origin)" },

      { "<leader>ks", LazyVim.pick("files", { cwd = vim.fn.expand("~/archlinux/") }), desc = "Find Files archlinux", mode = { "n", "x" } },
      { "<leader>kS", LazyVim.pick("grep", { cwd = vim.fn.expand("~/archlinux/") }), desc = "Grep archlinux", mode = { "n", "x" } },
      { "<leader>kt", LazyVim.pick("files", { cwd = vim.fn.expand("~/.local/share/Trash/files/") }), desc = "Find Files Trash", mode = { "n", "x" } },
      { "<leader>kT", LazyVim.pick("grep", { cwd = vim.fn.expand("~/.local/share/Trash/files/") }), desc = "Grep Trash", mode = { "n", "x" } },

      { "<leader>kq", LazyVim.pick("files", { cwd = vim.fn.expand("~/.src/prisma/apps/docs/content/docs/") }), desc = "Find Files prisma", mode = { "n", "x" } },
      { "<leader>kQ", LazyVim.pick("grep", { cwd = vim.fn.expand("~/.src/prisma/apps/docs/content/docs/") }), desc = "Grep prisma", mode = { "n", "x" } },
      { "<leader>kb", LazyVim.pick("files", { cwd = vim.fn.expand("~/.src/better-auth/docs/content/docs") }), desc = "Find Files better-auth", mode = { "n", "x" } },
      { "<leader>kB", LazyVim.pick("grep", { cwd = vim.fn.expand("~/.src/better-auth/docs/content/docs") }), desc = "Grep better-auth", mode = { "n", "x" } },
      { "<leader>kx", LazyVim.pick("files", { cwd = vim.fn.expand("~/.src/next.js/docs/01-app") }), desc = "Find Files next.js", mode = { "n", "x" } },
      { "<leader>kX", LazyVim.pick("grep", { cwd = vim.fn.expand("~/.src/next.js/docs/01-app") }), desc = "Grep next.js", mode = { "n", "x" } },
      { "<leader>kd", LazyVim.pick("files", { cwd = vim.fn.expand("~/.src/node/doc/api") }), desc = "Find Files node", mode = { "n", "x" } },
      { "<leader>kD", LazyVim.pick("grep", { cwd = vim.fn.expand("~/.src/node/doc/api") }), desc = "Grep node", mode = { "n", "x" } },
      { "<leader>ka", LazyVim.pick("files", { cwd = vim.fn.expand("~/.src/mdn/files/en-us/web/api") }), desc = "Find Files mdn api", mode = { "n", "x" } },
      { "<leader>kA", LazyVim.pick("grep", { cwd = vim.fn.expand("~/.src/mdn/files/en-us/web/api") }), desc = "Grep mdn api", mode = { "n", "x" } },
      { "<leader>kh", LazyVim.pick("files", { cwd = vim.fn.expand("~/.src/mdn/files/en-us/web/http") }), desc = "Find Files mdn http", mode = { "n", "x" } },
      { "<leader>kH", LazyVim.pick("grep", { cwd = vim.fn.expand("~/.src/mdn/files/en-us/web/http") }), desc = "Grep mdn http", mode = { "n", "x" } },
      { "<leader>kj", LazyVim.pick("files", { cwd = vim.fn.expand("~/.src/mdn/files/en-us/web/javascript") }), desc = "Find Files mdn javascript", mode = { "n", "x" } },
      { "<leader>kJ", LazyVim.pick("grep", { cwd = vim.fn.expand("~/.src/mdn/files/en-us/web/javascript") }), desc = "Grep mdn javascript", mode = { "n", "x" } },
      { "<leader>kr", LazyVim.pick("files", { cwd = vim.fn.expand("~/.src/react/src/content/reference/") }), desc = "Find Files react", mode = { "n", "x" } },
      { "<leader>kR", LazyVim.pick("grep", { cwd = vim.fn.expand("~/.src/react/src/content/reference/") }), desc = "Grep react", mode = { "n", "x" } },
      { "<leader>kc", LazyVim.pick("files", { cwd = vim.fn.expand("~/.src/typescript-cheatsheets-react/docs") }), desc = "Find Files typescript-cheatsheets-react", mode = { "n", "x" } },
      { "<leader>kC", LazyVim.pick("grep", { cwd = vim.fn.expand("~/.src/typescript-cheatsheets-react/docs") }), desc = "Grep typescript-cheatsheets-react", mode = { "n", "x" } },
      { "<leader>kl", LazyVim.pick("files", { cwd = vim.fn.expand("~/.src/LazyVim") }), desc = "Find Files LazyVim", mode = { "n", "x" } },
      { "<leader>kL", LazyVim.pick("grep", { cwd = vim.fn.expand("~/.src/LazyVim") }), desc = "Grep LazyVim", mode = { "n", "x" } },
    },
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ["*"] = {
          keys = {
            { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition", has = "definition" },
            { "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
            { "gw", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
            { "g<CR>", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
            { "gD", function() Snacks.picker.lsp_declarations() end,     desc= "Goto lsp_declarations" },
            { "gai", function() Snacks.picker.lsp_incoming_calls() end, desc = "C[a]lls Incoming", has = "callHierarchy/incomingCalls" },
            { "gao", function() Snacks.picker.lsp_outgoing_calls() end, desc = "C[a]lls Outgoing", has = "callHierarchy/outgoingCalls" },
          },
        },
      },
    },
  },

  {
    "folke/todo-comments.nvim",
    cmd = { "TodoTrouble", "TodoTelescope" },
    event = "LazyFile",
    opts = {},
    keys = {
      { "<leader>h[", function() Snacks.picker.todo_comments() end, desc = "Todo" },
      { "<leader>h]", function () Snacks.picker.todo_comments({ cwd = LazyVim.root.get({ buf = vim.api.nvim_get_current_buf() }) }) end, desc = "Todo/Fix/Fixme" },
      { "<Up>*", function() require("todo-comments").jump_next() end, desc = "Next Todo Comment" },
      { "<Left>*", function() require("todo-comments").jump_prev() end, desc = "Prev Todo Comment" },
    },
  },
}

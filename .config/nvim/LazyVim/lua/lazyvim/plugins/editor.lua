return {
  {
    "MagicDuck/grug-far.nvim",
    cmd = { "GrugFar", "GrugFarWithin" },
    keys = {
      {
        "<leader>ag",
        function()
          local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
          require("grug-far").open({
            prefills = { paths = LazyVim.root.get(), flags = "--ignore-case --fixed-strings --hidden" },
          })
        end,
        mode = { "n", "x" },
        desc = "root",
      },

      {
        "<leader>am",
        function()
          require("grug-far").open({
            prefills = { paths = vim.fn.expand("%"), flags = "--ignore-case --fixed-strings --hidden" },
          })
        end,
        mode = { "n", "x" },
        desc = "current file",
      },
    },
    opts = {
      wrap = false,
      windowCreationCommand = "tabnew",
    },
    config = function(_, opts)
      require("grug-far").setup(opts)
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("grug-far-custom-keybinds", { clear = true }),
        pattern = { "grug-far" },
        callback = function()
          vim.keymap.set("n", "<localleader>z", function()
            require("grug-far").get_instance(0):toggle_flags({ "--fixed-strings" })
          end, { buffer = true, desc = "Toggle --fixed-strings" })

          vim.keymap.set("n", "<localleader>g", function()
            require("grug-far").get_instance(0):toggle_flags({ "--ignore-case" })
          end, { buffer = true, desc = "Toggle --ignore-case" })
        end,
      })
    end,
  },

  {
    "folke/flash.nvim",
    event = "VeryLazy",
    vscode = true,
    opts = {
      search = { multi_window = false },
      label = { before = true, after = false, rainbow = { enabled = true, shade = 6 } },
      highlight = { backdrop = false },
      modes = {
        search = { enabled = true, highlight = { backdrop = false } },
        char = {
          autohide = true,
          search = { wrap = true },
          highlight = { backdrop = false },
          char_actions = function()
            return {
              [";"] = "next", -- set to `right` to always go right
              [","] = "prev", -- set to `left` to always go left
            }
          end,
        },
      },
    },
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts_extend = { "spec" },
    opts = {
      sort = { "local", "order", "desc", "alphanum", "mod" },
      preset = "helix",
      defaults = {},
      show_help = false,
      replace = {
        -- put latest patterns at the end to avoid conflicts
        desc = {
          { "<Plug>%(?(.*)%)?", "%1" },
          { "^%+", "" },
          { "<[cC]md>", "" },
          { "=", "" },
          { "<[cC][rR]>", "" },
          { "<[sS]ilent>", "" },
          { "^lua%s+", "" },
          { "^call%s+", "" },
          { "^:%s*", "" },
          { "inner", "🎯" },
          { "MC:", "🧞‍♂️" },
          { "clipboard", "📋" },
          { "[-<>(){}]", " " },
          { "outer", "🌐" },
          { "^[nN]ext ", "🔵 " },
          { "^[pP]rev ", "🔴 " },
          { "[nN]ext$", "🔵 " },
          { "[pP]rev$", "🔴 " },
          { "goto_%a+_start", "🌱" },
          { "goto_%a+_end", "🚩" },
          { "lhs", "LHS" },
          { "rhs", "RHS" },
          { "^%a+ %a+ to REPL", "📤" },
          { "=']", "" },
          { '"z', "" },
          { "browser", "🌎" },
          { "Gitsigns", "❓" },
          { "Github", " " },
          { "Google", " " },
          { "Lazygit", " " },
          { "Git", "  " },
          { "git", " 🔎" },
          { "Find Files*", "📁 " },
          { "Grep*", "🔎 " },
          { "grepFile*", " 📕 " },
          { "file*", "󰈔 " },
          { "@", "📚 " },
          { "[Dd]eleted?", "🚮" },
          { '"z', "📚 " },
          { "[rR]egister.*", "📚" },
          { "substitute", "🪓" },
          { "complete_word", "󰈭 " },
          { "auto_apply", "🅰️" },
          { "prefix", "S" },
          { "prompt_current_text", "🟦" },
          { "_", " " },
          { "let", "" },
          { "cursor position", "start" },
        },
      },
      icons = {
        separator = "┃",
        group = "",
        keys = {
          Up = "Up",
          Down = "Down",
          Left = "Left",
          Right = "Right",
          C = "C-",
          M = "M-",
          S = "S-",
          CR = "CR",
          Esc = "Esc",
          BS = "BS",
          Space = "leader",
          Tab = "Tab",
        },
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)

      if not vim.tbl_isempty(opts.defaults) then
        LazyVim.warn("which-key: opts.defaults is deprecated. Please use opts.spec instead.")
        wk.add(opts.defaults)
      end

      local sort_with_desc = { "manual", "desc" }
      local sort_without_desc = { "alphanum" }
      local sort_state = true

      vim.keymap.set("n", "<leader>hw", function()
        sort_state = not sort_state
        -- update sort in place without re-running full setup
        require("which-key.config").options.sort = sort_state and sort_with_desc or sort_without_desc
        vim.notify("which-key sort: " .. (sort_state and "desc" or "key"))
      end, { desc = "Toggle which-key sort order" })
    end,
  },

  {
    "lewis6991/gitsigns.nvim",
    event = "LazyFile",
    opts = {
      diff_opts = {
        ignore_whitespace = true, -- ignore ALL whitespace changes (spaces AND newlines)
      },
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      signs_staged = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
      },
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc, silent = true })
        end

        -- stylua: ignore start
        map("n", "]h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.nav_hunk("next")
          end
        end, "Next Hunk")
        map("n", "[h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.nav_hunk("prev")
          end
        end, "Prev Hunk")

        map("n", ">h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.nav_hunk("next", { target = "staged" })
          end
        end, "Next Hunk")
        map("n", "<h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.nav_hunk("prev", { target = "staged" })
          end
        end, "Prev Hunk")
        map("n", ">H", function() gs.nav_hunk("last", { target = "staged" }) end, "Gitsigns Last Hunk")
        map("n", "<H", function() gs.nav_hunk("first", { target = "staged" }) end, "Gitsigns First Hunk")

        map({ "n", "x" }, "<leader>jh", ":Gitsigns stage_hunk<CR>", "Gitsigns Stage Hunk")
        map("n", "<leader>ju", gs.stage_buffer, "Gitsigns Stage Buffer")
        map("n", "<leader>jU", gs.undo_stage_hunk, "Gitsigns Undo Stage Hunk")

        map("n", "<leader>jr", gs.reset_buffer, "Gitsigns Reset Buffer")
        map({ "n", "x" }, "<leader>jm", ":Gitsigns reset_hunk<CR>", "Gitsigns Reset Hunk")

        map("n", "<leader>jw", gs.preview_hunk_inline, "Gitsigns Preview Hunk Inline")
        map("n", "<M-p>", gs.preview_hunk, "Gitsigns Preview Hunk Inline")

        map("n", "<leader>jb", function() gs.blame() end, "Gitsigns Blame Buffer")
        map("n", "<leader>jB", function() gs.blame_line({ full = true }) end, "Gitsigns Blame Line")

        map("n", "<leader>j{", gs.diffthis, "Gitsigns Diff This")
        map("n", "<leader>j}", function() gs.diffthis("~") end, "Gitsigns Diff This ~")

        map({ "o", "x" }, "iu", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
      end,
    },
  },
}

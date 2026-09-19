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
      win = {
        no_overlap = false,
        col = math.huge,
        width = { min = 1, max = math.huge },
        height = { min = 1, max = math.huge },
      },
      layout = {
        width = { min = vim.o.columns, max = math.huge },
        spacing = 1,
      },
      show_help = false,
      replace = {
        desc = {
          { "<Plug>%(?(.*)%)?", "%1" },
          { "^%+", "" },
          { "<[cC]md>", "" },
          { "<[cC][rR]>", "" },
          { "<[sS]ilent>", "" },
          { "^lua%s+", "" },
          { "^call%s+", "" },
          { "MC:", "🧞‍♂️" },
          { "inner", "🎯" },
          { "outer", "🌐" },
          { "[nN]ext ", "🔵" },
          { "[pP]rev ", "🔴" },
          { "goto_%a+_start", "🌱" },
          { "goto_%a+_end", "🚩" },
          { "Find Files*", "📁 " },
          { "Grep*", "🔎 " },
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
        require("which-key.config").options.sort = sort_state and sort_with_desc or sort_without_desc
        vim.notify("which-key sort: " .. (sort_state and "desc" or "key"))
      end, { desc = "Toggle which-key sort order" })
    end,
    keys = {
      {
        "<leader>g^",
        function()
          require("which-key").show({ keys = "<leader>g", loop = true })
        end,
        desc = "Hydra Mode (which-key)",
      },
    },
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
        map("n", "]H", function() gs.nav_hunk("last") end, "Last Hunk")
        map("n", "[H", function() gs.nav_hunk("first") end, "First Hunk")
        map({ "n", "x" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
        map({ "n", "x" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
        map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
        map("n", "<leader>ghB", function() gs.blame() end, "Blame Buffer")
        map("n", "<leader>ghd", gs.diffthis, "Diff This")
        map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
        map({ "o", "x" }, "iH", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")

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
        map("n", "<M-p>", gs.preview_hunk, "Gitsigns Preview Hunk Inline")
      end,
    },
  },

  { "tpope/vim-fugitive", event = "VeryLazy" },
}

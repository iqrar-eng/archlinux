return {
  {
    "folke/snacks.nvim",
    event = "VeryLazy",
    opts = {
      picker = {
        sources = {
          explorer = {
            exclude = { ".git", ".github" },
            hidden = true,
            ignored = true,
            layout = { preset = "my_sidebar", preview = true },
            icons = { tree = { vertical = "│", middle = "├", last = "└" } },
            layouts = {
              my_sidebar = {
                preview = "main",
                layout = {
                  backdrop = false,
                  width = 28,
                  height = 0,
                  position = "left",
                  box = "vertical",
                  { win = "list" },
                  { win = "preview", height = 0.3 },
                },
              },
            },
          },
        },
      },
    },
    keys = {
      {
        "<leader>ht",
        function()
          local explorer = Snacks.picker.get({ source = "explorer" })[1]
          if explorer then
            explorer:close()
            return
          end
          local buf = vim.api.nvim_get_current_buf()
          local root = LazyVim.root.get({ buf = buf })
          Snacks.explorer({ cwd = root, focus = false })
        end,
        desc = "Toggle NvimTree (find file)",
      },
    },
    config = function(_, opts)
      require("snacks").setup(opts)
      vim.api.nvim_create_autocmd("BufEnter", {
        group = vim.api.nvim_create_augroup("SnacksExplorerRoot", { clear = true }),
        callback = function(args)
          local buf = args.buf
          local buftype = vim.bo[buf].buftype
          if vim.tbl_contains({ "terminal", "nofile", "quickfix", "prompt" }, buftype) then
            return
          end
          local file = vim.api.nvim_buf_get_name(buf)
          if file == "" or not vim.uv.fs_stat(file) then
            return
          end
          file = vim.uv.fs_realpath(file) or file

          local explorer = Snacks.picker.get({ source = "explorer" })[1]
          if not explorer then
            return
          end
          local root = LazyVim.root.get({ buf = buf })
          root = vim.uv.fs_realpath(root) or root

          vim.schedule(function()
            if explorer:cwd() ~= root then
              explorer:set_cwd(root)
            end
            require("snacks.explorer").reveal({ file = file })
          end)
        end,
      })

      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          if #vim.api.nvim_tabpage_list_wins(0) >= 2 then
            return
          end
          local buf = vim.api.nvim_get_current_buf()
          local file = vim.api.nvim_buf_get_name(buf)
          file = (file ~= "" and vim.uv.fs_realpath(file)) or file
          require("lazy").update({ show = false })
          if file ~= "" then
            vim.schedule(function()
              local picker = require("snacks.explorer").reveal({ file = file })
              if picker then
                picker.opts.enter = false
              end
            end)
          end
        end,
      })
    end,
  },
}

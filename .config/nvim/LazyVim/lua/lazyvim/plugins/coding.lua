return {

  {
    "nvim-mini/mini.ai",
    event = "VeryLazy",
    opts = function()
      local ai = require("mini.ai")
      local ts = ai.gen_spec.treesitter
      return {
        n_lines = 1500,
        silent = true,
        mappings = {
          around_next = "ah",
          inside_next = "ih",
          around_last = "a<leader>",
          inside_last = "i<leader>",
        },
        custom_textobjects = {
          u = ai.gen_spec.function_call(), -- u for "Usage"
          U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
          ["J"] = ts({ a = "@block.outer", i = "@block.inner" }), -- matches ]<Tab>/]x in goto
          ["j"] = ts({ a = "@comment.outer", i = "@comment.inner" }),
          ["y"] = ts({ a = "@parameter.outer", i = "@parameter.inner" }),
          ["Y"] = ts({ a = "@conditional.outer", i = "@conditional.inner" }),
          ["f"] = ts({ a = "@function.outer", i = "@function.inner" }),
          ["R"] = ts({ a = "@return.outer", i = "@return.inner" }),
          ["P"] = ts({ a = "@regex.outer", i = "@regex.inner" }),
          ["<Home>"] = ts({ a = "@class.outer", i = "@class.inner" }),
          ["<End>"] = ts({ a = "@call.outer", i = "@call.inner" }),
          ["<PageUp>"] = ts({ a = "@attribute.outer", i = "@attribute.inner" }),
          ["<PageDown>"] = ts({ a = "@loop.outer", i = "@loop.inner" }),
        },
      }
    end,
  },

  {
    "chrisgrieser/nvim-various-textobjs",
    event = "VeryLazy",
    config = function()
      require("various-textobjs").setup({
        keymaps = {
          useDefaults = true,
          disabledDefaults = { "i,", "a,", "r", "R", "L", "!", "|", "n", "Q", "C", "i_", "a_" },
        },
        forwardLooking = { small = 1500, big = 1500 },
        notify = { whenObjectNotFound = false },
      })
      vim.keymap.set({ "o", "x" }, "go", '<cmd>lua require("various-textobjs").column("down")<CR>')
      vim.keymap.set({ "o", "x" }, "gt", '<cmd>lua require("various-textobjs").column("up")<CR>')
      vim.keymap.set({ "o", "x" }, "gl", '<cmd>lua require("various-textobjs").column("both")<CR>')
      vim.keymap.set({ "o", "x" }, "iL", '<cmd>lua require("various-textobjs").lineCharacterwise("outer")<CR>')
      vim.keymap.set({ "o", "x" }, "il", '<cmd>lua require("various-textobjs").lineCharacterwise("inner")<CR>')
      vim.keymap.set({ "o", "x" }, "al", '<cmd>lua require("various-textobjs").entireBuffer()<CR>')
      vim.keymap.set({ "o", "x" }, "aO", '<cmd>lua require("various-textobjs").restOfIndentation()<CR>')
      vim.keymap.set({ "o", "x" }, "iO", '<cmd>lua require("various-textobjs").url()<CR>')

      vim.keymap.set("n", "du", function()
        -- select outer indentation
        require("various-textobjs").indentation("outer", "outer")

        -- plugin only switches to visual mode when a textobj has been found
        local indentationFound = vim.fn.mode():find("V")
        if not indentationFound then
          return
        end

        -- dedent indentation
        vim.cmd.normal({ "<", bang = true })

        -- delete surrounding lines
        local endBorderLn = vim.api.nvim_buf_get_mark(0, ">")[1]
        local startBorderLn = vim.api.nvim_buf_get_mark(0, "<")[1]
        vim.cmd(tostring(endBorderLn) .. " delete") -- delete end first so line index is not shifted
        vim.cmd(tostring(startBorderLn) .. " delete")
      end, { desc = "Delete Surrounding Indentation" })

      vim.keymap.set("n", "yu", function()
        local startPos = vim.api.nvim_win_get_cursor(0)

        -- identify start- and end-border
        require("various-textobjs").indentation("outer", "outer")
        local indentationFound = vim.fn.mode():find("V")
        if not indentationFound then
          return
        end
        vim.cmd.normal({ "V", bang = true }) -- leave visual mode so the '< '> marks are set

        -- copy them into the + register
        local startLn = vim.api.nvim_buf_get_mark(0, "<")[1] - 1
        local endLn = vim.api.nvim_buf_get_mark(0, ">")[1] - 1
        local startLine = vim.api.nvim_buf_get_lines(0, startLn, startLn + 1, false)[1]
        local endLine = vim.api.nvim_buf_get_lines(0, endLn, endLn + 1, false)[1]
        vim.fn.setreg("+", startLine .. "\n" .. endLine .. "\n")

        -- highlight yanked text
        local dur = 100
        local ns = vim.api.nvim_create_namespace("ysii")
        local bufnr = vim.api.nvim_get_current_buf()
        vim.hl.range(bufnr, ns, "IncSearch", { startLn, 0 }, { startLn, -1 }, { timeout = dur })
        vim.hl.range(bufnr, ns, "IncSearch", { endLn, 0 }, { endLn, -1 }, { timeout = dur })

        -- restore cursor position
        vim.api.nvim_win_set_cursor(0, startPos)
      end, { desc = "Yank surrounding indentation" })
    end,
  },
}

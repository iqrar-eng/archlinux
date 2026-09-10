local state_file = vim.fn.stdpath("state") .. "/aerial_auto"
local aerial_state = { auto = vim.fn.filereadable(state_file) == 0 or vim.fn.readfile(state_file)[1] == "1" }
local function save()
  vim.fn.writefile({ aerial_state.auto and "1" or "0" }, state_file)
end

return {
  {
    "stevearc/aerial.nvim",
    event = "LazyFile",
    opts = function()
      local icons = vim.deepcopy(LazyVim.config.icons.kinds)
      for kind, icon in pairs(vim.deepcopy(icons)) do
        if type(icon) == "string" then
          icons[kind] = icon:gsub("%s+$", "")
          if kind ~= "Collapsed" and not kind:match("Collapsed$") then
            icons[kind .. "Collapsed"] = "▍"
          end
        end
      end

      local opts = {
        backends = { "treesitter", "markdown", "lsp", "asciidoc", "man" },
        link_tree_to_folds = false,
        attach_mode = "global",
        icons = icons,
        show_guides = true,
        highlight_on_hover = true,
        open_automatic = function()
          return aerial_state.auto
        end,
        autojump = false,
        layout = {
          width = 28,
          placement = "edge",
          default_direction = "right",
          resize_to_content = false,
        },
        guides = {
          mid_item = "├",
          last_item = "└",
          nested_top = "│",
          whitespace = " ",
        },
        keymaps = {
          ["<C-Home>"] = function()
            vim.cmd("normal! gg")
            require("aerial").select({ jump = false })
          end,
          ["<C-End>"] = function()
            vim.cmd("normal! G")
            require("aerial").select({ jump = false })
          end,

          ["<PageUp>"] = function()
            local key = vim.api.nvim_replace_termcodes("<C-U>zz", true, false, true)
            vim.api.nvim_feedkeys(key, "n", false)
            require("aerial").select({ jump = false })
          end,
          ["<PageDown>"] = function()
            local key = vim.api.nvim_replace_termcodes("<C-D>zz", true, false, true)
            vim.api.nvim_feedkeys(key, "n", false)
            require("aerial").select({ jump = false })
          end,

          ["j"] = function()
            local count = math.max(vim.v.count, 1)
            if count == 1 then
              require("aerial.actions").down_and_scroll.callback()
            else
              vim.cmd("normal! m'" .. count .. "gj")
              require("aerial").select({ jump = false })
            end
          end,
          ["k"] = function()
            local count = math.max(vim.v.count, 1)
            if count == 1 then
              require("aerial.actions").up_and_scroll.callback()
            else
              vim.cmd("normal! m'" .. count .. "gk")
              require("aerial").select({ jump = false })
            end
          end,

          ["s"] = "actions.tree_decrease_fold_level",
          ["d"] = "actions.tree_increase_fold_level",
          ["c"] = "actions.tree_close_all",
          ["r"] = "actions.tree_open_all",
          ["i"] = "actions.prev_up",
          ["o"] = "actions.next_up",
          ["?"] = false,
        },
        filter_kind = LazyVim.config.kind_filter.default,
      }
      return opts
    end,
    keys = {
      {
        "<leader>ao",
        function()
          aerial_state.auto = not aerial_state.auto
          save()
          if aerial_state.auto then
            require("aerial").open({ focus = false })
          else
            require("aerial").close()
          end
          vim.notify("Aerial auto-open: " .. tostring(aerial_state.auto))
        end,
        desc = "Toggle Aerial auto-open",
      },
    },
    config = function(_, opts)
      require("aerial").setup(vim.tbl_deep_extend("force", opts, {
        get_highlight = function(symbol, is_icon, is_collapsed)
          local level = (symbol.level or 0) % 12 + 1
          return "AerialIndent" .. level
        end,
      }))
    end,
  },
}

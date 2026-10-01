return {
	{
		"jake-stewart/multicursor.nvim",
		branch = "1.0",
		event = "VeryLazy",
    -- stylua: ignore
    config = function()
      local mc = require("multicursor-nvim")
      mc.setup()

      -- global/multicursor-mode mappings
      vim.keymap.set({ "n", "x" }, "<C-S-H>", function() mc.lineAddCursor(-1) end, { desc = "MC: cursor above" })
      vim.keymap.set({ "n", "x" }, "<C-S-L>", function() mc.lineAddCursor(1) end, { desc = "MC: cursor below" })
      vim.keymap.set({ "n", "x" }, "<C-S-J>", function() mc.matchAddCursor(1) end, { desc = "MC: match forward" })
      vim.keymap.set({ "n", "x" }, "<C-S-K>", function() mc.matchAddCursor(-1) end, { desc = "MC: match backward" })
      vim.keymap.set({ "n", "x" }, "<M-H>", function() mc.lineSkipCursor(-1) end, { desc = "MC: skip above" })
      vim.keymap.set({ "n", "x" }, "<M-L>", function() mc.lineSkipCursor(1) end, { desc = "MC: skip below" })
      vim.keymap.set({ "n", "x" }, "<M-J>", function() mc.matchSkipCursor(1) end, { desc = "MC: skip fwd" })
      vim.keymap.set({ "n", "x" }, "<M-K>", function() mc.matchSkipCursor(-1) end, { desc = "MC: skip back" })

      vim.keymap.set({ "n", "x" }, "<leader>aa", mc.matchAllAddCursors, { desc = "MC: all matches" })

      vim.keymap.set({ "n", "x" }, "<C-N>", function() mc.searchAddCursor(1) end, { desc = "MC: cursor next search" })
      vim.keymap.set({ "n", "x" }, "<C-P>", function() mc.searchAddCursor(-1) end, { desc = "MC: cursor prev search" })
      vim.keymap.set({ "n", "x" }, "<C-S-N>", function() mc.searchSkipCursor(1) end, { desc = "MC: next search" })
      vim.keymap.set({ "n", "x" }, "<C-S-P>", function() mc.searchSkipCursor(-1) end, { desc = "MC: prev search" })
      vim.keymap.set("n", "<leader>a/", mc.searchAllAddCursors, { desc = "MC: all search results" })

      vim.keymap.set({ "n", "x" }, "<leader>[", mc.addCursorOperator, { desc = "MC: cursor per line" })
      vim.keymap.set({ "n", "x" }, "<leader>]", mc.operator, { desc = "MC: cursor per match" })

      vim.keymap.set({ "n","x" }, "g<leader>", mc.toggleCursor, { desc = "MC: toggle cursor" })
      vim.keymap.set("n", "<leader>ar", mc.restoreCursors, { desc = "MC: restore cursors" })
      vim.keymap.set("x", "<leader>ar", mc.matchCursors, { desc = "MC: match in selection" })
      vim.keymap.set("x", "<leader>al", mc.splitCursors, { desc = "MC: split by regex" })

      -- buffer/multicursor-mode mappings
      mc.addKeymapLayer(function(layerSet)
        layerSet("n", "<leader>al", mc.alignCursors, { desc = "MC: align columns" })

        layerSet({"x", "n"}, "g<C-A>", mc.sequenceIncrement)
        layerSet({"x", "n"}, "g<C-X>", mc.sequenceDecrement)

        layerSet("x", "<M-2>", function() mc.transposeCursors(1) end, { desc = "MC: transpose forward", buffer = true })
        layerSet("x", "<M-1>", function() mc.transposeCursors(-1) end, { desc = "MC: transpose backward", buffer = true })
        layerSet("x", "<M-5>", function() mc.swapCursors(1) end, { desc = "MC: swap forward", buffer = true })
        layerSet("x", "<M-4>", function() mc.swapCursors(-1) end, { desc = "MC: swap backward", buffer = true })

        layerSet({ "n", "x" }, "<C-O>", mc.jumpBackward, { desc = "MC: jump back", buffer = true })
        layerSet({ "n", "x" }, "<C-I>", mc.jumpForward, { desc = "MC: jump fwd", buffer = true })

        layerSet({ "n", "x" }, "<C-K>", function() for _ = 1, vim.v.count1 do mc.prevCursor() end end, { desc = "MC: prev cursor", buffer = true })
        layerSet({ "n", "x" }, "<C-J>", function() for _ = 1, vim.v.count1 do mc.nextCursor() end end, { desc = "MC: next cursor", buffer = true })
        layerSet({ "n", "x" }, "<C-H>", mc.firstCursor, { desc = "MC: first cursor", buffer = true })
        layerSet({ "n", "x" }, "<C-L>", mc.lastCursor, { desc = "MC: last cursor", buffer = true })

        layerSet({ "n","x" }, "g<Del>", mc.enableCursors, { desc = "MC: toggle cursor" })
        layerSet({ "n", "x" }, "<M-6>", mc.duplicateCursors, { desc = "MC: duplicate cursors", buffer = true })
        layerSet({ "n", "x" }, "<M-3>", function() for _ = 1, vim.v.count1 do mc.deleteCursor() end end, { desc = "MC: delete cursor", buffer = true })
        layerSet("n", "<Esc>", function()
          if not mc.cursorsEnabled() then
            mc.enableCursors()
          else
            mc.clearCursors()
          end
        end, { desc = "MC: enable/clear cursors", buffer = true })
      end)
    end,
	},
}

return {
  -- {
  --     "nvim-tree/nvim-tree.lua",
  --     version = "*",
  --     dependencies = {"nvim-tree/nvim-web-devicons"},
  --     config = function()
  --         require("nvim-tree").setup()
  --     end
  -- }
  -- 目录
  {
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        vim.keymap.set({ "n", "v" }, "<leader>e", [[<cmd>Neotree toggle<CR>]]),
        mappings = {
          ["<"] = "prev_source",
          [">"] = "next_source",
          ["i"] = "show_file_details",
        },
        source_selector = {
          winbar = true,
          statusline = false,
        },
        sources = {
          "filesystem",
          "buffers",
          "git_status",
          "document_symbols",
        },
      })
    end,
  },
}

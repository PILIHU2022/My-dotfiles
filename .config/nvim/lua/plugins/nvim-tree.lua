-- neo-tree 文件浏览器
return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        source_selector = {
          winbar = true,
          statusline = false,
        },
        sources = { "filesystem", "buffers", "git_status", "document_symbols" },
      })

      -- 快捷键映射
      vim.keymap.set({ "n", "v" }, "<leader>e", "<cmd>Neotree toggle<CR>", { desc = "Toggle Neo-tree" })
    end,
  },
}

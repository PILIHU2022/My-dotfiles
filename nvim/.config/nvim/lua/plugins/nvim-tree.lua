-- neo-tree 文件浏览器
return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    -- 执行 :Neotree 命令或按下 <leader>e 时才加载
    cmd = "Neotree",
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<CR>", desc = "Toggle Neo-tree", mode = { "n", "v" } },
    },
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
    end,
  },
}

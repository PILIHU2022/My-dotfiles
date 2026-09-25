-- Neogit Git 图形界面（替代 lazygit.nvim）
return {
  "NeogitOrg/neogit",
  -- Neogit 运行必需 plenary.nvim
  dependencies = { "nvim-lua/plenary.nvim" },
  -- 执行命令或按下快捷键时才加载
  cmd = "Neogit",
  keys = {
    { "<leader>lg", "<cmd>Neogit<cr>", desc = "Neogit" },
  },
  opts = {},
}

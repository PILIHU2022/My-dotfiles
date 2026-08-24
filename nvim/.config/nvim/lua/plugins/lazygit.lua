-- lazygit.nvim Git 图形界面
return {
  "kdheepak/lazygit.nvim",
  -- 执行命令或按下快捷键时才加载
  -- telescope/plenary 均为可选依赖（插件内部 pcall 探测），无需强制提前加载
  cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile", "LazyGitFilter", "LazyGitFilterRef" },
  keys = {
    { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
  },
}

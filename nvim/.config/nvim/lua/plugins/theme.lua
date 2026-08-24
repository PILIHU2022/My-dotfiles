-- 主题配置 (多主题备选，实际使用 catppuccin)
-- 全部懒加载：lazy.nvim 通过 ColorSchemePre 钩子，在执行 `:colorscheme <名称>` 时自动加载对应主题
return {
  { "folke/tokyonight.nvim", lazy = true },
  { "sainnhe/gruvbox-material", lazy = true },
  {
    "projekt0n/github-nvim-theme",
    name = "github-theme",
    lazy = true,
  },
}

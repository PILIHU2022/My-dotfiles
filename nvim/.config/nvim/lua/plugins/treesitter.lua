-- treesitter.lua - 修复版
return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  -- 移除 main 字段，让 Lazy 自动处理
  -- main = "nvim-treesitter.configs",  -- ← 删除这行
  opts = {
    ensure_installed = { "c", "lua", "python", "markdown", "markdown_inline" },
    auto_install = true,
    highlight = { enable = true },
    indent = { enable = true },
    rainbow = {
      enable = true,
      extended_mode = true,
      max_file_lines = 1000,
      -- Catppuccin Mocha 配色，便于区分嵌套层级
      colors = {
        "#f38ba8",
        "#f9e2af",
        "#a6e3a1",
        "#89b4fa",
        "#cba6f7",
        "#fab387",
        "#89dceb",
        "#f5c2e7",
        "#94e2d5",
        "#74c7ec",
      },
    },
    ignore_install_checks = true,
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
        },
      },
    },
  },
}

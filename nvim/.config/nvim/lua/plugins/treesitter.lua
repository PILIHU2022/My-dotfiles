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

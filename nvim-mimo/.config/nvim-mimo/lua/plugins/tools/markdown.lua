-- Markdown 工具插件
return {
  -- Markdown 预览
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && yarn install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
  },

  -- Markdown 表格模式
  {
    "Kicamon/markdown-table-mode.nvim",
    config = function()
      require("markdown-table-mode").setup({
        filetype = { "*.md" },
        options = {
          insert = true,
          insert_leave = true,
          alig_style = "center",
        },
      })
    end,
  },
}

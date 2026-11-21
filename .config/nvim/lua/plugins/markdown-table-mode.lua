-- Markdown 表格模式
return {
  "Kicamon/markdown-table-mode.nvim",
  config = function()
    require("markdown-table-mode").setup({
      filetype = { "*.md" },
      options = {
        insert = true,        -- 输入 "|" 时触发
        insert_leave = true,  -- 离开插入模式时触发
        alig_style = "center", -- 对齐方式: default, left, center, right
      },
    })
  end,
}

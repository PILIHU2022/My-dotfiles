-- 安装和配置conform
return {
  {
    "stevearc/conform.nvim", -- 安装插件
    config = function()
      -- 配置conform，使用black格式化Python
      require("conform").setup({
        formatters_by_ft = {
          c = { "clang-format" },
          markdown = { "mdformat" },
          lua = { "stylua" },
          yaml = { "yamlfmt" },
          python = function(bufnr)
            if require("conform").get_formatter_info("ruff_format", bufnr).available then
              return { "ruff_format" }
            else
              return { "black" }
            end
          end,
        },
        formatters = {
          stylua = {
            "column_width" == 100,
            "line_endings" == "Unix",
            "indent_type" == "Spaces",
            "indent_width" == 2,
            "quote_style" == "AutoPreferDouble",
            "call_parentheses" == "Always",
          },
          ruff_format = {},
          black = {
            args = { "--line-length=80" },
          },
          ["clang-format"] = {
            args = { "--style=Google" },
          },
        },
      })

      -- 自动格式化配置
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = { "*.py", "*.c" },
        callback = function(args)
          require("conform").format({ bufnr = args.buf })
        end,
      })
    end,
  },
}

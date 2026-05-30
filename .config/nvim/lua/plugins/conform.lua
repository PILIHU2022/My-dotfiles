-- conform.nvim 代码格式化配置
return {
  {
    "stevearc/conform.nvim",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          c = { "clang-format" },
          -- markdown = { "mdformat" },
          markdown = { "prettier" },
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
          stylua = {}, -- 默认配置即可，具体规则使用 stylua.toml
          ruff_format = {},
          black = { args = { "--line-length=80" } },
          ["clang-format"] = { args = { "--style=Google" } },
          -- prettier = { args = { "--prose-wrap always --print-width 80" } },
        },
      })

      -- 保存时自动格式化
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = { "*.py", "*.c", "*.md", "*.lua" },
        callback = function(args)
          require("conform").format({ bufnr = args.buf })
        end,
      })
    end,
  },
}

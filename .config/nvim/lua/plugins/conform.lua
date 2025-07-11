-- 安装和配置conform
return {
  {
    "stevearc/conform.nvim", -- 安装插件
    config = function()
      -- 配置conform，使用black格式化Python
      require("conform").setup({
        formatters_by_ft = {
          markdown = { "mdformat" },
          lua = { "stylua" },
          yaml = { "yamlfmt" },
          python = function(bufnr)
            if require("conform").get_formatter_info("ruff_format", bufnr).available then
              return { "ruff_format" }
            else
              return { "isort", "black" }
            end
          end,
        },
      })

      -- 自动格式化配置
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.py",
        callback = function(args)
          require("conform").format({ bufnr = args.buf })
        end,
      })
    end,
  },
}

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
          stylua = {},
          ruff_format = {},
          ruff_fix = {},
          ruff_organize_imports = {},
          black = { args = { "--line-length=80" } },
          ["clang-format"] = { args = { "--style=Google" } },
        },
      })

      -- 保存时自动格式化（异步，避免退出卡顿）
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = { "*.py", "*.c", "*.md", "*.lua" },
        callback = function(args)
          require("conform").format({ bufnr = args.buf, async = true })
        end,
      })

      -- 手动触发 lint 修复和导入排序
      vim.keymap.set("n", "<leader>ci", function()
        require("conform").format({
          async = true,
          formatters = { "ruff_fix", "ruff_organize_imports" },
        })
      end, { desc = "Fix lint & organize imports" })
    end,
  },
}

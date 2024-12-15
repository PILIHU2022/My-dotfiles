-- 安装和配置conform
return {
    {
        "stevearc/conform.nvim", -- 安装插件
        config = function()
            -- 配置conform，使用black格式化Python
            require("conform").setup({
                formatters_by_ft = {
                    python = { "black", "ruff_fix", "ruff_format", "ruff_organize_imports" },
                    lua = { "stylua" },
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

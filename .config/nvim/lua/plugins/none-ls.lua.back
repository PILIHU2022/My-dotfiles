return {
    {
        "nvimtools/none-ls.nvim",  -- 安装none-ls.nvim插件
        dependencies = { "nvim-lua/plenary.nvim" },  -- 依赖plenary.nvim
        config = function()
            local none_ls = require("null-ls")

            -- 配置none-ls，集成黑色和isort
            none_ls.setup({
                sources = {
                    none_ls.builtins.formatting.black,  -- 使用black进行格式化
                    -- none_ls.builtins.formatting.isort,   -- 使用isort排序导入
                },
            })

            -- 自动格式化配置
            vim.cmd [[
                augroup LspFormatting
                    autocmd! * <buffer>
                    autocmd BufWritePre *.py lua vim.lsp.buf.format()
                augroup END
            ]]
        end,
    }
}


return {
    -- Tab栏
    {
        "akinsho/bufferline.nvim",
        event = 'VeryLazy',
        config = true,
    },
    -- 缩进辅助线
    { "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        opts = {}
    },
    -- Git状态
    {
        "lewis6991/gitsigns.nvim",
        config = true,
    },
    -- 开始页面
    {
        "goolord/alpha-nvim",
        config = function()
            require 'alpha'.setup(require 'alpha.themes.dashboard'.config)
        end
    },
    -- Neovim plugin for automatically highlighting other uses of the word under the cursor using either LSP, Tree-sitter, or regex matching.
    {
        "RRethy/vim-illuminate",
        config = function()
            require('illuminate').configure()
        end
    },
    -- 彩色括号，方便辨识
    {
        'HiPhish/rainbow-delimiters.nvim',
        lazy = true,
        event = 'BufRead',
        config = function()
            local rainbow_delimiters = require('rainbow-delimiters')
            vim.g.rainbow_delimiters = {
                strategy = {
                    [''] = rainbow_delimiters.strategy['global'],
                    vim = rainbow_delimiters.strategy['local'],
                },
                query = {
                    [''] = 'rainbow-delimiters',
                    lua = 'rainbow-blocks',
                },
                highlight = {
                    'RainbowDelimiterBlue',
                    'RainbowDelimiterYellow',
                    'RainbowDelimiterCyan',
                    'RainbowDelimiterViolet',
                    'RainbowDelimiterRed',
                    'RainbowDelimiterOrange',
                    'RainbowDelimiterGreen',
                },
            }
        end
    },
}

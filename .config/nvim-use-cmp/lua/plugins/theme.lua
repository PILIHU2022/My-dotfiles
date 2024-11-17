return {
    -- {
    --     "folke/tokyonight.nvim",
    --     config = function()
    --         vim.cmd [[colorscheme tokyonight-storm]]
    --     end
    -- },
    -- {
    --     "sainnhe/gruvbox-material",
    --     config = function ()
    --         vim.cmd.colorscheme('gruvbox-material')
    --     end
    -- }
    {
        'projekt0n/github-nvim-theme',
        name = 'github-theme',
        lazy = false, -- make sure we load this during startup if it is your main colorscheme
        priority = 1000, -- make sure to load this before all the other start plugins
        config = function()
            require('github-theme').setup({})
            vim.cmd('colorscheme github_dark_dimmed')
        end,
    }
}

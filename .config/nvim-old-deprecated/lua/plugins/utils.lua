return {
    {
        "rhysd/accelerated-jk",
        config = function()
            vim.keymap.set("n", "j", "<Plug>(accelerated_jk_gj)")
            vim.keymap.set("n", "k", "<Plug>(accelerated_jk_gk)")
        end,
    },
    {
        "folke/persistence.nvim",
        config = function()
            require("persistence").setup()
            vim.keymap.set("n","<leader>qs", [[<cmd>lua require("persistence").load()<cr>]])
            vim.keymap.set("n","<leader>ql", [[<cmd>lua require("persistence").load({ last = true})<cr>]])
            vim.keymap.set("n","<leader>qd", [[<cmd>lua require("persistence").stop()<cr>]])
        end
    },
    {
        "ethanholz/nvim-lastplace",
        config = true,
    },
    -- {
    --     "folke/flash.nvim",
    --     config = function()
    --         require("flash").setup()
    --         vim.keymap.set({"n","x","o"},"s",
    --             function()
    --                 require("flash").jump({
    --                     search = {
    --                         mode = function(str)
    --                             return "\\<" .. str
    --                         end,
    --                     },
    --                 })
    --             end
    --         )
    --         vim.keymap.set({"n","x","o"},"S",
    --             function()
    --                 require("flash").treesitter()
    --             end
    --         )
    --         vim.keymap.set({"o"},"r",
    --             function()
    --                 require("flash").remote()
    --             end
    --         )
    --         vim.keymap.set({"o","x"},"R",
    --             function()
    --                 require("flash").treesitter_search()
    --             end
    --         )
    --     end,
    -- },
    {
        "echasnovski/mini.nvim",
        version = false,
        config = function ()
            -- Commit
            require('mini.comment').setup()
            mappings = {
                comment = 'gc',
                comment_line = 'gcc',
                comment_visual = 'gc',
            },

            -- Auto pair
            require('mini.pairs').setup()
            mappings = {
                ['('] = { action = 'open', pair = '()', neigh_pattern = '[^\\].' },
                ['（'] = { action = 'open', pair = '()', neigh_pattern = '[^\\].' },
                ['['] = { action = 'open', pair = '[]', neigh_pattern = '[^\\].' },
                ['{'] = { action = 'open', pair = '{}', neigh_pattern = '[^\\].' },
                [')'] = { action = 'close', pair = '()', neigh_pattern = '[^\\].' },
                ['）'] = { action = 'close', pair = '()', neigh_pattern = '[^\\].' },
                [']'] = { action = 'close', pair = '[]', neigh_pattern = '[^\\].' },
                ['}'] = { action = 'close', pair = '{}', neigh_pattern = '[^\\].' },
                ['"'] = { action = 'closeopen', pair = '""', neigh_pattern = '[^\\].', register = { cr = false } },
                ['“'] = { action = 'closeopen', pair = '“”', neigh_pattern = '[^\\].', register = { cr = false } },
                ["‘"] = { action = 'closeopen', pair = "‘’", neigh_pattern = '[^%a\\].', register = { cr = false } },
                ['`'] = { action = 'closeopen', pair = '``', neigh_pattern = '[^\\].', register = { cr = false } },
            },

            -- Add pair
            require('mini.surround').setup()
            mappings = {
                add = 'sa',
                delete = 'sd',
                find = 'sf',
                find_left = 'sF',
                highlight = 'sh',
                replace = 'sr',
                update_n_lines = 'sn',
            }
        end
    },
    {
        "kamykn/spelunker.vim",
        config = function()
            vim.g.spelunker_check_type = 2
        end
    },
    {
        "ellisonleao/glow.nvim",
        config = true,
    },
    {
        "nvim-neo-tree/neo-tree.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
            "MunifTanjim/nui.nvim",
        },
        config = function()
            require("neo-tree").setup()
            vim.keymap.set({"n", "v"},"<leader>e",[[<cmd>Neotree toggle<CR>]])
        end
    },
    {
        "folke/which-key.nvim",
        config = true,
    },
    {
        "s1n7ax/nvim-window-picker",
        config = function()
            require("window-picker").setup({
                filter_rules = {
                    include_current_win = true,
                    bo = {
                        filetype = { "fidget", "neo-tree" }
                    }
                }
            })
            vim.keymap.set("n",
                "<c-w>p",
                function()
                    local window_number = require('window-picker').pick_window()
                    if window_number then vim.api.nvim_set_current_win(window_number) end
                end
            )
        end
    },
}

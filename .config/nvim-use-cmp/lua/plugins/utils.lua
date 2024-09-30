return {
    -- 加速上下移动速度
    {
        "rhysd/accelerated-jk",
        config = function()
            vim.keymap.set("n", "j", "<Plug>(accelerated_jk_gj)")
            vim.keymap.set("n", "k", "<Plug>(accelerated_jk_gk)")
        end,
    },
    -- 自动会话管理
    {
        "folke/persistence.nvim",
        config = function()
            require("persistence").setup()
            vim.keymap.set("n", "<leader>qs", [[<cmd>lua require("persistence").load()<cr>]])
            vim.keymap.set("n", "<leader>ql", [[<cmd>lua require("persistence").load({ last = true})<cr>]])
            vim.keymap.set("n", "<leader>qd", [[<cmd>lua require("persistence").stop()<cr>]])
        end
    },
    -- 让光标在上次编辑的位置
    {
        "ethanholz/nvim-lastplace",
        config = true,
    },
    -- 多功能的工具
    {
        "echasnovski/mini.nvim",
        version = false,
        config = function()
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
                    ['['] = { action = 'open', pair = '[]', neigh_pattern = '[^\\].' },
                    ['{'] = { action = 'open', pair = '{}', neigh_pattern = '[^\\].' },
                    [')'] = { action = 'close', pair = '()', neigh_pattern = '[^\\].' },
                    ['"'] = { action = 'closeopen', pair = '""', neigh_pattern = '[^\\].', register = { cr = false } },
                    -- ['（'] = { action = 'open', pair = '（）', neigh_pattern = '[^\\].' },
                    -- ['）'] = { action = 'close', pair = '（）', neigh_pattern = '[^\\].' },
                    -- ['“'] = { action = 'closeopen', pair = '“”', neigh_pattern = '[^\\].', register = { cr = false } },
                    -- ["‘"] = { action = 'closeopen', pair = "‘’", neigh_pattern = '[^%a\\].', register = { cr = false } },
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
    -- 拼写检查
    {
        "kamykn/spelunker.vim",
        config = function()
            vim.g.spelunker_check_type = 2
        end
    },
    -- 按键显示
    {
        "folke/which-key.nvim",
        config = true,
    },
    -- 暂时无用
    -- {
    --     "s1n7ax/nvim-window-picker",
    --     config = function()
    --         require("window-picker").setup({
    --             filter_rules = {
    --                 include_current_win = true,
    --                 bo = {
    --                     filetype = { "fidget", "neo-tree" }
    --                 }
    --             }
    --         })
    --         vim.keymap.set("n",
    --             "<c-w>p",
    --             function()
    --                 local window_number = require('window-picker').pick_window()
    --                 if window_number then vim.api.nvim_set_current_win(window_number) end
    --             end
    --         )
    --     end
    -- },
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
    -- 预览Markdown
    -- {
    --     "ellisonleao/glow.nvim",
    --     config = true,
    -- },
}

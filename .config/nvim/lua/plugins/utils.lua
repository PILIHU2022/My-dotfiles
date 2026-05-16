-- 实用工具插件配置
return {
  -- ESC 快捷键优化
  {
    "max397574/better-escape.nvim",
    config = function()
      require("better_escape").setup({
        timeout = vim.o.timeoutlen,
        default_mappings = true,
      })
    end,
  },

  -- 加速上下移动
  {
    "rhysd/accelerated-jk",
    config = function()
      vim.keymap.set("n", "j", "<Plug>(accelerated_jk_gj)")
      vim.keymap.set("n", "k", "<Plug>(accelerated_jk_gk)")
    end,
  },

  -- 会话管理
  {
    "folke/persistence.nvim",
    config = function()
      require("persistence").setup()
      vim.keymap.set("n", "<leader>qs", "<cmd>lua require('persistence').load()<cr>", { desc = "Load session" })
      vim.keymap.set("n", "<leader>ql", "<cmd>lua require('persistence').load({ last = true})<cr>", { desc = "Load last session" })
      vim.keymap.set("n", "<leader>qd", "<cmd>lua require('persistence').stop()<cr>", { desc = "Stop session" })
    end,
  },

  -- 上次编辑位置
  { "ethanholz/nvim-lastplace", config = true },

  -- mini.nvim 工具集
  {
    "echasnovski/mini.nvim",
    version = false,
    config = function()
      require("mini.comment").setup()   -- 注释
      require("mini.pairs").setup()     -- 括号自动配对
      require("mini.surround").setup({  -- 环绕操作
        mappings = {
          add = "sa", delete = "sd", find = "sf", find_left = "sF",
          highlight = "sh", replace = "sr", update_n_lines = "sn",
        },
      })
    end,
  },

  -- 拼写检查
  { "kamykn/spelunker.vim", config = function() vim.g.spelunker_check_type = 2 end },

  -- 快捷键提示
  { "folke/which-key.nvim", config = true },
}

-- UI 增强插件配置
return {
  -- 标签栏
  { "akinsho/bufferline.nvim", event = "VeryLazy", config = true },

  -- 缩进辅助线
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },

  -- Git 状态标记
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "┃" },
          change = { text = "┃" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
          untracked = { text = "┆" },
        },
        signs_staged_enable = true,
        signcolumn = true,
        numhl = false,
        linehl = false,
        word_diff = false,
      })
    end,
  },

  -- 启动页
  {
    "goolord/alpha-nvim",
    config = function()
      require("alpha").setup(require("alpha.themes.dashboard").config)
    end,
  },

  -- 高亮光标下相同单词
  { "RRethy/vim-illuminate", config = function() require("illuminate").configure() end },
}

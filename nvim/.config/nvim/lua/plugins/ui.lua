-- UI 增强插件配置
return {
  -- 标签栏（条件懒加载：打开第二个文件 buffer 时才加载并显示）
  {
    "akinsho/bufferline.nvim",
    lazy = true,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<A-[>", "<cmd>BufferLineCyclePrev<CR>", desc = "Previous buffer" },
      { "<A-]>", "<cmd>BufferLineCycleNext<CR>", desc = "Next buffer" },
      { "<A-q>", "<cmd>BufferLineClose<CR>", desc = "Close buffer" },
    },
    init = function()
      -- 监听 BufAdd：当已打开的文件 buffer 数 >= 2 时才加载 bufferline（单文件时保持隐藏）
      local group =
        vim.api.nvim_create_augroup("UserLazyBufferline", { clear = true })
      vim.api.nvim_create_autocmd("BufAdd", {
        group = group,
        callback = function()
          local count = 0
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if
              vim.api.nvim_buf_is_valid(buf)
              and vim.api.nvim_buf_get_option(buf, "buflisted")
              and vim.api.nvim_buf_get_name(buf) ~= ""
            then
              count = count + 1
            end
          end
          if count >= 2 then
            require("lazy").load({ plugins = { "bufferline.nvim" } })
          end
        end,
      })
    end,
    config = function()
      -- 标签栏始终显示（nvim 默认 showtabline=1 时单标签页不显示标签栏）
      vim.o.showtabline = 2
      require("bufferline").setup({})
    end,
  },

  -- blink.pairs：自动配对括号，并启用彩虹括号高亮
  -- 颜色按括号嵌套层级循环，便于快速辨认多重括号层级
  {
    "saghen/blink.pairs",
    version = "*",
    event = { "InsertEnter", "BufReadPost" },
    dependencies = { "saghen/blink.lib" },
    build = function()
      require("blink.pairs").build():pwait(60000)
    end,
    config = function()
      -- 兜底：若 lazy.nvim 尚未执行 build，也在这里确保 native library 可用
      -- 使用 build() 从源码构建，不依赖当前 checkout 必须处于 release tag
      require("blink.pairs").build():pwait(60000)

      -- 定义彩虹高亮组颜色（Catppuccin Mocha 风格）
      local colors = {
        BlinkPairsRed = "#f38ba8",
        BlinkPairsYellow = "#f9e2af",
        BlinkPairsGreen = "#a6e3a1",
        BlinkPairsBlue = "#89b4fa",
        BlinkPairsPurple = "#cba6f7",
        BlinkPairsOrange = "#fab387",
        BlinkPairsCyan = "#89dceb",
        BlinkPairsPink = "#f5c2e7",
        BlinkPairsTeal = "#94e2d5",
        BlinkPairsSapphire = "#74c7ec",
      }
      for group, color in pairs(colors) do
        vim.api.nvim_set_hl(0, group, { fg = color })
      end
      vim.api.nvim_set_hl(0, "BlinkPairsUnmatched", { fg = "#f38ba8", undercurl = true })
      vim.api.nvim_set_hl(0, "BlinkPairsMatchParen", { fg = "#89b4fa", bold = true })

      require("blink.pairs").setup({
        highlights = {
          enabled = true,
          cmdline = true,
          -- 彩虹括号通过 groups 指定高亮组，颜色在下方 nvim_set_hl 中定义
          groups = {
            "BlinkPairsOrange",
            "BlinkPairsPurple",
            "BlinkPairsBlue",
            "BlinkPairsRed",
            "BlinkPairsYellow",
            "BlinkPairsGreen",
            "BlinkPairsCyan",
            "BlinkPairsPink",
            "BlinkPairsTeal",
            "BlinkPairsSapphire",
          },
          unmatched_group = "BlinkPairsUnmatched",

          -- 高亮光标下的配对括号
          matchparen = {
            enabled = true,
            cmdline = false,
            include_surrounding = false,
            group = "BlinkPairsMatchParen",
            priority = 250,
          },
        },
      })
    end,
  },

  -- 缩进辅助线
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },

  -- Git 状态标记
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
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
    event = "VimEnter",
    config = function()
      require("alpha").setup(require("alpha.themes.dashboard").config)
    end,
  },

  -- 高亮光标下相同单词
  {
    "RRethy/vim-illuminate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("illuminate").configure()
    end,
  },
}

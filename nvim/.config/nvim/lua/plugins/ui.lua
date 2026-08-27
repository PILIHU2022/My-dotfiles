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

  -- 彩虹括号
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local highlight = {
        "RainbowDelimiterRed",
        "RainbowDelimiterYellow",
        "RainbowDelimiterBlue",
        "RainbowDelimiterOrange",
        "RainbowDelimiterGreen",
        "RainbowDelimiterViolet",
        "RainbowDelimiterCyan",
        "RainbowDelimiterPink",
        "RainbowDelimiterTeal",
        "RainbowDelimiterSapphire",
      }

      -- Catppuccin Mocha 配色，便于区分嵌套层级
      local colors = {
        RainbowDelimiterRed = "#f38ba8",
        RainbowDelimiterYellow = "#f9e2af",
        RainbowDelimiterBlue = "#89b4fa",
        RainbowDelimiterOrange = "#fab387",
        RainbowDelimiterGreen = "#a6e3a1",
        RainbowDelimiterViolet = "#cba6f7",
        RainbowDelimiterCyan = "#89dceb",
        RainbowDelimiterPink = "#f5c2e7",
        RainbowDelimiterTeal = "#94e2d5",
        RainbowDelimiterSapphire = "#74c7ec",
      }

      for group, color in pairs(colors) do
        vim.api.nvim_set_hl(0, group, { fg = color })
      end

      require("rainbow-delimiters.setup").setup({
        highlight = highlight,
        query = {
          c = "rainbow-delimiters",
          lua = "rainbow-delimiters",
          python = "rainbow-delimiters",
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

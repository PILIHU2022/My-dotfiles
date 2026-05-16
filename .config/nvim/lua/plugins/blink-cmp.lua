-- blink.cmp 补全引擎配置
return {
  "saghen/blink.cmp",
  version = "1.*",
  dependencies = {
    "rafamadriz/friendly-snippets",  -- 代码片段
    "L3MON4D3/LuaSnip",              -- 片段引擎
    "echasnovski/mini.icons",        -- 图标
  },
  opts = {
    -- 快捷键配置 (无预设，完全自定义)
    keymap = {
      preset = "none",
      ["<CR>"] = { "accept", "fallback" },           -- 回车接受当前选中
      ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },   -- Tab 选择下一项/片段前进
      ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" }, -- Shift-Tab 选择上一项/片段后退
    },

    -- 普通模式补全配置
    completion = {
      keyword = { range = "full" },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 0,
        window = { border = "rounded" },
      },
      list = {
        selection = {
          preselect = false,     -- 不预选任何项目
          auto_insert = false,   -- 选中后不自动插入
        },
      },
      menu = {
        min_width = 15,
        max_height = 10,
        border = "rounded",
      },
      ghost_text = { enabled = true },  -- 幽灵文本提示
    },

    -- 命令行模式补全配置
    cmdline = {
      keymap = {
        ["<CR>"] = { "accept", "fallback" },
        ['<Tab>'] = { 'snippet_forward', 'fallback' },
        ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
      },
      completion = {
        list = {
          selection = {
            preselect = false,
            auto_insert = false,
          },
        },
        menu = {
          auto_show = function(ctx)
            return vim.fn.getcmdtype() == ":"  -- 仅在命令模式显示
          end,
        },
        ghost_text = { enabled = true },
      },
    },

    -- 补全源配置
    sources = {
      default = { "lsp", "snippets", "path", "buffer", "lazydev" },
      providers = {
        lsp = { score_offset = 4 },
        buffer = { score_offset = 3 },
        snippets = { score_offset = 2 },
        path = { score_offset = 1 },
        lazydev = {
          name = "LazyDev",
          module = "lazydev.integrations.blink",
          score_offset = 100,  -- 最高优先级
        },
      },
    },

    appearance = { nerd_font_variant = "mono" },
    fuzzy = { implementation = "prefer_rust_with_warning" },
  },
  opts_extend = { "sources.default" },
}

return {
  "saghen/blink.cmp",
  -- optional: provides snippets for the snippet source
  dependencies = {
    "Kaiser-Yang/blink-cmp-avante",
    "rafamadriz/friendly-snippets",
    "L3MON4D3/LuaSnip",
    "echasnovski/mini.icons",
  },

  -- use a release tag to download pre-built binaries
  version = "1.*",
  -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
  -- build = 'cargo build --release',
  -- If you use nix, you can build from source using latest nightly rust with:
  -- build = 'nix run .#build-plugin',

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
    -- 'super-tab' for mappings similar to vscode (tab to accept)
    -- 'enter' for enter to accept
    -- 'none' for no mappings
    --
    -- All presets have the following mappings:
    -- C-space: Open menu or open docs if already open
    -- C-n/C-p or Up/Down: Select next/previous item
    -- C-e: Hide menu
    -- C-k: Toggle signature help (if signature.enabled = true)
    --
    -- See :h blink-cmp-config-keymap for defining your own keymap
    -- keymap = { preset = "default" },
    cmdline = {
      keymap = {
        -- 选择并接受预选择的第一个
        -- ["<CR>"] = { "select_and_accept", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
      },
      completion = {
        -- 不预选第一个项目，选中后自动插入该项目文本
        list = {
          selection = {
            preselect = false,
            auto_insert = false,
          },
        },
        -- 自动显示补全窗口，仅在输入命令时显示菜单，而搜索或使用其他输入菜单时则不显示
        menu = {
          auto_show = function(ctx)
            return vim.fn.getcmdtype() == ":"
            -- enable for inputs as well, with:
            -- or vim.fn.getcmdtype() == '@'
          end,
        },
        ghost_text = {
          enabled = true
        },
      },
    },
    completion = {
      keyword = {
        range = "full",
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 0,
        window = {
          border = 'rounded'
          -- winhighlight = "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,EndOfBuffer:BlinkCmpDoc",
        },
      },
      -- 不预选第一个项目，选中后自动插入该项目文本
      list = {
        selection = {
          preselect = false,
          auto_insert = false,
        },
      },
      -- 针对菜单的外观配置
      menu = {
        min_width = 15,
        max_height = 10,
        border = "rounded", -- Defaults to `vim.o.winborder` on nvim 0.11+
      },
      ghost_text = {
        enabled = true,
      },
    },
    keymap = {
      preset = "none",
      ["<CR>"] = { "accept", "fallback" }, -- 更改成'select_and_accept'会选择第一项插入
      ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
      ["<Tab>"] = { "select_next", "snippet_forward", "fallback" }, -- 同时存在补全列表和snippet时，补全列表选择优先级更高
    },

    appearance = {
      -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = "mono",
    },

    -- Default list of enabled providers defined so that you can extend it
    -- elsewhere in your config, without redefining it, due to `opts_extend`
    sources = {
      default = {
        "buffer",
        "lsp",
        "snippets",
        "path",
        "avante",
      },
      providers = {
        buffer = { score_offset = 5 },
        lsp = {
          score_offset = 3,
        },
        path = { score_offset = 2 },
        snippets = { score_offset = 1 },
        avante = {
          module = "blink-cmp-avante",
          name = "Avante",
          opts = {
            kind_icons = {
              AvanteCmd = "",
              AvanteMention = "",
              AvanteShortcut = "",
            },
          },
        },
      },
    },

    -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
    -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
    -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
    --
    -- See the fuzzy documentation for more information
    fuzzy = { implementation = "prefer_rust_with_warning" },
  },

  opts_extend = { "sources.default" },
}

return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "folke/lazydev.nvim",
      "nvimdev/lspsaga.nvim",
      "saghen/blink.cmp",
    },
    opts = {
      servers = {
        lua_ls = {},
        pyright = {},
        -- ruff = {},
        -- bashls = {},
        clangd = {},
      },
    },
    config = function(_, opts)
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)
      local lspconfig = vim.lsp.config
      for server, config in pairs(opts.servers) do
        -- passing config.capabilities to blink.cmp merges with the capabilities in your
        -- `opts[server].capabilities, if you've defined it
        config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
        vim.lsp.config[server] = vim.tbl_deep_extend("force", {
          -- on_attach = on_attach,
          capabilities = capabilities,
        }, config)
      end
      require("lazydev").setup({
        lspconfig = true,
        override = function(_, library)
          library.enabled = true
          library.plugins = true
          library.types = true
        end,
      })

      require("lspsaga").setup({
        border = "single",
        beacon = {
          enable = true,
        },
        outline = {
          keys = {
            quit = "Q",
            toggle_or_jump = "<cr>",
          },
        },
        finder = {
          keys = {
            quit = "Q",
            edit = "<C-o>",
            toggle_or_open = "<cr>",
          },
        },
        definition = {
          keys = {
            edit = "<C-o>",
            vsplit = "<C-v>",
          },
        },
        code_action = {
          keys = {
            quit = "Q",
          },
          show_server_name = true,
          extend_gitsigns = true,
        },
        -- Options of rename
        rename = {
          in_select = false,
        },
        -- Options of lightbulb
        lightbulb = {
          enable = true,
          sign = false,
          virtual_text = true,
          enable_in_insert = true,
          debounce = 10,
          sign_priority = 20,
        },
        -- Set the icon of the lightbulb
        ui = {
          -- code_action = ' ',
          devicon = true,
          title = true,
          kind = {},
        },
      })

      vim.diagnostic.config({
        signs = {
          [vim.diagnostic.severity.ERROR] = "✘",
          [vim.diagnostic.severity.WARN] = " ",
        },
        virtual_text = {
          prefix = "❯",
        },
      })

      vim.opt.updatetime = 300
      vim.api.nvim_create_autocmd("CursorHold", {
        callback = function()
          local opts = {
            focusable = false,
            close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
            border = "rounded",
            source = "always",
            prefix = "❯",
            scope = "cursor",
          }
          vim.diagnostic.open_float(nil, opts)
        end,
      })
    end,
  },
}

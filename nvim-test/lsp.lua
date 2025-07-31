return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "folke/neodev.nvim",
      "nvimdev/lspsaga.nvim",
      "saghen/blink.cmp",
    },
    -- opts = {
    --   servers = {
    --     lua_ls = {
    --       settings = {
    --         Lua = {
    --           diagnostics = {
    --             globals = {
    --               "vim",
    --               "require",
    --             },
    --           },
    --           workspace = {
    --             checkThirdParty = false,
    --           },
    --           completion = {
    --             callSnippet = "Replace",
    --           },
    --         },
    --       },
    --     },
    --   },
    -- },

    config = function(_, opts)
      local lspconfig = require("lspconfig")
      local servers = {
        pyright = {},
        -- ruff = {},
        bashls = {},
        clangd = {},
        yamlls = {},
        lua_ls = {},
      }
      for server, config in pairs(opt.servers) do
        config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
        lspconfig[server].setup(config)
      end
    end,

    config = function()
      local capabilities = require("blink.cmp").get_lsp_capabilities()
      local lspconfig = require("lspconfig")

      for server, conf in pairs(servers) do
        require("lspconfig")[server].setup(vim.tbl_deep_extend("force", {
          on_attach = on_attach,
          capabilities = capabilities,
        }, conf))
      end
    end,
    config = function()
      local on_attach = function(_, bufnr)
        local nmap =
          function(keys, func, desc)
            if desc then
              desc = "LSP: " .. desc
            end

            vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
          end, nmap("<leader>pd", "<cmd>Lspsaga peek_definition<CR>", "Peek Definition")
        nmap("<leader>pr", "<cmd>Telescope lsp_references<CR>", "Peek References")
        nmap("<c-d>", "<cmd>Lspsaga hover_doc<CR>", "Hover Documentation")
        nmap("<leader>wa", vim.lsp.buf.add_workspace_folder, "Workspace Add Folder")
        nmap("<leader>wr", vim.lsp.buf.remove_workspace_folder, "Workspace Remove Folder")
        nmap("<leader>wl", function()
          vim.notify(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, "Workspace List Folders")
        nmap("<leader>rn", "<cmd>Lspsaga rename ++project<cr>", "Rename")
        nmap("<leader>ca", "<cmd>Lspsaga code_action<CR>", "Code Action")
        nmap("<leader>ot", "<cmd>Lspsaga outline<CR>", "OutLine")
        nmap("d[", "<cmd>Lspsaga diagnostic_jump_prev<CR>", "Diangostics Prev")
        nmap("d]", "<cmd>Lspsaga diagnostic_jump_next<CR>", "Diangostics Next")
        nmap("<space>f", function()
          vim.lsp.buf.format({ async = true })
        end, "[F]ormat code")
      end
      require("neodev").setup({
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

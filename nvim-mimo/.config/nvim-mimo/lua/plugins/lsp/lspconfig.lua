-- LSP 配置
return {
  {
    "neovim/nvim-lspconfig",
    dependencies = { "folke/lazydev.nvim" },
    opts = {
      servers = {
        lua_ls = {},
        pyright = {},
        ruff = {},
        clangd = {},
        marksman = {},
      },
    },
    config = function(_, opts)
      local default_lsp_config = {
        capabilities = vim.tbl_deep_extend(
          "force",
          vim.lsp.protocol.make_client_capabilities(),
          require("blink.cmp").get_lsp_capabilities(),
          opts.capabilities or {}
        ),
      }

      for server in pairs(opts.servers) do
        vim.lsp.config(server, default_lsp_config)
        vim.lsp.enable(server)
      end

      -- lazydev 配置
      require("lazydev").setup({
        lspconfig = true,
        override = function(_, library)
          library.enabled = true
          library.plugins = true
          library.types = true
        end,
      })

      -- 诊断配置
      vim.diagnostic.config({
        signs = {
          [vim.diagnostic.severity.ERROR] = "✘",
          [vim.diagnostic.severity.WARN] = " ",
        },
        virtual_text = { prefix = "❯" },
      })

      -- 悬停显示诊断信息
      vim.opt.updatetime = 300
      vim.api.nvim_create_autocmd("CursorHold", {
        callback = function()
          vim.diagnostic.open_float(nil, {
            focusable = false,
            close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
            border = "rounded",
            scope = "cursor",
          })
        end,
      })

      -- LSP 快捷键映射
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(args)
          local bufnr = args.buf

          vim.keymap.set(
            "n",
            "<leader>ca",
            "<cmd>Lspsaga code_action<CR>",
            { buffer = bufnr, desc = "LSP: Code Action" }
          )

          vim.keymap.set(
            "n",
            "<leader>rn",
            "<cmd>Lspsaga rename ++project<cr>",
            { buffer = bufnr, desc = "LSP: Rename (Project)" }
          )

          vim.keymap.set(
            "n",
            "<leader>ot",
            "<cmd>Lspsaga outline<CR>",
            { buffer = bufnr, desc = "LSP: Outline" }
          )

          vim.keymap.set(
            "n",
            "gd",
            "<cmd>Lspsaga definition<CR>",
            { buffer = bufnr, desc = "LSP: Go to Definition" }
          )

          vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder)
          vim.keymap.set(
            "n",
            "<leader>sd",
            "<cmd>Lspsaga show_diagnostics<CR>",
            { buffer = bufnr, desc = "LSP: Show Diagnostics" }
          )

          vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder)

          vim.keymap.set(
            "n",
            "gr",
            "<cmd>Lspsaga finder<CR>",
            { buffer = bufnr, desc = "LSP: Find References" }
          )

          vim.keymap.set(
            "n",
            "K",
            "<cmd>Lspsaga hover_doc<CR>",
            { buffer = bufnr, desc = "LSP: Hover" }
          )

          vim.keymap.set(
            "n",
            "gy",
            "<cmd>Lspsaga peek_type_definition<CR>",
            { buffer = bufnr, desc = "LSP: Type Definition" }
          )
        end,
      })
    end,
  },
}

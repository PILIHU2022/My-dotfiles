-- LSP 配置
return {
  {
    "neovim/nvim-lspconfig",
    dependencies = { "folke/lazydev.nvim" },
    opts = {
      servers = {
        lua_ls = {},
        pyright = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "basic",
                autoImportCompletions = true,
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "workspace",
                inlayHints = {
                  variableTypes = true,
                  functionReturnTypes = true,
                },
              },
            },
          },
        },
        ruff = {
          settings = {
            lineLength = 80,
            indentWidth = 4,
            format = { quoteStyle = "double" },
            lint = {
              select = { "E", "W", "F", "I", "N", "UP", "B", "SIM", "C4" },
              ignore = { "D100", "D101", "D102", "D103", "D104", "D105", "D107" },
            },
          },
        },
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

      -- lazydev 配置 (用于 Lua 类型定义)
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
          [vim.diagnostic.severity.WARN] = " ",
        },
        virtual_text = { prefix = "❯" },
        update_in_insert = true,
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

          -- Code Action 快捷键
          vim.keymap.set(
            "n",
            "<leader>ca",
            "<cmd>Lspsaga code_action<CR>",
            { buffer = bufnr, desc = "LSP: Code Action" }
          )

          -- 重命名快捷键 (项目范围)
          vim.keymap.set(
            "n",
            "<leader>rn",
            "<cmd>Lspsaga rename ++project<cr>",
            { buffer = bufnr, desc = "LSP: Rename (Project)" }
          )

          -- 大纲快捷键
          vim.keymap.set(
            "n",
            "<leader>ot",
            "<cmd>Lspsaga outline<CR>",
            { buffer = bufnr, desc = "LSP: Outline" }
          )

          -- 其他常用 LSP 快捷键
          -- 跳转到定义
          -- 跳转到光标下符号（函数、变量、类等）的定义位置
          -- 如果定义在其他文件中，会自动打开对应文件并跳转到定义行
          vim.keymap.set(
            "n",
            "gd",
            "<cmd>Lspsaga definition<CR>",
            { buffer = bufnr, desc = "LSP: Go to Definition" }
          )

          -- 添加工作区文件夹
          -- 将指定文件夹添加到 LSP 的工作区中
          -- 用于管理大型项目，可以让 LSP 索引额外的文件夹（如依赖库、子模块等）
          vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder) -- 快速打开错误/诊断窗口
          vim.keymap.set(
            "n",
            "<leader>sd",
            "<cmd>Lspsaga show_diagnostics<CR>",
            { buffer = bufnr, desc = "LSP: Show Diagnostics" }
          )

          -- 从当前工作区中移除特定文件夹
          -- 用于管理项目中的 LSP 工作区文件夹
          vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder)

          -- 查找引用
          -- 显示光标下符号（函数、变量、类等）在当前项目中的所有引用位置
          vim.keymap.set(
            "n",
            "gr",
            "<cmd>Lspsaga finder<CR>",
            { buffer = bufnr, desc = "LSP: Find References" }
          )

          -- 悬停文档
          -- 显示光标下符号的类型信息、文档说明和参数详情
          -- 相当于光标悬停弹窗，可以多次按 K 切换显示详情
          vim.keymap.set(
            "n",
            "K",
            "<cmd>Lspsaga hover_doc<CR>",
            { buffer = bufnr, desc = "LSP: Hover" }
          )

          -- 查看类型定义
          -- 跳转到光标下符号的类型定义位置
          -- 例如：跳转到变量的类型定义、函数的返回类型定义等
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
  {
    "nvimdev/lspsaga.nvim",
    event = "LspAttach",
    opts = {
      border = "single",
      beacon = { enable = true },
      outline = { keys = { quit = "q", toggle_or_jump = "<cr>" } },
      finder = { keys = { quit = "q", edit = "<C-o>", toggle_or_open = "<cr>" } },
      definition = { keys = { edit = "<C-o>", vsplit = "<C-v>" } },
      code_action = {
        keys = {
          quit = "q",
          exec = "<CR>",
        },
        show_server_name = true,
        num_shortcut = true,
        extend_gitsigns = true,
      },
      rename = { in_select = false },
      lightbulb = {
        enable = true,
        sign = true,
        virtual_text = true,
        enable_in_insert = true,
        debounce = 10,
        sign_priority = 20,
      },
      ui = { code_action = " ", devicon = true, title = true, kind = {} },
    },
  },
}

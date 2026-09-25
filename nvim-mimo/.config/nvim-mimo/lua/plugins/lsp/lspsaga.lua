-- Lspsaga 配置
return {
  {
    "nvimdev/lspsaga.nvim",
    event = "LspAttach",
    keys = {
      { "<leader>pd", "<cmd>Lspsaga peek_definition<CR>", desc = "Peek Definition" },
      { "<leader>pr", "<cmd>Telescope lsp_references<CR>", desc = "LSP References" },
      { "<c-d>", "<cmd>Lspsaga hover_doc<CR>", desc = "Hover Doc" },
      { "<leader>wa", vim.lsp.buf.add_workspace_folder, desc = "Add Workspace Folder" },
      { "<leader>wr", vim.lsp.buf.remove_workspace_folder, desc = "Remove Workspace Folder" },
      { "d[", "<cmd>Lspsaga diagnostic_jump_prev<CR>", desc = "Diagnostic Prev" },
      { "d]", "<cmd>Lspsaga diagnostic_jump_next<CR>", desc = "Diagnostic Next" },
    },
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
      ui = { code_action = " ", devicon = true, title = true, kind = {} },
    },
  },
}

local LSP_indicator = {
  function()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients > 0 then
      return clients[1].name
    end
    return "None"
  end,
  icon = " LSP:",
  color = { fg = "#ffffff", gui = "bold" },
}

return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("lualine").setup({
      options = {
        icons_enabled = true,
        component_separators = { left = ">", right = "<" },
      },
      sections = {
        lualine_c = { "filename", LSP_indicator },
        lualine_x = { "encoding", "fileformat", "filetype" },
      },
    })
  end,
}

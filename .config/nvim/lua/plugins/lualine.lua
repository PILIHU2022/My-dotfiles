-- lualine.lua - 修复后的版本
local LSP_indicator = {
  function()
    local msg = "None"
    local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
    -- 修复：使用 vim.lsp.get_clients() 替代弃用的 get_active_clients()
    local clients = vim.lsp.get_clients()

    if not clients or next(clients) == nil then
      return msg
    end

    for _, client in ipairs(clients) do
      local filetypes = client.config.filetypes
      if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
        return client.name
      end
    end
    return msg
  end,
  icon = " LSP:",
  color = { fg = "#ffffff", gui = "bold" },
}

return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
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

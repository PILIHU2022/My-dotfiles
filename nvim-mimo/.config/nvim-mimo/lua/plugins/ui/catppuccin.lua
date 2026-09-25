-- Catppuccin 主题配置
local highlight_groups = function(C)
  return {
    NormalFloat = { bg = C.none },           -- 透明浮动窗口
    FloatBorder = { fg = C.sky },
    TabLineSel = { bg = C.red },
    Pmenu = { bg = C.none },
    PmenuSel = { bg = C.overlay0 },

    -- blink.cmp 高亮
    BlinkCmpDoc = { link = "Pmenu" },
    BlinkCmpDocBorder = { link = 'FloatBorder' },
    BlinkCmpMenu = { link = "Pmenu" },
    BlinkCmpMenuBorder = { fg = C.blue },
    BlinkCmpMenuSelection = { link = "PmenuSel" },

    -- telescope 高亮
    TelescopeBorder = { fg = C.blue },
  }
end

return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      flavor = "mocha",                    -- latte, frappe, macchiato, mocha
      background = { light = "latte", dark = "mocha" },
      floating_border = "on",
      no_italic = false,
      no_bold = false,
      styles = {
        comments = { "italic" },
        functions = { "italic" },
        booleans = { "bold" },
        types = { "italic" },
      },
      integrations = {
        blink_cmp = true,
        gitsigns = true,
        indent_blankline = { enabled = true, colored_indent_levels = true },
        lsp_trouble = true,
        markdown = true,
        neotree = true,
        telescope = { enabled = true },
        treesitter_context = true,
        which_key = true,
      },
      highlight_overrides = { mocha = highlight_groups },
    })
    vim.cmd.colorscheme("catppuccin-mocha")
  end,
}

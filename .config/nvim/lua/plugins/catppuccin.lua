local highlight_groups = function(C)
  return {
    NormalFloat = { bg = C.none }, -- transparent
    FloatBorder = { fg = C.lavender },
    TabLineSel = { bg = C.red },
    Pmenu = { bg = C.none },
    PmenuSel = { bg = C.overlay0 },

    -- blink.cmp
    BlinkCmpMenuBorder = { fg = C.yellow },
    BlinkCmpDocBorder = { fg = C.rosewater },
    BlinkCmpMenu = { link = "Pmenu" },
    BlinkCmpMenuSelection = { link = "PmenuSel" },

    -- nvim-cmp
    -- change values in `winhighlight`
    -- CmpMenuBorder = { fg = C.yellow },
    -- CmpDocBorder = { fg = C.rosewater },
    -- CmpBG = { link = "Pmenu" },
    -- CmpSel = { link = "PmenuSel" },

    -- telescope
    -- https://github.com/nvim-telescope/telescope.nvim/wiki/
    -- FAQ#how-to-change-telescope-highlights-group
    TelescopeBorder = { fg = C.blue },
  }
end

local config = {
  flavor = "mocha", -- latte, frappe, macchiato, mocha
  background = "mocha",
  floating_border = "on",
  -- transparent_background = true,
  -- term_colors = true,
  no_italic = false,
  no_bold = false,
  no_underline = false,
  styles = {
    comments = { "italic" },
    onditionals = {},
    loops = {},
    functions = { "italic" },
    keywords = {},
    strings = {},
    variables = {},
    numbers = {},
    booleans = { "bold" },
    properties = {},
    types = { "italic" },
  },
  integrations = {
    cmp = true,
    gitsigns = true,
    indent_blankline = {
      enabled = true,
      colored_indent_levels = true,
    },
    lsp_trouble = true,
    markdown = true,
    neotree = true,
    telescope = {
      enabled = true,
    },
    treesitter_context = true,
    which_key = true,
    native_lsp = {
      enable = true,
      virtual_text = {
        errors = { "bold" },
        hints = { "italic" },
        warnings = {},
        information = {},
      },
      -- underlines = {
      --   errors = { "underline" },
      --   hints = { "underline" },
      --   warnings = { "underline" },
      --   information = { "underline" },
      -- },
      inlay_hints = {
        background = true,
      },
    },
  },
  -- user defined highlight group
  highlight_overrides = {
    mocha = highlight_groups,
  },
}

return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    require("catppuccin").setup(config)
    vim.cmd.colorscheme("catppuccin-mocha")
  end,
}

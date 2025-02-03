-- Markdown Preview
return {
  "OXY2DEV/markview.nvim",
  lazy = true, -- Recommended
  ft = "markdown", -- If you decide to lazy-load anyway
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("markview").setup({
      preview = { enable = false },
      border = "rounded",
    })
  end,
}

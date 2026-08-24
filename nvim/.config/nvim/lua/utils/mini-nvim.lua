-- mini.nvim 工具集
return {
  "echasnovski/mini.nvim",
  version = false,
  event = "VeryLazy",
  config = function()
    require("mini.comment").setup()
    require("mini.pairs").setup()
    require('mini.surround').setup()
  end,
}

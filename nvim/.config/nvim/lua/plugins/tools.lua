-- im-select.nvim 输入法切换
return {
  "keaising/im-select.nvim",
  event = { "InsertEnter", "CmdlineEnter" },
  config = function()
    require("im_select").setup({})
  end,
}

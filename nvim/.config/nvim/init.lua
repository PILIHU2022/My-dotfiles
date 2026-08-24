require("lazy_setup")
require("core.options")
require("core.keymap")

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    require("keymap.markdown").setup()
  end,
})

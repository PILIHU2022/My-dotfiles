local au = vim.api.nvim_create_autocmd
require("core.options")
require("core.keymap")
require("lazy_nvim")
-- yazi
require("keymap.yazi")
-- require("core.ImSwitch")
-- require("core.ranger")
-- require("core.CodeRunning")

-- Markdown keymap
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile", "FileType" }, {
  pattern = "markdown",
  callback = function()
    require("keymap.markdown")
  end,
})

-- Terminal
au("TermOpen", { command = "startinsert" })

-- highlight (invalid)
-- vim.api.nvim_create_autocmd("TextYankPost", {
--   callback = function()
--     vim.highlight.on_yank({ higroup = 'Visual', timeout = 200 })
--   end,
-- })

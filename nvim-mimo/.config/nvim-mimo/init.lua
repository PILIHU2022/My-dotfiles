require("lazy_setup")
require("core.options")
require("core.keymap")
-- yazi
-- require("keymap.yazi")
-- require("core.ImSwitch")
-- require("core.ranger")
-- require("core.CodeRunning")

-- Markdown keymap - 最简洁最可靠的方式
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    require("keymap.markdown")
  end,
})

-- Terminal
vim.api.nvim_create_autocmd("TermOpen", { command = "startinsert" })

-- highlight (invalid)
-- vim.api.nvim_create_autocmd("TextYankPost", {
--   callback = function()
--     vim.highlight.on_yank({ higroup = 'Visual', timeout = 200 })
--   end,
-- })

local au = vim.api.nvim_create_autocmd
require("core.options")
require("core.keymap")
-- require('core.keymap_Script')
require("lazy_nvim")
-- require("core.ImSwitch")
require("core.ranger")
require("core.CodeRunning")
au({ 'FileType' }, {
  -- group = group,
  pattern = 'markdown',
  callback = function()
    require('keymap.markdown')
  end,
})

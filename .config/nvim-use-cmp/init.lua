local au = vim.api.nvim_create_autocmd
require("core.options")
require("core.keymap")
require("lazy_nvim")
-- require("core.ImSwitch")
require("core.ranger")
require("core.CodeRunning")

-- Markdown keymap
au({ 'BufRead', 'BufNewFile', 'FileType' }, {
    pattern = { 'markdown' },
    callback = function()
        require('keymap.markdown')
    end,
})

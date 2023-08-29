-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt
opt.autowrite = true
opt.number = true
opt.relativenumber = false
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize" }
opt.cursorline = true -- Enable highlighting of the current line
opt.colorcolumn = "80" -- 设置垂直参考线(80)

-- tabs & indentation
opt.tabstop = 4 -- 4 spaces for tabs (prettier default)
opt.shiftwidth = 4 -- 4 spaces for indent width
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one

-- 设置全局变量
local opt = vim.opt

opt.autowrite = true

-- 相对行号
opt.number = true
opt.relativenumber = false

-- 在第八十列处显示垂直参考线
opt.colorcolumn = "80"

-- 设置Tab键和缩进
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true

-- 防止包裹
opt.wrap = false

-- 光标行
opt.cursorline = true

-- 启用鼠标
opt.mouse:append("a")

-- 系统剪贴板
opt.clipboard:append("unnamedplus")

-- 默认新窗口在右和下
opt.splitright = true
opt.splitbelow = true

-- 搜索
opt.ignorecase = true
opt.smartcase = true

-- 外观
opt.termguicolors = true
opt.signcolumn = "yes"

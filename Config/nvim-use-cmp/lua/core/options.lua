-- 设置全局变量
local opt = vim.opt

opt.autowrite = true

-- undofiles
opt.undofile = true
opt.undodir = '/home/PILIHU/.undofiles/'

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

vim.opt.list = true
vim.opt.listchars = 'tab:»·,nbsp:+,trail:·,extends:→,precedes:←'

vim.api.nvim_create_autocmd('TermOpen', { pattern = 'term://*', command = [[startinsert]] })

-- 设置在指定文件中启动包裹文字
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, { pattern = { '*.md', '*.txt' }, command = 'setlocal wrap', })

-- 设置复制时高亮复制行(在本主题无效)
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank({ higroup = 'Visual', timeout = 200 })
  end
})

-- 设置在特定文件后缀中的缩进
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile', 'FileType' }, {
  pattern = {'yaml','yml'},
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
  end,
})

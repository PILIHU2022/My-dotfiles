local map = require('core.keymap')
local cmd = map.cmd
-- vim.g.mapleader = ' '

-- For normal mode
map.n({
    -- telescope
    ['<leader>ff'] = cmd('Telescope find_files find_command=rg,--ignore,--hidden,--files'),
    ['<leader>fw'] = cmd('Telescope live_grep'),
    ['<leader>pr'] = cmd('Telescope lsp_references'),
    ['<leader>sv'] = "<C-w>v", -- 水平新增窗口
    ['<leader>sh'] = "<C-w>s", -- 垂直新增窗口
    ['<leader>nh'] = cmd('nohl<CR>'),
    -- 使用<ctrl>+上下左右键来切换上下左右窗口(nvim内)
    ["<C-h>"] = "<C-w>h", -- 切换到左边窗口
    ["<C-l>"] = "<C-w>l", -- 切换到右边窗口
    ["<C-k>"] = "<C-w>k", -- 切换到上面窗口
    ["<C-j>"] = "<C-w>j", -- 切换到下面窗口
    -- 设置切换标签页快捷键
    ["<A-[>"] = cmd("BufferLineCyclePrev<cr>"),
    ["<A-]>"] = cmd("BufferLineCycleNext<cr>"),
    ["<A-i>"] = cmd("BufferLinePick<cr>"),
    ["<A-q>"] = cmd("bp|sp|bn|bd!<cr>"),
    -- 使用<ctrl>+hjkl来调整窗口大小(nvim内)
    ['<C-up>'] = cmd(':resize +2<CR>'),
    ['<C-down>'] = cmd(':resize -2<CR>'),
    ['<C-left>'] = cmd(':vertical resize -2<CR>'),
    ['<C-right>'] = cmd(':vertical resize +2<CR>'),
    -- Markdown-preview
    ['<C-m>'] = cmd('MarkdownPreview<CR>'),
    -- nvim-tree
    ["<leader>e"] = cmd("Neotree<CR>"),
    -- 快捷打开Lazy
    ["<leader>l"] = cmd("Lazy<CR>"),
    -- 打开终端
    ["<leader>t"] = cmd("terminal<CR>"),
    ['<C-r>'] = cmd('redo<cr>')
})
-- For visual mode
map.v({
    ['J'] = cmd("m '>+1<CR>gv=gv"),
    ['K'] = cmd(":m '<-2<CR>gv=gv"),
    ['<C-r>'] = cmd('redo<cr>'),
})
-- For s mode
map.s({
    ['<C-r>'] = cmd('redo<cr>'),
})

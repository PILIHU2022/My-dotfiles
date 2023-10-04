vim.g.mapleader = " "

-- 设置变量
local keymap = vim.keymap

-- 单行或多行移动(暂时失效)
-- keymap.set("v", "J", ":move >+1<CR>gv=gv")
-- keymap.set("v", "K", ":move <-2<CR>gv=gv")

-- 窗口
keymap.set("n", "<leader>sv", "<C-w>v") -- 水平新增窗口 
keymap.set("n", "<leader>sh", "<C-w>s") -- 垂直新增窗口

-- 取消高亮
keymap.set("n", "<leader>nh", ":nohl<CR>")

-- 设置保存快捷键
keymap.set({ "i", "v", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>")

-- 单行或多行移动
keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- 使用<ctrl>+上下左右键来切换上下左右窗口(lazynvim内)
keymap.set("n", "<C-left>", "<C-w>h", opt) -- 切换到左边窗口
keymap.set("n", "<C-right>", "<C-w>l", opt) -- 切换到右边窗口
keymap.set("n", "<C-down>", "<C-w>j", opt) -- 切换到下面窗口
keymap.set("n", "<C-up>", "<C-w>k", opt) -- 切换到上面窗口

-- 设置切换标签页快捷键
keymap.set("n", "<A-right>", "<cmd>BufferLineCyclePrev<cr>")
keymap.set("n", "<A-left>", "<cmd>BufferLineCycleNext<cr>")
keymap.set("n", "<A-i>", "<cmd>BufferLinePick<cr>")
keymap.set("n", "<A-q>", "<cmd>bp|sp|bn|bd!<cr>")

-- 使用<ctrl>+hjkl来调整窗口大小(lazynvim内)
keymap.set('n', '<C-j>', ':resize +2<CR>', opts)
keymap.set('n', '<C-k>', ':resize -2<CR>', opts)
keymap.set('n', '<C-l>', ':vertical resize -2<CR>', opts)
keymap.set('n', '<C-h>', ':vertical resize +2<CR>', opts)

-- nvim-tree
keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")

-- Mason
keymap.set("n", "<leader>cm", ":Mason<CR>")

-- 快捷打开Lazy
keymap.set("n", "<leader>l", ":Lazy<CR>")

-- 复制快捷键
keymap.set("v", "<C-c>", "+yy")

-- 打开终端
keymap.set("n", "<leader>t", ":terminal<CR>")

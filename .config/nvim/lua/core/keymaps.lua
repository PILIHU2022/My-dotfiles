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

-- nvim-tree
keymap.set("n", "<leader>e", ":Ntree<CR>")

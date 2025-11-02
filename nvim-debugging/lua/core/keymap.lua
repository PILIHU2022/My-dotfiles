vim.g.mapleader = " "

-- 设置变量
local keymap = vim.keymap

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

-- 使用<ctrl>+上下左右键来切换上下左右窗口(nvim内)
keymap.set("n", "<C-h>", "<C-w>h") -- 切换到左边窗口
keymap.set("n", "<C-l>", "<C-w>l") -- 切换到右边窗口
keymap.set("n", "<C-k>", "<C-w>k") -- 切换到上面窗口
keymap.set("n", "<C-j>", "<C-w>j") -- 切换到下面窗口

-- 设置切换标签页快捷键
keymap.set({ "n", "t" }, "<A-[>", "<cmd>BufferLineCyclePrev<cr>")
keymap.set({ "n", "t" }, "<A-]>", "<cmd>BufferLineCycleNext<cr>")
keymap.set({ "n", "t" }, "<A-i>", "<cmd>BufferLinePick<cr>")
keymap.set({ "n", "t" }, "<A-q>", "<cmd>bp|sp|bn|bd!<cr>")

-- 使用<ctrl>+hjkl来调整窗口大小(nvim内)
keymap.set("n", "<C-up>", ":resize +2<CR>")
keymap.set("n", "<C-down>", ":resize -2<CR>")
keymap.set("n", "<C-left>", ":vertical resize -2<CR>")
keymap.set("n", "<C-right>", ":vertical resize +2<CR>")

-- Markdown-preview
-- keymap.set('n', '<C-m>', ':MarkdownPreview<CR>')

-- nvim-tree
keymap.set("n", "<leader>e", ":Neotree toggle<CR>")

-- Mason
-- keymap.set("n", "<leader>cm", ":Mason<CR>")

-- 快捷打开Lazy
keymap.set("n", "<leader>l", ":Lazy<CR>")

-- 复制快捷键
-- keymap.set("v", "<C-c>", "+yy")

-- 重做快捷键(redo)
keymap.set({ "n", "v", "s" }, "<C-r>", ":redo<CR>")

-- 打开终端
keymap.set("n", "<leader>t", ":terminal<CR>")

-- 设置相对行数
keymap.set("n", "<leader>y", ":set relativenumber!<bar>set number<CR>")

-- conform.nvim format code
keymap.set(
  "n",
  "<leader>f",
  ':lua require("conform").format()<CR>',
  { desc = "LSP: [F]ormat code" }
)

-- none-ls.nvim format code
-- keymap.set('n', '<leader>fl', ':lua vim.lsp.buf.format()<CR>')

-- Theme switcher for Chameleon.nvim
-- vim.keymap.set("n", "<leader>th", function()
--   require("tswitch").open()
-- end, { desc = "Theme Switcher" })

-- lspsaga
keymap.set("n", "<leader>pd", "<cmd>Lspsaga peek_definition<CR>")
keymap.set("n", "<leader>pr", "<cmd>Telescope lsp_references<CR>")
keymap.set("n", "<c-d>", "<cmd>Lspsaga hover_doc<CR>")
keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder)
keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder)
-- keymap.set('n', "<leader>wl", function()vim.notify(vim.inspect(vim.lsp.buf.list_workspace_folders()))end, "Workspace List Folders")
keymap.set("n", "<leader>rn", "<cmd>Lspsaga rename ++project<cr>")
keymap.set("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>")
keymap.set("n", "<leader>ot", "<cmd>Lspsaga outline<CR>")
keymap.set("n", "d[", "<cmd>Lspsaga diagnostic_jump_prev<CR>")
keymap.set("n", "d]", "<cmd>Lspsaga diagnostic_jump_next<CR>")

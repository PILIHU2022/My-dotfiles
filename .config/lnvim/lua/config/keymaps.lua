-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- This file is automatically loaded by lazyvim.config.init
local Util = require("lazyvim.util")

local function map(mode, lhs, rhs, opts)
  local keys = require("lazy.core.handler").handlers.keys
  ---@cast keys LazyKeysHandler
  -- do not create the keymap if a lazy keys handler exists
  --  if not keys.active[keys.parse({ lhs, mode = mode }).id] then
  --    opts = opts or {}
  --    opts.silent = opts.silent ~= false
  --    if opts.remap and not vim.g.vscode then
  --      opts.remap = nil
  --    end
  --    vim.keymap.set(mode, lhs, rhs, opts)
  --  end
end

-- 使用<ctrl>+上下左右键来切换上下左右窗口(lazynvim内)
map("n", "<C-left>", "<C-w>h", { desc = "Go to left window", remap = true }) -- 切换到左边窗口
map("n", "<C-right>", "<C-w>l", { desc = "Go to right window", remap = true }) -- 切换到右边窗口
map("n", "<C-down>", "<C-w>j", { desc = "Go to lower window", remap = true }) -- 切换到下面窗口
map("n", "<C-up>", "<C-w>k", { desc = "Go to upper window", remap = true }) -- 切换到上面窗口

-- 使用<ctrl>+hjkl来调整窗口大小(lazynvim内)
map("n", "<C-h>", "<cmd>resize +2<cr>", { desc = "Increase window height" }) -- 使窗口增加2高度
map("n", "<C-j>", "<cmd>resize -2<cr>", { desc = "Decrease window height" }) -- 使窗口减少2高度
map("n", "<C-l>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" }) -- 使窗口减少2宽度
map("n", "<C-k>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" }) -- 使窗口增加2宽度

-- 保存文件
map({ "i", "v", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- 切换标签页,目前失败
-- map("n", "<A-left>", "<cmd>tablast<cr>", { desc = "Last Tab" })
-- map("n", "<A-e>", "<cmd>tabfirst<cr>", { desc = "First Tab" })
-- map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
-- map("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
-- map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
-- map("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

-- 移动整行
map("n", "<C-y>", "<cmd>m .+1<cr>==", { desc = "Move down" })
map("n", "<C-k>", "<cmd>m .-2<cr>==", { desc = "Move up" })

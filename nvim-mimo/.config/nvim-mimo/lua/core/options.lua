-- option.lua - 模块化版本
local opt = vim.opt

-- 辅助函数
local function set_local_indent(width)
  vim.opt_local.tabstop = width
  vim.opt_local.shiftwidth = width
  vim.opt_local.softtabstop = width
end

-- 路径配置
local cache_dir = os.getenv("HOME") .. "/.cache/nvim"
local undodir = cache_dir .. "/undodir"
vim.fn.mkdir(undodir, "p")

-- 核心设置
local settings = {
  -- 超时
  timeout = true,
  timeoutlen = 300,

  -- 文件
  autowrite = true,
  undofile = true,
  undodir = undodir,

  -- 显示
  number = true,
  relativenumber = false,
  colorcolumn = "80",
  cursorline = true,
  signcolumn = "yes",
  termguicolors = true,
  conceallevel = 0,
  wrap = false,
  list = true,
  listchars = { tab = "»·", nbsp = "+", trail = "·", extends = "→", precedes = "←" },

  -- 缩进
  tabstop = 4,
  shiftwidth = 4,
  expandtab = true,
  autoindent = true,

  -- 交互
  mouse = "a",
  clipboard = "unnamedplus",

  -- 窗口
  splitright = true,
  splitbelow = true,

  -- 搜索
  ignorecase = true,
  smartcase = true,
}

-- 应用设置
for key, value in pairs(settings) do
  opt[key] = value
end

-- 自动命令
local augroup = vim.api.nvim_create_augroup("UserOptions", { clear = true })

-- 终端自动进入插入模式
vim.api.nvim_create_autocmd("TermOpen", {
  group = augroup,
  pattern = "term://*",
  command = "startinsert",
})

-- Markdown/文本文件启用换行
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = augroup,
  pattern = { "*.md", "*.txt" },
  callback = function()
    vim.opt_local.wrap = true
  end,
})

-- 复制高亮
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  callback = function()
    vim.hl.on_yank({ higroup = "Visual", timeout = 300 })
  end,
})

-- 2 空格缩进文件类型
local two_space_files = { "*.yaml", "*.yml", "*.toml", "*.mjs", "*.js", "*.lua", "*.c" }
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = augroup,
  pattern = two_space_files,
  callback = function()
    set_local_indent(2)
  end,
})

-- 4 空格缩进文件类型
local four_space_files = { "*.py" }
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = augroup,
  pattern = four_space_files,
  callback = function()
    set_local_indent(4)
  end,
})

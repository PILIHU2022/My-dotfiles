local feedkeys = function(keys, mode)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, true, true), mode, true)
end

local function RunWin(opt)
  local Win = require("core.util.FloatWin")
  Win:Create({
    anchor = "NE",
    width = 0.25,
    height = 0.86,
    title = "  Code Running ",
  }, {
    buflisted = true,
    pos = "tr",
  })
  vim.cmd(opt)
  vim.api.nvim_command("file Code Running")
end

local function Run()
  vim.cmd("w")
  local filetype = vim.bo.filetype
  local filename = vim.fn.expand("%")
  local runfile = vim.fn.expand("%<")
  local runfile_dir = vim.fn.expand("%:p:h")
  if vim.fn.getcwd() == runfile_dir then
    runfile = runfile_dir .. "/" .. runfile
  end
  if filetype == "c" then
    RunWin(
      string.format(
        'term gcc "%s" -o "%s" && "%s" && rm -f "%s"',
        filename,
        runfile,
        runfile,
        runfile
      )
    )
  elseif filetype == "cpp" then
    RunWin(
      string.format(
        'term g++ "%s" -std=c++17 -O2 -g -Wall -o "%s" && "%s" && rm -rf "%s"',
        filename,
        runfile,
        runfile,
        runfile
      )
    )
  elseif filetype == "python" then
    RunWin("term python3 " .. filename)
  elseif filetype == "lua" then
    RunWin("term luajit " .. filename)
  elseif filetype == "sh" then
    RunWin("term bash " .. filename)
  elseif filetype == "markdown" then
    vim.cmd("MarkdownPreview")
  elseif filetype == "html" then
    vim.cmd([[
      tabe
      execute 'term live-server --browser=' . g:browser
      tabclose
    ]])
    feedkeys("<ESC>", "n")
  end
end

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "c", "cpp", "python", "lua", "markdown", "sh", "html" },
  callback = function()
    vim.keymap.set("n", "<F5>", Run, {})
  end,
})

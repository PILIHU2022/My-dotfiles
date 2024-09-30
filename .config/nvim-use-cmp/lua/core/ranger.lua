local prev_win = -1
local winnr = -1
local bufnr = -1
local tempname = ''
local workpath = ''

local function OpenFile(open)
  if open == 'vsplit' then
    vim.cmd('set splitright')
  end

  if vim.fn.filereadable(vim.fn.expand(tempname)) == 1 then
    local filenames = vim.fn.readfile(tempname)
    for _, filename in ipairs(filenames) do
      vim.cmd(open .. ' ' .. filename)
    end
  end
end

local function EndOpt()
  vim.fn.delete(tempname)
  vim.cmd('silent! lcd ' .. workpath)
end

local function TabName(name)
  vim.api.nvim_create_autocmd('TermEnter', {
    buffer = bufnr,
    callback = function()
      vim.api.nvim_command('file ' .. name)
    end
  })
end

local function CloseFloatWin()
  vim.api.nvim_win_close(winnr, true)
  vim.api.nvim_buf_delete(bufnr, { force = true })
  vim.api.nvim_set_current_win(prev_win)
end

local function Ranger(open, opt)
  prev_win = vim.api.nvim_get_current_win()
  workpath = vim.fn.getcwd()
  if opt then
    vim.cmd('silent! lcd ' .. vim.lsp.buf.list_workspace_folders()[1])
  else
    vim.cmd('silent! lcd %:p:h')
  end
  local Win = require('core.util.FloatWin')
  Win:Create({
    width = 0.8,
    height = 0.8,
    title = ' Ranger ',
  })
  WinInfo = Win:GetInfo()
  winnr, bufnr = WinInfo.winnr, WinInfo.bufnr
  TabName('Ranger')
  tempname = vim.fn.tempname()
  vim.fn.termopen(string.format('ranger --choosefiles="%s"', tempname), {
    on_exit = function()
      if vim.api.nvim_win_is_valid(winnr) then
        CloseFloatWin()
        OpenFile(open)
      end
      EndOpt()
    end
  })
end

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  callback = function()
    vim.keymap.set('n', '<leader>ra', function() Ranger('edit', false) end, {})
    vim.keymap.set('n', '<leader>rl', function() Ranger('vsplit', false) end, {})
    vim.keymap.set('n', '<leader>rw', function() Ranger('edit', true) end, {})
  end
})

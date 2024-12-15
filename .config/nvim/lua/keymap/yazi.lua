local map = require('core.keymap_script')
map.n({
    -- yazi
    ['<leader>ra'] = function()
      require('core.yazi').yazi('edit')
    end,

    ['<leader>rh'] = function()
      require('core.yazi').yazi('vsplit', 'left')
    end,

    ['<leader>rj'] = function()
      require('core.yazi').yazi('split', 'down')
    end,

    ['<leader>rk'] = function()
      require('core.yazi').yazi('split', 'up')
    end,

    ['<leader>rl'] = function()
      require('core.yazi').yazi('vsplit', 'right')
    end,
})

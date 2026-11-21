local map = require("core.keymap_script")
map.n({
  -- yazi
  ["<leader>ya"] = function()
    require("core.yazi").yazi("edit")
  end,

  ["<leader>yh"] = function()
    require("core.yazi").yazi("vsplit", "left")
  end,

  ["<leader>yj"] = function()
    require("core.yazi").yazi("split", "down")
  end,

  ["<leader>yk"] = function()
    require("core.yazi").yazi("split", "up")
  end,

  ["<leader>yl"] = function()
    require("core.yazi").yazi("vsplit", "right")
  end,
})

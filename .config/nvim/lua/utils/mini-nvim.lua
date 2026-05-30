-- mini.nvim 工具集
return {
  "echasnovski/mini.nvim",
  version = false,
  config = function()
    require("mini.comment").setup() -- 注释
    require("mini.pairs").setup() -- 括号自动配对
    require("mini.surround").setup({ -- 环绕操作
      mappings = {
        add = "sa",
        delete = "sd",
        find = "sf",
        find_left = "sF",
        highlight = "sh",
        replace = "sr",
        update_n_lines = "sn",
      },
    })
  end,
}

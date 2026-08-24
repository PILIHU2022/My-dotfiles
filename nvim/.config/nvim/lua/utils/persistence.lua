return {
  -- 会话管理
  {
    "folke/persistence.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>qs", "<cmd>lua require('persistence').load()<cr>", desc = "Load session" },
      { "<leader>ql", "<cmd>lua require('persistence').load({ last = true})<cr>", desc = "Load last session" },
      { "<leader>qd", "<cmd>lua require('persistence').stop()<cr>", desc = "Stop session" },
    },
    config = function()
      require("persistence").setup()
    end,
  },
}

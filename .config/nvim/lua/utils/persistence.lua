return {
  -- 会话管理
  {
    "folke/persistence.nvim",
    config = function()
      require("persistence").setup()
      vim.keymap.set(
        "n",
        "<leader>qs",
        "<cmd>lua require('persistence').load()<cr>",
        { desc = "Load session" }
      )
      vim.keymap.set(
        "n",
        "<leader>ql",
        "<cmd>lua require('persistence').load({ last = true})<cr>",
        { desc = "Load last session" }
      )
      vim.keymap.set(
        "n",
        "<leader>qd",
        "<cmd>lua require('persistence').stop()<cr>",
        { desc = "Stop session" }
      )
    end,
  },
}

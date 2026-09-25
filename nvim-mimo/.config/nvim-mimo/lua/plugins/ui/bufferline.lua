-- 标签栏
return {
  "akinsho/bufferline.nvim",
  event = "VeryLazy",
  config = true,
  keys = {
    { "<A-[>", "<cmd>BufferLineCyclePrev<cr>", mode = { "n", "t" }, desc = "Buffer Previous" },
    { "<A-]>", "<cmd>BufferLineCycleNext<cr>", mode = { "n", "t" }, desc = "Buffer Next" },
    { "<A-i>", "<cmd>BufferLinePick<cr>", mode = { "n", "t" }, desc = "Buffer Pick" },
    { "<A-q>", "<cmd>bp|sp|bn|bd!<cr>", mode = { "n", "t" }, desc = "Buffer Close" },
  },
}

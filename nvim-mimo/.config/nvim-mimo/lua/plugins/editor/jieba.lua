-- jieba.nvim 中文分词支持
return {
  "neo451/jieba.nvim",
  ft = { "markdown" },
  build = "xmake",
  dependencies = {
    "neo451/jieba-lua",
  },
}

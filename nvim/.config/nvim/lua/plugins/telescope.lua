-- telescope.nvim 模糊查找
return {
  "nvim-telescope/telescope.nvim",
  -- 按下快捷键或执行 :Telescope 命令时才加载
  cmd = "Telescope",
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find Files" },
    { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Live Grep" },
    { "<leader><space>", "<cmd>Telescope buffers<CR>", desc = "Find Buffers" },
    { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Help Tags" },
    { "<leader>?", "<cmd>Telescope oldfiles<CR>", desc = "Recent Files" },
    {
      "<leader>/",
      function()
        require("telescope.builtin").current_buffer_fuzzy_find(
          require("telescope.themes").get_dropdown({ winblend = 10, previewer = false })
        )
      end,
      desc = "Search in Current Buffer",
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  config = function()
    require("telescope").setup({
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
      },
    })
    require("telescope").load_extension("fzf")
  end,
}

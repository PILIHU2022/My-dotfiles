-- Neogit Git 图形界面（替代 lazygit.nvim）
return {
  "NeogitOrg/neogit",
  dependencies = {
    -- Neogit 运行必需 plenary.nvim
    "nvim-lua/plenary.nvim",

    -- diffview.nvim：作为 Neogit 的依赖安装，充当「三方合并冲突视图」的后端。
    -- 为什么直接列在 dependencies 里：Neogit 判断集成是否可用是用
    -- config.check_integration("diffview")，内部 pcall(require, "diffview")，
    -- 只有 diffview 在 runtimepath 中时才会走冲突视图那条代码路径；
    -- 放在依赖里可以让它跟随 Neogit 一起按需加载，避免忘装导致功能静默降级。
    --
    -- 装上以后行为变化（buffers/status/actions.lua 的 n_stage）：
    --   · 光标停在冲突文件行按 `s`：不再提示 “Conflicts must be resolved
    --     before staging”，而是打开 diffview 的 3 栏冲突视图；
    --     关闭视图时若冲突标记已清干净，Neogit 会自动 git add 该文件。
    --   · 光标停在 “Unstaged changes” 区块标题上按 `s`：为所有冲突文件一次
    --     性打开冲突视图；关闭时若全部解决，自动暂存并自动弹出 Merge popup，
    --     按 `m` → `m` 即完成 merge 提交。
    --
    -- 版本要求：需要带 sections.conflicting 与 --selected-file 的 diffview
    -- （upstream main 已包含；发行版/旧镜像里的老版本可能没有）。
    --
    -- 冲突视图中的按键（diffview 默认值，本仓库 <leader> 即空格）：
    --   ]x / [x              下一个 / 上一个冲突标记
    --   <leader>co/ct/cb/ca  当前冲突取 OURS / THEIRS / BASE / 全部版本
    --   <leader>cO/cT/cB/cA  整个文件取 OURS / THEIRS / BASE / 全部版本
    --   dx / dX              删除当前 / 整个文件的冲突区块
    --   2do / 3do            从 OURS / THEIRS 窗口取一个 hunk（3 栏布局）
    --   g<C-x>               在 diff3 / diff4 / diff1 等布局间循环
    --   g?                   打开当前布局的帮助面板
    --   另外 :h copy-diffs 的通用写法也可用（:diffget / :diffput、do、dp）
    {
      "sindrets/diffview.nvim",
      -- 跟随 Neogit 一起按需加载（按 <leader>lg 时才载入），无需额外按键
      -- 默认布局已够用；想改合并视图布局就取消下面注释
      -- opts = {
      --   view = {
      --     merge_tool = {
      --       -- 默认 diff3_horizontal；可选 diff3_vertical / diff3_mixed /
      --       -- diff4_mixed / diff1（单窗口）等，视图里 g<C-x> 也能临时切换
      --       layout = "diff3_mixed",
      --       disable_diagnostics = true,
      --     },
      --   },
      -- },
    },
  },
  -- 执行命令或按下快捷键时才加载
  cmd = "Neogit",
  keys = {
    { "<leader>lg", "<cmd>Neogit<cr>", desc = "Neogit" },
  },
  opts = {
    -- 显式启用 diffview 集成（为 nil / "auto" 时 Neogit 也会自动探测，
    -- 写死是为了集成没装上时能在 Neogit 日志里看出是配置问题还是缺插件）
    integrations = { diffview = true },
    -- 显式指定 diff/冲突视图用 diffview；留 nil 时 Neogit 先探测 diffview
    -- 再退回 codediff（本配置没装 codediff）
    diff_viewer = "diffview",
  },
}

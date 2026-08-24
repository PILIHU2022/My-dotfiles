return {
  "lervag/vimtex",
  -- 打开 TeX 文件时懒加载；init 中的全局变量在启动时即生效
  ft = "tex",
  -- tag = "v2.15", -- uncomment to pin to a specific release
  init = function()
    -- VimTeX configuration goes here, e.g.
    -- 编译时 quickfix（日志）窗口永不自动弹出；日志仍记录，可用 :copen / :VimtexLog 查看
    vim.g.vimtex_quickfix_mode = 0
    -- Wayland 下 xdotool 无法获取窗口 ID，改用 zathura_simple（不依赖 xdotool）
    vim.g.vimtex_view_method = "zathura_simple"
    -- 关闭 synctex 正向搜索：打开 PDF 时 zathura 不再高亮光标所在行。
    -- 副作用：同时禁用正向跳转（vim → PDF）与反向搜索（PDF 点击跳回 vim）。
    vim.g.vimtex_view_zathura_use_synctex = 0
    -- 默认前缀是 <localleader>l（\l），中文输入法下反斜杠常被 IME 吞掉；
    -- 且 <leader>l 已被 Lazy、<leader>lg 已被 LazyGit 占用，
    -- 因此改用 <leader>v：默认键变为 <Space>v*（如 <Space>vl 编译、<Space>vv 查看）
    vim.g.vimtex_mappings_prefix = "<leader>v"
    -- 禁用 vimtex 默认的 <Space>vl（仅编译），
    -- 由 config 中自定义的"保存并编译（自动预览）"接管该键
    vim.g.vimtex_mappings_disable = { n = { "l" } }
    -- 默认编译引擎设为 pdflatex（Computer Modern 已安装，任何环境可用）。
    -- 注意：xelatex 内核默认字体是 Latin Modern（本机缺失且按要求不装字体），
    -- 在字体就绪前 xelatex 无法编译任何文档；需要时可用文件内
    -- "% !TEX program = xelatex" / "% !TEX TS-program = ..." 指令按文件切换。
    -- 回退引擎（_）为 -pdf，其余映射保留。
    vim.g.vimtex_compiler_latexmk_engines = {
      ["_"] = "-pdf",
      pdfdvi = "-pdfdvi",
      pdfps = "-pdfps",
      pdflatex = "-pdf",
      luatex = "-lualatex",
      lualatex = "-lualatex",
      xelatex = "-xelatex",
      ["context (pdftex)"] = "-pdf -pdflatex=texexec",
      ["context (luatex)"] = "-pdf -pdflatex=context",
      ["context (xetex)"] = "-pdf -pdflatex='texexec --xtx'",
    }
    vim.g.vimtex_compiler_latexmk = {
      -- 恢复 vimtex 默认选项（引擎由上面 engines 决定，不放 -xelatex）
      options = { "-verbose", "-file-line-error", "-synctex=1", "-interaction=nonstopmode" },
      continuous = true, -- 后台持续编译，保存后自动重编译
      -- 编译缓存（aux 等）目录：<主文件目录>/Compile/<文件名>/
      aux_dir = function(file_info)
        return file_info.root .. "/Compile/" .. file_info.target_name
      end,
      -- PDF 输出目录：<主文件目录>/PDF/<文件名>/
      out_dir = function(file_info)
        return file_info.root .. "/PDF/" .. file_info.target_name
      end,
    }
  end,
  config = function()
    -- 保存并编译：保存当前文件后触发后台编译，
    -- 编译成功自动打开/更新 zathura 预览（vimtex_view_automatic 默认为 1）。
    -- 注：vimtex 默认的 <Space>vl（仅编译）已在 init 中用 mappings_disable 禁用。
    vim.keymap.set("n", "<leader>vl", "<cmd>w<CR><cmd>VimtexCompile<CR>", { desc = "Vimtex: 保存并编译（自动预览）" })

    -- 退出 nvim 时：停止所有 vimtex 编译并关闭本项目的 PDF 预览窗口
    vim.api.nvim_create_autocmd("VimLeavePre", {
      callback = function()
        -- 1) 显式停止所有 vimtex 编译（vimtex 自带 VimLeave 清理，此处兜底）
        pcall(vim.fn["vimtex#compiler#stop_all"])
        -- 2) 清理可能残留的 latexmk（vimtex 启动的命令含 vimtex_compiler_callback 标记）
        vim.fn.system("pkill -f 'latexmk.*vimtex_compiler_callback' 2>/dev/null")
        -- 3) 关闭本项目的 zathura 预览窗口（按 PDF 实际路径的文件名匹配）
        for _, st in ipairs(vim.fn["vimtex#state#list_all"]()) do
          local c = st.compiler
          local pdf
          if c and c.out_dir and c.out_dir ~= "" and c.file_info and c.file_info.jobname then
            -- PDF 输出目录：<root>/PDF/<name>/<name>.pdf
            pdf = c.out_dir .. "/" .. c.file_info.jobname .. ".pdf"
          else
            -- 兜底：主文件同目录
            pdf = (st.tex or ""):gsub("%.tex$", ".pdf")
          end
          if vim.fn.filereadable(pdf) == 1 then
            local name = vim.fn.fnamemodify(pdf, ":t"):gsub("([%^%$%.%[%]%*%+%?%(%)%|%{%}%\\])", "\\%1")
            vim.fn.system("pkill -f 'zathura.*" .. name .. "' 2>/dev/null")
          end
        end
      end,
    })
  end,
}

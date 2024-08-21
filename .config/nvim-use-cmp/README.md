# 本仓库包含有Neovim（nvim）、LazyVim（lnvim）、MiniNvim（大概是）（mnvim）

# Neovim的配置
# 功能:
- 快捷键
- 插件
- 可选项
# 如何使用
将本仓库的nvim目录下的所有文件克隆到~/.config/nvim中，重新打开nvim即可（显示出clone或者黑屏一段时间属于正常现象，在安装插件）
# 快捷键：
## 标签页
- Alt+⬅️，切换到上一个标签页
- Alt+➡️，切换到下一个标签页
- Alt+q，关闭当前标签页
## 分屏:
- Ctrl+⬆️，切换到上面的分屏
- Ctrl+⬇️，切换到下面的分屏
- Ctrl+⬅️，切换到左边的分屏
- Ctrl+➡️，切换到右边的分屏
## 分屏大小:
- Ctrl+h，当前的分屏宽度+2
- Ctrl+j，当前的分屏宽度-2
- Ctrl+l，当前的分屏高度-2
- Ctrl+k，当前的分屏高度+2
## Language Server Protocol补全功能(自带Python和C的)
- Tab，补全当前所选的代码
- Ctrl+e，退出补全(一次性)
- Shift+Tab，从下到上选择代码
- Ctrl+k/j/d/f，功能未知
~~剩下的自己探索吧，文件位置在lua/config/keymaps.lua~~
# 可选项(该顺序对应文件中的行号):
- 设置了autowrite
- 设置了相对行号(7~8)
- 设置了sessionoptions
- 设置了当前行突出显示
- 在第80列处设置了提示线，不需要的可以删除
- 设置了Tab键为4个空格的缩进
- 设置缩进宽度为4个空格
- 设置了将制表符展开为空格
- 设置了开始新行时从当前行复制缩进
文件位置在lua/config/options.lua

# 使用Markdown-Preview插件(待完成)

使用本仓库的配置会自动安装Markdown-Preview插件
文件为`lua/plugins/markdown-preview.lua`

若使用，请输入`:MarkdownPreview`

若关闭，请输入`:MarkdownPreviewStop`

若输入`:MarkdownPreview`后无法使用预览，如下

# Todo
- 录制视频或GIF来说明一些功能

# 更新于2023-10-29 17:50

\<leader\> = space

| 按键               | 功能                       | 模式 |
|:------------------:|:--------------------------:|:----:|
| \<leader\> + ra    | 打开ranger                 | n    |
| \<leader\> + rl    | 打开ranger                 | n    |
| \<leader\> + rw    | 打开ranger                 | n    |
| j                  | 长按以快速向下             | n    |
| k                  | 长按以快速向上             | n    |
| \<leader\> + e     | 当前文件夹的目录树         | n,v  |
| \<F5\>             | 运行代码（仅特定格式）     | n    |
| \<leader\> + ff    | 查找文件                   | n    |
| \<leader\> + fg    | 查找内容（文件夹中）       | n    |
| \<leader\> + space | 切换标签页？               | n    |
| \<leader\> + fh    | 查找帮助                   | n    |
| \<leader\> + ?     | 查找最近打开的文件         | n    |
| \<leader\> + /     | 文件内快速查找跳转         | n    |
| \<leader\> + pd    | 查看定义                   | n    |
| \<leader\> + pr    | 查看参考                   | n    |
| Ctrl + k           | 悬停显示文档               | n    |
| \<leader\> + wa    | 工作区添加文件             | n    |
| \<leader\> + wr    | 工作区重命名文件夹         | n    |
| \<leader\> + wl    | 工作区列出文件夹           | n    |
| \<leader\> + rn    | 重命名变量                 | n    |
| \<leader\> + ca    | 显示代码动作               | n    |
| \<leader\> + ot    | 打开outline                | n    |
| d[                 | 上一个代码诊断             | n    |
| d]                 | 下一个代码诊断             | n    |
| \<leader\> + f     | 格式化代码                 | n    |
| \<leader\> + qs    | 打开近期所打开的一个文件   | n    |
| \<leader\> + ql    | 恢复之前打开的文件         | n    |
| \<leader\> + qd    | 恢复之前打开的文件（所有） | n    |
| gc/gcc             | 快速注释（多行/单行）      | v/n  |
| \<leader\> + lg    | 打开lazygit                | n    |

| LSP   | 模式 | 功能                 |
|:-----:|:----:|:--------------------:|
| Tab   | i    | 当显示选项时向下选择 |
| S-Tab | i    | 当显示选项时向上选择 |
| Enter | i    | 确认选择             |

| Markdown | 模式 | 功能       |
|:--------:|:----:|:----------:|
| 《       | i    | 输入`《》` |
| 》       | i    | 输入`>`    |
| “        | i    | 输入`“”`   |
| ”        | i    | 输入`“”`   |
| ,b       | i    | 加粗       |
| ,s       | i    | 删除线     |
| ,h       | i    | 高亮       |
| ,i       | i    | 斜体       |
| ,d       | i    | 代码       |
| ,c       | i    | 代码块     |
| ,m       | i    | 列表       |
| ,p       | i    | 图片链接   |
| ,a       | i    | 超链接     |
| ,l       | i    | 未知       |
| ,t       | i    | 目录       |
| ,1       | i    | 一级标题   |
| ,2       | i    | 二级标题   |
| ,3       | i    | 三级标题   |
| ,4       | i    | 四级标题   |
| ,5       | i    | 五级标题   |

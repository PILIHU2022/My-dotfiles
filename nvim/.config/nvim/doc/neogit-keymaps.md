# Neogit 快捷键总表

> 本文件由插件源码提取生成，键位均为**默认值**（本仓库 `lua/plugins/neogit.lua` 的 `opts` 未覆盖 `mappings`）。
>
> - Neogit：`v3.0.0-221-g5adc81b2`（`~/.local/share/nvim/lazy/neogit`）
> - diffview.nvim：`main@4516612`（Neogit 的冲突视图后端，作为依赖安装）
> - 符号：`<leader>` = **空格**（`vim.g.mapleader = " "`）；`<cr>` = 回车；`<s-cr>` = Shift+回车；`<c-x>` = Ctrl+x；`<m-x>` = Alt+x；`<tab>` = Tab
> - 大小写敏感：Neogit 用大写键表示「不应用开关，直接执行动作」

## 0. 进入 Neogit

| 按键 | 模式 | 说明 |
| --- | --- | --- |
| `<leader>lg`（空格 l g） | n | 打开 Neogit 状态窗口（本仓库唯一的 Neogit 全局映射） |
| `:Neogit` | - | 同上（命令方式） |
| `:NeogitLog` | - | 当前文件（或指定路径）的 log，可带范围 |
| `:NeogitCommit [SHA]` | - | 查看指定提交，缺省 HEAD |
| `:NeogitResetState` | - | 重置所有 popup 记住的开关状态 |

## 1. 状态缓冲区（Status Buffer）主键位

> Popup 的键在这里同样生效，见第 2 节；`s` / `x` 在冲突文件上行为不同，见第 4 节。

| 按键 | 动作 | 说明 |
| --- | --- | --- |
| `j` / `k` | MoveDown / MoveUp | 上下移动 |
| `<tab>`、`za` | Toggle | 折叠 / 展开当前区块 |
| `zo` / `zc` | OpenFold / CloseFold | 展开 / 折叠 |
| `zO` / `zC` | Depth4 / Depth1 | 展开到 4 层 / 折叠到 1 层 |
| `1` `2` `3` `4` | Depth1–Depth4 | 按层级展开 |
| `o` | OpenTree | 打开折叠树 |
| `s` | Stage | 暂存当前 hunk / 文件；冲突文件上打开 diffview 冲突视图 |
| `S` | StageUnstaged | 暂存所有未暂存变更 |
| `<c-s>` | StageAll | 暂存全部 |
| `u` | Unstage | 取消暂存当前项 |
| `U` | UnstageStaged | 取消全部暂存 |
| `-` | Reverse | 把该变更反向应用到工作区 |
| `x` | Discard | 丢弃变更；冲突文件上询问 ours / theirs / conflict / abort |
| `K` | Untrack | 取消跟踪 |
| `R` | Rename | 重命名文件 |
| `y` | ShowRefs | 打开 refs 视图 |
| `Y` | YankSelected | 复制光标所在项 |
| `$` | CommandHistory | Git 命令历史缓冲区 |
| `Q` | Command | 手动输入并执行 git 命令 |
| `I` | InitRepo | 在目录中初始化仓库 |
| `<cr>` | GoToFile | 打开文件 |
| `<s-cr>` | PeekFile | 浮窗预览文件 |
| `<c-v>` / `<c-x>` / `<c-t>` | VSplitOpen / SplitOpen / TabOpen | 垂直分割 / 水平分割 / 新标签打开 |
| `{` / `}` | 上一个 / 下一个 hunk 头 | 跳转 hunk |
| `[c` / `]c` | OpenOrScrollUp / OpenOrScrollDown | 上一个 / 下一个变更 |
| `<c-k>` / `<c-j>` | PeekUp / PeekDown | 向上 / 向下预览 |
| `<c-n>` / `<c-p>` | NextSection / PreviousSection | 下一个 / 上一个区块 |
| `<c-r>` | RefreshBuffer | 刷新缓冲区 |
| `gp` | GoToParentRepo | 跳到父仓库 |
| `q` | Close | 关闭 Neogit |

## 2. 打开 Popup 的按键

| 按键 | Popup | 可用位置 |
| --- | --- | --- |
| `?` | Help 帮助 | 状态窗口 / 日志视图 |
| `c` | Commit 提交 | 状态窗口 / 日志视图 |
| `A` | CherryPick 摘取 | 状态窗口 / 日志视图 |
| `b` | Branch 分支 | 状态窗口 / 日志视图 |
| `B` | Bisect 二分 | 状态窗口 / 日志视图 |
| `d` | Diff 差异 | 状态窗口 / 日志视图 |
| `f` | Fetch 获取 | 状态窗口 / 日志视图 |
| `i` | Ignore 忽略 | 状态窗口 |
| `l` | Log 日志 | 状态窗口 |
| `L` | Margin 侧栏 | 状态窗口 |
| `m` | Merge 合并 | 状态窗口 / 日志视图 |
| `M` | Remote 远端 | 状态窗口 / 日志视图 |
| `p` | Pull 拉取 | 状态窗口 / 日志视图 |
| `P` | Push 推送 | 状态窗口 / 日志视图 |
| `r` | Rebase 变基 | 状态窗口 / 日志视图 |
| `X` | Reset 重置 | 状态窗口 / 日志视图 |
| `v` | Revert 回退 | 状态窗口 / 日志视图 |
| `Z` | Stash 暂存 | 状态窗口 |
| `t` | Tag 标签 | 状态窗口 / 日志视图 |
| `w` | Worktree 工作树 | 状态窗口 |
| `Y` | Yank 复制提交信息 | Commit 视图（`<cr>` 进入某提交后） |

Popup 内通用键：`q` / `<esc>` 关闭；`<tab>` 切换光标所在行的开关或选项。

## 3. 各 Popup 内部键位

> 部分键会因状态不同而出现两次（例如 merge 进行中 vs 未进行、二分进行中、cherry-pick / revert 进行中），表中按源码行序分行列出。


### Help 帮助 popup（状态窗口 / 日志视图 按 `?` 打开）

> 键位随上下文动态生成：分为 Commands / Applying changes / Essential commands 三组，列出光标处可用的命令与对应按键。

### Commit 提交 popup（状态窗口 / 日志视图 按 `c` 打开）

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `a` | 开关 | Stage all modified and deleted files |
| `e` | 开关 | Allow empty commit |
| `v` | 开关 | Show diff of changes to be committed |
| `h` | 开关 | Disable hooks |
| `R` | 开关 | Claim authorship and reset author date |
| `A` | 选项 | Override the author |
| `s` | 开关 | Add Signed-off-by line |
| `S` | 选项 | Sign using gpg |
| `C` | 选项 | Reuse commit message |

**Create**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `c` | 动作 | Commit |

**Edit HEAD**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `e` | 动作 | Extend |
| `a` | 动作 | Amend |
| `w` | 动作 | Reword |

**Edit**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `f` | 动作 | Fixup |
| `s` | 动作 | Squash |
| `A` | 动作 | Alter |
| `n` | 动作 | Augment |
| `W` | 动作 | Revise |

**Edit and rebase**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `F` | 动作 | Instant Fixup |
| `S` | 动作 | Instant Squash |

**Spread across commits**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `x` | 动作 | Absorb |

### CherryPick 摘取 popup（状态窗口 / 日志视图 按 `A` 打开）

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `m` | 选项 | Replay merge relative to parent |
| `s` | 选项 | Strategy |
| `F` | 开关 | Attempt fast-forward |
| `x` | 开关 | Reference cherry in commit message |
| `e` | 开关 | Edit commit messages |
| `s` | 开关 | Add Signed-off-by lines |
| `S` | 选项 | Sign using gpg |

**Apply here**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `A` | 动作 | Pick |
| `a` | 动作 | Apply |
| `h` | 动作 | Harvest |
| `m` | 动作 | Squash |

**Apply elsewhere**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `d` | 动作 | Donate |
| `n` | 动作 | Spinout |
| `s` | 动作 | Spinoff |

**Cherry Pick**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `A` | 动作 | continue |
| `s` | 动作 | skip |
| `a` | 动作 | abort |

### Branch 分支 popup（状态窗口 / 日志视图 按 `b` 打开）


**Configure branch**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `d` | 配置项 | branch.<当前分支>.description |
| `u` | 配置项 | branch.<当前分支>.merge |
| `m` | 配置项 | branch.<当前分支>.remote |
| `R` | 配置项 | branch.<当前分支>.rebase |
| `p` | 配置项 | branch.<当前分支>.pushRemote |
| `r` | 开关 | 检出已有分支时递归子模块 |

**Checkout**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `b` | 动作 | branch/revision |
| `l` | 动作 | local branch |
| `r` | 动作 | recent branch |
| `c` | 动作 | new branch |
| `s` | 动作 | new spin-off |
| `w` | 动作 | new worktree |

**Create**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `n` | 动作 | new branch |
| `S` | 动作 | new spin-out |
| `W` | 动作 | new worktree |

**Do**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `C` | 动作 | Configure... |
| `m` | 动作 | rename |
| `X` | 动作 | reset |
| `D` | 动作 | delete |
| `o` | 动作 | pull request |

### Bisect 二分 popup（状态窗口 / 日志视图 按 `B` 打开）

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `r` | 开关 | Don't checkout commits |
| `p` | 开关 | Follow only first parent of a merge |

**Actions**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `B` | 动作 | Start |
| `S` | 动作 | Scripted |
| `b` | 动作 | Bad |
| `g` | 动作 | Good |
| `s` | 动作 | Skip |
| `r` | 动作 | Reset |
| `S` | 动作 | Run script |

### Diff 差异 popup（状态窗口 / 日志视图 按 `d` 打开）


**Diff**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `d` | 动作 | this |
| `h` | 动作 | this..HEAD |
| `r` | 动作 | range |
| `p` | 动作 | paths |
| `u` | 动作 | unstaged |
| `s` | 动作 | staged |
| `w` | 动作 | worktree |

**Show**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `c` | 动作 | Commit |
| `t` | 动作 | Stash |

### Fetch 获取 popup（状态窗口 / 日志视图 按 `f` 打开）

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `p` | 开关 | Prune deleted branches |
| `t` | 开关 | Fetch all tags |
| `F` | 开关 | force |

**Fetch from**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `p` | 动作 | pushRemote 远端 |
| `u` | 动作 | upstream 远端 |
| `e` | 动作 | elsewhere |
| `a` | 动作 | all remotes |

**Fetch**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `o` | 动作 | another branch |
| `r` | 动作 | explicit refspec |
| `m` | 动作 | submodules |

**Configure**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `C` | 动作 | Set variables... |

### Ignore 忽略 popup（状态窗口 按 `i` 打开）


**Gitignore**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `t` | 动作 | shared at top-level (.gitignore) |
| `s` | 动作 | shared in sub-directory (path/to/.gitignore) |
| `p` | 动作 | privately for this repository (.git/info/exclude) |
| `g` | 动作 | 所有仓库私有（全局 excludes 文件） |

### Log 日志 popup（状态窗口 按 `l` 打开）


**Commit Limiting**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `n` | 选项 | Limit number of commits |
| `A` | 选项 | Limit to author |
| `F` | 选项 | Search messages |
| `G` | 开关 | Search changes |
| `S` | 开关 | Search occurrences |
| `L` | 开关 | Trace line evolution |
| `s` | 选项 | Limit to commits since |
| `u` | 选项 | Limit to commits until |
| `m` | 开关 | Omit merges |
| `p` | 开关 | First parent |
| `i` | 开关 | Invert search messages |

**History Simplification**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `D` | 开关 | Simplify by decoration |
| `-` | 选项 | Limit to files |
| `f` | 开关 | Follow renames when showing single-file log |

**Commit Ordering**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `r` | 开关 | Reverse order |
| `o` | 开关 | Order commits by |
| `R` | 开关 | List reflog |

**Formatting**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `g` | 开关 | Show graph |
| `c` | 开关 | Show graph in color |
| `d` | 开关 | Show refnames |
| `S` | 开关 | Show signatures |

**Log**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `l` | 动作 | current |
| `h` | 动作 | HEAD |
| `u` | 动作 | related |
| `o` | 动作 | other |
| `L` | 动作 | local branches |
| `b` | 动作 | all branches |
| `a` | 动作 | all references |
| `B` | 动作 | matching branches |
| `T` | 动作 | matching tags |
| `m` | 动作 | merged |

**Reflog**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `r` | 动作 | current |
| `H` | 动作 | HEAD |
| `O` | 动作 | other |

**Other**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `s` | 动作 | shortlog |

### Margin 侧栏 popup（状态窗口 按 `L` 打开）

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `o` | 开关 | Order commits by |
| `d` | 开关 | Show refnames |

**Refresh**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `g` | 动作 | buffer |

**Margin**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `L` | 动作 | toggle visibility |
| `l` | 动作 | cycle style |
| `d` | 动作 | toggle details |
| `x` | 动作 | toggle shortstat |

### Merge 合并 popup（状态窗口 / 日志视图 按 `m` 打开）


**Actions**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `m` | 动作 | Commit merge |
| `a` | 动作 | Abort merge |
| `f` | 开关 | Fast-forward only |
| `n` | 开关 | No fast-forward |
| `s` | 选项 | Strategy |
| `X` | 选项 | Strategy Option |
| `b` | 开关 | Ignore changes in amount of whitespace |
| `w` | 开关 | Ignore whitespace when comparing lines |
| `A` | 选项 | Diff algorithm |
| `S` | 选项 | Sign using gpg |
| `m` | 动作 | Merge |
| `e` | 动作 | Merge and edit message |
| `n` | 动作 | Merge but don't commit |
| `a` | 动作 | Absorb |
| `p` | 动作 | Preview merge |
| `s` | 动作 | Squash merge |
| `i` | 动作 | Dissolve |

### Pull 拉取 popup（状态窗口 / 日志视图 按 `p` 打开）

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `r` | 配置项 | branch.<当前分支>.rebase |
| `f` | 开关 | Fast-forward only |
| `r` | 开关 | Rebase local commits |
| `a` | 开关 | Autostash |
| `t` | 开关 | Fetch tags |
| `F` | 开关 | Force |

**Pull from**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `p` | 动作 | pushRemote |
| `u` | 动作 | upstream |
| `e` | 动作 | elsewhere |

**Configure**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `C` | 动作 | Set variables... |

### Push 推送 popup（状态窗口 / 日志视图 按 `P` 打开）

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `f` | 开关 | Force with lease |
| `F` | 开关 | Force |
| `h` | 开关 | Disable hooks |
| `d` | 开关 | Dry run |
| `u` | 开关 | Set the upstream before pushing |
| `T` | 开关 | Include all tags |
| `t` | 开关 | Include related annotated tags |

**Push <当前分支> to**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `p` | 动作 | pushRemote 或 pushDefault |
| `u` | 动作 | upstream |
| `e` | 动作 | elsewhere |

**Push**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `o` | 动作 | another branch |
| `r` | 动作 | explicit refspec |
| `m` | 动作 | matching branches |
| `T` | 动作 | a tag |
| `t` | 动作 | all tags |

**Configure**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `C` | 动作 | Set variables... |

### Rebase 变基 popup（状态窗口 / 日志视图 按 `r` 打开）


**Actions**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `r` | 动作 | Continue |
| `s` | 动作 | Skip |
| `e` | 动作 | Edit |
| `a` | 动作 | Abort |
| `k` | 开关 | Keep empty commits |
| `r` | 选项 | Rebase merges |
| `u` | 开关 | Update branches |
| `d` | 开关 | Use author date as committer date |
| `t` | 开关 | Use current time as author date |
| `a` | 开关 | Autosquash |
| `A` | 开关 | Autostash |
| `i` | 开关 | Interactive |
| `h` | 开关 | Disable hooks |
| `S` | 选项 | Sign using gpg |

**Rebase <分支> onto**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `p` | 动作 | pushRemote |
| `u` | 动作 | upstream |
| `e` | 动作 | elsewhere |
| `b` | 动作 | base 分支 |

**Rebase**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `i` | 动作 | interactively |
| `s` | 动作 | a subset |
| `m` | 动作 | to modify a commit |
| `w` | 动作 | to reword a commit |
| `d` | 动作 | to remove a commit |
| `f` | 动作 | to autosquash |

### Remote 远端 popup（状态窗口 / 日志视图 按 `M` 打开）

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `f` | 开关 | Fetch after add |
| `u` | 配置项 | remote.origin.url |
| `U` | 配置项 | remote.origin.fetch |
| `s` | 配置项 | remote.origin.pushurl |
| `S` | 配置项 | remote.origin.push |
| `O` | 配置项 | remote.origin.tagOpt |

**Actions**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `a` | 动作 | Add |
| `r` | 动作 | Rename |
| `x` | 动作 | Remove |
| `C` | 动作 | Configure... |
| `p` | 动作 | Prune stale branches |
| `P` | 动作 | Prune stale refspecs |
| `b` | 动作 | Update default branch |
| `z` | 动作 | Unshallow remote |

### Reset 重置 popup（状态窗口 / 日志视图 按 `X` 打开）


**Reset**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `f` | 动作 | file |
| `b` | 动作 | branch |

**Reset this**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `m` | 动作 | mixed (HEAD and index) |
| `s` | 动作 | soft (HEAD only) |
| `h` | 动作 | hard (HEAD, index and files) |
| `k` | 动作 | keep (HEAD and index, keeping uncommitted) |
| `i` | 动作 | index (only) |
| `w` | 动作 | worktree (only) |

### Revert 回退 popup（状态窗口 / 日志视图 按 `v` 打开）

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `m` | 选项 | Replay merge relative to parent |
| `e` | 开关 | Edit commit messages |
| `E` | 开关 | Don't edit commit messages |
| `s` | 开关 | Add Signed-off-by lines |
| `s` | 选项 | Strategy |
| `S` | 选项 | Sign using gpg |

**Revert**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `v` | 动作 | Commit(s) |
| `V` | 动作 | Changes |
| `h` | 动作 | Hunk |
| `v` | 动作 | continue |
| `s` | 动作 | skip |
| `a` | 动作 | abort |

### Stash 暂存 popup（状态窗口 按 `Z` 打开）

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `u` | 开关 | Also save untracked files |
| `a` | 开关 | Also save untracked and ignored files |

**Stash**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `z` | 动作 | both |
| `i` | 动作 | index |
| `w` | 动作 | worktree |
| `x` | 动作 | keeping index |
| `P` | 动作 | push |

**Snapshot**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `Z` | 动作 | both |
| `I` | 动作 | index |
| `W` | 动作 | worktree |
| `r` | 动作 | to wip ref |

**Use**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `p` | 动作 | pop |
| `a` | 动作 | apply |
| `d` | 动作 | drop |

**Inspect**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `l` | 动作 | List |
| `v` | 动作 | Show |

**Transform**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `b` | 动作 | Branch |
| `B` | 动作 | Branch here |
| `m` | 动作 | Rename |
| `f` | 动作 | Format patch |

### Tag 标签 popup（状态窗口 / 日志视图 按 `t` 打开）


**Arguments**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `f` | 开关 | Force |
| `a` | 开关 | Annotate |
| `s` | 开关 | Sign |
| `u` | 选项 | Sign as |

**Create**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `t` | 动作 | tag |
| `r` | 动作 | release |

**Do**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `x` | 动作 | delete |
| `p` | 动作 | prune |

### Worktree 工作树 popup（状态窗口 按 `w` 打开）


**Worktree**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `w` | 动作 | Checkout |
| `W` | 动作 | Create |

**Do**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `g` | 动作 | Goto |
| `m` | 动作 | Move |
| `D` | 动作 | Delete |

### Yank 复制提交信息 popup（Commit 视图 按 `Y` 打开）


**Yank Commit info**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `Y` | 动作 | Hash |
| `s` | 动作 | Subject |
| `m` | 动作 | Message (subject and body) |
| `b` | 动作 | Message body |
| `u` | 动作 | URL |
| `d` | 动作 | Diff |
| `a` | 动作 | Author |
| `t` | 动作 | Tags |

### BranchConfig 分支配置 popup（Branch popup 内 按 `C` 打开）


**Configure branch**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `d` | 配置项 | branch.<当前分支>.description |
| `u` | 配置项 | branch.<当前分支>.merge |
| `m` | 配置项 | branch.<当前分支>.remote |
| `r` | 配置项 | branch.<当前分支>.rebase |
| `p` | 配置项 | branch.<当前分支>.pushRemote |

**Configure repository defaults**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `R` | 配置项 | pull.rebase |
| `P` | 配置项 | remote.pushDefault |
| `b` | 配置项 | neogit.baseBranch |
| `A` | 配置项 | neogit.askSetPushDefault |

**Configure branch creation**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `as` | 配置项 | branch.autoSetupMerge |
| `ar` | 配置项 | branch.autoSetupRebase |

### RemoteConfig 远端配置 popup（Remote popup 内 按 `C` 打开）


**Configure remote**

| 按键 | 类型 | 说明 |
| --- | --- | --- |
| `u` | 配置项 | remote.<远端>.url |
| `U` | 配置项 | remote.<远端>.fetch |
| `s` | 配置项 | remote.<远端>.pushurl |
| `S` | 配置项 | remote.<远端>.push |
| `O` | 配置项 | remote.<远端>.tagOpt |


### 其它视图与缓冲区

**Commit 视图**（在 log 视图或状态窗口里对提交按 `<cr>` 进入）

| 按键 | 说明 |
| --- | --- |
| `a` | OpenFileInWorktree：跳到工作区中对应位置 |
| `o` | 在浏览器 / 远端服务打开该提交 |
| `<cr>` | 打开该 hunk 对应的文件内容（临时只读标签页） |
| `{` / `}` | 上一个 / 下一个 hunk 或 diff 头 |
| `-` | 把该变更反向应用到工作区 |
| `Y` | 打开 Yank popup |
| `za` / `<tab>` | 折叠当前区块 |
| `q` / `<esc>` | 关闭 |
| popup 键 | `A` `b` `B` `c` `d` `f` `i` `l` `m` `p` `P` `r` `t` `v` `w` `X` `Z` |

**Commit 编辑器**（写提交信息时，含 `git merge --continue` 弹出的界面）

| 按键 | 说明 |
| --- | --- |
| `<c-c><c-c>` | Submit 提交（插入模式下同样可用） |
| `<c-c><c-k>` | Abort 放弃 |
| `<m-p>` / `<m-n>` | 上一条 / 下一条历史信息 |
| `<m-r>` | 重置提交信息 |
| `q` | 关闭 |
| `ZZ` / `ZQ` | 保存提交 / 放弃（同 Vim） |

**Rebase todo 编辑器**

| 按键 | 说明 |
| --- | --- |
| `p` / `r` / `e` / `s` / `f` / `d` / `x` / `b` | Pick / Reword / Edit / Squash / Fixup / Drop / Execute / Break |
| `<cr>` | 打开该提交 |
| `gk` / `gj` | 当前行上移 / 下移 |
| `[c` / `]c` | 向上 / 向下滚动 |
| `<c-c><c-c>` / `<c-c><c-k>` | 提交 / 放弃 |

**Finder / 模糊查找（选分支、选远端等）**

| 按键 | 说明 |
| --- | --- |
| `<cr>` | 选择 |
| `<c-c>` / `<esc>` | 关闭 |
| `<c-n>` / `<c-p>`、`<down>` / `<up>` | 下一个 / 上一个 |
| `<tab>` | 插入补全项 |
| `<c-y>` | 复制选中项 |
| `<space>` / `<s-space>` | 多选切换（正向 / 反向） |

**Refs 视图**（状态窗口 `y`）、**Log / Reflog 视图**（`:NeogitLog`、`l` popup 的结果）

| 按键 | 说明 |
| --- | --- |
| `x`（仅 Refs 视图） | 删除分支（DeleteBranch） |
| `Y` | Log 视图里复制光标处提交的 hash；Commit 视图里打开 Yank popup |
| `<c-r>` | 刷新 |
| popup 键 | 与状态窗口同一套（`c` `b` `A` `B` `d` `f` `m` `M` `p` `P` `r` `v` `X` `t` `Z`） |
| visual 模式 | 先 `V` 多选提交，再按上述 popup 键可批量操作 |

**Diff 缓冲区 / Process 缓冲区 / 命令历史**

| 缓冲区 | 按键 | 说明 |
| --- | --- | --- |
| Diff | `{` / `}` | 上一个 / 下一个 hunk |
| Diff | `<tab>` / `q` | 折叠切换 / 关闭 |
| Process | `<c-c>`、`q` / `<esc>` | 中断进程 / 关闭 |
| 命令历史 | `<c-k>` / `<c-j>` | 上一条 / 下一条命令 |
| 命令历史 | `<tab>`、`q` / `<esc>` | 切换详情 / 关闭 |

## 4. 合并冲突快速处理（配合 diffview）

前置：`lua/plugins/neogit.lua` 已把 `sindrets/diffview.nvim` 列为 Neogit 依赖，并设置
`integrations = { diffview = true }`、`diff_viewer = "diffview"`。

| 步骤 | 按键 | 说明 |
| --- | --- | --- |
| 1 | `<leader>lg` | 打开 Neogit，冲突文件出现在 **Unstaged changes**（模式 `UU` / `AA` / `DU` …） |
| 2 | `m` → `m` | Merge popup 选分支合并；冲突时提示 `Merging failed...` |
| 3a | `s`（在冲突文件上） | 打开 diffview 三栏冲突视图（LEFT=OURS，RIGHT=THEIRS，中间=工作区文件） |
| 3b | `s`（在 Unstaged 区块标题上） | 为**所有**冲突文件打开冲突视图；关闭时若全部解决会自动暂存并自动弹出 Merge popup |
| 3c | `x`（在冲突文件上） | 整文件取一边：`&ours` / `&theirs` / `&conflict` / `&abort`（默认回车 = 取消） |
| 4 | 见下表 | 在冲突视图里逐块解决 |
| 5 | 关闭冲突视图 | 冲突标记清干净后 Neogit 自动 `git add` 该文件 |
| 6 | `m` → `m` | Commit merge（`git merge --continue`，弹出 Neogit 提交编辑器，`<c-c><c-c>` 提交） |
| 中止 | `m` → `a` | Abort merge（`git merge --abort`） |
| 中止 | `X` → `h` | Reset hard |

**diffview 冲突视图内的按键（默认值）**

| 按键 | 说明 |
| --- | --- |
| `]x` / `[x` | 下一个 / 上一个冲突标记（文件面板里同样可用） |
| `<leader>co` / `<leader>ct` | 当前冲突取 OURS / THEIRS |
| `<leader>cb` / `<leader>ca` | 当前冲突取 BASE / 全部版本（等于只删标记） |
| `<leader>cO` / `<leader>cT` / `<leader>cB` / `<leader>cA` | 整个文件取 OURS / THEIRS / BASE / 全部 |
| `dx` / `dX` | 删除当前 / 整个文件的冲突区块（取 none） |
| `2do` / `3do` | 从 OURS / THEIRS 窗口取一个 hunk（3 栏布局；4 栏布局另有 `1do` 取 BASE） |
| `g<C-x>` | 在三栏 / 四栏 / 单窗口等布局间循环 |
| `g?` | 打开当前布局的帮助面板 |
| `<tab>` / `<s-tab>` | 下一个 / 上一个文件 |
| `-` / `s` / `S` / `U`（文件面板） | 暂存 / 取消暂存当前项、全部暂存 / 全部取消 |
| `:diffget` / `:diffput`、`do` / `dp` | Vim 原生 `:h copy-diffs` 写法同样可用 |

> 判定「冲突已解决」的依据是文件里不再有冲突标记（Neogit 用 `git diff --check <file>` 判断），
> 只删内容不删 `<<<<<<<` / `=======` / `>>>>>>>` 整行是不行的。

**变基 / 拣选冲突的对应键**

| 进行中的操作 | 继续 | 跳过 | 中止 |
| --- | --- | --- | --- |
| Merge | `m` → `m` | — | `m` → `a` |
| Rebase | `r` → `r`（Continue） | `r` → `s`（Skip） | `r` → `a`（Abort） |
| Cherry-pick | `A` → `A`（continue） | `A` → `s`（skip） | `A` → `a`（abort） |
| Revert | `v` → `v`（continue） | `v` → `s`（skip） | `v` → `a`（abort） |

## 5. 自定义

`lua/plugins/neogit.lua` 的 `opts.mappings` 可覆盖任意一节；把某个键设为 `false` 即禁用：

```lua
opts = {
  integrations = { diffview = true },
  diff_viewer = "diffview",
  mappings = {
    status = { ["<leader>p"] = "PushPopup", ["s"] = false },
    popup = { ["P"] = "PushPopup" },
  },
}
```

---

> 键位来源：`~/.local/share/nvim/lazy/neogit/lua/neogit/config.lua`（status / popup / commit_view / finder 等）
> 与 `lua/neogit/popups/*/init.lua`（各 popup 内部键位）；diffview 部分来源为
> `~/.local/share/nvim/lazy/diffview.nvim/lua/diffview/config.lua`。


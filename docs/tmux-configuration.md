# tmux 配置与键位指南

本包提供一份可直接使用的 tmux 配置：本地 Arch 会话使用 `C-a` 前缀，SSH 会话使用标准 `C-b` 前缀，因此从本地 tmux 进入 VPS tmux 时不会互相抢快捷键。配置还包含 Vim 风格窗格操作、性能监测和常用键位提示，并用内置颜色实现 Catppuccin Mocha 主题。配置不依赖 TPM（tmux 插件管理器）、Catppuccin 插件或网络下载。

## 文件与部署

配置文件位于 `tmux/.config/tmux/tmux.conf`，Stow 后部署为 `~/.config/tmux/tmux.conf`。

```bash
# 在仓库根目录预览并安装
stow -d . -t ~ -n -v tmux
stow -d . -t ~ tmux

# 启动、重连与卸载
tmux new -s main
tmux attach -t main
stow -d . -t ~ -D tmux
```

tmux 会优先读取 `~/.tmux.conf`。若该文件已存在，先备份或移走；也可以显式加载本配置：

```bash
tmux -f ~/.config/tmux/tmux.conf
```

配置在 tmux 3.5a 上校验。修改后按状态栏显示的前缀加 `r` 重新加载
（本地为 `C-a r`，VPS 为 `C-b r`），无需重启会话。

## 终端自动启动与真彩色

`zsh/.zshrc` 会让每个新开的交互式终端都新建一个独立的 tmux 会话，默认名称
为 `term-YYYYmmdd-HHMMSS-PID`，避免同时打开多个终端时重名。已在 tmux 内运行时
不会重复启动。临时跳过自动启动：

```bash
TMUX_AUTOSTART=0 zsh
```

如果需要固定会话名（同名会话已存在时附加而不是新建）：

```bash
TMUX_SESSION=work zsh
```

## 本地与 VPS 的双层 tmux

配置在 tmux server 启动时检查 `SSH_CONNECTION`，自动选择前缀：

| 启动环境 | 前缀 | 典型场景 |
| --- | --- | --- |
| 本地终端 | `C-a` | Arch Linux 上的外层 tmux |
| SSH 登录 | `C-b` | VPS 上的 tmux；其他客户端直连 VPS 时也是 `C-b` |

因此本地 tmux 与 VPS tmux 叠加时：

- `C-a ...` 由本地外层 tmux 处理，例如 `C-a c`、`C-a d`。
- `C-b ...` 会穿过本地 tmux，由 VPS 内层 tmux 处理，例如 `C-b c`、`C-b d`。
- `C-a C-a` 向当前窗格发送原始 `C-a`；在 VPS tmux 中按 `C-b C-b`
  则向远端程序发送原始 `C-b`。
- 状态栏会自动显示当前层的前缀，不需要手动记两套提示。

VPS 上的 tmux 仍是共享的唯一持久会话，其他设备直接 `ssh` 后运行
`tmux attach -t main` 即可，使用标准 `C-b`。如果 VPS 没有部署本配置，
只需确保远端 tmux 的前缀是 `C-b`；本地配置仍会使用 `C-a` 避让。

tmux server 在启动时复制环境，后续重载配置读取的是该 server 的环境。
如果从旧配置切换后前缀没有变化，先退出所有会话再重新启动 server。

配色方面：

- `kitty/.config/kitty/kitty.conf` 已加载 Catppuccin Mocha 主题。
- kitty 及其内部 tmux 会话会设置 `COLORTERM=truecolor`。
- tmux 使用 `tmux-256color`，并为 `xterm*` 启用 `RGB` 终端能力。

若颜色不正确，先确认终端本身支持真彩色，再检查 `echo "$TERM $COLORTERM"`。

## 键位表示法

`C-a` 表示按住 `Ctrl` 再按 `a`，松开后按下一个键。例如本地 `C-a c` 是
`Ctrl+a`，松开，再按 `c`。`C-a C-a` 会把一个原始 `C-a` 发送给窗格内的程序。
SSH 到 VPS 后，下表键位中的前缀应替换为 `C-b`。

状态栏左侧会按当前层显示 `C-a ? help`（VPS 为 `C-b ? help`）等提示；
其中前缀加 `?` 可查看当前 tmux 的全部键位。

按主题整理的完整键位表见 [tmux-keybindings.md](tmux-keybindings.md)。

| 操作 | 键位 | 说明 |
| --- | --- | --- |
| 帮助 | `C-a ?` | 查看当前全部键位 |
| 命令模式 | `C-a :` | 输入 tmux 命令 |
| 重载配置 | `C-a r` | 重新读取本配置 |
| 分离会话 | `C-a d` | 保留会话并返回 shell |

## 窗口

| 键位 | 意义 |
| --- | --- |
| `C-a c` | 在当前目录新建窗口 |
| `C-a n` / `C-a p` | 下一个 / 上一个窗口 |
| `C-a 1` … `C-a 9` | 按编号切换窗口；编号从 1 开始 |
| `C-a Tab` | 返回上一次使用的窗口 |
| `C-a w` | 选择窗口或会话 |
| `C-a ,` | 重命名当前窗口 |
| `C-a &` | 关闭当前窗口（需确认） |

## 窗格

| 键位 | 意义 |
| --- | --- |
| `C-a %` 或 `C-a \|` | 左右分屏 |
| `C-a "` 或 `C-a -` | 上下分屏 |
| `C-a h/j/k/l` | 向左 / 下 / 上 / 右切换窗格 |
| `C-a H/J/K/L` | 向左 / 下 / 上 / 右调整大小，可连续按键 |
| `C-a z` | 最大化 / 还原当前窗格 |
| `C-a x` | 关闭当前窗格（需确认） |
| `C-a o` | 循环切换窗格 |
| `C-a {` / `C-a }` | 与相邻窗格交换位置 |
| `C-a Space` | 切换窗格布局 |

新建窗口和分屏都继承当前目录；`C-a c` 与两种分屏快捷方式均可直接复用当前工作路径。

## 会话与复制

| 键位 | 意义 |
| --- | --- |
| `C-a C` | 在当前目录新建会话 |
| `C-a s` | 打开会话树，列出并切换会话 |
| `C-a S` | 打开会话树，重命名光标所在会话 |
| `C-a )` / `C-a (` | 下一个 / 上一个会话 |
| `C-a $` | 重命名当前会话 |
| `C-a [` | 进入复制模式 |
| `v` / `y` | 复制模式中开始选择 / 复制并退出 |
| `/` / `n` / `N` | 搜索 / 下一个 / 上一个匹配项 |
| `Esc` | 退出复制模式 |
| `C-a ]` | 粘贴最近的缓冲区 |

使用 `C-a S` 时，先在会话树中用 `j` / `k` 或方向键选择会话，按 `Enter`
打开重命名提示，输入新名称后再次按 `Enter`；按 `C-c` 取消。

鼠标已启用。拖拽选择后松开即复制，滚轮可进入历史记录；复制依赖终端支持 OSC 52（kitty 支持）。若系统剪贴板未更新，检查终端设置或使用 `C-a ]` 粘贴 tmux 缓冲区。

## Catppuccin Mocha 主题

主题直接使用 Catppuccin Mocha 色值，而不是加载外部插件：

- 背景使用 Mantle `#181825`，文字使用 Text `#cdd6f4`。
- 会话标签使用 Mauve `#cba6f7`，当前窗口使用 Blue `#89b4fa`。
- 性能信息使用 Green `#a6e3a1`，时间使用 Subtext0 `#a6adc8`。
- 非活动窗口、消息框和选中项使用 Surface 色系。
- 活动窗格边框为蓝色，搜索命中为黄色 `#f9e2af`。

若十六进制颜色显示异常，确认终端和 `$TERM` 支持真彩色；配置已为 `xterm-kitty`
启用 `Tc`，并通过 `terminal-features` 为 `xterm*` 声明 `RGB` 能力。

## 性能监测

状态栏右侧每 5 秒显示 CPU 利用率、内存占用和 CPU 温度，例如：

```text
CPU 8% | MEM 34% | TEMP 45°C
```

数据由 `tmux/.config/tmux/scripts/system-status.sh` 采集，Stow 后位于
`~/.config/tmux/scripts/system-status.sh`：

- CPU 利用率通过两次 `/proc/stat` 采样差值计算；正常情况下复用上一次采样，
  首次运行或缓存过期时短暂采样 0.2 秒。
- 内存占用按 `/proc/meminfo` 的 `MemTotal` 与 `MemAvailable` 计算，
  不把缓存全部算作已用内存。
- CPU 温度优先读取 `coretemp`、`k10temp`、`cpu_thermal`、`soc_thermal`
  等 hwmon/thermal sysfs 节点，无需安装 `lm_sensors`；读取不到时显示 `--`。

CPU 采样缓存优先写入 `${XDG_RUNTIME_DIR}/tmux-status-${UID}/cpu`；
运行时目录不可写时回退到 `${TMPDIR:-/tmp}/tmux-status-${UID}/cpu`。缓存不会进入仓库。
手动验证：

```bash
bash -n ~/.config/tmux/scripts/system-status.sh
~/.config/tmux/scripts/system-status.sh
```

如需降低开销，可把 `status-interval` 调大；修改后按 `C-a r` 重载配置。

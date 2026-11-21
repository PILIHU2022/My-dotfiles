# Waybar 配置（Catppuccin Mocha）

Waybar 配置、样式与辅助脚本，配色统一为 Catppuccin Mocha。

## 外观

一条 34px 高的顶部胶囊栏，底色 `#1e1e2e`，每个模块是一枚圆角 12px 的深色胶囊（`@surface0` 描边），靠 `6px` 间距隔开：

- 左侧：工作区圆点按 `@lavender` 高亮，播放器显示曲名与播放/暂停状态，窗口标题右侧跟应用图标。
- 中间：CPU / 内存 / 磁盘百分比，键盘布局，以及带 `Hi!` 前缀的用户名与运行时长。
- 右侧：铃铛（桃色，后面跟未读数量）→ 免打扰开关（绿色/黄色）→ 系统托盘 → 网速（青色的上传/下载箭头）→ 音量（蓝紫色喇叭）→ 时钟（`@lavender`）。

通知历史按钮与免打扰开关就是最右边那组的前两枚，故意放在托盘左边。

> 截图存在 `docs/waybar-preview.png` 与 `docs/waybar-preview-notification.png`（`.gitignore` 里忽略了 `*.png`，所以不入库）。这两张旧图渲染于免打扰开关加入之前，不显示新按钮；开关两态的实测图在 `docs/waybar-dnd-on.png`（绿色 bell-ring）与 `docs/waybar-dnd-off.png`（黄色 bell-off）。

## 依赖

| 组件 | 用途 | 必需 |
| --- | --- | --- |
| `waybar` | 本体（`v0.15+`） | 是 |
| `mako` | 通知守护进程，`makoctl history` 提供历史数据 | 是 |
| `fuzzel` | 通知历史的列表菜单 | 是 |
| `jq`、`python3` | 脚本里解析/格式化数据 | 是 |
| `playerctl` | 左侧播放状态模块 | 是 |
| `mpv` | 新通知提示音；免打扰时脚本会跳过它 | 是 |
| `zenity` | 用文本窗口看通知正文（不会把看过的通知再写进历史） | 否 |

```bash
sudo pacman -S waybar mako fuzzel jq python playerctl mpv zenity
```

## 字体

图标全部来自 Nerd Font 私用区字形，需要装有 Nerd Font 补丁的等宽字体：

```bash
sudo pacman -S ttf-nerd-fonts-symbols-mono
# 或任何带 Nerd Font 补丁的字体，如 CascadiaCode NF、JetBrainsMono Nerd Font
```

`style.css` 里的字体栈是 `"Cascadia Mono NF", "Cascadia Code NF", "Source Han Sans CN", "Noto Sans CJK SC", sans-serif`，前两个负责图标与等宽西文，后两个兜底中文。

## 模块布局

- 左：`hyprland/workspaces`、`custom/playerctl`、`custom/playerlabel`、`hyprland/window`
- 中：`cpu`、`memory`、`disk`、`keyboard-state`、`user`
- 右：`custom/notification`、`custom/notification-dnd`、`tray`、`network`、`pulseaudio`、`clock`

`custom/notification` 是「历史通知按钮」，`custom/notification-dnd` 是紧挨它的「免打扰开关」，两枚都故意排在 `tray` 左边。

## 通知历史按钮

脚本：`scripts/notification-history.sh`，子命令 `status | menu | restore | dismiss`。

| 操作 | 行为 |
| --- | --- |
| 左键 | `fuzzel` 列出历史（`应用 ｜ 摘要 · 正文前 50 字`），选中后用 `zenity` 文本窗口看完整正文 |
| 中键 | 恢复最近一条通知（`makoctl restore`） |
| 右键 | 关闭当前屏幕上所有通知（`makoctl dismiss --all`），不会清空历史 |

查看正文优先走 `zenity --text-info`，因为 `notify-send` 会把「你刚看的那条」重新写进 mako 历史，越看越多；没装 zenity 时才退回 `notify-send`。

历史为空时不会弹通知（免得「暂无历史通知」自己进历史），装了 zenity 就弹个提示窗。

## 免打扰开关

脚本：`scripts/notification-dnd.sh`，子命令 `status | toggle`。按钮状态直接读 mako 的 `do-not-disturb` mode，不维护额外状态文件；重启 waybar 不会丢状态，重启 mako 会回到「通知开启」。

| 状态 | 图标 | 行为 |
| --- | --- | --- |
| 通知开启 | `󰂞`（bell-ring，绿色） | 正常弹窗并播放提示音 |
| 免打扰 | `󰂛`（bell-off，黄色） | 通知不弹窗、不响铃，仍可在 mako 历史中查看 |
| mako 未运行 | `󰂛`（红色） | tooltip 提示，无法切换 |

左键点击切换；切换后脚本发送 `SIGRTMIN+9`，waybar 会立刻重跑 `status` 换图标。

免打扰由 mako 侧两处共同保证：

1. `mako/.config/mako/config` 里的 `[mode=do-not-disturb]` 设置 `invisible=1`，激活后通知不显示；
2. `on-notify` 改为调用 `mako/.config/mako/scripts/notify-sound.sh`，播放前再查一次 `makoctl mode`；处于免打扰时（或 makoctl 查询失败时）直接退出，绝不发声。

```ini
[mode=do-not-disturb]
invisible=1
```

也可以手动切换，便于排查：

```bash
makoctl mode -a do-not-disturb   # 开启免打扰
makoctl mode -r do-not-disturb   # 恢复通知
makoctl mode                     # 查看当前 mode
```

## 日历对齐

时钟 tooltip 里的 `{calendar}` 由 Waybar 生成，按「7 列 × 3 字符」的等宽网格排版（第一列 2 字符，其余每列 3 字符），星期行里的汉字按「宽字符 = 2 字符」计算。默认字体栈里汉字会回退到 Source Han Sans 这类比例字体：一个汉字实际只占约 1.8 个等宽字符宽，星期行整体比日期网格窄，越往右偏得越多。

`config.jsonc` 用 `calendar.format.days` 把整块日历包进 `Maple Mono CN`：

```jsonc
"calendar": {
    "format": {
        "days": "<span font_family='Maple Mono CN'>{}</span>"
    }
}
```

该字体中英文严格 2:1（汉字宽度正好是数字/空格的 2 倍），整块日历正好是 20 个等宽单元格，星期行与日期列严格对齐。依赖：

```bash
sudo pacman -S ttf-maplemono-cn   # AUR
```

> `format.days` 的 `{}` 是**整块日历文本（含换行）**，不是只包日期行；外面再套一层字体即可，不要拆行重排。

## 图标大小

Nerd Font 的图标每个字形的实际墨迹高度差别很大（同样的字号，箭头只有铃铛的 2/3 高），所以不能简单地把所有图标设成同一个字号。`config.jsonc` 里按**墨迹高度归一化**给每个字形单独标了缩放比例，让所有图标看起来和铃铛一样大：

```jsonc
"format": "<span size='135%'>󰍛</span> {}%"
```

- 比例范围 110%–160%，铃铛是 115%（基准）。
- 同一组会变的状态图标保持同一比例：音量三种喇叭统一 120%，网络上下箭头统一 115%，避免数值跳动时图标忽大忽小。
- 时钟的三种格式（`{:%H:%M}`、精确到秒的备选、`format-alt` 日期）统一 120%，和音量用同一个比例，并且 `#clock` 保持全局 16px 字号。Pango 的行盒高度由这一行里最大的 span 决定：16px 下 120% 是 30px 行盒、基线 24px，垂直居中后基线与音量（同样是 30px / 24px）落在同一条线上。原来用的 135% + `#clock { font-size: 17px }` 会把行盒撑到 37px，居中后时间基线比音量低约 2px，就是「时间与音量不在一条水平线上」的来源；以后调时钟字号或比例时，先用截图确认行盒高度没变。
- 比例是用字体文件里每个字形的 `yMax - yMin` 算出来的（`fontTools` + `BoundsPen`），改字体后需要重新算。
- Pango 的 `size` 必须带 `%`：`size='115'` 是 115pt，字形会直接消失。

`scripts/notification-history.sh` 里的铃铛与空铃铛也按同样方式包了 `<span>`（`ICON_BELL` / `ICON_EMPTY`）；`scripts/notification-dnd.sh` 的 bell-ring 用 141%、bell-off 用 132%，同样是按墨迹高度与 115% 的铃铛对齐。

### 窗口标题图标

`hyprland/window` 的 `rewrite` 规则在标题前插了一个 Nerd Font 图标。这些图标的墨迹中心固定在基线上方约 `0.347em`（`fontTools` 量 `uniF0239` / `uniF268` / `uniF36F` 都一样），而中文的墨迹中心更低，所以标题是中文时图标会明显「飘」在字的上方：

```jsonc
"(.*) — Mozilla Firefox": "<span size='130%' rise='-2048'>󰈹</span> $1",
"(.*) - Google Chrome":   "<span size='135%' rise='-2048'></span> $1",
"nvim (.*)":              "<span size='110%' rise='-1024'></span> $1"
```

- `rise` 是 Pango 单位（1024 = 1px）；负值把字形往下压。实测 130% + `rise='-2048'` 时，图标墨迹在 14–25 行、中文墨迹在 12–27 行，两者中心同为 19.5px；不加 `rise` 时图标中心 18.5、中文 20.5，正是截图里的错位。
- 图标与标题之间只留**一个**空格（`</span> $1`）。两个空格在 16px 下会空出近 20px，看着像断开的两个模块。
- 没有 `rise` 时（旧配置），中文标题的图标中心比文字中心高 2px，就是截图里那种错位。

> 内联 markup 只对**重新加载后的 config** 生效：改 `config.jsonc` 后执行 `killall -SIGUSR2 waybar`（或重启服务），Waybar 会重新读取配置；只改 `style.css` 时 `reload_style_on_change` 会自动重载。之前出现过「铃铛变大了、其它图标没变」，就是脚本重启后立刻生效、而 config 还跑在旧进程里的缘故；发一次 SIGUSR2 即可。

## Tooltip 方块

GTK 的 tooltip 是独立的 `GtkTooltipWindow`，CSS 节点名是 `tooltip`，结构为 `tooltip.background > box > (image + label)`。GTK 主题会先给窗口层画一块不透明、圆角 6px 的底，和 `style.css` 里的 12px 圆角叠加时，气泡下方会露出一条直角方块。

`style.css` 的处理是把窗口层（含 `csd` 阴影和 `decoration`）全部清成透明，只让内部 `box` 承担底色、圆角和描边：

```css
tooltip > box {
    background-color: @base;
    border: 2px solid @surface1;
    border-radius: 12px;
}
```

## 配色

`style.css` 顶部用 `@define-color` 定义了整套 Catppuccin Mocha：

| 变量 | 色值 | 用途 |
| --- | --- | --- |
| `@base` | `#1e1e2e` | bar 与胶囊底色 |
| `@mantle` / `@crust` | `#181825` / `#11111b` | 更深的层次 |
| `@surface0/1/2` | `#313244` / `#45475a` / `#585b70` | 描边、分隔 |
| `@text` / `@subtext0/1` | `#cdd6f4` / `#a6adc8` / `#bac2de` | 正文 |
| `@lavender` / `@blue` / `@sapphire` / `@sky` / `@teal` | `#b4befe` / `#89b4fa` / `#74c7ec` / `#89dceb` / `#94e2d5` | 工作区、网络、时钟 |
| `@green` / `@yellow` / `@peach` / `@red` | `#a6e3a1` / `#f9e2af` / `#fab387` / `#f38ba8` | 状态色 |

## 文件

| 文件 | 说明 |
| --- | --- |
| `config.jsonc` | 栏位、模块与按钮绑定 |
| `style.css` | 主样式（Mocha 调色板、胶囊、tooltip） |
| `style/style-dark.css` | 兼容入口，只有 `@import url("../style.css");` |
| `scripts/notification-history.sh` | 通知历史按钮的逻辑 |
| `scripts/notification-dnd.sh` | 免打扰/开启通知按钮的逻辑 |
| `An_example_waybar/` | 上游示例，未启用 |

免打扰后端在 mako stow 包里：`mako/.config/mako/config`（`[mode=do-not-disturb]` 与 `on-notify`）和 `mako/.config/mako/scripts/notify-sound.sh`（提示音兜底）。

## 生效

```bash
makoctl reload                    # 改了 mako/.config/mako/config 后
killall -SIGUSR2 waybar           # 改了 waybar 的 config.jsonc 或 style.css 后
# 或 systemctl --user restart waybar
```

> 本次实测 `killall -SIGUSR2 waybar` 能重新读取 `modules-right` 并显示新增的 `custom/notification-dnd`；如果 Waybar 由 systemd 管理，用 `systemctl --user restart waybar` 也可以。`custom/notification-dnd` 必须让 Waybar 重新加载配置后才会出现，单纯改 style.css 不够。

> 旧文档里 `cp -r ./waybar ~/.config/hypr/` 的路径已经过时：本仓库走 stow，`~/.config/waybar` 直接软链到 `waybar/.config/waybar`，改动不需要复制。
